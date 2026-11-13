"""Cluster concepts of a trained CBM.

Option A ("by classification"): each concept is described by its column of the
concept->class weight matrix, scaled by the concept's activation std (so the
vector is the logit change caused by a 1-sd change of the concept) and centred
over classes (softmax ignores a per-concept constant). Cosine distance.

Option B ("by activation"): each concept is described by its activations over
the test set; distance = 1 - Pearson correlation.
"""

import json
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import torch
from scipy.cluster.hierarchy import dendrogram, fcluster, leaves_list, linkage
from scipy.spatial.distance import squareform
from sklearn.decomposition import PCA
from sklearn.metrics import adjusted_rand_score, silhouette_score


def effect_matrix(W: np.ndarray, c_prob: np.ndarray) -> np.ndarray:
    """(K, C) matrix: effect of +1 sd of each concept on each class logit, centred."""
    E = (W * c_prob.std(0, keepdims=True)).T
    return E - E.mean(1, keepdims=True)


def cosine_distance(X: np.ndarray) -> np.ndarray:
    Xn = X / np.clip(np.linalg.norm(X, axis=1, keepdims=True), 1e-12, None)
    D = 1.0 - Xn @ Xn.T
    return _clean(D)


def correlation_distance(c_prob: np.ndarray) -> np.ndarray:
    return _clean(1.0 - np.nan_to_num(np.corrcoef(c_prob.T)))


def _clean(D: np.ndarray) -> np.ndarray:
    D = np.clip((D + D.T) / 2, 0.0, 2.0)
    np.fill_diagonal(D, 0.0)
    return D


def cluster(D: np.ndarray, k_range=range(2, 13)):
    """Average-linkage agglomerative clustering; k chosen by silhouette."""
    Z = linkage(squareform(D, checks=False), method="average")
    sil = {}
    for k in k_range:
        labels = fcluster(Z, k, criterion="maxclust")
        if 1 < len(set(labels)) < len(D):
            sil[k] = float(silhouette_score(D, labels, metric="precomputed"))
    best_k = max(sil, key=sil.get)
    return Z, fcluster(Z, best_k, criterion="maxclust"), best_k, sil


def plot_dendrogram(Z, names, title, path):
    fig, ax = plt.subplots(figsize=(7, 0.22 * len(names) + 1.5))
    dendrogram(Z, labels=names, orientation="right", ax=ax, leaf_font_size=8)
    ax.set_title(title)
    ax.set_xlabel("distance")
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)


def plot_heatmap(E, Z, concept_names, class_names, title, path):
    rows = leaves_list(Z)
    cols = leaves_list(linkage(E.T, method="average", metric="correlation"))
    M = E[rows][:, cols]
    lim = np.abs(M).max()
    fig, ax = plt.subplots(figsize=(0.42 * len(class_names) + 3, 0.2 * len(concept_names) + 2.5))
    im = ax.imshow(M, cmap="RdBu_r", vmin=-lim, vmax=lim, aspect="auto")
    ax.set_xticks(range(len(cols)), [class_names[j] for j in cols], rotation=90, fontsize=8)
    ax.set_yticks(range(len(rows)), [concept_names[i] for i in rows], fontsize=8)
    ax.set_title(title)
    fig.colorbar(im, ax=ax, label="class logit change per +1 sd of concept")
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)


def plot_interventions(metrics: dict, path):
    fig, ax = plt.subplots(figsize=(6, 4))
    for mode, m in metrics.items():
        if "intervention_curve" in m:
            ax.plot(m["intervention_curve"], label=mode)
    if "baseline" in metrics:
        ax.axhline(metrics["baseline"]["acc"], color="gray", ls="--", label="baseline BERT")
    ax.set_xlabel("number of concepts replaced by their true value")
    ax.set_ylabel("test accuracy")
    ax.set_title("Test-time concept intervention")
    ax.legend()
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)


def pca_tweets(c_prob, y, concept_names, class_names, title, path, n_arrows: int = 12) -> dict:
    """PCA of tweets in (standardised) concept space, as a biplot.

    Left: tweets on PC1/PC2 coloured by class, with class centroids.
    Right: concept loadings (the n_arrows longest are labelled), plus scree inset.
    """
    X = (c_prob - c_prob.mean(0)) / np.clip(c_prob.std(0), 1e-6, None)
    pca = PCA(n_components=min(10, X.shape[1])).fit(X)
    S = pca.transform(X)[:, :2]
    var = pca.explained_variance_ratio_
    load = pca.components_[:2].T * np.sqrt(pca.explained_variance_[:2])  # (K, 2) correlations with PCs

    fig, (ax, ax2) = plt.subplots(1, 2, figsize=(15, 7))
    cmap = plt.get_cmap("tab20")
    ax.scatter(S[:, 0], S[:, 1], c=y, cmap=cmap, vmin=0, vmax=19, s=4, alpha=0.35, linewidths=0)
    for j, name in enumerate(class_names):
        cx, cy = S[y == j].mean(0)
        ax.scatter(cx, cy, color=cmap(j), s=70, edgecolors="black", linewidths=0.8, zorder=3)
        ax.annotate(name, (cx, cy), fontsize=7, xytext=(4, 4), textcoords="offset points", zorder=4)
    lo, hi = np.percentile(S, [0.5, 99.5], axis=0)
    ax.set_xlim(lo[0], hi[0])
    ax.set_ylim(lo[1], hi[1])
    ax.set_xlabel(f"PC1 ({var[0]:.1%} var.)")
    ax.set_ylabel(f"PC2 ({var[1]:.1%} var.)")
    ax.set_title(f"{title}: test tweets in concept space (dots = class centroids)")

    top = np.argsort(-np.linalg.norm(load, axis=1))[:n_arrows]
    for k in range(len(concept_names)):
        strong = k in top
        ax2.arrow(0, 0, *load[k], color="crimson" if strong else "lightgray", width=0.002,
                  head_width=0.02, length_includes_head=True, zorder=2 if strong else 1)  # fmt: skip
        if strong:
            ax2.annotate(concept_names[k], load[k], fontsize=8, xytext=(3, 3), textcoords="offset points")
    lim = np.abs(load).max() * 1.25
    ax2.set_xlim(-lim, lim)
    ax2.set_ylim(-lim, lim)
    ax2.axhline(0, color="gray", lw=0.5)
    ax2.axvline(0, color="gray", lw=0.5)
    ax2.set_xlabel("correlation with PC1")
    ax2.set_ylabel("correlation with PC2")
    ax2.set_title("concept loadings")
    inset = ax2.inset_axes([0.72, 0.05, 0.26, 0.2])
    inset.bar(range(1, len(var) + 1), var, color="gray")
    inset.set_title("explained var.", fontsize=7)
    inset.tick_params(labelsize=6)
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)

    def top_loadings(pc):
        order = np.argsort(pca.components_[pc])
        return {"negative": [concept_names[k] for k in order[:5]],
                "positive": [concept_names[k] for k in order[::-1][:5]]}  # fmt: skip

    return {
        "explained_variance_ratio": var.tolist(),
        "pc1": top_loadings(0),
        "pc2": top_loadings(1),
        # how much of the class signal PC1/PC2 keep: between-class share of variance
        "between_class_var_share": [
            float(sum((y == j).mean() * S[y == j, d].mean() ** 2 for j in range(len(class_names))) / S[:, d].var())
            for d in range(2)
        ],
    }


def run(out_dir: Path, modes: list[str]) -> None:
    metrics_path = out_dir / "metrics.json"
    if metrics_path.exists():
        plot_interventions(json.loads(metrics_path.read_text()), out_dir / "interventions.png")

    report = {}
    for mode in modes:
        path = out_dir / f"{mode}.pt"
        if not path.exists():
            continue
        art = torch.load(path, weights_only=False)
        names, classes = art["concept_names"], art["class_names"]
        W, c_prob = art["W"].numpy(), art["c_prob_test"].numpy()
        E = effect_matrix(W, c_prob)

        results = {}
        for opt, D in (("A_weights", cosine_distance(E)), ("B_activations", correlation_distance(c_prob))):
            Z, labels, k, sil = cluster(D)
            plot_dendrogram(Z, names, f"{mode} - option {opt}", out_dir / f"dendrogram_{mode}_{opt}.png")
            groups = {}
            for name, lab in zip(names, labels):
                groups.setdefault(int(lab), []).append(name)
            results[opt] = {"k": k, "silhouette": sil[k], "silhouette_by_k": sil, "clusters": groups}
            if opt == "A_weights":
                plot_heatmap(E, Z, names, classes, f"{mode}: concept -> class effects", out_dir / f"heatmap_{mode}.png")
                # which classes each cluster pushes towards
                for lab, members in groups.items():
                    mean = E[[names.index(n) for n in members]].mean(0)
                    top = [classes[j] for j in np.argsort(-mean)[:3]]
                    results[opt].setdefault("top_classes", {})[lab] = top
            results[opt]["labels"] = labels.tolist()
        results["A_vs_B_adjusted_rand"] = float(
            adjusted_rand_score(results["A_weights"]["labels"], results["B_activations"]["labels"])
        )
        pca = pca_tweets(c_prob, art["y_test"].numpy(), names, classes, mode, out_dir / f"pca_{mode}.png")
        results["pca"] = pca
        report[mode] = results

        print(f"\n=== {mode} ===  ARI(A, B) = {results['A_vs_B_adjusted_rand']:.3f}")
        ev = pca["explained_variance_ratio"]
        print(f"-- PCA of tweets in concept space: PC1 {ev[0]:.1%}, PC2 {ev[1]:.1%}, first 10 PCs {sum(ev):.1%}; "
              f"between-class share PC1 {pca['between_class_var_share'][0]:.1%}, PC2 {pca['between_class_var_share'][1]:.1%}")  # fmt: skip
        for pc in ("pc1", "pc2"):
            print(f"   {pc}: (-) {', '.join(pca[pc]['negative'])}  |  (+) {', '.join(pca[pc]['positive'])}")
        for opt in ("A_weights", "B_activations"):
            r = results[opt]
            print(f"-- option {opt}: k={r['k']}, silhouette={r['silhouette']:.3f}")
            for lab, members in sorted(r["clusters"].items()):
                top = f"  -> {', '.join(r['top_classes'][lab])}" if "top_classes" in r else ""
                print(f"   [{lab}] {', '.join(members)}{top}")

    (out_dir / "clusters.json").write_text(json.dumps(report, indent=2))
