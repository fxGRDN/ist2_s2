"""BERT concept bottleneck models (Koh et al., 2020) and a plain BERT baseline.

Modes
-----
baseline     BERT [CLS] -> classes (no bottleneck)
joint        BERT -> concepts -> classes, trained end-to-end with CE + lambda * BCE
sequential   BERT -> concepts trained with BCE; then classifier on *predicted* concepts
independent  same concept model; classifier trained on *true* (pseudo-label) concepts

In all CBMs the classifier is a single linear layer on concept probabilities
(sigmoid outputs), so its weight matrix W[class, concept] is directly readable.
"""

import json
from dataclasses import asdict, dataclass
from pathlib import Path

import numpy as np
import torch
import torch.nn.functional as F
from sklearn.metrics import f1_score, roc_auc_score
from torch import nn
from tqdm import tqdm
from transformers import AutoModel, AutoTokenizer, get_linear_schedule_with_warmup


@dataclass
class TrainConfig:
    bert: str = "bert-base-uncased"
    max_length: int = 64
    epochs: int = 3
    batch_size: int = 32
    lr: float = 2e-5  # encoder
    head_lr: float = 1e-3  # linear layers on top of BERT
    lam: float = 1.0  # weight of the concept loss in joint training
    concept_threshold: float = 0.5  # binarisation of NLI scores into concept labels
    l1: float = 1e-4  # sparsity penalty on the concept->class weights
    seed: int = 0
    device: str = "cuda"


class BertCBM(nn.Module):
    """BERT encoder with optional concept bottleneck.

    n_concepts=0  -> plain classifier on [CLS]
    n_classes=0   -> concept predictor only
    """

    def __init__(self, bert: str, n_concepts: int, n_classes: int):
        super().__init__()
        self.encoder = AutoModel.from_pretrained(bert)
        hidden = self.encoder.config.hidden_size
        self.dropout = nn.Dropout(0.1)
        self.to_concepts = nn.Linear(hidden, n_concepts) if n_concepts else None
        in_dim = n_concepts or hidden
        self.to_classes = nn.Linear(in_dim, n_classes) if n_classes else None

    def head_parameters(self):
        return [p for n, p in self.named_parameters() if not n.startswith("encoder.")]

    def forward(self, input_ids, attention_mask):
        cls = self.encoder(input_ids=input_ids, attention_mask=attention_mask).last_hidden_state[:, 0]
        h = self.dropout(cls)
        concept_logits = class_logits = None
        if self.to_concepts is not None:
            concept_logits = self.to_concepts(h)
            h = torch.sigmoid(concept_logits)  # the bottleneck: only concepts go on
        if self.to_classes is not None:
            class_logits = self.to_classes(h)
        return concept_logits, class_logits


def _batches(n: int, batch_size: int, shuffle: bool, generator=None):
    idx = torch.randperm(n, generator=generator) if shuffle else torch.arange(n)
    for i in range(0, n, batch_size):
        yield idx[i : i + batch_size]


def fine_tune(model: BertCBM, enc: dict, y, c, cfg: TrainConfig, desc: str) -> None:
    """Fine-tune on whatever outputs the model has: CE on classes + lam * BCE on concepts."""
    dev = cfg.device
    model.to(dev).train()
    opt = torch.optim.AdamW(
        [
            {"params": model.encoder.parameters(), "lr": cfg.lr, "weight_decay": 0.01},
            {"params": model.head_parameters(), "lr": cfg.head_lr, "weight_decay": 0.0},
        ]
    )
    n = len(y)
    steps = cfg.epochs * ((n + cfg.batch_size - 1) // cfg.batch_size)
    sched = get_linear_schedule_with_warmup(opt, int(0.06 * steps), steps)
    gen = torch.Generator().manual_seed(cfg.seed)
    both = model.to_concepts is not None and model.to_classes is not None
    bar = tqdm(total=steps, desc=desc)
    for _ in range(cfg.epochs):
        for idx in _batches(n, cfg.batch_size, shuffle=True, generator=gen):
            ids, mask = enc["input_ids"][idx].to(dev), enc["attention_mask"][idx].to(dev)
            with torch.autocast(device_type=dev.split(":")[0], dtype=torch.bfloat16):
                c_logits, y_logits = model(ids, mask)
            loss = 0.0
            if y_logits is not None:
                loss = loss + F.cross_entropy(y_logits.float(), y[idx].to(dev))
                if both and cfg.l1:
                    loss = loss + cfg.l1 * model.to_classes.weight.abs().sum()
            if c_logits is not None:
                bce = F.binary_cross_entropy_with_logits(c_logits.float(), c[idx].to(dev))
                loss = loss + (cfg.lam if both else 1.0) * bce
            opt.zero_grad(set_to_none=True)
            loss.backward()
            nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            opt.step()
            sched.step()
            bar.update()
            bar.set_postfix(loss=f"{loss.item():.3f}")
    bar.close()


@torch.no_grad()
def predict(model: BertCBM, enc: dict, cfg: TrainConfig):
    """Return (concept probabilities or None, class logits or None) on CPU."""
    dev = cfg.device
    model.to(dev).eval()
    cs, ys = [], []
    for idx in _batches(len(enc["input_ids"]), 256, shuffle=False):
        with torch.autocast(device_type=dev.split(":")[0], dtype=torch.bfloat16):
            c_logits, y_logits = model(enc["input_ids"][idx].to(dev), enc["attention_mask"][idx].to(dev))
        if c_logits is not None:
            cs.append(torch.sigmoid(c_logits.float()).cpu())
        if y_logits is not None:
            ys.append(y_logits.float().cpu())
    return (torch.cat(cs) if cs else None), (torch.cat(ys) if ys else None)


def fit_linear(c_train, y_train, n_classes: int, cfg: TrainConfig, steps: int = 2000):
    """Multinomial logistic regression concepts -> classes (full batch, L1 on weights)."""
    torch.manual_seed(cfg.seed)
    dev = cfg.device
    lin = nn.Linear(c_train.shape[1], n_classes).to(dev)
    x, y = c_train.to(dev), y_train.to(dev)
    opt = torch.optim.Adam(lin.parameters(), lr=0.05)
    sched = torch.optim.lr_scheduler.CosineAnnealingLR(opt, steps)
    for _ in range(steps):
        loss = F.cross_entropy(lin(x), y) + cfg.l1 * lin.weight.abs().sum()
        opt.zero_grad()
        loss.backward()
        opt.step()
        sched.step()
    return lin.weight.detach().cpu(), lin.bias.detach().cpu()


# ---------------------------------------------------------------- evaluation


def class_metrics(logits, y) -> dict:
    pred = logits.argmax(-1)
    return {
        "acc": (pred == y).float().mean().item(),
        "macro_f1": f1_score(y.numpy(), pred.numpy(), average="macro"),
    }


def concept_metrics(c_prob, c_true) -> dict:
    """Agreement of predicted concepts with the binarised NLI pseudo-labels."""
    pred, true = (c_prob > 0.5).numpy(), c_true.numpy().astype(bool)
    f1 = f1_score(true, pred, average=None, zero_division=0)
    seen = (true.any(0)) & (~true.all(0))
    auc = [roc_auc_score(true[:, k], c_prob[:, k].numpy()) for k in np.where(seen)[0]]
    return {
        "concept_acc": float((pred == true).mean()),
        "concept_macro_f1": float(f1[seen].mean()),
        "concept_mean_auc": float(np.mean(auc)),
        "per_concept_f1": f1.tolist(),
    }


def intervention_curve(c_prob, c_true, y, W, b, n_orders: int = 10, seed: int = 0) -> list[float]:
    """Test-time intervention (Koh et al.): replace the first n predicted concepts
    (in a random order) by their true values; return accuracy for n = 0..K."""
    K = c_prob.shape[1]
    rng = np.random.default_rng(seed)
    accs = np.zeros(K + 1)
    for _ in range(n_orders):
        order = rng.permutation(K)
        c = c_prob.clone()
        accs[0] += ((c @ W.T + b).argmax(-1) == y).float().mean().item()
        for n, k in enumerate(order, start=1):
            c[:, k] = c_true[:, k]
            accs[n] += ((c @ W.T + b).argmax(-1) == y).float().mean().item()
    return (accs / n_orders).tolist()


def evaluate_cbm(c_prob, c_true, y, W, b) -> dict:
    m = class_metrics(c_prob @ W.T + b, y)
    m.update(concept_metrics(c_prob, c_true))
    # Leakage probe: does accuracy survive when concepts are forced to be binary?
    hard = (c_prob > 0.5).float()
    m["acc_hard_concepts"] = class_metrics(hard @ W.T + b, y)["acc"]
    m["acc_true_concepts"] = class_metrics(c_true @ W.T + b, y)["acc"]
    m["intervention_curve"] = intervention_curve(c_prob, c_true, y, W, b)
    return m


# ---------------------------------------------------------------- driver


def run(data: dict, out_dir: Path, cfg: TrainConfig, modes: list[str]) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    torch.manual_seed(cfg.seed)
    splits = data["splits"]
    K, C = len(data["concept_names"]), len(data["class_names"])

    tok = AutoTokenizer.from_pretrained(cfg.bert)
    enc = {
        s: tok(d["text"], padding="max_length", truncation=True, max_length=cfg.max_length, return_tensors="pt")
        for s, d in splits.items()
    }
    y = {s: d["label"] for s, d in splits.items()}
    c = {s: (d["concepts"] > cfg.concept_threshold).float() for s, d in splits.items()}  # hard labels
    print(f"concept base rates (train): min {c['train'].mean(0).min():.3f}  "
          f"median {c['train'].mean(0).median():.3f}  max {c['train'].mean(0).max():.3f}")  # fmt: skip

    metrics_path = out_dir / "metrics.json"
    metrics = json.loads(metrics_path.read_text()) if metrics_path.exists() else {}

    def save(mode: str, m: dict, **artifacts):
        metrics[mode] = m
        metrics_path.write_text(json.dumps(metrics, indent=2))
        if artifacts:
            torch.save(
                {**artifacts, "concept_names": data["concept_names"], "class_names": data["class_names"],
                 "y_test": y["test"], "c_true_test": c["test"], "config": asdict(cfg)},
                out_dir / f"{mode}.pt",
            )  # fmt: skip
        short = {k: round(v, 4) for k, v in m.items() if isinstance(v, float)}
        print(f"== {mode}: {short}")

    if "baseline" in modes:
        model = BertCBM(cfg.bert, 0, C)
        fine_tune(model, enc["train"], y["train"], None, cfg, "baseline")
        m = {f"val_{k}": v for k, v in class_metrics(predict(model, enc["val"], cfg)[1], y["val"]).items()}
        m.update(class_metrics(predict(model, enc["test"], cfg)[1], y["test"]))
        save("baseline", m)
        del model

    if "joint" in modes:
        model = BertCBM(cfg.bert, K, C)
        fine_tune(model, enc["train"], y["train"], c["train"], cfg, "joint")
        W, b = model.to_classes.weight.detach().float().cpu(), model.to_classes.bias.detach().float().cpu()
        c_test = predict(model, enc["test"], cfg)[0]
        save("joint", evaluate_cbm(c_test, c["test"], y["test"], W, b), W=W, b=b, c_prob_test=c_test)
        del model

    if "sequential" in modes or "independent" in modes:
        model = BertCBM(cfg.bert, K, 0)
        fine_tune(model, enc["train"], y["train"], c["train"], cfg, "concept model")
        c_train, c_test = predict(model, enc["train"], cfg)[0], predict(model, enc["test"], cfg)[0]
        del model
        for mode, feats in (("sequential", c_train), ("independent", c["train"])):
            if mode in modes:
                W, b = fit_linear(feats, y["train"], C, cfg)
                save(mode, evaluate_cbm(c_test, c["test"], y["test"], W, b), W=W, b=b, c_prob_test=c_test)

    return metrics
