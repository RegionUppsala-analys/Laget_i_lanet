# Dokumentation – R-skript för trygghet och säkerhetsstatistik
*Uppsala län – BRÅ, NTU, räddningstjänst och ambulans*

---

## Översikt

Projektet består av tre delar som tillsammans laddar hem, bearbetar och visualiserar statistik om brottslighet, otrygghet och räddningstjänst i Uppsala läns kommuner. Data hämtas från BRÅ (direkt nedladdning), NTU (Nationella trygghetsundersökningen, inbäddad i BRÅ-filerna) och Kolada (MSB, SOS Alarm, Socialstyrelsen).

| Fil/skript | Syfte |
|---|---|
| `load_save_data.R` | Laddar ned BRÅ-indikatordata och hämtar Kolada-data, sparar lokalt |
| `create_save_plots.R` | Läser in sparad data och skapar diagram (SVG/PNG) och interaktiva Plotly-figurer |
| `survey_berakning.R` | Delad hjälpfunktion för viktade surveyskattningar (se separat avsnitt) |

---

## Gemensam konfiguration

Båda skripten laddar inställningar via:

```r
source("Script/install_load_packages.R")
source("Script/settings.R")
source("Script/search_kolada.R")
install_and_load()
settings <- get_settings()
```

Variabler som används:

| Variabel | Beskrivning |
|---|---|
| `kommunkod` | Kommunkoder för Uppsala läns kommuner |
| `kommuner` | Kommunnamn |
| `kommun_colors` | Färgpalett per kommun |
| `lan` | Länets namn (t.ex. `"Uppsala län"`) |

### Färgkonvention

BRÅ-diagrammen använder en utökad färgpalett:

```r
kommun_colors2 <- c(
  kommun_colors,
  setNames("#B81867", lan),   # Uppsala län – mörkrosa
  "Hela Riket" = "black"      # Riket – svart
)
```

---

## Datastruktur – BRÅ Excel-filer

BRÅ:s kommunspecifika indikatordata laddas ned som Excel-filer med filnamnskonventionen `Data/df_ind_[KommunNamn].xlsx`. Varje fil har ett fast sheet-schema:

| Sheet | Brottstyp |
|---|---|
| 2 | Skadegörelsebrott |
| 3 | Narkotikabrott |
| 4 | Våldsbrott utomhus, vuxna |
| 5 | Våld i nära relation (VINR), kvinnor |
| 6 | Våld i nära relation (VINR), män |
| 7 | Våld mot barn, inomhus, flickor |
| 8 | Våld mot barn, utomhus, flickor |
| 9 | Våld mot barn, inomhus, pojkar |
| 10 | Våld mot barn, utomhus, pojkar |
| 11 | Personrån, unga |
| 12 | Stöldbrott |
| 13 | Bilbrott |
| 14 | Bostadsinbrott |
| 15 | Trafikbrott |
| NTU-namngivna sheets | NTU-variabler (otrygghet, utsatthet, bostadsområde) |

Första raden i varje sheet hoppas över (`skip = 1`) och kolumn 1 döps om till `Region`. Data pivoteras till long-format med kolumnerna `Year` (heltal extraherat via regex) och `Type` (`"Antal"` eller `"Antal per 100 000"`).

Länet och Hela Riket exkluderas alltid från `Type == "Antal"` (absoluta tal), eftersom deras befolkningsstorlek gör jämförelse missvisande – de visas bara som rate per 100 000.

---

---

# `load_save_data.R` – Datainladdning

## Geografiska filer

### DeSO-geografi
Hämtar DeSO-geografifiler via ett externt GitHub-skript. Laddar bara ned om filer saknas.

```r
source("https://raw.githubusercontent.com/RegionUppsala-analys/.../get_deso.R")
func_deso()
```

---

## BRÅ-indikatorer

### `func_bra_indikatorer()`
Laddar ned BRÅ:s kommunspecifika indikatorexcelfiler för samtliga åtta kommuner i Uppsala län direkt från BRÅ:s webbplats. Varje fil har en hårdkodad direktlänk och sparas med kommunnamnet i filnamnet.

- **Källa:** `bra.se` (direktlänkar per kommun)
- **Kommuner:** Enköping, Tierp, Heby, Håbo, Knivsta, Uppsala, Älvkarleby, Östhammar

**Sparade filer:**

| Fil | Kommun |
|---|---|
| `Data/df_ind_Enköping.xlsx` | Enköping |
| `Data/df_ind_Tierp.xlsx` | Tierp |
| `Data/df_ind_Heby.xlsx` | Heby |
| `Data/df_ind_Håbo.xlsx` | Håbo |
| `Data/df_ind_Knivsta.xlsx` | Knivsta |
| `Data/df_ind_Uppsala.xlsx` | Uppsala |
| `Data/df_ind_Älvkarleby.xlsx` | Älvkarleby |
| `Data/df_ind_Östhammar.xlsx` | Östhammar |

> **OBS!** Länkarna är hårdkodade och innehåller tidsstämplar som troligtvis ändras när BRÅ publicerar ny data. Länkarna måste uppdateras manuellt vid varje ny nedladdning.

---

## Kolada – brottslighet

### `func_avvikelse_brott()`
Hämtar modellberäknade avvikelsevärden för anmälda våldsbrott och stöld-/tillgreppsbrott (kodade 0=Fler än, 1=Lika många, 2=Färre än förväntad nivå). Filtrerar på år efter 2008.

- **Källa:** Kolada (`"Avvikelse från modellberäknat värde för anmälda"`)
- **Sparas som:** `Data/df_avvikelse_brott.csv`

---

## Kolada – räddningstjänst och ambulans

### `func_larmbehandlingstid()`
Hämtar mediantid för larmbehandling (tid från larm till utlarmning) för räddningstjänst respektive ambulans, från år 2008 och framåt. Sparar två separata filer.

- **Källa:** Kolada
- **Sparas som:** `Data/df_larmbehandlingstid.csv`, `Data/df_larmbehandlingstid_ambulans.csv`

---

### `func_responstid_raddning()`
Hämtar medianresponstid (från 112-samtal till första resurs på plats) för räddningstjänst, från år 2008 och framåt.

- **Källa:** Kolada
- **Sparas som:** `Data/df_responstid.csv`

---

### `func_responstid_ambulans()`
Hämtar medianresponstid för ambulans, från år 2008 och framåt.

- **Källa:** Kolada
- **Sparas som:** `Data/df_responstid_ambulans.csv`

---

### `func_brander()`
Hämtar antal utvecklade bränder i byggnad per 1 000 invånare, från år 2008 och framåt. Filtrerar på den äldre variabeldefinitionen (`-2023`).

- **Källa:** Kolada (MSB)
- **Sparas som:** `Data/df_brander.csv`

> **OBS!** BRÅ/MSB har släppt en ny variabeldefinition för bränder. Den gamla (`-2023`) har längre tidsserie men annorlunda definition. Kommentaren i koden påpekar detta och att uppdatering kan behövas.

---

### `func_ivpa()`
Hämtar antal IVPA-insatser (i väntan på ambulans) per 1 000 invånare per kommun, från år 2008 och framåt.

- **Källa:** Kolada
- **Sparas som:** `Data/df_ivpa.csv`

---

### `func_kostnad_olycka()`
Hämtar kostnad för olyckor totalt (kr/invånare) per kommun, från år 2008 och framåt.

- **Källa:** Kolada (MSB)
- **Sparas som:** `Data/df_kost_olycka.csv`

---

### `func_avvikelse_olycka()`
Hämtar modellberäknade avvikelsevärden för sjukhusvårdade till följd av olyckor och för utvecklade bränder i byggnad (kodade 0/1/2 som brottsavvikelsen), från år 2008 och framåt.

- **Källa:** Kolada
- **Sparas som:** `Data/df_avvikelse_olycka.csv`

---

### `func_sjukhusvar_olycka()`
Hämtar antal sjukhusvårdade till följd av oavsiktliga skador (olyckor) per 1 000 invånare, från år 2008 och framåt.

- **Källa:** Kolada (Socialstyrelsen)
- **Sparas som:** `Data/df_sjukhusvar_olycka.csv`

---

---

# `create_save_plots.R` – Diagramskapande

## Syfte

Läser in BRÅ-indikatordata (kommunspecifika Excel-filer) och Kolada-CSV-filer och skapar diagram. Statiska ggplot2-diagram sparas som SVG och PNG (96 dpi) i `Figurer/`. Interaktiva Plotly-figurer returneras för inbäddning i rapport.

---

## BRÅ-indikatorer – anmälda brott

Alla BRÅ-funktioner nedan tar parametern `kommun = 'Uppsala'` (default) och skapar en fil per anropskommun. Diagrammet visar alltid kommunen, Uppsala län och Hela Riket. Facets delar diagrammet i `Antal` (gäller bara kommunen) och `Antal per 100 000` (alla tre nivåer). Y-axeln är fri per facet (`scales = "free_y"`).

---

### `skadebrott(kommun)`
Visar utvecklingen av anmälda skadegörelsebrott.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheet 2
- **Sparas som:** `Figurer/skadebrott_[Kommun].svg/.png`

---

### `narkotikabrott(kommun)`
Visar utvecklingen av anmälda narkotikabrott.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheet 3
- **Sparas som:** `Figurer/narkotikabrott_[Kommun].svg/.png`

---

### `vald_utomhus_vuxna(kommun)`
Visar utvecklingen av anmälda våldsbrott utomhus mot vuxna.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheet 4
- **Sparas som:** `Figurer/vald_vuxen_utomhus_[Kommun].svg/.png`

---

### `VINR_kvinnor(kommun)`
Visar utvecklingen av anmält våld i nära relation mot kvinnor.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheet 5
- **Sparas som:** `Figurer/VINR_k_[Kommun].svg/.png`

---

### `VINR_man(kommun)`
Visar utvecklingen av anmält våld i nära relation mot män.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheet 6
- **Sparas som:** `Figurer/VINR_m_[Kommun].svg/.png`

---

### `vald_barn(kommun)`
Kombinerar data från fyra sheets (7–10) och skapar ett diagram med fyra facets: våld inomhus flickor, våld utomhus flickor, våld inomhus pojkar, våld utomhus pojkar. Visar bara rate per 100 000 (absoluta tal filtreras bort). X-axeln visas i 45° vinkel.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheets 7–10
- **Sparas som:** `Figurer/vald_barn_[Kommun].svg/.png`

---

### `personran_av_barn(kommun)`
Visar utvecklingen av anmälda personrån mot unga.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheet 11
- **Sparas som:** `Figurer/personran_b_[Kommun].svg/.png`

---

### `stoldbrott(kommun)`
Visar utvecklingen av anmälda stöldbrott.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheet 12
- **Sparas som:** `Figurer/stoldbrott_[Kommun].svg/.png`

---

### `bilbrott(kommun)`
Visar utvecklingen av anmälda bilbrott.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheet 13
- **Sparas som:** `Figurer/bilbrott_[Kommun].svg/.png`

---

### `bostadsinbrott(kommun)`
Visar utvecklingen av anmälda bostadsinbrott.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheet 14
- **Sparas som:** `Figurer/bostadsinbrott_[Kommun].svg/.png`

---

### `trafikbrott(kommun)`
Visar utvecklingen av anmälda trafikbrott.

- **Indata:** `Data/df_ind_[Kommun].xlsx`, sheet 15
- **Sparas som:** `Figurer/trafikbrott_[Kommun].svg/.png`

---

## NTU – Nationella trygghetsundersökningen

NTU-data hämtas ur de kommunspecifika BRÅ-Excel-filerna via namngivna sheets (t.ex. `"Misshandel-NTU"`). Variablerna är grupperade i tre temaområden. Årsintervallen är tvååriga (t.ex. `2017/2018`).

### Temagrupper och ingående variabler

**Utsatthet för brott:**
Misshandel, Sexualbrott, Rån, Försäljningsbedrägeri, Kort/kreditbedrägeri, Cykelstöld

**Otrygghet och oro för brott:**
Otrygghet utomhus, Oro för misshandel, Oro för sexualbrott, Oro för rån, Oro för bostadsinbrott, Oro stöld/skadegörelse bil, Valt annan väg, Avstått aktivitet

**Problem i bostadsområdet:**
Skadegörelse, Klotter, Fortkörning, Störande körning, Påverkad av alkohol/droger, Gäng i området, Öppen narkotikahandel

---

### `NTU_all_regions(ntu_grupp)`
Interaktivt Plotly-linjediagram som visar NTU-data för alla kommuner i Uppsala (läst från alla `df_ind_*.xlsx`-filer i `Data/`), Uppsala län och Hela Riket. Dropdown-meny för att välja NTU-variabel. Åren förkortas till startåret (t.ex. `2017/2018` → `2017`). Titlarna är fullständiga metodbeskrivningar från NTU-dokumentationen.

- **Indata:** Alla `Data/df_ind_*.xlsx` (loopar med `purrr::map_dfr`)
- **Parameter:** `ntu_grupp` – en av tre temagrupper (se ovan)
- **Returneras** som interaktivt Plotly-objekt.

---

### `NTU(kommun, ntu_grupp)` *(används ej)*
Äldre version av NTU-diagrammet för en enskild kommun. Visar bara kommunen, Uppsala län och Hela Riket. Hårdkodad till 3 regioner i dropdown-logiken (`length(ntu_sheets)*3`), vilket kan ge fel om antalet regioner avviker.

> **Används ej** – ersatt av `NTU_all_regions()`.

---

### `NTU_choose_years(kommun, ntu_grupp, years)` *(används ej)*
Variant av `NTU()` som filtrerar på specifika årsintervall och visar stapeldiagram istället för linjer. Parametern `years` anger vilka årsintervall (t.ex. `c("2017/2018", "2022/2023")`) som ska inkluderas.

> **Används ej** – funktionaliteten är inte integrerad i rapporten.

---

## Kolada – brottslighet (avvikelsediagram)

### `avvikelse_vald()`
Skapar ett heat map-diagram (geom_tile) per variabel (våldsbrott resp. stöld/tillgreppsbrott) som visar om varje kommun har fler, lika många eller färre anmälda brott än modellberäknat värde, per år. Kommunerna sorteras i fallande bokstavsordning på y-axeln. Färgkodning: röd = fler än, blå = lika många, grön = färre än.

- **Indata:** `Data/df_avvikelse_brott.csv`
- **Sparas som:** `Figurer/avvikelse_brott_1.svg/.png`, `Figurer/avvikelse_brott_2.svg/.png`

---

## Kolada – räddningstjänst och ambulans

### `brandforsvar()`
Linjediagram per kommun över antal utvecklade bränder i byggnad per 1 000 invånare. Var 2:e år visas på x-axeln.

- **Indata:** `Data/df_brander.csv`
- **Sparas som:** `Figurer/brandforsvar.svg/.png`

---

### `ivpa()`
Linjediagram per kommun över antal IVPA-insatser per 1 000 invånare. Filtrerar på specifik variabeltitel. Var 2:e år visas på x-axeln.

- **Indata:** `Data/df_ivpa.csv`
- **Filter:** `title == "IVPA-insatser (i väntan på ambulans), antal/1000 inv"`
- **Sparas som:** `Figurer/ivpa.svg/.png`

---

### `responstid()`
Linjediagram per kommun över medianresponstid (minuter) för räddningstjänst. Var 2:e år visas på x-axeln.

- **Indata:** `Data/df_responstid.csv`
- **Sparas som:** `Figurer/responstid.svg/.png`

---

### `kostnad_olycka()`
Linjediagram per kommun över total olyckskostnad (kr/invånare). Var 2:e år visas på x-axeln.

- **Indata:** `Data/df_kost_olycka.csv`
- **Sparas som:** `Figurer/kostnad.svg/.png`

---

### `avvikelse_sjukhus()`
Samma heat map-upplägg som `avvikelse_vald()` men för olycksdata (sjukhusvårdade till följd av olyckor och bränder). NA-värden tas bort innan plottning. Skapar en fil per variabel (indexnumrerad).

- **Indata:** `Data/df_avvikelse_olycka.csv`
- **Sparas som:** `Figurer/avvikelse_raddning1.svg/.png`, `Figurer/avvikelse_raddning2.svg/.png`

> **OBS!** Filnamnet saknar understreck mellan `raddning` och siffran (t.ex. `avvikelse_raddning1` inte `avvikelse_raddning_1`).

---

### `olycka()`
Linjediagram per kommun över antal sjukhusvårdade till följd av oavsiktliga skador per 1 000 invånare. Filtrerar på specifik variabeltitel.

- **Indata:** `Data/df_sjukhusvar_olycka.csv`
- **Filter:** `"Sjukhusvårdade till följd av oavsiktliga skador (olyckor), antal/1000 inv"`
- **Sparas som:** `Figurer/olycka.svg/.png`

---

---



# `survey_berakning.R` – Surveyberäkningar

## Syfte

Innehåller hjälpfunktionen `make_survey_plot_df()` som används för att beräkna viktade proportionsskattningar med konfidensintervall från enkätdata. Funktionen är utformad för att leverera ett plotklart dataframe.

------------------------------------------------------------------------

## `make_survey_plot_df(df, var, weight, group1, group2, psu = NULL, strata = NULL)`

Skapar ett long-format dataframe med proportionsskattningar och logit-baserade konfidensintervall per grupp och variabelnivå, med stöd för komplex surveydesign (vikter, PSU/kluster och strata).

### Parametrar

| Parameter | Typ | Beskrivning |
|------------------------|------------------------|------------------------|
| `df` | data.frame | Enkätdataframe |
| `var` | character | Variabelnamn att analysera (binär eller flernivå-faktor) |
| `weight` | character | Namn på kalibreringsviktvariabeln |
| `group1` | character | Första gruppvariabel (används för färg/facet) |
| `group2` | character | Andra gruppvariabel (används för facet) |
| `psu` | character | PSU/klustervariabel (valfri, default `NULL` → `~1`) |
| `strata` | character | Stratavariabel (valfri, default `NULL`) |

### Returnerar

Ett long-format dataframe med kolumnerna:

| Kolumn   | Beskrivning                                 |
|----------|---------------------------------------------|
| `group1` | Värde på första grupperingsvariabeln        |
| `group2` | Värde på andra grupperingsvariabeln         |
| `level`  | Nivå av den analyserade variabeln           |
| `prop`   | Skattad andel                               |
| `ci_l`   | Nedre konfidensintervallgräns (logit-metod) |
| `ci_u`   | Övre konfidensintervallgräns (logit-metod)  |

### Metod

Funktionen loopar över varje unik nivå av `var` och anropar `svyby()` + `svyciprop()` med `method = "logit"` separat. Denna approach ger robustare konfidensintervall nära 0 och 1 jämfört med lineariseringsmetoden. Resultaten slås ihop med `bind_rows()`.

### Exempel

``` r
plot_df <- make_survey_plot_df(
  df      = enkätdata,
  var     = "Hälsofråga",
  weight  = "wk",
  group1  = "Kön",
  group2  = "Åldersgrupp",
  psu     = "psu_variabel",
  strata  = "strata_variabel"
)
```

## Ej offentlig funktionalitet

Projektet innehåller ytterligare analys- och visualiseringsfunktioner som inte ingår i den publika dokumentationen.

Dessa komponenter behandlar känsliga eller sekretessreglerade data och har därför exkluderats från det öppna repositoriet. De omfattar bland annat:

- känsliga surveyvariabler

De interna funktionerna följer samma övergripande arkitektur som övriga diagramfunktioner:
- datainläsning
- transformation
- statistisk bearbetning
- ggplot-/plotly-baserad visualisering
- export till SVG/PNG

Publik dokumentation beskriver endast de delar som kan delas öppet utan risk för röjande av känslig information.


---

## Körordning och användning

### Körordning

Skripten bör köras i följande ordning:

1. `load_save_data.R` – laddar ned BRÅ-indikatorexcelfiler och hämtar all Kolada-data
2. `create_save_plots.R` – skapar alla diagram utifrån sparad data

`survey_berakning.R` laddas via `source()` i `create_save_plots.R` och behöver inte köras separat.

---

### Skapa diagram för en enskild kommun

BRÅ-diagramfunktionerna tar ett `kommun`-argument. För att skapa alla brottsdiagram för en specifik kommun anropas funktionerna med kommunnamnet som det stavas i filnamnet (matchar BRÅ:s namngivning):

```r
source("Script/create_save_plots.R")

# Byt ut "Enköping" mot valfri kommuns namn
skadebrott("Enköping")
narkotikabrott("Enköping")
vald_utomhus_vuxna("Enköping")
VINR_kvinnor("Enköping")
VINR_man("Enköping")
vald_barn("Enköping")
personran_av_barn("Enköping")
stoldbrott("Enköping")
bilbrott("Enköping")
bostadsinbrott("Enköping")
trafikbrott("Enköping")
```

Kommunnamnen måste stämma exakt med filnamnen i `Data/`:

```
Enköping, Tierp, Heby, Håbo, Knivsta, Uppsala, Älvkarleby, Östhammar
```

---

### Skapa NTU-diagram för alla kommuner

```r
# Välj ett av tre temaområden:
NTU_all_regions("Utsatthet för brott")
NTU_all_regions("Otrygghet och oro för brott")
NTU_all_regions("Problem i bostadsområdet")
```

Funktionen hittar automatiskt alla `df_ind_*.xlsx`-filer i `Data/` och kombinerar dem.

---

### Skapa Kolada-diagram

```r
avvikelse_vald()    # Heat map: avvikelse anmälda brott
avvikelse_sjukhus() # Heat map: avvikelse sjukhusvårdade/bränder
brandforsvar()
ivpa()
responstid()
kostnad_olycka()
olycka()
```

---

## Mappstruktur

```
Projektmapp/
├── Script/
│   ├── install_load_packages.R
│   ├── settings.R
│   ├── search_kolada.R
│   ├── survey_berakning.R
│   ├── load_save_data.R
│   └── create_save_plots.R
├── Data/
│   ├── df_ind_Enköping.xlsx          # BRÅ-indikatorfiler, en per kommun
│   ├── df_ind_Tierp.xlsx
│   ├── df_ind_Heby.xlsx
│   ├── df_ind_Håbo.xlsx
│   ├── df_ind_Knivsta.xlsx
│   ├── df_ind_Uppsala.xlsx
│   ├── df_ind_Älvkarleby.xlsx
│   ├── df_ind_Östhammar.xlsx
│   ├── df_avvikelse_brott.csv        # Kolada – avvikelse anmälda brott
│   ├── df_avvikelse_olycka.csv       # Kolada – avvikelse sjukhusvård/bränder
│   ├── df_brander.csv                # Kolada – utvecklade bränder
│   ├── df_ivpa.csv                   # Kolada – IVPA-insatser
│   ├── df_kost_olycka.csv            # Kolada – olyckskostnader
│   ├── df_larmbehandlingstid.csv     # Kolada – larmbehandlingstid räddning
│   ├── df_larmbehandlingstid_ambulans.csv
│   ├── df_responstid.csv             # Kolada – responstid räddning
│   ├── df_responstid_ambulans.csv    # Kolada – responstid ambulans
│   └── df_sjukhusvar_olycka.csv      # Kolada – sjukhusvårdade olyckor
└── Figurer/                          # Skapas automatiskt – SVG och PNG
    ├── skadebrott_[Kommun].svg/.png
    ├── narkotikabrott_[Kommun].svg/.png
    ├── vald_vuxen_utomhus_[Kommun].svg/.png
    ├── VINR_k_[Kommun].svg/.png
    ├── VINR_m_[Kommun].svg/.png
    ├── vald_barn_[Kommun].svg/.png
    ├── personran_b_[Kommun].svg/.png
    ├── stoldbrott_[Kommun].svg/.png
    ├── bilbrott_[Kommun].svg/.png
    ├── bostadsinbrott_[Kommun].svg/.png
    ├── trafikbrott_[Kommun].svg/.png
    ├── avvikelse_brott_1.svg/.png
    ├── avvikelse_brott_2.svg/.png
    ├── avvikelse_raddning1.svg/.png
    ├── avvikelse_raddning2.svg/.png
    ├── brandforsvar.svg/.png
    ├── ivpa.svg/.png
    ├── responstid.svg/.png
    ├── kostnad.svg/.png
    └── olycka.svg/.png
```

---

## Datakällor

| Källa | Typ av data |
|---|---|
| BRÅ (direktnedladdning) | Kommunspecifika brottsindikatorer och NTU-data (Excel) |
| Kolada / MSB | Avvikelse anmälda brott, bränder, IVPA, olyckskostnader |
| Kolada / SOS Alarm | Responstid och larmbehandlingstid, räddningstjänst och ambulans |
| Kolada / Socialstyrelsen | Sjukhusvårdade till följd av olyckor |

---

## Kända noteringar

| Skript | Notering |
|---|---|
| `load_save_data.R` | BRÅ-länkarna i `func_bra_indikatorer()` är hårdkodade med tidsstämplar och måste uppdateras manuellt vid varje ny datapublicering |
| `load_save_data.R` | MSB har publicerat ny variabeldefinition för bränder – koden filtrerar medvetet på den gamla (`-2023`) och kommentaren i koden påpekar detta |
| `create_save_plots.R` | `NTU()` och `NTU_choose_years()` är markerade som "Används ej" och ersätts av `NTU_all_regions()` |
| `create_save_plots.R` | `avvikelse_sjukhus()` sparar filer utan understreck före index: `avvikelse_raddning1` (inte `avvikelse_raddning_1`) – bör göras konsekvent med `avvikelse_brott_1` |
| `create_save_plots.R` | `larmbehandlingstid`-data laddas ned men ingen diagramfunktion för det finns i skriptet, lägg till! |
| `create_save_plots.R` | `responstid_ambulans`-data laddas ned men ingen diagramfunktion för det finns i skriptet, lägg till! |


