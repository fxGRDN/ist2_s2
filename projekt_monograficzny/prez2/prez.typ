// ============================================================
//  Prezentacja: Wyniki Przeglądu Literatury (PRISMA-ScR)
//  Temat: Od Grad-CAM po SAE i CBM: Przegląd metod wyjaśnień
//         i probingu wizualnego w perspektywie Pragmatic Stance
//  Projekt Monograficzny - Politechnika Wrocławska
//  Autor: Kacper Borys | Promotor: prof. dr hab. inż. Halina Kwaśnicka
//  Prowadzący kurs: dr hab. Radosław Szczepanowski, prof. uczelni
//  Kompilacja: typst compile prez.typ prez.pdf
// ============================================================

// Paleta: jeden kolor główny, jeden akcent, szarości
#let primary = rgb("#0f3d64")
#let accent = rgb("#1d6fb8")
#let ink = rgb("#1e293b")
#let muted = rgb("#64748b")
#let rule = rgb("#d5dce6")
#let tag-green = rgb("#15803d")
#let tag-red = rgb("#b91c1c")

#set page(
  width: 21cm,
  height: 11.84cm, // Format 16:9
  margin: (x: 1.3cm, top: 0.85cm, bottom: 0.95cm),
  footer: context {
    if counter(page).get().first() > 1 {
      set text(font: "Noto Sans", size: 6.5pt, fill: muted)
      grid(
        columns: (1fr, auto),
        [#counter(page).display() / #counter(page).final().first()],
      )
    }
  },
)

#set text(font: "Libertinus Serif", size: 10pt, fill: ink, lang: "pl")
#set par(leading: 0.52em, spacing: 0.8em)
#set list(
  marker: text(fill: muted)[–],
  indent: 0pt,
  body-indent: 0.5em,
  spacing: 0.6em,
)

// Mała etykieta wersalikami
#let kicker(body, fill: accent) = text(
  font: "Noto Sans",
  size: 6.6pt,
  weight: "bold",
  tracking: 0.06em,
  fill: fill,
  body,
)

// Slajd: etykieta sekcji, tytuł, podtytuł, treść
#let slide(title: none, subtitle: none, section: none, body) = {
  pagebreak(weak: true)
  if section != none { block(below: 8pt, kicker(section)) }
  block(above: 8pt, below: 8pt, text(17pt, weight: "bold", fill: primary, title))
  if subtitle != none { block(above: 8pt, text(9.2pt, fill: muted, subtitle)) }
  v(10pt)
  body
}

// Nagłówek kolumny
#let h(body, fill: primary) = block(
  below: 0.75em,
  text(11pt, weight: "bold", fill: fill, body),
)

// Wyróżnienie: sama kreska po lewej, bez tła
#let note(body, color: accent) = block(
  width: 100%,
  inset: (left: 9pt, y: 1pt),
  stroke: (left: 1.5pt + color),
  body,
)

// Pozycja ze znacznikiem (numer, RQ1, ...) w kolorze akcentu
#let entry(tag, body, width: 1.5em, color: accent, below: 0.9em) = block(
  below: below,
  grid(
    columns: (width, 1fr),
    text(weight: "bold", fill: color, tag), body,
  ),
)

// Komórka siatki 2x2: cienka linia u góry, tytuł, treść
#let cell(title, body, label: none) = block(
  width: 100%,
  stroke: (top: 0.6pt + rule),
  inset: (top: 8pt),
)[
  #if label != none { block(below: 0.45em, kicker(label)) }
  #block(below: 0.65em, text(11pt, weight: "bold", fill: primary, title))
  #body
]

#let mono(body) = {
  set smartquote(enabled: false) // zapytania muszą mieć proste cudzysłowy
  text(font: "DejaVu Sans Mono", size: 7.2pt, fill: muted, body)
}

// ============================================================
// SLAJD 1 - Strona Tytułowa
// ============================================================
#align(left + horizon)[
  #kicker[SYSTEMATYCZNY PRZEGLĄD ZAKRESU PRZY UŻYCIU METODY PRISMA]
  #block(above: 12pt, below: 14pt, text(25pt, weight: "bold", fill: primary)[Czy model rozumie, co widzi?])
  #block(width: 82%, text(12pt, fill: rgb("#334155"))[Od Grad-CAM po SAE i CBM: Przegląd metod wyjaśnień wizualnych i probingu w perspektywie pragmatycznej])

  #block(above: 2em, below: 1.4em, line(length: 100%, stroke: 0.6pt + rule))

  #grid(
    columns: (auto, auto),
    column-gutter: 4em,
    [
      #text(8pt, fill: muted)[Przedstawia:] \
      #text(10.5pt, weight: "bold", fill: primary)[Kacper Borys]
    ],
    [
      #text(8pt, fill: muted)[Promotor pracy magisterskiej:] \
      #text(10.5pt, weight: "bold", fill: primary)[prof. dr hab. inż. Halina Kwaśnicka] \
      #text(8pt, fill: muted)[Katedra Sztucznej Inteligencji PWr]
    ],
  )
]

// ============================================================
// SLAJD 2 - Cel Przeglądu i Pytania Badawcze (Punkt 1)
// ============================================================
#slide(
  title: [1. Cel Przeglądu Literatury i Pytania Badawcze],
  subtitle: [Spektrum metod: od map atrybucji (Grad-CAM), przez słowniki (SAE), po modele koncepcyjne (CBM)],
  section: [PUNKT 1: CEL I RQ],
)[
  #grid(
    columns: (1fr, 1.3fr),
    gutter: 2.4em,
    [
      #h[Cel przeglądu zakresu]
      Krytyczny przegląd metod oceny wierności semantycznej w widzeniu komputerowym pod kątem przejścia od *naiwnego realizmu* (wiary w odkrywanie „prawdziwej ontologii sieci”) do *postawy pragmatycznej (Pragmatic Stance)*.

      #v(0.5em)
      #note[
        #set text(size: 9.5pt)
        *Teza:* \
        Metody XAI (Grad-CAM, SAE, sondy, CBM) nie dają bezpośredniego wglądu w rzeczywiste działanie modelu. To narzędzia, które należy oceniać wyłącznie pod kątem *zdolności do przewidywania błędów*, *podatności na interwencje przyczynowe* i *odporności na skróty (shortcut learning)*.
      ]
    ],
    [
      #h[Pytania badawcze przeglądu]
      #set text(size: 9.7pt)
      #entry(width: 2.6em)[RQ1][
        *Wierność metod atrybucji i probingu* \
        W jakim stopniu mapy istotności (Grad-CAM, LRP), słowniki SAE oraz sondy odzwierciedlają mechanizm decyzyjny sieci, a na ile są artefaktami niezależnymi od parametrów modelu (*sanity checks*)?
      ]
      #entry(width: 2.6em)[RQ2][
        *Nieidentyfikowalność i wyciek informacji* \
        Jakie patologie (mnogość konkurencyjnych słowników w SAE, zjawisko *concept leakage* w CBM) obalają realistyczne traktowanie reprezentacji jako „prawdy o modelu”?
      ]
      #entry(width: 2.6em)[RQ3][
        *Pragmatyczne kryteria ewaluacji* \
        Jakie protokoły empiryczne (zadania kontrolne, randomizacja kaskadowa, interwencje w obecności skrótów tła) pozwalają obiektywnie odróżnić operacyjną semantykę od zapamiętywania?
      ]
    ],
  )
]

// ============================================================
// SLAJD 3 - Strategia Wyszukiwania Literatury (Punkt 2)
// ============================================================
#slide(
  title: [2. Strategia Wyszukiwania Literatury],
  subtitle: [Baza OpenAlex, ramy czasowe oraz 4 filary zapytań obejmujące pełne spektrum interpretowalności],
  section: [PUNKT 2: STRATEGIA],
)[
  #grid(
    columns: (1fr, 1.4fr),
    gutter: 2.4em,
    [
      #h[Przeszukana baza naukowa]
      - *OpenAlex API & Web* — globalny otwarty indeks publikacji naukowych (integrujący m.in. Crossref, PubMed, arXiv).
      - *Typy publikacji:* `article`, `inproceedings`, `preprint / misc`.
      - *Zapytanie:* Tytuły i abstrakty (`title_and_abstract`).

      #v(0.5em)
      #note[
        #set text(size: 9.5pt)
        *Ramy czasowe:* Publikacje z lat *2018 – 2026* \
        #text(fill: muted)[Od przełomu Sanity Checks i TCAV (2018), przez CBM (2020), po najnowsze debaty nad identyfikowalnością SAE i stosowalnym XAI (2024–2026).]
      ]
    ],
    [
      #h[4 Filary zapytań Boole'owskich]
      #entry[1][
        *Atrybucja wizualna (mapy istotności)* \
        #mono[("Grad-CAM" OR "saliency maps" OR "Layer-wise Relevance Propagation" OR "LRP")]
      ]
      #entry[2][
        *Mechanistyczna interpretowalność i SAE* \
        #mono[("Sparse Autoencoders" OR "SAE" OR "dictionary learning" OR "monosemanticity")]
      ]
      #entry[3][
        *Probing semantyczny i modele koncepcyjne* \
        #mono[("linear probing" OR "TCAV" OR "Concept Bottleneck" OR "CBM" OR "CEM")]
      ]
      #entry[4][
        *Kryteria pragmatyczne, audyt i wierność* \
        #mono[AND ("pragmatic" OR "faithfulness" OR "sanity checks" OR "control tasks" OR "leakage" OR "intervention")]
      ]
    ],
  )
]

// ============================================================
// SLAJD 4 - Selekcja Publikacji: PRISMA-ScR (Punkt 3)
// ============================================================
#slide(
  title: [3. Selekcja Publikacji wg Metodologii PRISMA-ScR],
  subtitle: [Rzeczywisty przebieg selekcji na podstawie danych z OpenAlex (2018–2026)],
  section: [PUNKT 3: PRISMA-ScR],
)[
  #set text(size: 9.3pt)
  #set list(spacing: 0.5em)
  #grid(
    columns: (1.25fr, 1.15fr),
    gutter: 2.4em,
    [
      #h[Przebieg selekcji w procedurze PRISMA-ScR]
      #entry(below: 0.8em)[1][
        *Identyfikacja rekordów (Baza OpenAlex, n = 1047)*
        #v(-0.25em)
        - Artykuły w czasopismach (`article`): *n = 490*
        - Preprinty (`preprint / misc`): *n = 322*
        - Publikacje konferencyjne (`inproceedings`): *n = 235*
        #v(-0.25em)
        #text(fill: muted)[Po automatycznej deduplikacji w zbiorze: *n = 1037* unikalnych rekordów.]
      ]
      #entry(below: 0.8em)[2][
        *Przesiewanie tytułów i abstraktów* \
        Oceniono 1037 rekordów. Wykluczono *n = 881* prac spoza obszaru widzenia komputerowego oraz czysto komercyjnych wdrożeń bez analizy reprezentacji. Zakwalifikowano: *n = 156*.
      ]
      #entry(below: 0.8em)[3][
        *Ocena pełnych tekstów* \
        Szczegółowo oceniono *156* artykułów. Wykluczono *n = 120* prac na podstawie zdefiniowanych kryteriów E1–E4.
      ]
      #entry(color: tag-green, below: 0pt)[4][
        #text(fill: tag-green)[*Włączenie do syntezy (n = 36)*] \
        Mapy atrybucji: *9* · SAE i interpretowalność mechanistyczna: *8* · Probing i zadania kontrolne: *9* · CBM/CEM: *10*
      ]
    ],
    [
      #h[Kryteria Kwalifikacji i Wykluczenia]
      #text(weight: "bold", fill: tag-green)[Kryteria włączenia:]
      - Głębokie modele widzenia komputerowego (CNN, Vision Transformers).
      - Jawna analiza semantyki, cech słownikowych lub uczenia na skróty.
      - Zastosowanie metod weryfikacji wierności (testy poprawności, testy interwencyjne, probing z zadaniami kontrolnymi, sterowanie aktywacjami).
      - Publikacje z wiodących konferencji AI (NeurIPS, ICML, ICLR, CVPR, ECCV) lub recenzowanych czasopism.

      #v(0.5em)
      #text(weight: "bold", fill: tag-red)[Kryteria wykluczenia (n = 120):]
      - *E1 (n = 46):* Brak formalnej/empirycznej walidacji wierności.
      - *E2 (n = 39):* Drobne modyfikacje funkcji straty bez badania cech.
      - *E3 (n = 23):* Badania czysto tekstowe bez odniesienia do widzenia komputerowego.
      - *E4 (n = 12):* Brak możliwości replikacji / brak kodu.
    ],
  )
]

// ============================================================
// SLAJD 5 - Najważniejsze Wyniki Przeglądu (Punkt 4)
// ============================================================
#slide(
  title: [4. Najważniejsze Wyniki: Spektrum Metod w Świetle Pragmatyzmu],
  subtitle: [Kluczowe ustalenia dla czterech głównych paradygmatów wyjaśnień wizualnych i probingu],
  section: [PUNKT 4: WYNIKI],
)[
  #set text(size: 9pt)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2.4em,
    row-gutter: 1.1em,
    cell[1. Mapy atrybucji (Grad-CAM, LRP)][
      - *Podważenie założeń realizmu:* Adebayo i in. (NeurIPS 2018) wykazali, że część metod (Guided Backprop, Guided Grad-CAM) nie przechodzi testów poprawności — działają jak detektory krawędzi niezależne od wag wyższych warstw. Gradienty i Grad-CAM testy przechodzą.
      - *Postawa pragmatyczna:* Páez (2019) postuluje odejście od wymogu pełnej wierności wyjaśnień na rzecz pragmatycznych warunków rozumienia modelu przez odbiorcę.
    ],
    cell[2. Rzadkie autoenkodery (SAE)][
      - *Złudzenie jednoznacznej dekompozycji:* Wyjaśnienia mechanistyczne są *nieidentyfikowalne* — wiele obwodów i interpretacji równie dobrze odtwarza zachowanie sieci (Méloux, ICLR 2025). SAE znajdują pozornie interpretowalne cechy nawet w losowych sieciach (*The Dead Salmons of AI Interpretability*, 2025).
      - *Postawa pragmatyczna:* Wartość cech SAE nie wynika z ich „prawdziwości ontologicznej”, lecz z możliwości sterowania modelem (*activation steering*) i tłumienia skrótów.
    ],
    cell[3. Probing semantyczny (liniowy, TCAV)][
      - *Problem pojemności sondy:* Wysoka dokładność sondy nie oznacza, że model używa danej cechy (Belinkov 2022; Ravichander 2021); sonda potrafi zapamiętać losowe etykiety zadania kontrolnego (Hewitt & Liang 2019).
      - *Postawa pragmatyczna:* Przejście od pasywnego odczytu do probingu przyczynowego (*causal probing*, por. Belinkov 2022) oraz pomiaru selektywności.
    ],
    cell[4. Modele koncepcyjne (CBM, CEM)][
      - *Wyciek konceptów (concept leakage):* Warstwa konceptów przenosi dodatkową informację o zadaniu, wykraczającą poza same koncepty (Margeloiu 2021).
      - *Zawodność interwencji:* Przy niepełnym zbiorze konceptów częściowa interwencja człowieka może paradoksalnie *zwiększyć błąd modelu* (Verghese 2026); autorzy wiążą to z uczeniem na skróty (*shortcut learning*).
    ],
  )
]

// ============================================================
// SLAJD 6 - Zidentyfikowane Luki Badawcze (Punkt 5)
// ============================================================
#slide(
  title: [5. Zidentyfikowane Luki Badawcze],
  subtitle: [Białe plamy w literaturze: brak rygorystycznych testów pragmatycznych wspólnych dla wszystkich metod],
  section: [PUNKT 5: LUKI],
)[
  #set text(size: 9.6pt)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2.4em,
    row-gutter: 1.1em,
    cell(label: [LUKA 1])[Brak wspólnych testów poprawności (Grad-CAM vs CBM/SAE)][
      O ile protokół kaskadowej randomizacji wag Adebayo (2018) zastosowano do map istotności, a pojedyncze prace testują SAE na losowych sieciach, o tyle *brakuje wspólnego protokołu stosowanego równolegle do map atrybucji, sond, warstw CBM i słowników SAE*.
    ],
    cell(label: [LUKA 3])[Odporność interwencji na skróty tła][
      Metody interwencyjne (sterowanie aktywacjami w SAE, korekta cech w CBM) testowane są głównie w warunkach i.i.d.; odporność CBM na zmianę tła badali Koh i in. (2020). Brakuje jednak bezpośredniego porównania skuteczności interwencji w obecności jawnych skrótów tła (np. Waterbirds) między architekturami *CNN vs Vision Transformers*.
    ],
    cell(label: [LUKA 2])[Brak miary selektywności w probingu modeli wizyjnych][
      Metoda zadań kontrolnych Hewitta i Lianga (2019) upowszechniła się w NLP, ale w widzeniu komputerowym (probing cech pośrednich, TCAV, warstwy koncepcji) *nadal brakuje formalnych testów selektywności* odróżniających wydobywanie wiedzy od zapamiętywania.
    ],
    cell(label: [LUKA 4])[Pomijanie poziomów abstrakcji cech][
      Wszystkie badane paradygmaty traktują cechy jednopoziomowo (pojedynczy neuron, kierunek CAV, cecha SAE, koncept CBM). Brakuje analizy sprawdzającej, jak podatność na iluzję semantyczną zależy od psycholingwistycznego poziomu abstrakcji pojęć.
    ],
  )
]

// ============================================================
// SLAJD 7 - Wnioski i Uzasadnienie Własnego Badania (Punkt 6)
// ============================================================
#slide(
  title: [6. Wnioski i Uzasadnienie Własnego Badania],
  subtitle: [Projekt magisterski jako wielopoziomowy audyt pragmatyczny metod wyjaśnień wizualnych],
  section: [PUNKT 6: BADANIE],
)[
  #set text(size: 9.3pt)
  #grid(
    columns: (1.25fr, 1.15fr),
    gutter: 2.4em,
    [
      #h[Koncepcja badania magisterskiego]
      #note[
        *Tytuł:* „Identyfikowalność wizualnych metod wyjaśniających”
      ]

      #v(0.5em)
      *Realizacja zgodnie z postawą pragmatyczną:*
      #v(0.2em)
      #entry(below: 0.75em)[1][
        *Kaskadowa randomizacja wag (Protokół Adebayo)* \
        Zastosowanie protokołu randomizacji wag warstwa po warstwie do map atrybucji (Grad-CAM), sond oraz warstw wąskiego gardła koncepcji (CBM) na *ResNet-50 vs ViT-B/16*.
      ]
      #entry(below: 0.75em)[2][
        *Zadania kontrolne i selektywność (Hewitt i Liang w widzeniu komputerowym)* \
        Weryfikacja selektywności sond i wektorów koncepcji na zbiorach CUB-200 i AwA2 — oddzielenie informacji zawartej w reprezentacji od pojemności pamięciowej sondy.
      ]
      #entry(below: 0pt)[3][
        *Ocena interwencji w obecności skrótów* \
        Sprawdzenie podatności na interwencje przyczynowe na zbiorze Waterbirds: czy interwencja człowieka rzeczywiście odwraca wpływ skrótu tła?
      ]
    ],
    [
      #h[Wartość Dodana i Znaczenie Badania]
      #set list(spacing: 1em)
      - *Oryginalność i unifikacja metodyczna:* \
        Przegląd literatury z lat 2025–2026 wskazuje na brak prac zestawiających metody atrybucji (Grad-CAM), probing i modele koncepcyjne (CBM) w ramach wspólnego, rygorystycznego protokołu randomizacji i zadań kontrolnych.

      - *Przełamanie fałszywego zaufania:* \
        Zamiast jałowych sporów o to, „czy sieć myśli jak człowiek”, badanie ma dostarczyć empirycznych kryteriów pomagających ocenić, kiedy wyjaśnieniom można ufać.

      - *Znaczenie praktyczne:* \
        Istotne dla zastosowań w medycynie i systemach krytycznych, gdzie poleganie na fałszywych wyjaśnieniach post-hoc stwarza bezpośrednie ryzyko błędnych decyzji.
    ],
  )
]

// ============================================================
// SLAJD 8 - Kluczowa Bibliografia Przeglądu
// ============================================================
#slide(
  title: [Kluczowa Bibliografia Przeglądu Literatury],
  subtitle: [Wybrane podstawowe pozycje reprezentujące 4 nurty włączone do syntezy PRISMA-ScR],
  section: [LITERATURA],
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2.4em,
    [
      #h[Atrybucja, probing i postawa pragmatyczna]
      #set text(size: 9pt)
      - *Selvaraju, R. R. et al. (ICCV 2017)* — #emph[Grad-CAM: Visual Explanations from Deep Networks].
      - *Adebayo, J. et al. (NeurIPS 2018)* — #emph[Sanity Checks for Saliency Maps].
      - *Hewitt, J., & Liang, P. (EMNLP 2019)* — #emph[Designing and Interpreting Probes with Control Tasks].
      - *Páez, A. (2019)* — #emph[The Pragmatic Turn in Explainable AI (XAI)]. Minds and Machines.
      - *Belinkov, Y. (Computational Linguistics 2022)* — #emph[Probing Classifiers: Promises, Shortcomings, and Advances].
      - *Orgad, H. et al. (ICML 2026)* — #emph[Position: Interpretability Can Be Actionable].
    ],
    [
      #h[Modele koncepcyjne, SAE i uczenie na skróty]
      #set text(size: 9pt)
      - *Koh, P. W. et al. (ICML 2020)* — #emph[Concept Bottleneck Models].
      - *Geirhos, R. et al. (Nat. Mach. Intell. 2020)* — #emph[Shortcut Learning in Deep Neural Networks].
      - *Margeloiu, A. et al. (2021)* — #emph[Do Concept Bottleneck Models Learn as Intended?]
      - *Zarlenga, M. E. et al. (NeurIPS 2022)* — #emph[Concept Embedding Models].
      - *Verghese, G. et al. (arXiv 2026)* — #emph[Harmful Partial Interventions and Benign Leakage in Concept-based Models].
      - *Méloux, M. et al. (ICLR 2025)* — #emph[Everything, Everywhere, All at Once: Is Mechanistic Interpretability Identifiable?]
    ],
  )
  #v(1.2em)
  #text(9pt, fill: muted)[Pełny zestaw 36 pozycji ujętych w procedurze PRISMA-ScR jest dostępny w bazie projektu.]
]
