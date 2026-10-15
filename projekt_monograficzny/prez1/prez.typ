// ============================================================
//  Szkielet prezentacji - praca monograficzna (4 slajdy)
//  "Czy CNN rozumie semantykę obrazu, czy tylko rozpoznaje wzorce?"
//  Compile: typst compile prez.typ prez.pdf
//  Placeholders do uzupełnienia = [TODO]
// ============================================================

#set page(
  width: 21cm,
  height: 11.84cm, // 16:9
  margin: (x: 1.2cm, top: 1.0cm, bottom: 1.1cm),
  footer: context align(right)[#text(8.5pt, gray)[#counter(page).display()]],
)

#set text(font: "Libertinus Serif", size: 11pt, lang: "pl")
#set heading(numbering: none)
#set par(leading: 0.6em)
#set list(indent: 1.05em, body-indent: 0.2em, spacing: 0.3em)

#let accent = rgb("#1f6feb")
#let muted = rgb("#57606a")

// --- slajd -------------------------------------------------
#let slide(title: none, subtitle: none, body) = {
  pagebreak(weak: true)
  align(left + horizon)[
    #if title != none {
      block(width: 100%)[#text(20pt, weight: "bold", fill: accent)[#title]]
      v(-0.5em)
      line(length: 100%, stroke: 1.1pt + accent)
      v(0.4em)
    }
    #if subtitle != none {
      text(10pt, fill: muted)[#subtitle]
      v(0.4em)
    }
    #body
  ]
}

// --- pasek dolny -------------------------------------------
#let strip(content) = {
  v(0.3em)
  block(width: 100%, inset: (x: 8pt, y: 3pt), radius: 4pt, fill: rgb("#eef2f6"))[
    #text(8.5pt)[#content]
  ]
}

#let cols(a, b, gap: 2.2em) = grid(
  columns: 2,
  gutter: gap,
  align(left)[#a], align(left)[#b],
)

// --- karta etapu (kolumny o równej wysokości) --------------
#let stage(head, body) = {
  block(
    width: 100%,
    height: 100%,
    inset: (x: 11pt, y: 9pt),
    radius: 6pt,
    fill: rgb("#f7f9fb"),
    stroke: 0.7pt + rgb("#d6dde5"),
  )[
    #text(12.5pt, weight: "bold", fill: accent)[#head]
    #v(0.35em)
    #line(length: 100%, stroke: 0.7pt + rgb("#c9d3de"))
    #v(0.55em)
    #set par(leading: 0.3em)
    #set list(spacing: 1em, indent: 1.0em, body-indent: 0.15em)
    #body
  ]
}

// ============================================================
// SLAJD 1 - Strona tytułowa
// ============================================================
#align(left + horizon)[
  #v(0.8em)
  #text(29pt, weight: "bold", fill: accent)[Czy model „rozumie”, co widzi?]
  #v(0.15em)
  #text(16pt)[Wyjaśnienia wizualne głębokich modeli a semantyka obiektów i scen]
  #v(0.6em)
  #line(length: 100%, stroke: 1.3pt + accent)
  #v(0.6em)
  #text(11.5pt)[
    Czy aktywacje generowane przez głębokie modele uczenia maszynowego
    (Grad-CAM, LRP, saliency maps) odzwierciedlają zrozumienie semantyki obrazu,
    czy jedynie powierzchowne rozpoznanie wzorców - wiedzę o tym, #emph[gdzie spojrzeć],
    żeby coś zaklasyfikować.
  ]
  #line(length: 100%, stroke: 0.5pt + accent)
  #v(0.9em)
  #text(9pt)[
    Projekt monograficzny - #text(fill: black)[2026-10-15] \
    Autor: #text(fill: black)[Kacper Borys] \
    Promotor: #text(fill: black)[prof. dr hab. inż. Halina Kwaśnicka] \
    #text(gray)[
      Prezentacja częsciowo stworzona przy pomocy AI
    ]
  ]

]

// ============================================================
// SLAJD 2 - Cel, zakres, pytania badawcze
// ============================================================
#slide(title: [1. Cel, zakres i pytania badawcze])[
  #cols(
    [
      #text(weight: "bold")[Cel]
      Czy wyjaśnienia generowane przez modele głębokie #emph[ujawniają zrozumienie
        semantyki] obrazów, czy tylko #emph[odzwierciedlają powierzchowne rozpoznawanie wzorców].

      #v(0.45em)
      #text(weight: "bold")[Zakres]
      Analiza i porównanie wyjaśnień wizualnych: Grad-CAM, LRP, saliency maps oraz inne metody (możliwie autorskie)
      w kontekście semantycznych cech obiektów i scen.

      #v(0.45em)
      #text(weight: "bold")[Znaczenie]
      Zaufanie do modeli: interpretowalność #sym.inter semantyka. Wyjaśnienie #sym.eq.not wyjaśnienie #emph[dobrze].

      #v(0.45em)
      #text(weight: "bold")[Definicja „rozumienia semantycznego”]
      #text(fill: muted)[Do zrobienia jako część pracy]
    ],
    [
      #text(weight: "bold")[Pytania badawcze]
      #v(0.10em)
      - *1.* Czy heatmapy pokrywają się z obszarami istotnymi semantycznie dla człowieka?
      #v(0.10em)
      - *2.* Czy wyjaśnienia różnicują klasy bliskie semantycznie (wilk / pies, samolot / dron, labrador / golden retriever)?
      #v(0.10em)
      - *3. * ...?

    ],
  )
]

// ============================================================
// SLAJD 3 - Metodyka
// ============================================================
#slide(
  title: [2. Metodologia],
)[
  #block(width: 100%, height: 80%)[
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 1.0em,
      align(left + top)[#stage([Etap 1 · Teoria])[
        - #text(weight: "bold")[Interpretowalność] i XAI dla obrazów.
        - #text(weight: "bold")[Semantyka] vs. rozpoznanie wzorców.
        - #text(weight: "bold")[Metody:] CAM → Grad-CAM → LRP → saliency / integrated gradients.
        - #text(weight: "bold")[Definicja] „rozumienia semantycznego” w AI.
        - #text(weight: "bold")[Krytyka:] zawodność i niestabilność saliency maps.
      ]],
      align(left + top)[#stage([Etap 2 · Eksperyment])[
        - #text(weight: "bold")[Modele:] ResNet50, EfficientNet.
        - #text(weight: "bold")[Klasy bliskie semantycznie:] labrador / golden retriever,
          wilk / pies, samolot / dron.
        - #text(weight: "bold")[Ta sama sieć,] różne metody wyjaśnień.
        - #text(weight: "bold")[Semantic probing:] probe'y uczące się atrybutów
          (Visual Genome, CUB-200).
      ]],
      align(left + top)[#stage([Etap 3 · Ocena])[
        - #text(weight: "bold")[IoU] wyjaśnień z maskami segmentacji semantycznej.
        - #text(weight: "bold")[Pixel-wise overlap] między metodami.
        - #text(weight: "bold")[Semantyczna trafność] / zgodność semantyczna wyjaśnień.
        - #text(weight: "bold")[Analiza błędów:] heatmapy „off tangent”, preteksty.
        - #text(weight: "bold")[Wnioski] + kierunki dalszych badań.
      ]],
    )
  ]
]

// ============================================================
// SLAJD 4 - Literatura i kierunki dalszych badań
// ============================================================
#slide(title: [3. Literatura i kierunki dalszych badań])[
  #grid(
    columns: 3,
    gutter: 0.9em,
    align(left + top)[
      #text(10.5pt, weight: "bold", fill: accent)[Metody wyjaśnień wizualnych]
      #v(0.25em)
      #set text(size: 8pt)
      #set par(leading: 0.25em)
      #set list(spacing: 0.3em, indent: 0.9em, body-indent: 0.1em)
      - Zeiler & Fergus (2014) — Visualizing and Understanding Convolutional
        Networks, ECCV
      - Zhou i in. (2016) — Learning Deep Features for Discriminative
        Localization (CAM), CVPR
      - Selvaraju i in. (2020) — Grad-CAM, IJCV 128(2)
      - Binder i in. (2016) — Layer-wise Relevance Propagation for Neural Networks with Local Renormalization Layers, arXiv:1604.00825

      #v(0.5em)
      #text(10.5pt, weight: "bold", fill: accent)[Zastosowania XAI]
      #v(0.25em)
      - Szymkowski (2023) — Neural Networks and Saliency Maps in Diabetic
        Retinopathy Diagnosis, Springer
      - Peiffer (2024) — An Experimental Investigation into the Evaluation of
        Explainability Methods
    ],
    align(left + top)[
      #text(10.5pt, weight: "bold", fill: accent)[Krytyka metod i metryki wyjaśnień]
      #v(0.25em)
      #set text(size: 8pt)
      #set par(leading: 0.25em)
      #set list(spacing: 0.3em, indent: 0.9em, body-indent: 0.1em)
      - Kindermans i in. (2017) — The (Un)reliability of Saliency Methods,
        arXiv:1711.00867
      - Adebayo i in. (2020) — Sanity Checks for Saliency Maps, NeurIPS
      - Rosenzweig i in. (2023) — When Saliency Goes off on a Tangent,
        arXiv:2110.06639
      - Lin i in. (2019) — Do Explanations Reflect Decisions?, arXiv:1910.07387
      - Raatikainen & Rahtu (2025) — The Weighting Game: Evaluating Quality of Explainability Methods, LNCS 15726
      - Pawlicki i in. (2024) — Evaluating the Necessity of the Multiple Metrics
        for Assessing Explainable AI, Neurocomputing 602
      - Szczepankiewicz i in. (2023) — Ground Truth Based Comparison of Saliency
        Maps Algorithms, Scientific Reports 13
    ],
    align(left + top)[
      #text(10.5pt, weight: "bold", fill: accent)[Semantyka vs. rozpoznanie wzorców]
      #v(0.25em)
      #set text(size: 8pt)
      #set par(leading: 0.25em)
      #set list(spacing: 0.3em, indent: 0.9em, body-indent: 0.1em)
      - Yan & Zhou (2017) — How Intelligent Are Convolutional Neural Networks?,
        arXiv
      - Bau i in. (2017) — Network Dissection: Quantifying Interpretability of
        Deep Visual Representations, CVPR
      - Kim i in. (2018) — Interpretability Beyond Feature Attribution: TCAV,
        ICML
      - Chen i in. (2020) — Concept Whitening for Interpretable Image Recognition,
        Nat. Mach. Intell. 2
      - Geirhos i in. (2019) — ImageNet-trained CNNs are Biased towards Texture,
        ICLR
      - Geirhos i in. (2020) — Shortcut Learning in Deep Neural Networks,
        Nat. Mach. Intell. 2
      - Zellers i in. (2019) — From Recognition to Cognition: Visual Commonsense
        Reasoning, CVPR
    ],
  )
]
