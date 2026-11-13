# profilowanie

Concept Bottleneck Model (CBM) on top of BERT for tweet classification, plus
clustering of the learned concepts by how they affect the classification.

## Goal

1. Take BERT and force its prediction to go through a small layer of
   human-readable concepts (e.g. `christmas`, `humor`, `romantic_love`), so that
   every prediction can be explained as "these concepts were active".
2. Classify tweets from TweetEval-emoji (predict which of 20 emoji a tweet used).
3. Cluster the concepts based on the classification: concepts that push the
   model towards the same classes should land in the same group.
4. Check what the bottleneck costs (accuracy against plain BERT) and whether the
   concepts are actually used (intervention test).

## Pipeline

| Step | What happens | Code |
|---|---|---|
| Concepts | 52 hand-written concepts, each with an NLI hypothesis | `concepts.py` |
| Pseudo-labels | TweetEval has no concept labels, so a zero-shot NLI model scores every (tweet, concept) pair; scores above 0.5 count as "concept present" | `data.py` |
| Models | Plain BERT baseline and three CBMs (joint, sequential, independent; Koh et al., 2020). The classifier is one linear layer on concept probabilities | `train.py` |
| Evaluation | Class accuracy and macro-F1, concept F1/AUC against the pseudo-labels, accuracy with hard concepts (leakage probe), intervention curve | `train.py` |
| Clustering | Option A: concept-to-class weights, scaled by activation std, cosine distance. Option B: concept activations on the test set, correlation distance. Agglomerative clustering, k picked by silhouette | `cluster.py` |

## Usage

```bash
uv run profilowanie all        # prepare + train + cluster
uv run profilowanie prepare    # download tweets, compute concept pseudo-labels
uv run profilowanie train      # train baseline and the three CBMs
uv run profilowanie cluster    # cluster concepts, draw plots
```

Useful flags: `--n-train/--n-val/--n-test` (subsample sizes, 0 = full split),
`--modes`, `--epochs`, `--lam` (concept loss weight), `--l1` (sparsity of the
concept-to-class weights), `--bert`, `--nli-model`. See `--help`.

## Outputs

- `data/emoji_concepts.pt`: tweets, labels and concept scores (cached).
- `outputs/metrics.json`: all metrics per training mode.
- `outputs/{mode}.pt`: concept-to-class weights and test-set concept predictions.
- `outputs/clusters.json`: clusters for both options, silhouette scores, agreement between options A and B.
- `outputs/dendrogram_*.png`, `outputs/heatmap_*.png`, `outputs/interventions.png`.
- `outputs/pca_{mode}.png`: PCA of test tweets in concept space (tweets coloured by class, class centroids, concept loadings).

## Caveats

- Concept labels are pseudo-labels from an NLI model, so they are noisy. Concept
  F1 measures agreement with that model, not with humans.
- Emoji prediction is a hard task; plain BERT is far from perfect too.
- The CBM classifier sees soft concept probabilities, which can leak label
  information. `acc_hard_concepts` in the metrics shows how much.

## References

- Koh et al., 2020. Concept Bottleneck Models.
- Oikarinen et al., 2023. Label-Free Concept Bottleneck Models.
- Ludan et al., 2023. Interpretable-by-Design Text Understanding with Iteratively Generated Concept Bottleneck.
- Sun et al., 2024. Concept Bottleneck Large Language Models.
- Barbieri et al., 2020. TweetEval.
