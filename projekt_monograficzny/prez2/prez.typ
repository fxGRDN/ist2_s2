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
        [Przegląd literatury (PRISMA-ScR) · Kacper Borys],
        [Slajd #counter(page).display() z #counter(page).final().first()],
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
      Krytyczne zmapowanie metod ewaluacji wierności semantycznej w wizji komputerowej pod kątem przejścia od *naiwnego realizmu* (wiary w odkrywanie „prawdziwej ontologii sieci”) do *postawy pragmatycznej (Pragmatic Stance)*.

      #v(0.5em)
      #note[
        #set text(size: 9.5pt)
        *Przewodnia teza pragmatyczna:* \
        Metody XAI (Grad-CAM, SAE, sondy, CBM) nie są oknem do „świadomości” modelu. Są modelami narzędziowymi ocenianymi wyłącznie przez ich *zdolność do przewidywania błędów*, *manipulowalność przyczynową* i *odporność na skróty (shortcut learning)*.
      ]
    ],
    [
      #h[Pytania badawcze przeglądu (Scoping RQ)]
      #set text(size: 9.7pt)
      #entry(width: 2.6em)[RQ1][
        *Wierność metod atrybucji i probingu* \
        W jakim stopniu mapy saliency (Grad-CAM, LRP), słowniki SAE oraz sondy odzwierciedlają mechanikę decyzyjną sieci, a na ile stanowią artefakty niezależne od parametrów modelu (*sanity checks*)?
      ]
      #entry(width: 2.6em)[RQ2][
        *Nieidentyfikowalność i wyciek informacji* \
        Jakie patologie (wielość konkurencyjnych słowników w SAE, zjawisko *concept leakage* w CBM) obalają realistyczne traktowanie reprezentacji jako „prawdy o modelu”?
      ]
      #entry(width: 2.6em)[RQ3][
        *Pragmatyczne kryteria ewaluacji* \
        Jakie protokoły empiryczne (zadania kontrolne, randomizacja kaskadowa, interwencje pod skrótami tła) pozwalają obiektywnie odróżnić operacyjną semantykę od memorizacji?
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
      - *OpenAlex API & Web* — globalny otwarty indeks publikacji naukowych (integrujący m.in. Scopus, Web of Science, Crossref, PubMed, arXiv).
      - *Typy publikacji:* `article`, `inproceedings`, `preprint / misc`.
      - *Kwerenda:* Tytuły i abstrakty (`title_and_abstract`).

      #v(0.5em)
      #note[
        #set text(size: 9.5pt)
        *Ramy czasowe:* Publikacje z lat *2018 – 2026* \
        #text(fill: muted)[Od przełomu Sanity Checks i TCAV (2018), przez CBM (2020), po najnowsze debaty nad identyfikowalnością SAE i actionable XAI (2024–2026).]
      ]
    ],
    [
      #h[4 Filary zapytań Boole'owskich]
      #entry[1][
        *Atrybucja wizualna (Saliency)* \
        #mono[("Grad-CAM" OR "saliency maps" OR "Layer-wise Relevance Propagation" OR "LRP")]
      ]
      #entry[2][
        *Mechanistyczna interpretowalność & SAE* \
        #mono[("Sparse Autoencoders" OR "SAE" OR "dictionary learning" OR "monosemanticity")]
      ]
      #entry[3][
        *Probing semantyczny & Modele koncepcyjne* \
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
  subtitle: [Rzeczywisty przepływ selekcji na bazie danych z OpenAlex (2018–2026)],
  section: [PUNKT 3: PRISMA-ScR],
)[
  #set text(size: 9.3pt)
  #set list(spacing: 0.5em)
  #grid(
    columns: (1.25fr, 1.15fr),
    gutter: 2.4em,
    [
      #h[Przepływ selekcji w procedurze PRISMA-ScR]
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
        *Przesiewanie (Screening tytułów i abstraktów)* \
        Oceniono 1037 rekordów. Wykluczono *n = 881* prac poza zakresem widzenia komputerowego / czystych wdrożeń komercyjnych bez analizy reprezentacji. Zakwalifikowano: *n = 156*.
      ]
      #entry(below: 0.8em)[3][
        *Kwalifikowalność (Eligibility pełnych tekstów)* \
        Szczegółowo oceniono *156* artykułów. Wykluczono *n = 120* prac na podstawie zdefiniowanych kryteriów E1–E4.
      ]
      #entry(color: tag-green, below: 0pt)[4][
        #text(fill: tag-green)[*Włączenie do syntezy (Included, n = 36)*] \
        Mapy atrybucji: *9* · SAE & Mechanistic: *8* · Probing & Control: *9* · CBM/CEM: *10*
      ]
    ],
    [
      #h[Kryteria Kwalifikacji i Wykluczenia]
      #text(weight: "bold", fill: tag-green)[Kryteria włączenia (Inclusion):]
      - Głębokie modele widzenia komputerowego (CNN, Vision Transformers).
      - Jawna analiza semantyki, cech słownikowych lub dróg na skróty.
      - Zastosowanie metodyk weryfikacji wierności (sanity checks, testy interwencyjne, probing z zadaniami kontrolnymi, steering).
      - Publikacje z wiodących konferencji AI (NeurIPS, ICML, ICLR, CVPR, ECCV) lub recenzowanych czasopism.

      #v(0.5em)
      #text(weight: "bold", fill: tag-red)[Kryteria wykluczenia (Exclusion, n = 120):]
      - *E1 (n = 46):* Brak formalnej/empirycznej walidacji wierności.
      - *E2 (n = 39):* Inkrementalne zmiany funkcji straty bez badania cech.
      - *E3 (n = 23):* Badania czysto tekstowe bez przeniesienia na widzenie.
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
  #set text(size: 9.3pt)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2.4em,
    row-gutter: 1.1em,
    cell[1. Mapy atrybucji (Grad-CAM, LRP)][
      - *Upadek roszczeń realistycznych:* Adebayo i in. (NeurIPS 2018) udowodnili, że mapy gradientowe oblewają testy poprawności — działają jak detektory krawędzi niezależne od wag wyższych warstw.
      - *Postawa pragmatyczna:* Páez (2019) wskazuje, że saliency nie odkrywa mechaniki modelu, lecz służy wyłącznie jako wstępna heurystyka wykrywania anomalii dla człowieka.
    ],
    cell[2. Sparse Autoencoders (SAE) w wizji][
      - *Iluzja unikalnej dekompozycji:* *The Dead Salmons of AI* oraz Chughtai (2025) wykazują, że rozbicie superpozycji na cechy jest *nieidentyfikowalne* — wiele słowników równie dobrze rekonstruuje sieć.
      - *Postawa pragmatyczna:* Wartość cech SAE nie wynika z ich „prawdziwości ontologicznej”, lecz ze sterowalności (*activation steering*) i gaszenia skrótów.
    ],
    cell[3. Probing semantyczny (Linear, TCAV)][
      - *Dylemat pojemności:* Wysoka dokładność sondy nie oznacza, że model używa danej cechy (Belinkov 2022); sonda potrafi nauczyć się zadania z szumu (Hewitt & Liang 2019).
      - *Postawa pragmatyczna:* Przejście od pasywnego odczytu do probingu przyczynowego (*causal probing*, Ravichander 2021) oraz mierzenia selektywności.
    ],
    cell[4. Modele koncepcyjne (CBM, CEM)][
      - *Concept Leakage:* Ciągłe wąskie gardła tworzą kanał steganograficzny, przemycając cechy pozorne obok semantyki (Margeloiu 2021).
      - *Załamanie interwencji:* W obecności skrótów poznawczych (*shortcut learning*) częściowa interwencja człowieka może paradoksalnie *zwiększyć błąd modelu* (Verghese 2026).
    ],
  )
]

// ============================================================
// SLAJD 6 - Zidentyfikowane Luki Badawcze (Punkt 5)
// ============================================================
#slide(
  title: [5. Zidentyfikowane Luki Badawcze],
  subtitle: [Białe plamy w literaturze: brak rygorystycznych testów pragmatycznych w poprzek metod],
  section: [PUNKT 5: LUKI],
)[
  #set text(size: 9.6pt)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2.4em,
    row-gutter: 1.1em,
    cell(label: [LUKA 1])[Brak unifikacji Sanity Checks (Grad-CAM vs CBM/SAE)][
      O ile protokół kaskadowej randomizacji wag Adebayo (2018) przetestował mapy saliency, o tyle *nigdy nie został systematycznie zaaplikowany do warstw CBM ani słowników SAE*. Nie zbadano, czy dekompozycje cech to cecha reprezentacji, czy artefakt geometrii przestrzeni ukrytej.
    ],
    cell(label: [LUKA 3])[Odporność interwencji pod wpływem skrótów tła][
      Większość metod interwencyjnych (steering w SAE, korekta cech w CBM) testowana jest w warunkach i.i.d. Brakuje bezpośredniego porównania siły sprawczej interwencji w obecności jawnych skrótów tła (np. Waterbirds) między architekturami *CNN vs Vision Transformers*.
    ],
    cell(label: [LUKA 2])[Brak miary selektywności w wizyjnym probingu][
      Metodyka zadań kontrolnych Hewitta i Lianga (2019) zrewolucjonizowała NLP, ale w widzeniu komputerowym (probing cech pośrednich, TCAV, warstwy koncepcji) *nadal brakuje formalnych testów selektywności* odróżniających wydobywanie wiedzy od memorizacji.
    ],
    cell(label: [LUKA 4])[Ignorowanie poziomów abstrakcji cech][
      Wszystkie badane paradygmaty traktują cechy na płasko (pojedynczy neuron, kierunek CAV, cecha SAE, koncept CBM). Brakuje analizy sprawdzającej, jak podatność na iluzję semantyczną zależy od psycholingwistycznego poziomu abstrakcji pojęć.
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
        *Tytuł:* „Empiryczny audyt pragmatyczny wyjaśnień wizualnych i probingu semantycznego: od map atrybucji po modele koncepcyjne”
      ]

      #v(0.5em)
      *Realizacja w paradygmacie Pragmatic Stance:*
      #v(0.2em)
      #entry(below: 0.75em)[1][
        *Kaskadowa randomizacja wag (Protokół Adebayo)* \
        Aplikacja protokołu zniszczenia wag warstwa po warstwie do map atrybucji (Grad-CAM), sond probingu oraz warstw Concept Bottleneck na *ResNet-50 vs ViT-B/16*.
      ]
      #entry(below: 0.75em)[2][
        *Zadania kontrolne i selektywność (Hewitt & Liang w CV)* \
        Weryfikacja selektywności sond i wektorów koncepcji na zbiorach CUB-200 i AwA2 — oddzielenie informacji operacyjnej od pojemności pamięciowej.
      ]
      #entry(below: 0pt)[3][
        *Ewaluacja interwencji pod wpływem skrótów* \
        Testowanie manipulowalności przyczynowej na zbiorze Waterbirds: czy interwencja człowieka rzeczywiście odwraca wpływ skrótu tła?
      ]
    ],
    [
      #h[Wartość Dodana i Znaczenie Badania]
      #set list(spacing: 1em)
      - *Oryginalność i unifikacja metodyczna:* \
        Audyt literatury 2025–2026 wskazuje brak prac zestawiających metody atrybucji (Grad-CAM), probing i modele koncepcyjne (CBM) pod wspólnym, rygorystycznym rygorem randomizacji i zadań kontrolnych.

      - *Przełamanie fałszywego zaufania:* \
        Zamiast jałowych sporów o to, „czy sieć myśli jak człowiek”, badanie dostarczy twardych, inżynierskich kryteriów określających, kiedy wyjaśnieniom można bezpiecznie ufać.

      - *Znaczenie aplikacyjne:* \
        Kluczowe w systemach medycznych i krytycznych, gdzie poleganie na fałszywych wyjaśnieniach post-hoc stwarza bezpośrednie ryzyko błędnych decyzji.
    ],
  )
]

// ============================================================
// SLAJD 8 - Kluczowa Bibliografia Przeglądu
// ============================================================
#slide(
  title: [Kluczowa Bibliografia Przeglądu Literatury],
  subtitle: [Wybrane fundamentalne pozycje reprezentujące 4 nurty włączone do syntezy PRISMA-ScR],
  section: [LITERATURA],
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 2.4em,
    [
      #h[Atrybucja, Probing & Pragmatic Stance]
      #set text(size: 9pt)
      - *Selvaraju, R. R. et al. (ICCV 2017)* — #emph[Grad-CAM: Visual Explanations from Deep Networks].
      - *Adebayo, J. et al. (NeurIPS 2018)* — #emph[Sanity Checks for Saliency Maps].
      - *Hewitt, J., & Liang, P. (EMNLP 2019)* — #emph[Designing and Interpreting Probes with Control Tasks].
      - *Páez, A. (2019)* — #emph[The Pragmatic Turn in Explainable AI (XAI)]. Minds and Machines.
      - *Belinkov, Y. (Computational Linguistics 2022)* — #emph[Probing Classifiers: Promises, Shortcomings, and Advances].
      - *Orgad, H. et al. (ICML 2024)* — #emph[Position: Interpretability Can Be Actionable].
    ],
    [
      #h[Concept Bottlenecks, SAE & Shortcut Learning]
      #set text(size: 9pt)
      - *Koh, P. W. et al. (ICML 2020)* — #emph[Concept Bottleneck Models].
      - *Geirhos, R. et al. (Nat. Mach. Intell. 2020)* — #emph[Shortcut Learning in Deep Neural Networks].
      - *Margeloiu, A. et al. (2021)* — #emph[Do Concept Bottleneck Models Learn Intended Concepts? Concept Leakage].
      - *Zarlenga, M. E. et al. (NeurIPS 2022)* — #emph[Concept Embedding Models].
      - *Verghese, S. et al. (arXiv 2026)* — #emph[Harmful Partial Interventions and Benign Leakage in Concept-based Models].
      - *Chughtai, B. et al. / Méloux et al. (ICLR)* — #emph[Everything, Everywhere, All at Once: Is Mechanistic Interpretability Identifiable?].
    ],
  )
  #v(1.2em)
  #text(9pt, fill: muted)[Pełny zestaw 36 pozycji ujętych w procedurze PRISMA-ScR zdeponowano w bazie projektu.]
]
