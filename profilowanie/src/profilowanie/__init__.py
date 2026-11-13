"""BERT concept bottleneck model on TweetEval-emoji with concept clustering."""

import argparse
from pathlib import Path

MODES = ["baseline", "joint", "sequential", "independent"]


def main() -> None:
    p = argparse.ArgumentParser(prog="profilowanie", description=__doc__)
    p.add_argument("step", choices=["prepare", "train", "cluster", "all"])
    p.add_argument("--data", type=Path, default=Path("data/emoji_concepts.pt"))
    p.add_argument("--out", type=Path, default=Path("outputs"))
    p.add_argument("--modes", nargs="+", choices=MODES, default=MODES)
    p.add_argument("--n-train", type=int, default=20000, help="0 = full split")
    p.add_argument("--n-val", type=int, default=2000)
    p.add_argument("--n-test", type=int, default=5000)
    p.add_argument("--nli-model", default="MoritzLaurer/deberta-v3-base-zeroshot-v2.0")
    p.add_argument("--bert", default="bert-base-uncased")
    p.add_argument("--epochs", type=int, default=3)
    p.add_argument("--batch-size", type=int, default=32)
    p.add_argument("--lam", type=float, default=1.0, help="concept loss weight (joint)")
    p.add_argument("--l1", type=float, default=1e-4, help="L1 on concept->class weights")
    p.add_argument("--seed", type=int, default=0)
    p.add_argument("--device", default="cuda")
    a = p.parse_args()

    if a.step in ("prepare", "train", "all"):
        from .data import prepare

        sizes = {"train": a.n_train, "val": a.n_val, "test": a.n_test}
        data = prepare(a.data, sizes, a.seed, a.nli_model, a.device)
    if a.step in ("train", "all"):
        from .train import TrainConfig, run

        cfg = TrainConfig(
            bert=a.bert, epochs=a.epochs, batch_size=a.batch_size,
            lam=a.lam, l1=a.l1, seed=a.seed, device=a.device,
        )  # fmt: skip
        run(data, a.out, cfg, a.modes)
    if a.step in ("cluster", "all"):
        from .cluster import run as run_cluster

        run_cluster(a.out, [m for m in a.modes if m != "baseline"])
