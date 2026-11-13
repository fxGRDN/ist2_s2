"""TweetEval-emoji loading and zero-shot NLI concept pseudo-labelling."""

from pathlib import Path

import numpy as np
import torch
from datasets import load_dataset
from tqdm import tqdm
from transformers import AutoModelForSequenceClassification, AutoTokenizer

from .concepts import HYPOTHESES, NAMES

# ASCII names for the 20 TweetEval-emoji classes (matplotlib cannot render emoji).
CLASS_NAMES = [
    "red_heart", "heart_eyes", "tears_of_joy", "two_hearts", "fire",
    "smiling_blush", "sunglasses", "sparkles", "blue_heart", "kiss",
    "camera", "us_flag", "sun", "purple_heart", "wink",
    "hundred", "grin", "xmas_tree", "camera_flash", "wink_tongue",
]  # fmt: skip

SPLITS = {"train": "train", "val": "validation", "test": "test"}


def load_tweets(sizes: dict[str, int], seed: int) -> dict[str, dict]:
    """Return {split: {"text": [...], "label": LongTensor}} with random subsampling."""
    raw = load_dataset("cardiffnlp/tweet_eval", "emoji")
    assert raw["train"].features["label"].num_classes == len(CLASS_NAMES)
    rng = np.random.default_rng(seed)
    out = {}
    for split, hf_split in SPLITS.items():
        ds = raw[hf_split]
        n = min(sizes[split], len(ds)) if sizes[split] > 0 else len(ds)
        idx = np.sort(rng.choice(len(ds), size=n, replace=False))
        sub = ds.select(idx)
        out[split] = {"text": list(sub["text"]), "label": torch.tensor(sub["label"])}
    return out


@torch.no_grad()
def nli_concept_scores(
    texts: list[str],
    model_name: str,
    device: str,
    tweets_per_batch: int = 16,
    max_length: int = 128,
) -> torch.Tensor:
    """Score every (tweet, concept hypothesis) pair. Returns (N, K) P(entailment)."""
    tok = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForSequenceClassification.from_pretrained(model_name).to(device).eval()

    label2id = {k.lower(): v for k, v in model.config.label2id.items()}
    entail = next(v for k, v in label2id.items() if k.startswith("entail"))
    # Zero-shot convention: entailment vs. its opposite, ignoring "neutral".
    contra = [v for k, v in label2id.items() if k.startswith(("contra", "not_entail"))]
    other = contra[0] if contra else next(v for v in label2id.values() if v != entail)

    K = len(HYPOTHESES)
    scores = torch.empty(len(texts), K)
    order = np.argsort([len(t) for t in texts])  # similar lengths -> less padding
    for start in tqdm(range(0, len(order), tweets_per_batch), desc="NLI concepts"):
        idx = order[start : start + tweets_per_batch]
        premises = [texts[i] for i in idx for _ in range(K)]
        hyps = HYPOTHESES * len(idx)
        enc = tok(
            premises, hyps, padding=True, truncation="only_first",
            max_length=max_length, return_tensors="pt",
        ).to(device)  # fmt: skip
        with torch.autocast(device_type=device.split(":")[0], dtype=torch.bfloat16):
            logits = model(**enc).logits.float()
        p = logits[:, [other, entail]].softmax(-1)[:, 1]
        scores[torch.as_tensor(idx)] = p.view(len(idx), K).cpu()
    return scores


def prepare(path: Path, sizes: dict[str, int], seed: int, nli_model: str, device: str) -> dict:
    """Build (or load from cache) the dataset with concept pseudo-labels."""
    if path.exists():
        data = torch.load(path, weights_only=False)
        if data["concept_names"] == NAMES and data["meta"] == {
            "sizes": sizes, "seed": seed, "nli_model": nli_model
        }:  # fmt: skip
            return data
        print(f"{path} is stale (different concepts or settings), rebuilding")

    splits = load_tweets(sizes, seed)
    for split, d in splits.items():
        print(f"[{split}] scoring {len(d['text'])} tweets x {len(NAMES)} concepts")
        d["concepts"] = nli_concept_scores(d["text"], nli_model, device)
    data = {
        "splits": splits,
        "concept_names": NAMES,
        "class_names": CLASS_NAMES,
        "meta": {"sizes": sizes, "seed": seed, "nli_model": nli_model},
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    torch.save(data, path)
    return data
