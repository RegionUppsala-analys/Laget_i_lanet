# Dokumentation – R-skript för digital infrastruktur
*Uppsala län – bredband och mobiltäckning*

---

## Översikt

Projektet består av tre skript som tillsammans hämtar, bearbetar och visualiserar statistik om bredbandsutbyggnad och mobiltäckning i Uppsala läns kommuner. Data hämtas från Kolada och Post- och telestyrelsen (PTS).

| Skript | Syfte |
|---|---|
| `load_save_data.R` | Hämtar data från Kolada och PTS och sparar lokalt |
| `create_save_plots.R` | Skapar och sparar diagram |
| `create_tables.R` | Bearbetar PTS-data om mobiltäckning och sparar som RDS-filer för tabellrendering i Quarto |

---

## Gemensam konfiguration

Alla tre skript laddar gemensamma inställningar via:

```r
source("Script/install_load_packages.R")
source("Script/settings.R")
install_and_load()
settings <- get_settings()
```

Följande variabler används genomgående:

| Variabel | Beskrivning |
|---|---|
| `kommunkod` | Kommunkoder för Uppsala läns kommuner |
| `kommuner` | Kommunnamn |
| `kommun_colors` | Färgpalett per kommun |
| `lanskod` | Länets kod |
| `lan` | Länets namn |

`load_save_data.R` läser också in `riket_narliggande` (riket och närliggande regioner för jämförelser) och `search_kolada.R` (hjälpfunktion för att söka och hämta Kolada-data).

---

---

# `load_save_data.R` – Datainladdning

## Syfte

Hämtar statistik om bredband och mobiltäckning från Kolada och PTS och sparar som CSV- och Excel-filer i mappen `Data/` (skapas automatiskt). Varje funktion anropas direkt efter sin definition.

---

## Funktioner

### `func_df_internet()`
Hämtar andelen hushåll med tillgång till fast bredband om minst 100 Mbit/s per kommun, från år 2010 och framåt.

- **Källa:** Kolada (`"Tillgång till fast bredband om minst 100 Mbit/s, andel (%)"`)
- **Sparas som:** `Data/df_internet.csv`

---

### `func_df_internet_gb()`
Hämtar andelen hushåll med tillgång till eller möjlighet att ansluta till bredband om minst 1 Gbit/s, uppdelat på tre kategorier:

- Alla hushåll (totalt)
- Hushåll i tätbebyggt område
- Hushåll i glesbebyggt område

- **Källa:** Kolada (`"Hushåll med tillgång till eller möjlighet att ansluta till bredband om minst 1 Gbit/s"`)
- **Sparas som:** `Data/df_internet_gb.csv`

---

### `func_bredbandskollen()`
Hämtar genomsnittliga mätresultat från Bredbandskollen (Internetstiftelsen) per kommun, för fyra indikatorer:

- Nedströms hastighet via webb (Mbit/s)
- Uppströms hastighet via webb (Mbit/s)
- Nedströms hastighet via mobil (Mbit/s)
- Uppströms hastighet via mobil (Mbit/s)

- **Källa:** Kolada (`"Bredbandskollen, genomsnittligt"`)
- **Sparas som:** `Data/df_bredbandskollen.csv`

---

### `func_tackningsdata()`
Laddar ned två Excel-filer direkt från PTS:s webbplats:

1. **Mobiltäckning** – täckningsdata per operatör och område (tabellbilaga 1–3)
2. **Teknik** – hushållens tillgång till olika tekniker (4G, 5G, fiber m.m.)

- **Källa:** PTS statistikportal (`statistik.pts.se`)
- **Sparas som:** `Data/mobiltackning.xlsx`, `Data/teknik.xlsx`

---

---

# `create_save_plots.R` – Diagramskapande

## Syfte

Läser in lokalt sparad data och skapar interaktiva Plotly-diagram och statiska ggplot2-diagram. Statiska diagram sparas i `Figurer/` (skapas automatiskt) som SVG och PNG (96 dpi). Interaktiva objekt returneras för inbäddning i rapport.

---

## Funktioner

### `tillgang_bred()`
Interaktivt Plotly-linjediagram som visar andelen hushåll med tillgång till fast bredband (≥ 100 Mbit/s) per år för varje kommun i Uppsala. Alla kommuner visas i samma diagram med kommunspecifika färger. Unified hover visar alla kommuners värden simultant.

- **Indata:** `Data/df_internet.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

### `tillgang_bred_gb()`
Interaktivt Plotly-linjediagram som visar tillgången till gigabitbredband (≥ 1 Gbit/s) per kommun, med en dropdown-meny för att växla mellan de tre kategorierna (alla hushåll, tätbebyggt, glesbebyggt). Titeln och y-axeln uppdateras automatiskt vid val.

- **Indata:** `Data/df_internet_gb.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

### `bredbandskollen()`
Skapar ett statiskt ggplot2-linjediagram per kommun med mätresultat från Bredbandskollen. Diagrammet är uppdelat i två paneler (webb/mobil) och visar upp- och nedströms hastighet i Mbit/s som separata linjer med olika färger.

- **Indata:** `Data/df_bredbandskollen.csv`
- **Sparas som:** `Figurer/bredbandskollen_[KommunNamn].svg/.png`

---

### `femg()`
Skapar statiska ggplot2-stapeldiagram per bebyggelsetyp (tätbebyggt/glesbebyggt) som visar hushållens tillgång till 5G (NR) för senaste tillgängliga år. Varje diagram innehåller två paneler: andel (%) och absolut antal hushåll. Kommunerna sorteras i fallande bokstavsordning på y-axeln.

- **Indata:** `Data/teknik.xlsx` (flik 4)
- **Filter:** Kommuner i Uppsala, senaste år, exklusive totalnivå
- **Sparas som:** `Figurer/femg_[Område].svg/.png` (ett diagram per bebyggelsetyp)

---

### `teknik()`
Skapar ett statiskt ggplot2-stapeldiagram per kommun som visar andelen hushåll med tillgång till olika tekniker (4G, 5G/NR, fiber, kabel m.m.) för senaste tillgängliga år. Endast tekniker med andel > 0 visas. Använder totalnivå (hela kommunen).

- **Indata:** `Data/teknik.xlsx` (flik 4)
- **Filter:** Kommuner i Uppsala, senaste år, `Område == "total"`
- **Sparas som:** `Figurer/teknik_[KommunNamn].svg/.png`

---

---

# `create_tables.R` – Tabellförberedelse

## Syfte

Bearbetar PTS:s mobiltäckningsdata från Excel-filen och sparar strukturerade RDS-filer som sedan används för att rendera tabeller direkt i Quarto-dokumentet. Inga tabeller renderas i detta skript – det fungerar enbart som databearbetningssteg.

---

## Funktioner

### `mobilt_agg_tbl()`
Läser in aggregerad mobiltäckningsdata (flik 3 i `mobiltackning.xlsx`) för alla operatörer sammantaget. Bearbetar den komplexa tvåradsrubriken (täckningstyp + år) och pivoterar till long-format för att sedan gå tillbaka till wide med åren som kolumner. Filtrerar på Uppsala läns länskod och kommunkoder.

**Bearbetning:**
- Rensas från specialtecken (`-`, `>`, `%`, kommatecken)
- Värden ≤ 1 multipliceras med 100 (konverterar decimaler till procent)
- Avrundas till 2 decimaler och förses med `%`-suffix
- Sorteras så att "Totalt alla områden" hamnar överst

- **Indata:** `Data/mobiltackning.xlsx` (flik 3)
- **Sparas som:** `Data/mobilt_wide.rds`

---

### `mobilt_tbl()`
Läser in operatörsspecifik mobiltäckningsdata (flikar 4–7 i `mobiltackning.xlsx`) för Telenor, Tele2, Telia och Tre. Kör samma bearbetning som `mobilt_agg_tbl()` per operatör, men behåller bara det senaste tillgängliga årets kolumn och döper om den till operatörens namn. Slår ihop alla fyra operatörer till ett gemensamt dataset med `full_join`.

- **Indata:** `Data/mobiltackning.xlsx` (flikar 4–7)
- **Sparas som:** `Data/mobilt_wide_op.rds`

---

---

## Mappstruktur

```
Projektmapp/
├── Script/
│   ├── install_load_packages.R   # Pakethantering
│   ├── settings.R                # Regioninställningar
│   ├── search_kolada.R           # Hjälpfunktion för Kolada-sökningar
│   ├── load_save_data.R
│   ├── create_save_plots.R
│   └── create_tables.R
├── Data/                         # Skapas automatiskt
│   ├── df_internet.csv
│   ├── df_internet_gb.csv
│   ├── df_bredbandskollen.csv
│   ├── mobiltackning.xlsx        # Laddas ned av func_tackningsdata()
│   ├── teknik.xlsx               # Laddas ned av func_tackningsdata()
│   ├── mobilt_wide.rds           # Genereras av create_tables.R
│   └── mobilt_wide_op.rds        # Genereras av create_tables.R
└── Figurer/                      # Skapas automatiskt – SVG och PNG
```

---

## Datakällor

| Källa | Typ av data |
|---|---|
| Kolada | Bredband ≥ 100 Mbit/s, gigabitbredband (tätt/glesbebyggt), Bredbandskollen |
| PTS (direktnedladdning) | Mobiltäckning per operatör och område, tekniktyper per hushåll |

---

## Körordning

Skripten bör köras i följande ordning:

1. `load_save_data.R` – hämtar och sparar all rådata
2. `create_tables.R` – bearbetar mobiltäckningsdata till RDS-filer
3. `create_save_plots.R` – skapar diagram baserade på sparad data