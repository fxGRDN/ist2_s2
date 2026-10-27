// Etap 1 — opis słowny problemu.
// Kompilacja: typst compile prez.typ prez.pdf

#let group = [Dawid Nowak, Szymon Pestrowicz, Kacper Borys]

#set page(
  width: 21cm,
  height: 11.84cm,
  margin: (x: 1.15cm, top: 0.85cm, bottom: 1.05cm),
  footer: context {
    set text(7.5pt, fill: rgb("#6b7280"))
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      [#counter(page).display()],
    )
  },
)

#set text(font: "FreeSans", size: 12.5pt, lang: "pl", hyphenate: false)
#set par(leading: 0.38em, justify: false)
#set list(indent: 0.85em, body-indent: 0.32em, spacing: 0.34em)

#let accent = rgb("#1d4e89")
#let ink = rgb("#1c2430")
#let muted = rgb("#5c6770")
#let wash = rgb("#f3f6fa")
#let line-col = rgb("#d5dee8")

#set text(fill: ink)

#let slide(title, body) = {
  pagebreak(weak: true)
  block(width: 100%)[
    #text(19pt, weight: "bold", fill: accent)[#title]
    #v(-0.15em)
    #line(length: 100%, stroke: 1.15pt + accent)
  ]
  v(0.55em)
  body
}

#let tag(body) = box(
  inset: (x: 7pt, y: 2pt),
  radius: 3pt,
  fill: rgb("#e7eef6"),
)[#text(9.5pt, fill: accent, weight: "bold")[#body]]

#let card(body) = block(
  width: 100%,
  inset: (x: 9pt, y: 7pt),
  radius: 5pt,
  fill: wash,
  stroke: 0.6pt + line-col,
  breakable: false,
)[#body]

#let term(name, body) = block(spacing: 0.34em, breakable: false)[
  #text(11.5pt)[#text(weight: "bold", fill: accent)[#name] — #body]
]

// ============================================================
// 1. Tytuł
// ============================================================

#align(horizon)[
  #tag[Etap 1 · Opis problemu]
  #v(0.55em)
  #text(22pt, weight: "bold", fill: accent)[
    Podział pojemności łączy w sieci autonomicznej
  ]
  #v(0.7em)
  #text(11pt, fill: muted)[
    Specjalistyczne technologie w sieciach informatycznych nowej generacji
  ]
  #v(0.65em)
  #line(length: 100%, stroke: 0.8pt + line-col)
  #v(0.55em)
  #text(11.5pt)[
    D. Gąsior, M. Drwal, _Pareto-optimal Nash equilibrium in capacity allocation game for self-managed networks_, Computer Networks 57 (2013), 2817–2832. DOI: 10.1016/j.comnet.2013.06.012
  ]
  #v(0.45em)
  #text(12pt)[Grupa: #group]
  #v(0.7em)
  #text(10.5pt, fill: muted)[
    *Zastosowanie AI.* Do utworzenia i skomponowania prezentacji zostało wykorzystane AI. ]]


// ============================================================
// 2. Opis
// ============================================================

#slide[1. Opis problemu i kontekst][
  Współczesne sieci szkieletowe i systemy autonomiczne (AS) obsługują tysiące jednoczesnych transmisji danych. W takich środowiskach centralne zarządzanie podziałem pasma staje się niemożliwe ze względu na skalę, a koszty manualnej konfiguracji przez administratorów stale przewyższają ceny samego sprzętu. Wymusza to przejście na paradygmat *sieci autonomicznych* (*self-managed networks*), w których urządzenia sieciowe same optymalizują swoje parametry.

  #v(0.4em)
  W rozpatrywanym problemie trasy wszystkich przepływów są z góry ustalone. Zadanie sprowadza się do wyznaczenia alokacji przepustowości łączy (problem _NUM_), tak aby zmaksymalizować łączną efektywność transmisji przy zachowaniu ograniczeń fizycznych infrastruktury.

  #v(0.4em)
  #card[
    *Podstawowy problem:* Rzeczywista szybkość transmisji jest ograniczona przez najwęższe gardło na trasie ($x_r = min_l s_(l r)$). Samodzielny podział pasma na pojedynczym łączu prowadzi do marnotrawstwa zasobów, a nadmiarowa pojemność przyznana zablokowanemu przepływowi przepada, zamiast zasilić inne, lokalne połączenia.
  ]
]

// ============================================================
// 3. Znaczenie problemu
// ============================================================

#slide[2. Wyjaśnienie znaczenia problemu][
  #set list(spacing: 0.85em)
  - *Skalowalność i eliminacja centralnego zarządcy* \
    W wielkich sieciach operatorskich (AS, ISP) ze względu na liczbę przepływów niemożliwe jest globalne wyliczanie alokacji w czasie rzeczywistym. Decyzje muszą zapadać lokalnie na poziomie routerów.

  - *Rosnące koszty operacyjne (OPEX)* \
    Koszt pracy administratorów i ręcznej konfiguracji urządzeń przewyższa obecnie ceny samego sprzętu. Samoregulacja (*self-management*) pozwala ograniczyć rolę człowieka do zadania polityki działania sieci.

  - *Odzyskiwanie marnowanego pasma (bottleneck)* \
    Niezależny podział pasma na łączach powoduje straty: nadmiar przepustowości oddany zablokowanej transmisji przepada. Właściwa koordynacja pozwala przesunąć te zasoby na przepływy lokalne.

  - *Ochrona przed samolubnością użytkowników* \
    Przeniesienie roli gracza z użytkownika końcowego na urządzenie operatora eliminuje ryzyko manipulacji i nadużyć pasma ze strony aplikacji klienckich.
]


#slide[3. Przykładowe zastosowania][
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    [
      #text(weight: "bold", fill: accent)[Domeny międzyoperatorskie (AS / ISP)]
      #v(0.3em)
      Optymalizacja przepustowości na łączach tranzytowych i stykowych przy z góry wyznaczonym routingu (BGP), gdzie poszczególne organizacje nie wymieniają się wewnętrznymi danymi o topologii.

      #v(1.1em)
      #text(weight: "bold", fill: accent)[Współpraca z protokołem TCP]
      #v(0.3em)
      Warstwa autonomiczna obok mechanizmów transportowych. Routery ustalają bezpieczne limity pasma dla zagregowanych przepływów ruchu, uwzględniając najsłabsze ogniwa na ich ścieżkach.
    ],
    [
      #text(weight: "bold", fill: accent)[Wirtualizacja sieci i Network Slicing]
      #v(0.3em)
      Autonomiczny podział pasma łączy fizycznych między niezależne sieci wirtualne (*slices*) o różnych profilach ruchu, eliminując konieczność ciągłej interwencji zarządcy wirtualizacji.

      #v(1.1em)
      #text(weight: "bold", fill: accent)[Sieci mobilne (Self-Organizing Networks)]
      #v(0.3em)
      Łącza dosyłowe (*backhaul*) w architekturach 4G LTE oraz 5G, gdzie lokalne węzły muszą samoczynnie równoważyć obciążenie przy dynamicznie zmieniającej się liczbie abonentów.
    ],
  )
]


#slide[4. Studium przypadku: Wymiana ruchu międzyoperatorskiego][
  #text(weight: "bold", fill: accent)[Węzły IXP i tranzyt między operatorami (np. DE-CIX, PLIX)]

  #v(0.3em)
  - *Sytuacja:* Niezależni operatorzy (ISP) wymieniają ze sobą terabity danych na sekundę. Trasy pakietów są z góry wyznaczone przez protokół BGP.
  #v(0.3em)
  - *Problem:* Operatorzy to konkurujące ze sobą firmy, gdzie żaden operator nie zgodzi się na zewnętrzny, centralny system sterujący jego routerami.
  #v(0.3em)
  - *Działanie algorytmu:* Router każdego operatora działa autonomicznie. Samodzielnie monitoruje swoje łącza wyjściowe i jeśli wykryje, że dany tranzyt jest spowalniany dalej przez wąskie gardło u obcego operatora, odbiera mu puste pasmo i alokuje je na rzecz *przepływów lokalnych* (transmisji kończących się wewnątrz własnej domeny).
]


#slide[5. Słownik pojęć i skrótów][
  #set text(11.5pt)
  #let term(abbrev, full, desc) = block(spacing: 0.55em)[
    #text(weight: "bold", fill: accent)[#abbrev]
    #if full != "" [ (#text(fill: muted, style: "italic")[#full]) ]
    --- #desc
  ]

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    [
      #term("Self-managed networks", "autonomic networks", [
        sieci autonomiczne (samosterujące); koncepcja, w której urządzenia same zarządzają swoimi zasobami i konfiguracją na podstawie ogólnych wytycznych administratora.
      ])

      #term("NUM", "Network Utility Maximization", [
        klasyczny problem optymalizacyjny polegający na maksymalizacji sumy funkcji użyteczności wszystkich przepływów przy ograniczeniach pojemności łączy.
      ])

      #term("Bottleneck", "wąskie gardło", [
        najwolniejsze łącze na trasie danego przepływu, które ogranicza jego maksymalną rzeczywistą przepustowość ($x_r = min_l s_(l r)$).
      ])

    ],
    [
      #term("AS", "Autonomous System", [
        system autonomiczny; spójny zbiór sieci i routerów IP pod wspólną administracją techniczną (np. duża sieć korporacyjna, uczelniana lub operator).
      ])

      #term("ISP", "Internet Service Provider", [
        dostawca usług internetowych; operator telekomunikacyjny zarządzający infrastrukturą transmisyjną i łączami tranzytowymi.
      ])

      #term("BGP", "Border Gateway Protocol", [
        podstawowy protokół routingu międzyoperatorskiego (zewnętrznego), odpowiedzialny za wymianę tras między różnymi systemami autonomicznymi (AS).
      ])

      #term("Backhaul", "sieć dosyłowa", [
        łącza transmisyjne łączące lokalne stacje dostępowe lub bazowe z główną siecią szkieletową operatora.
      ])

    ],
  )
]


#slide[5. Słownik pojęć i skrótów][
  #set text(11.5pt)
  #let term(abbrev, full, desc) = block(spacing: 0.55em)[
    #text(weight: "bold", fill: accent)[#abbrev]
    #if full != "" [ (#text(fill: muted, style: "italic")[#full]) ]
    --- #desc
  ]

  #term("IXP", "Internet Exchange Point", [
    punkt wymiany ruchu internetowego; fizyczna infrastruktura sieciowa umożliwiająca różnym operatorom (ISP) i dostawcom treści bezpośrednią, lokalną wymianę danych bez pośredników tranzytowych.
  ])

  #term("DE-CIX", "Deutscher Commercial Internet Exchange", [
    zlokalizowany we Frankfurcie jeden z największych na świecie punktów wymiany ruchu internetowego (IXP), obsługujący przepływy o natężeniu kilkunastu terabitów na sekundę.
  ])

  #term("PLIX", "Polish Internet eXchange", [
    największy w Polsce komercyjny punkt wymiany ruchu internetowego zlokalizowany w Warszawie, zrzeszający krajowych i międzynarodowych operatorów telekomunikacyjnych.
  ])
]
