// Etap 1 — opis słowny problemu.
// Kompilacja: typst compile prez.typ prez.pdf
//
// Całość treści slajdów została uzyskana z wykorzystaniem AI
// na podstawie artykułu Gąsior, Drwal (Computer Networks, 2013).
// Przed wysłaniem uzupełnij skład grupy.

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
      [Całość treści slajdów uzyskana z wykorzystaniem AI. Źródło merytoryczne: Gąsior, Drwal (2013).],
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
#tag[Etap 1 · opis problemu]
#v(0.55em)
#text(22pt, weight: "bold", fill: accent)[
  Podział pojemności łączy w sieci autonomicznej
]
#v(0.28em)
#text(13pt)[
  Gra o alokację przepustowości i równowaga, której nie opłaca się porzucać
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
  *Zastosowanie AI.* Całość treści tych slajdów została uzyskana z wykorzystaniem AI na podstawie artykułu. Stopka jest na każdym slajdzie. Skład grupy sprawdza treść przed zaliczeniem.
]
]


// ============================================================
// 3. Opis
// ============================================================

#slide[Opis problemu][
  Sieć składa się z łączy o skończonej pojemności i z przepływów,
  czyli transmisji o *ustalonej trasie*. Routing jest już wybrany.
  Przedmiotem decyzji nie jest ścieżka, tylko *porcja pojemności*,
  jaką każde łącze oddaje każdemu przepływowi, który przez nie przechodzi.

  #v(0.45em)
  Każdy przepływ ma użyteczność: szybciej jest lepiej, ale kolejny przyrost
  szybkości daje coraz mniejszy zysk. W artykule ta funkcja jest też czytana
  jako skłonność użytkownika do zapłaty operatorowi. Rozważane funkcje
  prowadzą do podziału *proporcjonalnie sprawiedliwego*.

  #v(0.45em)
  #card[
    *Cel globalny* (network utility maximization): dobrać szybkości tak,
    by suma użyteczności była jak największa i żadne łącze nie dostało
    więcej ruchu, niż ma pojemności.
  ]
  #v(0.45em)
  Szybkość przepływu wyznacza *najmniejsza* porcja przyznana mu na trasie.
  Pojemność oddana ponad to wąskie gardło przepada.
]

// ============================================================
// 4. Dlaczego gra
// ============================================================

#slide[Skąd bierze się gra][
  Przy skali operatora nikt nie ustawia wszystkich szybkości naraz.
  Decyzja zapada na routerze, z wiedzy lokalnej i krótkiego sygnału o zatorze.

  #v(0.4em)
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.7em,
    card[
      *Typowy model*\
      Graczem jest użytkownik albo źródło. Wybiera trasę lub szybkość
      i dba tylko o siebie. Tak działają gry zatorowe i gry o routing.
    ],
    card[
      *Model z artykułu*\
      Graczem jest łącze: interfejs wyjściowy routera.
      Pojemność rozdaje urządzenie operatora, nie aplikacja.
    ],
  )
  #v(0.5em)
  Routery mogą należeć do *różnych organizacji* i nie muszą liczyć alokacji
  tym samym algorytmem. Każde łącze dba o usługi na własnych interfejsach.
  Samo optimum centralne tego nie opisuje: potrzebny jest stan, z którego
  *żadnemu łączu nie opłaca się odejść w pojedynkę*.
]

// ============================================================
// 5. Gra opisowo
// ============================================================

#slide[Gra o pojemność, bez wzorów][
  #term[Gracz][jedno łącze.]
  #term[Strategia dopuszczalna][
    podział pojemności tego łącza między jego przepływy.
    Suma porcji nie przekracza pojemności. Cudzym przepływom łącze nic nie daje.
  ]
  #term[Profil strategii][zestaw podziałów wszystkich łączy.]
  #term[Wypłata łącza][
    ocena *rzeczywistych* szybkości przepływów przez to łącze.
    Szybkość to minimum po całej trasie, więc łącze nie zyskuje na porcji,
    której wąskie gardło dalej i tak nie przepuści.
  ]
  #v(0.15em)
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.7em,
    card[
      *Wagi równe*\
      Każdy przepływ tak samo wchodzi do wypłaty łącza.
    ],
    card[
      *Wagi odwrotne do długości trasy*\
      Długi przepływ liczy się słabiej. Przy tych wagach suma wypłat
      pokrywa się z celem globalnym.
    ],
  )
]

// ============================================================
// 6. Czego szukamy
// ============================================================

#slide[Jakie rozwiązanie jest dobre][
  #card[
    *Równowaga Nasha w strategiach czystych.*
    Przy niezmienionych decyzjach pozostałych żadne łącze nie podniesie
    własnej wypłaty, zmieniając swój podział.
  ]
  #v(0.45em)
  #card[
    *Silna optymalność w sensie Pareta.*
    Nie ma innego podziału, przy którym czyjaś wypłata rośnie,
    a niczyja nie maleje.
  ]
  #v(0.5em)
  Artykuł podaje rozproszony sposób liczenia, który taki stan znajduje.
  Podział „każde łącze raz, tylko u siebie” równowagą być nie musi:
  łącze za wąskim gardłem woli oddać wolną pojemność przepływom lokalnym.

  #v(0.35em)
  *Cena stabilności* i *cena anarchii* mierzą, jak daleko równowaga odchodzi
  od optimum centralnego. Przy wagach równych optimum samo jest równowagą,
  więc cena stabilności wynosi 1. Bez przepływów lokalnych istnieją też
  równowagi dowolnie złe.
]

// ============================================================
// 7. Przykład
// ============================================================

#slide[Przykład: wąskie gardło i puste oddanie pojemności][
  Dwa łącza w szeregu, pojemności 10 i 100. Trzy przepływy: jeden przez oba
  łącza oraz po jednym lokalnym. Użyteczność logarytmiczna, wagi równe.

  #v(0.4em)
  #table(
    columns: (1.45fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center),
    stroke: 0.5pt + line-col,
    inset: (x: 7pt, y: 5pt),
    table.header(
      text(weight: "bold", fill: accent)[Łącze],
      text(weight: "bold", fill: accent)[wspólny],
      text(weight: "bold", fill: accent)[lokalny na 1],
      text(weight: "bold", fill: accent)[lokalny na 2],
    ),
    [1 · pojemność 10], [5], [5], [—],
    [2 · krok lokalny], [50], [—], [50],
    [2 · po korekcie], [5], [—], [95],
  )
  #v(0.4em)
  Po kroku lokalnym wspólny przepływ i tak płynie z szybkością 5.
  Łącze szybkie oddało mu 45 jednostek, których nie użyje.
  Gdy *samo* zmieni podział na 5 i 95, jego wypłata rośnie
  (logarytm z 95 zamiast z 50), a łącze wolne nic nie robi.
  To nie jest równowaga. Algorytm z artykułu zatrzymuje się właśnie
  na podziale (5, 5) oraz (5, 95): szybkości wynoszą 5, 5 i 95.
]

// ============================================================
// 8. Znaczenie
// ============================================================

#slide[Dlaczego ten problem jest ważny][
  #list(
    [*Koszt obsługi przez ludzi.* Utrzymanie sieci przez administratorów rośnie wobec ceny urządzeń. W sieci autonomicznej człowiek określa cel, a urządzenia mają go realizować.],
    [*Skala.* W systemie autonomicznym albo u operatora przepływów jest za dużo na jeden centralny rachunek w każdej chwili. Protokół ma działać na routerze.],
    [*Wiele organizacji.* Sąsiednie routery nie muszą ufać wspólnemu algorytmowi. Analiza równowagi mówi, co zostaje, gdy każdy dba o własne interfejsy.],
    [*Luka lokalnej sprawiedliwości.* Równy podział na jednym interfejsie nie widzi, że część pojemności i tak utknie na wolniejszym łączu dalej.],
    [*Jakość równowagi nie jest oczywista.* Przy równych wagach optimum społeczne jest równowagą. W innych układach równowaga może być od niego dowolnie daleko.],
  )
]

// ============================================================
// 9. Zastosowania
// ============================================================

#slide[Gdzie ten opis się stosuje][
  #list(
    [*Sieć operatora z ustalonym routingiem.* Spór dotyczy podziału pojemności interfejsów, nie wyboru trasy przez aplikację.],
    [*Sterowanie szybkością obok klasycznego TCP.* TCP realizuje pewną użyteczność użytkowników. Tu decyzję o porcjach pojemności podejmują łącza i widzą całą trasę przez minimum.],
    [*Routery autonomiczne.* Administrator podaje cel (rodzaj użyteczności i wagi). Interfejsy same poprawiają podział, gdy wykryją, że przepływ już stanął na innym łączu.],
    [*Fragment szeregowy większej sieci.* Jeden przepływ długi i przepływ lokalny na każdym łączu. Dla takiej budowy artykuł opisuje, jak zła może być najgorsza równowaga.],
  )
  #v(0.35em)
  #text(11.5pt, fill: muted)[
    Pokrewne, ale osobne modele: podział klas jakości usług, pojemność sieci
    wirtualnych, dostęp bezprzewodowy. W tej pracy trasa jest dana,
    a gra toczy się o pojemność łącza.
  ]
]

// ============================================================
// 10. Słownik 1
// ============================================================

#slide[Słownik][
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.9em,
    [
      #term[Sieć autonomiczna][
        urządzenia same realizują cel administratora, przy ograniczonej koordynacji.
      ]
      #term[Przepływ][transmisja o z góry wybranej trasie.]
      #term[Alokacja][porcje pojemności łącza oddane jego przepływom.]
      #term[Wąskie gardło][
        łącze, które na trasie przyznaje najmniej i wyznacza szybkość.
      ]
      #term[Przepływ nasycony][
        doszedł już do swojego minimum na trasie i nie przyspieszy.
      ]
      #term[Użyteczność][
        rosnąca, wklęsła ocena szybkości; także skłonność do zapłaty.
      ]
    ],
    [
      #term[Użyteczność izoelastyczna][
        rodzina funkcji dająca podział proporcjonalnie sprawiedliwy.
        Szczególny przypadek: logarytm.
      ]
      #term[NUM][
        maksymalizacja sumy użyteczności przepływów
        przy pojemnościach łączy.
      ]
      #term[Gracz][
        łącze, nie użytkownik końcowy.
      ]
      #term[Strategia][
        dopuszczalny podział pojemności jednego łącza.
      ]
      #term[Wypłata][
        użyteczność szybkości przepływów przez dane łącze,
        z wagą przepływu.
      ]
      #term[Dobrobyt społeczny][
        suma użyteczności wszystkich przepływów.
        To ten sam cel co NUM.
      ]
    ],
  )
]

// ============================================================
// 11. Słownik 2 + dalej
// ============================================================

#slide[Słownik i co dalej][
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.9em,
    [
      #term[Czysta równowaga Nasha][
        profil, z którego żaden gracz nie odejdzie sam,
        bo własnej wypłaty nie podniesie.
      ]
      #term[Silne optimum Pareta][
        nie da się komuś poprawić, nikomu nie pogarszając.
      ]
      #term[Cena stabilności][
        ile razy najlepszy dobrobyt jest lepszy od najlepszej równowagi.
      ]
      #term[Cena anarchii][
        ile razy najlepszy dobrobyt jest lepszy od najgorszej równowagi.
      ]
    ],
    card[
      #text(11.5pt)[
        *Na etap 2.* Zmienne, ograniczenia pojemności, kryterium wzorami, gracze, strategie, wypłaty.
        #v(0.4em)
        *Na etap 3.* Algorytm i szukanie równowagi. Krok lokalny nie wystarcza. Krok iterowany widzi, które przepływy już stanęły.
        #v(0.4em)
        *Obok artykułu.* Kelly, Maulloo, Tan (1998): NUM. Kephart, Chess (2003): autonomic computing.
      ]
    ],
  )
]
