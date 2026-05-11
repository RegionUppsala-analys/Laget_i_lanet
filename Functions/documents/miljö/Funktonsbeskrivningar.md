# Dokumentation – R-skript för miljö- och naturanalys
*Uppsala län – avfall, vatten, natur, skog och miljömål*

---

## Översikt

Projektet består av fem skript som tillsammans hämtar, bearbetar och visualiserar statistik om miljö och natur i Uppsala läns kommuner. Data hämtas från Kolada, SCB, Naturvårdsverket (GIS/GML), Skogsstyrelsen, SGU, Länsstyrelsen (RUS) och EU:s föroreningsdatabas (E-PRTR).

| Skript | Syfte |
|---|---|
| `load_save_data.R` | Hämtar data från externa API:er och sparar lokalt |
| `create_save_plots.R` | Skapar och sparar diagram och interaktiva kartor |
| `create_tables.R` | Skapar `gt`- och `reactable`-tabeller |
| `load_geodata.R` | Hjälpfunktion för att ladda ned GML/ZIP-filer via Atom-feeds |
| `skrapare.R` | Skrapar miljömålsbedömningar från RUS webbplats |

---

## Gemensam konfiguration

`load_save_data.R`, `create_save_plots.R`, `create_tables.R` och `skrapare.R` laddar inställningar via:

```r
source("Script/install_load_packages.R")
source("Script/settings.R")
source("Script/search_kolada.R")   # endast load_save_data.R
source("Script/load_geodata.R")    # endast load_save_data.R
install_and_load()
settings <- get_settings()
```

Variabler som används:

| Variabel | Beskrivning |
|---|---|
| `kommunkod` | Kommunkoder för Uppsala läns kommuner |
| `kommuner` | Kommunnamn |
| `kommun_colors` | Färgpalett per kommun |
| `lanskod` | Länets kod (används för geografisk filtrering) |
| `lan` | Länets namn |
| `riket_narliggande` | Riket och närliggande regioner (endast `load_save_data.R`) |

### Manuellt hanterad data

| Data | Källa | Notering |
|---|---|---|
| Förorenade områden | Naturvårdsverket (CSV) | Laddas ned manuellt och sparas som `data-och-statistik-fororenade-omraden-fororenade-omraden-.csv` |
| GML/GIS-filer (skyddade områden, produktionsanläggningar) | Naturvårdsverket Atom-feed | Laddas ned via `load_geodata_atom()` i ett separat steg |
| Grundvattenkvalitet (GML+CSV) | SGU | Laddas ned manuellt: `grundvattenkvalitet_analysresultat_provplatser.gpkg` och `analys_grundvatten.csv` |

---

---

# `load_save_data.R` – Datainladdning

## Syfte

Hämtar miljö- och naturstatistik från SCB, Kolada och Skogsstyrelsen och sparar som CSV-filer i `Data/`. Varje funktion anropas direkt efter sin definition. Laddar även in `load_geodata.R` som källfil.

---

## Geografiska filer

Hämtar DeSO-geografifiler via GitHub-skript och laddar ned SCB:s kommungränser (SWEREF99TM) till `Data/Kommun_Sweref99TM/` och `Data/Lan_Sweref99TM/`. Existenskontroll finns för ZIP-filen.

---

## SCB – Areal

### `func_df_deso_land_vatten()`
Hämtar land- och vattenarealdata (hektar) per arealtyp för alla DeSO-koder i Uppsala län. Filtrerar på koder som börjar med `lanskod` (t.ex. `"03"`).

- **SCB-tabell:** Areal2025 (MI0802)
- **Sparas som:** `Data/df_deso_land_vatten.csv`

---

### `func_markanvandning()`
Hämtar markanvändning (hektar) per kommun för sex klasser: total jordbruksmark, total skogsmark, bebyggd och anlagd mark, öppen myrmark, övrig mark och total landareal. Pivoteras till wide-format och beräknar andelar av total landareal per klass.

- **SCB-tabell:** MarkanvN (MI0803A)
- **Sparas som:** `Data/df_markanvandning.csv`

---

## Kolada – Avfall

### `func_df_avfall()`
Hämtar tre avfallsmått per kommuner: andelen kommunalt avfall till materialåtervinning (inkl. biologisk behandling, %), avfall till deponi (kg/inv) och totalt insamlat avfall (kg/inv). Rensar med `str_squish()` för exakt titelsmatchning.

- **Sparas som:** `Data/df_avfall.csv`

---

### `func_df_matavf()`
Hämtar insamlat mat- och restavfall (kg/inv) per kommuner.

- **Sparas som:** `Data/df_matavf.csv`

---

### `func_df_returpapp()`
Hämtar insamlade förpackningar och returpapper (kg/inv) per kommuner.

- **Sparas som:** `Data/df_returpapp.csv`

---

### `func_df_grovt()`
Hämtar insamlat grovavfall (kg/inv) per kommuner.

- **Sparas som:** `Data/df_grovt.csv`

---

### `func_df_farligt()`
Hämtar insamlat farligt avfall, inklusive elavfall och batterier (kg/inv) per kommuner.

- **Sparas som:** `Data/df_farligt.csv`

---

### `func_df_avfall_avgift()`
Hämtar avgiften för avfallshämtning (ny definition, kr/kvm inkl. moms) för typfastighet enligt Nils Holgersson-modellen per kommuner.

- **Sparas som:** `Data/df_avfall_avgift.csv`

---

### `func_df_avfall_kost()`
Hämtar bruttokostnad och nettokostnad för avfallshantering (kr/inv) per kommuner.

- **Filter:** `title %in% c("Kostnad avfallshantering, kr/inv", "Nettokostnad avfallshantering, kr/inv")`
- **Sparas som:** `Data/df_avfall_kost.csv`

---

## Kolada – Natur

### `func_df_skyddad_natur()` 
**Första definitionen** hämtar andelen skyddad natur per typ (land, hav, inlandsvatten, %). Filtrerar på tre specifika titlar.

- **Sparas som:** `Data/df_skyddad_natur.csv`

**Andra definitionen** (skriver över den första) hämtar medelavstånd till skyddad natur (km) per kommuner.

- **Sparas som:** `Data/df_avstand_natur.csv`


### `func_df_miljokval()`
Hämtar Miljökvalitet – Kommunindex för alla kommuner i Sverige.

- **Sparas som:** `Data/df_miljokval.csv`

---

### `func_df_hallbarhet()`
Hämtar Miljömässig hållbarhet – Kommunindex för alla kommuner i Sverige.

- **Sparas som:** `Data/df_hallbarhet.csv`

---

### `func_ekomark()`
Hämtar andelen ekologiskt brukad åkermark (%) per kommuner.

- **Sparas som:** `Data/df_eko.csv`

---

### `func_slatterang()`
Hämtar slåtteräng i hektar och andel (%) per kommuner.

- **Sparas som:** `Data/df_slatt.csv`

---

### `func_df_betesmark()`
Hämtar total betesmark i hektar och andel (%) per kommuner.

- **Sparas som:** `Data/df_betesmark.csv`

---

### `func_eko_sjo()`
Hämtar andelen sjöar, vattendrag och kustvatten med god ekologisk status (%) per kommuner.

- **Sparas som:** `Data/df_ekovatten.csv`

---

## Skogsstyrelsen

### `func_kalmarksareal()`
Hämtar statistik om sammanhängande kalmarksareal (hektar) – medel, median och 95:e percentil – per region och år. Filtrerar bort aggregerade landsdelsregioner (Götaland, Svealand m.fl.).

- **Källa:** Skogsstyrelsens PxWeb API (JO1403_8.a.px)
- **Sparas som:** `Data/df_kalmarksareal.csv`

---

### `func_skogsareal()`
Hämtar produktiv skogsmarksareal, medelbrukningsenhet och medianbrukningsenhet per Uppsala-kommuner, från år 2005 och framåt.

- **Källa:** Skogsstyrelsens PxWeb API (PX12.px)
- **Sparas som:** `Data/df_prod_skog.csv`

---

## Kolada – Vatten

### `func_vatten_kolada()`
En sammanslagen funktion med fem inbäddade block som hämtar:

| Block | Data | Sparas som |
|---|---|---|
| 1 | Avgift för vatten och avlopp inkl. moms (kr/kvm, Nils Holgersson) | `Data/avgift_vatten_NHM.csv` |
| 2 | Investeringsutgifter vattenförsörjning och avloppshantering (kr/inv) | `Data/investering_vatten.csv` |
| 3 | Vattenanvändning totalt, hushåll, jordbruk, industri och övrig (kbm/inv) | `Data/vattenanvandning.csv` |
| 4 | Nettokostnad vattenförsörjning och avloppshantering (kr/inv) | `Data/nettokostnad_vatten.csv` |
| 5 | Grundvattenförekomster med god kemisk och kvantitativ status (%) | `Data/df_grund.csv` |

---

## Geodata (Naturvårdsverket)

### `geo_data()` *(wrapper-funktion)*
Wrapper-funktion skapad för att förhindra automatisk körning. Innehåller anrop till `load_geodata_atom()` för skyddade områden. Varje geodataladdning måste anropas **manuellt**:

```r
load_geodata_atom(
  url = 'https://geodata.naturvardsverket.se/atom/inspire/ps/SE_ProtectedSites_serviceFeed.xml',
  file_path = "Data/ProtectedSites"
)
```

- **Sparas under:** `Data/ProtectedSites/`

---

---

# `create_save_plots.R` – Diagramskapande

## Syfte

Läser in lokalt sparad data och skapar interaktiva Plotly-diagram och statiska ggplot2-diagram (sparas i `Figurer/` som SVG/PNG, 96 dpi) samt interaktiva Leaflet- och `mapview`-kartor (returneras för Quarto-inbäddning).

---

## Avfall

### `avfall()`
Interaktivt Plotly-linjediagram med tre avfallsmått (materialåtervinning %, deponi kg/inv, totalt insamlat kg/inv) per kommuner, med dropdown för att byta variabel. Y-axelns titel och diagramtiteln uppdateras automatiskt via `args` när variabel byts.

- **Indata:** `Data/df_avfall.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

### `Avfall_kategoori()`
Interaktivt Plotly-linjediagram med fyra avfallskategorier (mat-/restavfall, förpackningar/returpapper, grovavfall, farligt avfall) per kommuner, med dropdown för att byta kommun. Kategorierna färgkodas med `#4AA271`, `#F9B000`, `#8B4A9C` och `#6F787E`. Legenden visas horisontellt under diagrammet.

> **OBS!** Funktionsnamnet har ett stavfel: `Avfall_kategoori` (dubbelt o).

- **Indata:** `Data/df_matavf.csv`, `Data/df_returpapp.csv`, `Data/df_grovt.csv`, `Data/df_farligt.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

### `avfall_avgift()`
Statiskt ggplot2-stapeldiagram med avfallshämtningsavgiften (kr/kvm) per kommuner för senaste tillgängliga år.

- **Indata:** `Data/df_avfall_avgift.csv`
- **Sparas som:** `Figurer/avgift_avfall.svg/.png`

---

### `avfall_kostnad()`
Statiskt ggplot2-stapeldiagram med facets (Kostnad / Nettokostnad) för avfallshantering (kr/inv) per kommuner, senaste år. Y-axeln är fri per facet.

- **Indata:** `Data/df_avfall_kost.csv`
- **Sparas som:** `Figurer/kost_avfall.svg/.png`

---

## Miljö- och hållbarhetsindex

### `miljo_index()`
Statiskt ggplot2-stapeldiagram med Uppsala-kommunernas miljöindex för senaste år. Fyra referenslinjer visas: 25:e percentilen, 75:e percentilen, riksmaximum och riksminimum (beräknade på alla svenska kommuner). Etiketter placeras till höger via `coord_cartesian(clip = "off")`.

- **Indata:** `Data/df_miljokval.csv`
- **Filter:** `municipality_type == 'K'`, senaste år
- **Sparas som:** `Figurer/miljoindex.svg/.png`

---

### `hallbarhetsindex()`
Identiskt upplägg som `miljo_index()` men för hållbarhetsindex.

- **Indata:** `Data/df_hallbarhet.csv`
- **Sparas som:** `Figurer/hallbarhetsindex.svg/.png`

---

## Markanvändning

### `karta_skog()`
Interaktiv Leaflet-karta som visar andelen skogsmark per Uppsala-kommunerna, färgkodad med `viridis`-skala. Kommunnamn visas som fasta etiketter via `addLabelOnlyMarkers()`. Popup visar alla fem markanvändningsandelar.

- **Indata:** `Data/df_markanvandning.csv`, `Data/Kommun_Sweref99TM/Kommun_Sweref99TM.shp`
- **Filter:** Senaste 5-årsintervall
- **Returneras** som interaktiv Leaflet-karta.

---

### `karta_landareal()` *(ej klar)*
Interaktiv `mapview`-karta tänkt att visa andelen sjöareal per DeSO-område. Markerad som `###### EJ klar` i koden.

- **Indata:** `Data/df_deso_land_vatten.csv`, `Data/DeSO_2025.gpkg`
- **Returneras** som `mapview`-karta (ofullständig implementation).

---

## Natur

### `andel_skyddadnatur()`
Interaktivt Plotly-stapeldiagram med andelen skyddad natur (land, inlandsvatten, hav) per kommuner för senaste tillgängliga år, med dropdown för att byta kommun. Y-axeln är fast vid 0–100%.

- **Indata:** `Data/df_skyddad_natur.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

### `avstand_skyddadnatur()`
Statiskt ggplot2-stapeldiagram med medelavståndet till skyddad natur (km) per kommuner, senaste år.

- **Indata:** `Data/df_avstand_natur.csv`
- **Sparas som:** `Figurer/avstand_skyddadnatur.svg/.png`

---

### `ekomark()`
Statiskt ggplot2-stapeldiagram med andelen ekologiskt brukad åkermark (%) per kommuner, senaste år. Y-axeln är fast vid 0–50%.

- **Indata:** `Data/df_eko.csv`
- **Sparas som:** `Figurer/eko_mark.svg/.png`

---

### `betesmark()`
Statiskt ggplot2-stapeldiagram med facets (Andel % / Hektar) för total betesmark per kommuner, senaste år.

- **Indata:** `Data/df_betesmark.csv`
- **Sparas som:** `Figurer/betesmark.svg/.png`

---

### `slatt_mark()`
Statiskt ggplot2-stapeldiagram med facets (Andel % / Hektar) för slåtteräng per kommuner, senaste år.

- **Indata:** `Data/df_slatt.csv`
- **Sparas som:** `Figurer/slatterang.svg/.png`

---

### `skydd_karta()`
Interaktiv Leaflet-karta med tre typer av skyddade områden i Uppsala: naturreservat (grön), djur- och växtskyddsområden (röd) och kulturreservat (gul). Lagerkontrollen tillåter av/påslagning per typ.

- **Indata:** `Data/ProtectedSites/PS.protectedSites.NR.gml`, `PS.protectedSites.DVO.gml`, `PS.protectedSites.KR.gml`, länsgränser Shape-fil
- **Returneras** som interaktiv Leaflet-karta.

> **OBS!** GML-filerna måste finnas i `Data/ProtectedSites/` och laddas ned manuellt via `load_geodata_atom()`.

---

## Vatten

### `eko_vatten()`
Statiskt ggplot2-stapeldiagram per vattentyp (sjöar / vattendrag) för andelen med god ekologisk status (%) per kommuner, senaste år. Skapar en fil per vattentyp. Filtrerar bort kustvatten och nollvärden. Filnamnet byggs på första ordet i titeln (`str_split(t, " ")[[1]][1]`).

- **Indata:** `Data/df_ekovatten.csv`
- **Sparas som:** `Figurer/eko_vatten_Sjöar.svg/.png`, `Figurer/eko_vatten_Vattendrag.svg/.png`

---

### `avgift_vatten()`
Statiskt ggplot2-linjediagram med VA-avgiften (kr/kvm, Nils Holgersson-modellen) per kommuner och år.

- **Indata:** `Data/avgift_vatten_NHM.csv`
- **Sparas som:** `Figurer/avgift_vatten.svg/.png`

---

### `inv_vatten()`
Statiskt ggplot2-linjediagram med investeringsutgifterna för vattenförsörjning och avloppshantering (kr/inv) per kommuner och år. Filtrerar bort nollvärden.

- **Indata:** `Data/investering_vatten.csv`
- **Sparas som:** `Figurer/inv_vatten.svg/.png`

---

### `netto_vatten()`
Statiskt ggplot2-linjediagram med nettokostnaden för vattenförsörjning och avloppshantering (kr/inv) per kommuner och år.

- **Indata:** `Data/nettokostnad_vatten.csv`
- **Sparas som:** `Figurer/netto_vatten.svg/.png`

---

### `grundvatten_kolada()`
Statiskt ggplot2-linjediagram med facets per kommuner för andelen grundvattenförekomster med god kemisk och kvantitativ status (%) över tid. Y-axeln är fast vid 0–100%.

- **Indata:** `Data/df_grund.csv`
- **Sparas som:** `Figurer/grundvatten_kolada.svg/.png`

---

### `vattenanvändning()`
Interaktivt Plotly-linjediagram med fem vattenanvändningsmått (totalt, hushåll, jordbruk, industri, övrig, kbm/inv) per år för Uppsala och alla övriga svenska regioner, med dropdown för att byta mått. Uppsala markeras i mörkrosa med tjock linje; övriga regioner visas i grått.

- **Indata:** `Data/vattenanvandning.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

## Skog

### `kalmark()`
Interaktivt Plotly-linjediagram som visar medianen för sammanhängande kalmarksareal (hektar) för Uppsala och alla övriga svenska län. Övriga lä visas som grå bakgrundslinjer (ej i legenden), Uppsala markeras i mörkrosa med tjock linje och punkter.

- **Indata:** `Data/df_kalmarksareal.csv`
- **Filter:** `Variabel == 'Median'`
- **Returneras** som interaktivt Plotly-objekt.

---

### `prod_skog()`
Interaktivt Plotly-linjediagram med produktiv skogsmarksareal per kommuner, med dropdown för att välja variabel (medelbrukningsenhet, medianbrukningsenhet, antal brukningsenheter m.fl.). Y-axelns titel uppdateras automatiskt och ersätter interna variabelnamn med mer läslig text.

- **Indata:** `Data/df_prod_skog.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

## Förorenade produktionsanläggningar

### `prod_karta()`
Interaktiv Leaflet-karta som visar produktionsanläggningar (E-PRTR) i Uppsala med total utsläppsmängd (kg) som färgskala (vit → röd). Läser GML-filen från Naturvårdsverket och kopplar den mot en separat GML-fil med emissionsdata. Utsläpp summeras per anläggning (`localId`) över alla ämnen och medier.

- **Indata:** `Data/prodanlagg/pf.ProductionFacility.SWE.EPSG4258.gml`, `Data/prodanlagg/LCPEPRTR_2020_20210924_version_1.gml`, länsgränser Shape-fil
- **Returneras** som interaktiv Leaflet-karta.

> **OBS!** Emissionsfilen är från år 2020. Ny data kräver manuell filersättning och uppdatering av filnamnet i koden.

---

---

# `create_tables.R` – Tabellskapande

## Syfte

Skapar `gt`- och `reactable`-tabeller för miljörapporten. Tabeller renderas direkt i Quarto och sparas inte som filer.

---

## `rus_lansstyrelse(lan, year)`
Skapar en `gt`-tabell med Länsstyrelsens regionala bedömning av alla miljökvalitetsmål. Lägger till piltecken (🡅/🡇/🡆) till trendtexterna via `case_when()`. Färgkodar `Målbedömning`- och `Trend`-kolumnerna med faktordefinerade paletter:

- **Målbedömning:** grön = uppnås/nära, röd = uppnås ej, grå = ingen regional bedömning
- **Trend:** grön = positiv, röd = negativ/negativ utveckling, grå = neutral/oklar/ingen bedömning

| Parameter | Beskrivning |
|---|---|
| `lan` | URL-slug för länets RUS-sida (default `'uppsala-lan'`) |
| `year` | År som visas i undertiteln (default `'2025'`) |

- **Indata:** `Data/miljomal_[lan]_[year].csv` (genereras av `skrapare.R`)
- **Returneras** som `gt`-tabell.

---

## `riskomraden()`
Skapar en `gt`-tabell med antal riskklassade förorenade områden (riskklass 1–4) per Sveriges alla län. Flyttar Uppsala längst upp i tabellen. Färgkodar alla fyra riskklasskolumner med en grå–röd numerisk skala (högre antal = mörkare röd).

> **OBS!** Undertiteln innehåller ett hårdkodat år (`paste("År", 2015)`) som inte är en parameter. Kommentaren `##### Händra år här om data uppdateras` indikerar manuell uppdatering.

- **Indata:** `Data/data-och-statistik-fororenade-omraden-fororenade-omraden-.csv`
- **Returneras** som `gt`-tabell.

---

## `grundvatten_sort()`
Skapar en interaktiv `reactable`-tabell med grundvattenkvalitetsanalysresultat för provplatser i Uppsala. Visar senaste mätvärde per provplats och parameter. Raderna färgkodas från grönt (lågt värde) till rött (högt värde) baserat på normaliserade värden (0–1) inom varje parameter via `rescale()`. Provplatskolumnen är filtrerbar och sökbar. Tabellen pagineras (10/25/50 rader per sida).

- **Indata:** `Data/grundvatten/grundvattenkvalitet_analysresultat_provplatser.gpkg`, `Data/analys_grundvatten.csv`
- **Filter:** Enbart provplatser i Uppsala (filtrering på `lanskod`), enbart grundvatten (`properties.provtyp == 'grundvatten'`)
- **Returneras** som `reactable`-tabell.

---

---

# `load_geodata.R` – Geodatanedladdning via Atom-feeds

## Syfte

Fristående hjälpfunktion som automatiserar nedladdning av GML- och ZIP-filer från Atom-feeds (Inspire-standard). Används primärt för Naturvårdsverkets geodatatjänster. Laddas in via `source("Script/load_geodata.R")` i `load_save_data.R`.

Filen innehåller även en lokal `install_and_load()`-funktion med alla nödvändiga CRAN-paket för fristående körning.

---

## `load_geodata_atom(url, file_path)`

Laddar ned alla GML/ZIP-filer från en Atom-feed-URL och sparar dem i angiven mapp.

| Parameter | Beskrivning |
|---|---|
| `url` | URL till Atom-flödets servicefeed (XML) |
| `file_path` | Lokal mapp att spara filer i (skapas om den saknas med `dir.create`) |

### Pipeline

1. **Läser servicefeed** – Hämtar huvud-XML med `read_xml()`, extraherar namespace
2. **Hittar dataset-feeds** – Söker i `<content>`-noder (CDATA HTML) med regex efter `.xml`-URL:er, samt i `<link rel='alternate'>`-noder
3. **Loopar över dataset-feeds** – För varje feed:
   - Extraherar nedladdningslänkar (`.zip`, `.gml`, `.gml.gz`) från `<d1:id>`-noder med regex
   - Hoppar över redan nedladdade filer (filexistenskontroll)
   - Laddar ned med `download.file(mode = "wb")`
   - **Fallback:** Om nedladdningen misslyckas söker den i `<id>`-noder för alternativ URL och försöker på nytt
4. **Packar upp ZIP-filer** – Kör `unzip()` på alla ZIP-filer i mappen och tar bort dem efteråt
5. **Felhantering** – `tryCatch` på huvud-feed, varje dataset-feed och enskilda nedladdningar. Fel och varningar loggas med `message()` och körningen fortsätter med nästa objekt (`next`)

### Användningsexempel

```r
# Skyddade områden (naturreservat, DVO, kulturreservat)
load_geodata_atom(
  url = 'https://geodata.naturvardsverket.se/atom/inspire/ps/SE_ProtectedSites_serviceFeed.xml',
  file_path = "Data/ProtectedSites"
)

# E-PRTR produktionsanläggningar
load_geodata_atom(
  url = 'https://geodata.naturvardsverket.se/atom/inspire/pf/SE_PF_EURegistry_serviceFeed.xml',
  file_path = "Data/prodanlagg"
)
```

---

---

# `skrapare.R` – RUS Miljömålsskrapning

## Syfte

Skrapar Länsstyrelsens regionala årliga uppföljning av miljökvalitetsmålen (RUS) från `www.rus.se` och sparar resultatet som CSV för användning av `create_tables.R`.

---

## `rus_reader(lan, year)`

| Parameter | Beskrivning |
|---|---|
| `lan` | URL-slug för länets RUS-sida (default `'uppsala-lan'`) |
| `year` | Innevarande år – används i filnamnet (default `'2025'`) |

### Pipeline

1. Hämtar sidan med `read_html()`
2. Extraherar alla `h2`- och `h3`-rubriker (`.wp-block-heading`)
3. Börjar extrahera data **efter** rubriken "Generationsmålet" (hoppar över inledande text)
4. Itererar över varje `h2`-rubrik med `map_dfr()` – ett miljömål per rubrik
5. Per miljömål extraheras via `extract_section()`:
   - **Miljömål** – rubriktexten
   - **Målbedömning** – textraden direkt efter rubriken "Målbedömning"
   - **Trend** – textraden direkt efter rubriken "Miljötillstånd"
   - **Beskrivning** – all text före "Målbedömning" sammanslagen med `paste(collapse = " ")`
6. `h3`-noder hoppas över (returnerar `NULL`)

- **Sparas som:** `Data/miljomal_[lan]_[year].csv`

**Körning:**

```r
rus_reader(lan = 'uppsala-lan', year = '2025')
```

> **OBS!** Skraparen är beroende av RUS sidstruktur. Om webbsidan ändrar taggnamn, rubriktext ("Målbedömning"/"Miljötillstånd") eller HTML-upplägg slutar skraparen att fungera och behöver anpassas manuellt.

---

---

## Mappstruktur

```
Projektmapp/
├── Script/
│   ├── install_load_packages.R
│   ├── settings.R
│   ├── search_kolada.R
│   ├── load_geodata.R
│   ├── load_save_data.R
│   ├── create_save_plots.R
│   ├── create_tables.R
│   └── skrapare.R
├── Data/
│   ├── Kommun_Sweref99TM/              # SCB kommungränser
│   ├── Lan_Sweref99TM/                 # SCB länsgränser
│   ├── DeSO_2025.gpkg
│   │
│   │   # Automatiskt nedladdade (load_save_data.R):
│   ├── df_deso_land_vatten.csv
│   ├── df_markanvandning.csv
│   ├── df_avfall.csv
│   ├── df_matavf.csv / df_returpapp.csv / df_grovt.csv / df_farligt.csv
│   ├── df_avfall_avgift.csv / df_avfall_kost.csv
│   ├── df_skyddad_natur.csv / df_avstand_natur.csv
│   ├── df_miljokval.csv / df_hallbarhet.csv
│   ├── df_eko.csv / df_slatt.csv / df_betesmark.csv / df_ekovatten.csv
│   ├── df_kalmarksareal.csv / df_prod_skog.csv
│   ├── avgift_vatten_NHM.csv / investering_vatten.csv
│   ├── vattenanvandning.csv / nettokostnad_vatten.csv / df_grund.csv
│   │
│   │   # Genereras av skrapare.R:
│   ├── miljomal_[lan]_[year].csv
│   │
│   │   # Manuellt nedladdade:
│   ├── data-och-statistik-fororenade-omraden-fororenade-omraden-.csv
│   ├── grundvatten/
│   │   ├── grundvattenkvalitet_analysresultat_provplatser.gpkg
│   │   └── analys_grundvatten.csv
│   ├── ProtectedSites/                 # GML (laddas via load_geodata_atom)
│   │   ├── PS.protectedSites.NR.gml
│   │   ├── PS.protectedSites.DVO.gml
│   │   └── PS.protectedSites.KR.gml
│   └── prodanlagg/                     # GML (laddas via load_geodata_atom)
│       ├── pf.ProductionFacility.SWE.EPSG4258.gml
│       └── LCPEPRTR_2020_20210924_version_1.gml
└── Figurer/                            # Skapas automatiskt – SVG och PNG
```

---

## Datakällor

| Källa | Typ av data |
|---|---|
| SCB PxWeb API | Markanvändning (MI0803A), DeSO-areal (MI0802) |
| Kolada / Avfall Sverige | Avfallsstatistik, kostnader, avgifter |
| Kolada / SCB | Miljö- och hållbarhetsindex |
| Kolada / Naturvårdsverket | Skyddad natur, ekologisk mark, vatten |
| Kolada / SGU / Länsstyrelserna | Grundvattenförekomster med god status |
| Kolada / Jordbruksverket | Ekologisk åkermark, slåtteräng, betesmark |
| Kolada / Nils Holgersson gruppen | VA-avgifter |
| Skogsstyrelsen PxWeb API | Kalmarksareal, produktiv skogsmarksareal |
| Naturvårdsverket (Atom/GML) | Skyddade områden (Inspire PS), E-PRTR produktionsanläggningar |
| SGU (manuell) | Grundvattenkvalitetsanalys per provplats |
| Naturvårdsverket (manuell CSV) | Riskklassade förorenade områden |
| RUS / Länsstyrelsen (webbskrapning) | Regionala miljömålsbedömningar |

---

## Kända noteringar

| Skript | Notering |
|---|---|
| `create_save_plots.R` | `Avfall_kategoori()` har ett stavfel i funktionsnamnet (dubbelt o) |
| `create_save_plots.R` | `karta_landareal()` är markerad som "EJ klar" och saknar fullständig implementation |
| `create_tables.R` | `riskomraden()` har ett hårdkodat år (2015) i undertiteln – kommentaren anger manuell uppdatering |
| `create_tables.R` | `grundvatten_sort()` kräver manuellt nedladdad data från SGU – ingen automatisk nedladdningsfunktion finns |
| `create_save_plots.R` | `prod_karta()` är hårdkodad till emissionsfil från 2020 – ny data kräver manuell filersättning |
| `skrapare.R` | Skraparen är beroende av RUS HTML-struktur och kräver manuell anpassning om sidan ändras |