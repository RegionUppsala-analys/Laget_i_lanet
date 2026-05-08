# Dokumentation – R-skript för klimat- och energianalys
*Uppsala län*

---

## Översikt

Projektet består av tre skript som tillsammans hämtar, bearbetar och visualiserar statistik om klimat och energi för Uppsala läns kommuner. Data hämtas från Nationella emissionsdatabasen (SMHI), Energimyndigheten, SCB, Kolada, SLU och Konsumtionskompassen.

| Skript | Syfte |
|---|---|
| `load_save_data.R` | Hämtar data från externa källor och sparar lokalt |
| `create_save_plots.R` | Skapar och sparar diagram och interaktiva kartor |
| `create_tables.R` | Skapar interaktiva `gt`- och `reactable`-tabeller |

---

## Gemensam konfiguration

Alla tre skript laddar gemensamma inställningar via:

```r
source("Script/install_load_packages.R")
source("Script/settings.R")
source("Script/search_kolada.R")   # endast load_save_data.R
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
| `riket_narliggande` | Riket och närliggande regioner (endast `load_save_data.R`) |

Konstanten `mellan_sverige` definieras i `load_save_data.R` och används för att filtrera Energimyndighetens data till Uppsala och grannlän:

```r
mellan_sverige <- c("Uppsala län", "Södermanlands län", "Östergötlands län",
                    "Örebro län", "Västmanlands län", "Gävleborgs län", "Stockholms län")
```

### Manuellt hanterad data

Flera datakällor kräver manuell hantering vid uppdatering:

| Data | Källa | Åtgärd |
|---|---|---|
| Konsumtionskompassen (DeSO-utsläpp) | konsumtionskompassen.se | Laddas ned manuellt per kommun, sparas i `Data/` |
| Konsumtionskompassen (tidsserier) | konsumtionskompassen.se | Laddas ned manuellt per kommun som CSV |
| Temperaturprognos (RCP 2.6/4.5/8.5) | SMHI klimatscenariotjänst | Laddas ned manuellt som CSV |
| Uppsalas temperaturserie | SMHI | URL-årtalet och filnamnet i `temperatur()` måste uppdateras |
| Kolbindning (rasterdata) | SLU Kolkartor | Laddas ned automatiskt av `kolbindnin_nedladdning()` men sökvägen i `kolbindning()` kan behöva uppdateras |

---

---

# `load_save_data.R` – Datainladdning

## Syfte

Hämtar statistik från externa API:er och webbplatser och sparar som CSV- och Excel-filer i mappen `Data/` (skapas automatiskt). Varje funktion anropas direkt efter sin definition.

---

## Geografiska filer

### DeSO-geografi
Hämtar DeSO-geografifiler via ett externt GitHub-skript. Laddar bara ned om filer saknas.

### Kommungränser (Shape-fil)
Laddar ned SCB:s officiella kommungränser (SWEREF99TM) och packar upp till `Data/Kommun_Sweref99TM/`. Kontrollerar inte om filen redan finns – ZIP-filen extraheras alltid vid körning.

> **OBS!** Till skillnad från liknande skript i projektet saknas här en kontroll för om filen redan är extraherad. Det kan ge onödiga omkörningar.

---

## Klimat – emissioner

### `func_df_emissions_data()`
Laddar ned växthusgasdata (totala utsläpp) för Uppsala läns alla kommuner som Excel-fil från Nationella emissionsdatabasen. Läser in med `skip = 5` för att få årtalen som kolumnrubriker och byter namn på de fyra första kolumnerna till Huvudsektor, Undersektor, Län och Kommun. Tar bort den första dataraden (aggregatrad).

- **Källa:** Nationella emissionsdatabasen (SMHI), direktlänk med länsfiltret `county=03`
- **Sparas som:** `Data/df_emissions_data.csv`

---

### `func_vaxthusgas()`
Hämtar total utsläpp till luft av växthusgaser (ton CO₂-ekv/inv) per kommun från Kolada, från år 2004 och framåt.

- **Källa:** Kolada (`"växthusgaser"`)
- **Filter:** `"Utsläpp till luft av växthusgaser totalt, ton CO2-ekv/inv"`
- **Sparas som:** `Data/df_vaxthusgas.csv`

---

### `func_df_utslapp_kv()`
Hämtar utsläpp till luft av kväveoxider (NOx, kg/inv) per kommun, från år 2004 och framåt.

- **Källa:** Kolada
- **Sparas som:** `Data/df_utslapp_kv.csv`

---

### `func_df_utslapp_pm()`
Hämtar utsläpp till luft av PM2.5-partiklar (kg/inv) per kommun, från år 2004 och framåt.

- **Källa:** Kolada
- **Sparas som:** `Data/df_utslapp_pm.csv`

---

### `func_df_utslapp_am()`
Hämtar utsläpp till luft av ammoniak (NH3, kg/inv) per kommun, från år 2004 och framåt.

- **Källa:** Kolada
- **Sparas som:** `Data/df_utslapp_am.csv`

---

### `func_df_utslapp_org()`
Hämtar utsläpp till luft av flyktiga organiska ämnen (NMVOC, ton/inv) per kommun, från år 2004 och framåt.

- **Källa:** Kolada
- **Sparas som:** `Data/df_utslapp_org.csv`

---

## Klimat – temperatur (SMHI)

### `func_uppsala_tm_1722_2022(ar = "2022")`
Laddar ned SMHI:s rekonstruerade temperaturserie för Uppsala (1722–angivet år) som ZIP, och packar upp datafilen till `Data/`.

- **Källa:** SMHI direktlänk (URL innehåller årtalet och en tidsstämpel)
- **Parameter:** `ar` – slutåret i tidsserien (default `"2022"`)
- **Sparas som:** `Data/Uppsalas_temperaturserie.zip` + extraherad `.dat`-fil

> **OBS!** URL:en innehåller en hårdkodad tidsstämpel som troligtvis behöver uppdateras när SMHI publicerar ny data. Detta är markerat med en kommentar i koden.

---

## Klimat – markanvändning (SCB)

### `func_markanvandning()`
Hämtar markanvändningsdata för Uppsala läns kommuner per markanvändningsklass och år. Pivoterar till wide-format med klasserna som kolumner och beräknar andelar av total landareal för jordbruksmark, skogsmark, bebyggd mark, öppen myrmark och övrig mark.

- **SCB-tabell:** MarkanvN (MI0803A)
- **Klasser:** Total jordbruksmark, total skogsmark, bebyggd och anlagd mark, öppen myrmark, övrig mark, total landareal
- **Sparas som:** `Data/df_markanvandning.csv`

---

## Energi – SCB

### `func_df_Elhandelspriser()`
Hämtar månadsvis elhandelspris (öre/kWh, exkl. skatt, moms och nätavgift) per avtalstyp, elområde och kundkategori från januari 2022 och framåt. Tar bort NA-värden (saknade månader).

- **SCB-tabell:** SSDManadElhandelpris (EN0301A)
- **Sparas som:** `Data/df_Elhandelspriser.csv`

---

### `func_elproduktion()`
Hämtar elproduktion och bränsleanvändning (MWh) per produktionssätt och bränsletyp för Uppsala läns kommuner, alla tillgängliga år.

- **SCB-tabell:** ProdbrEl (EN0203A)
- **Sparas som:** `Data/df_Elproduktion.csv`

---

## Energi – Energimyndigheten

### `func_energianvandning()`
Hämtar total energianvändning för värme och varmvatten i lokaler (faktisk och temperaturkorrigerad), fördelat på energislag och lokaltyp, för Uppsala och sex grannlän (`mellan_sverige`). Indexmatchning mot API-metadatan används för att filtrera rätt länskoder.

- **Källa:** Energimyndighetens statistikdatabas (EN0103_14)
- **Sparas som:** `Data/df_energianvändning.csv`

---

### `func_df_effekt_verk()`
Hämtar antal vindkraftsverk och installerad effekt per kommuner i Uppsala, från år 2003 och framåt. Indexmatchning mot API-metadata används för att hämta rätt kommuner. Siffror rensas bort från kommunnamnen.

- **Källa:** Energimyndighetens statistikdatabas (EN0105_4)
- **Sparas som:** `Data/df_effekt_verk.csv`

---

### `func_solceller()`
Hämtar antal nätanslutna solcellsanläggningar och installerad effekt per capita och landareal, per effektklass och kategori, för Uppsala läns kommuner från år 2016 och framåt. Indexmatchning mot API-metadata. Siffror rensas bort från kommunnamnen.

- **Källa:** Energimyndighetens statistikdatabas (EN0123_2)
- **Sparas som:** `Data/df_solcell.csv`

---

### `func_framtida_elbehov()`
Laddar ned Energimyndighetens Excel-rapport om framtida elbehov på länsnivå (scenarion till 2050).

- **Källa:** Energimyndigheten direktlänk
- **Sparas som:** `Data/framtida_elbehov.xlsx`

---

## Energi – Kolada

### `kolada_f_energianvandning()`
Hämtar slutanvändning av el och fjärrvärme (MWh/inv) per kommun. Exkluderar sekretessbelagda värden.

- **Filter:** `"Slutanvändning av fjärrvärme inom det geografiska området, MWh/inv"` och `"Slutanvändning av el..."`)
- **Sparas som:** `Data/df_energianvandning.csv`

---

### `kolada_df_slutanvandning_tjanst()`
Hämtar energianvändning (MWh/inv) per sektor: jordbruk/skogsbruk/fiske, industri/byggverksamhet, offentlig verksamhet, transporter och övriga tjänster.

- **Sparas som:** `Data/df_slutanvandning_tjanst.csv`

---

### `kolada_slutanvandning_hushall()`
Hämtar energianvändning (MWh/inv) uppdelat på bostadstyp: småhus, flerbostadshus, fritidshus och totalt hushåll.

- **Sparas som:** `Data/df_slutanvandning_hushall.csv`

---

### `func_df_elavbrott()`
Hämtar två elavbrottsmått per kommun: genomsnittlig avbrottstid per kund (SAIDI, minuter) och andel kunder med 4 eller fler oaviserade långa avbrott (CEMI-4, %).

- **Sparas som:** `Data/df_elavbrott.csv`

---

## Energi – Fordonsstatistik (Kolada)

### `func_fordonsstatistik()`
En sammansatt funktion med tre inbäddade block som hämtar tre fordonsmått per kommun:

1. **Antal bilar per 1 000 invånare** – alla bilkategorier → `Data/df_bil.csv`
2. **Genomsnittlig körsträcka med personbil** – från år 2010 → `Data/df_stracka.csv`
3. **Andel fossiloberoende personbilar** (%) – från år 2010 → `Data/df_andel_bil.csv`

> **OBS!** Funktionen har en syntaktisk oregelbundenhet med dubbla `{{` vid funktionsdefinitionen. Koden fungerar men är inte idiomatisk R.

---

## Klimat – Kolbindning (SLU)

### `kolbindnin_nedladdning()`
En stor sammansatt funktion som automatiskt hittar senaste tillgängliga år på SLU:s kolkartors webbplats, laddar ned och extraherar tre ZIP-filer:

| Fil | Innehåll |
|---|---|
| `Documentation.zip` | Dokumentation (alla filer extraheras) |
| `Stock_SOC.zip` | Kolförrådet i mark (ton C/ha), raster `.tif` |
| `Change_All.zip` | Förändring i kolförrådet, raster `.tif` |

Hoppar automatiskt över filer som redan finns. Timeout sätts till 1 000 sekunder för stora filer. ZIP-filer raderas efter extraktion. Felhantering med `tryCatch` för både nedladdning och extraktion.

**Inbäddade hjälpfunktioner:**

- **`is_extracted(zipfile, out_dir)`** – kontrollerar om en ZIP redan är uppackad
- **`skapa_uppsala_dataset_mark(lanskod)`** – beskär `Stock_SOC.tif` till Uppsala, nedskalar rastern (factor 10), projicerar till WGS84 och beräknar medelvärde av kolförråd per kommun (exkluderar pixlar = 0 som representerar vatten). Sparar `Stock_SOC_Uppsala_wgs.tif` och `Uppsala_kommuner_wgs.shp`
- **`skapa_uppsala_dataset_change(lanskod)`** – samma pipeline men för `Change_All.tif`. Inkluderar alla pixlar i medelvärdesberäkningen (inkl. noll). Sparar `Stock_SOC_Uppsala_change.tif` och `Uppsala_kommuner_change.shp`

> **OBS!** `skapa_uppsala_dataset_mark()` och `skapa_uppsala_dataset_change()` är kommenterade ut i koden (`#skapa_uppsala_dataset_mark(lanskod)`) och körs alltså inte automatiskt. De måste anropas manuellt efter nedladdningen.

- **Sparas under:** `Data/kolbindning/[år]/`

---

---

# `create_save_plots.R` – Diagramskapande

## Syfte

Läser in lokalt sparad data och skapar statiska ggplot2-diagram (sparas i `Figurer/` som SVG/PNG) och interaktiva Plotly/Leaflet-figurer (returneras för inbäddning i rapport). `Figurer/` skapas automatiskt om den saknas.

---

## Energi – Framtida elbehov

### `future_elbehov()`
Skapar ett stapeldiagram per scenario (Energimyndighetens tre scenarier) som visar det framtida elbehovet (GWh) per sektor och år för Uppsala. Y-axeln är gemensam för alla scenarier. X-axeln visar var 5:e år.

- **Indata:** `Data/framtida_elbehov.xlsx`, flik 2
- **Sektorer (färgkodade):** Bostäder, Datacenter, Industri, Inrikes transporter, Service
- **Sparas som:** `Figurer/framtid_behov_[Scenario].svg/.png`

---

### `future_elbehov_sektor()`
Variant av `future_elbehov()` som skapar separata diagram per sektor med scenarierna som linjer (eller staplar) inom samma diagram. Möjliggör jämförelse av scenarion inom varje sektor.

- **Indata:** `Data/framtida_elbehov.xlsx`, flik 2
- **Sparas som:** `Figurer/framtid_behov_sektor_[Sektor].svg/.png`

---

## Energi – Elhandelspriser

### `Elhandelspriser()`
Interaktivt Plotly-linjediagram med månadsvis elhandelspris (öre/kWh) i elområde SE3, uppdelat på avtalstyp och kundkategori. Dropdown för att välja kundkategori. Unified hover.

- **Indata:** `Data/df_Elhandelspriser.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

## Energi – Elproduktion

### `Elproduktion()`
Interaktivt Plotly-diagram som visar elproduktion (MWh) per produktionssätt och bränsletyp för Uppsala läns kommuner, med dropdown-meny för att välja kommun och år.

- **Indata:** `Data/df_Elproduktion.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

## Energi – Slutanvändning (Kolada)

### `Slutanvandning_el_fjarr()`
Statiskt ggplot2-linjediagram som visar slutanvändning av el och fjärrvärme (MWh/inv) per kommun över tid.

- **Indata:** `Data/df_energianvandning.csv`
- **Sparas som:** `Figurer/slutanvandning_el_fjarr.svg/.png`

---

### `Slutanvandning_el_fjarr_plotly()`
Interaktiv Plotly-version av `Slutanvandning_el_fjarr()` med dropdown för energislag (el/fjärrvärme) och unified hover.

- **Indata:** `Data/df_energianvandning.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

### `Slutanvandning_tjanst()`
Statiskt ggplot2-linjediagram som visar energianvändning per tjänstesektor (jordbruk, industri, offentlig sektor, transporter, övriga tjänster) per kommun.

- **Indata:** `Data/df_slutanvandning_tjanst.csv`
- **Sparas som:** `Figurer/slutanvandning_tjanst.svg/.png`

---

### `Slutanvandning_tjanst_plotly()`
Interaktiv Plotly-version av `Slutanvandning_tjanst()` med dropdown för sektor och kommun.

- **Indata:** `Data/df_slutanvandning_tjanst.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

### `Slutanvandning_hushall()`
Statiskt ggplot2-linjediagram som visar energianvändning per bostadstyp (småhus, flerbostadshus, fritidshus, totalt hushåll) per kommun.

- **Indata:** `Data/df_slutanvandning_hushall.csv`
- **Sparas som:** `Figurer/slutanvandning_hushall.svg/.png`

---

## Energi – Elavbrott

### `Elavbrott()`
Statiskt ggplot2-linjediagram per kommun som visar SAIDI (genomsnittlig avbrottstid, minuter) och CEMI-4 (andel kunder med ≥ 4 avbrott, %) i separata paneler (facets).

- **Indata:** `Data/df_elavbrott.csv`
- **Sparas som:** `Figurer/elavbrott.svg/.png`

---

## Energi – Vindkraft och solceller

### `Effektverk()`
Statiskt ggplot2-stapel- eller linjediagram som visar antal vindkraftsverk och installerad effekt per kommun och år.

- **Indata:** `Data/df_effekt_verk.csv`
- **Sparas som:** `Figurer/effektverk.svg/.png`

---

### `solcell()`
Statiskt ggplot2-linjediagram som visar installerad solcellseffekt per capita och landareal per effektklass och kommun.

- **Indata:** `Data/df_solcell.csv`
- **Sparas som:** `Figurer/solcell.svg/.png`

---

## Klimat – Konsumtionskompassen

> Alla tre Konsumtionskompassen-funktioner kräver manuellt nedladdad data från konsumtionskompassen.se. Årtalet `ar <- 2022` är hårdkodat och måste uppdateras när ny data publiceras.

### `Deso_konsumtionskompass()`
Interaktiv Leaflet-karta med konsumtionsbaserade utsläpp per capita (kg CO₂-ekv) för Uppsala läns DeSO-områden och kommuner. Har två lager som kan växlas: Kommun och DeSO. DeSO-lagret är gömt i startvyn. DeSO-geografin väljs automatiskt baserat på årtalet: DeSO 2025 används för år efter 2023, annars DeSO 2018.

Popup visar totalt utsläpp i ton och per capita per DeSO/kommun. DeSO-legendens CSS-visning styrs via JavaScript för att dölja DeSO-legendan när kommunlagret visas.

- **Indata (manuell):** `Data/sammanräknade-utsläpp-i-valda-konsumtionskategorier_[KommunNamn].csv` (en per kommun), DeSO-geografifil, kommungränser Shape-fil
- **Returneras** som interaktiv Leaflet-karta.

---

### `Utslapp_over_tid()`
Interaktivt Plotly-linjediagram som visar konsumtionsbaserade utsläpp per kategori och år för Uppsala läns kommuner, med dropdown-meny för att välja kommun.

- **Indata (manuell):** CSV-tidsseriedata per kommun från Konsumtionskompassen
- **Returneras** som interaktivt Plotly-objekt.

---

### `Fordelning_per_kategori()`
Interaktivt Plotly-stapeldiagram som visar utsläppsfördelning per konsumtionskategori för senaste år, med dropdown-meny för att välja kommun.

- **Indata (manuell):** `Data/fotavtryck-per-konsumtionskategori.csv` (manuellt nedladdad)
- **Returneras** som interaktivt Plotly-objekt.

---

## Klimat – Växthusgaser

### `vaxthusgaser()`
Interaktivt Plotly-linjediagram med total växthusgasutsläpp (ton CO₂-ekv/inv) per kommun över tid. Unified hover.

- **Indata:** `Data/df_vaxthusgas.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

### `vaxthus_perkategori()`
Statiskt ggplot2-stapeldiagram som visar växthusgasutsläpp fördelade per huvudsektor och undersektor för Uppsala läns kommuner. Läser från Emissionsdatabasens CSV och skapar ett diagram per kommun.

- **Indata:** `Data/df_emissions_data.csv`
- **Sparas som:** `Figurer/vaxthus_perkategori_[KommunNamn].svg/.png`

---

### `vaxthus_perkategori_plotly()`
Interaktiv Plotly-version av `vaxthus_perkategori()` med dropdown-meny för att välja kommun och interaktiv fördelning per sektor.

- **Indata:** `Data/df_emissions_data.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

### `utslapp_till_luft()`
Interaktivt Plotly-linjediagram med luftföroreningar (NOx, PM2.5, NH3, NMVOC) per kommun och år, med dropdown för att välja ämne.

- **Indata:** `Data/df_utslapp_kv.csv`, `Data/df_utslapp_pm.csv`, `Data/df_utslapp_am.csv`, `Data/df_utslapp_org.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

## Klimat – Markanvändning och kolbindning

### `karta_skog()`
Interaktiv Leaflet-karta som visar andelen skogsmark per kommun i Uppsala. Popup visar andel jordbruksmark, skogsmark, bebyggd mark och övrig mark.

- **Indata:** `Data/df_markanvandning.csv`, kommungränser Shape-fil
- **Returneras** som interaktiv Leaflet-karta.

---

### `kolbindning()`
Interaktiv Leaflet-karta som visar kolförrådet i mark (ton C/ha) och förändringen i kolförråd per DeSO-område och kommun i Uppsala. Har lager för Stock (förråd) och Change (förändring). Läser GeoTIFF-rasterfiler och kommunpolygoner.

- **Indata:** `Data/Stock_SOC_Uppsala_wgs.tif`, `Data/Stock_SOC_Uppsala_change.tif`, `Data/Uppsala_kommuner_wgs.shp`, `Data/Uppsala_kommuner_change.shp`
- **Returneras** som interaktiv Leaflet-karta.

> **OBS!** Sökvägen `"Data/kolbindning/2023/Stock_SOC.tif"` inne i `kolbindnin_nedladdning()` är hårdkodad till år 2023. Om `kolbindnin_nedladdning()` laddar ned ett nyare år måste sökvägen i `skapa_uppsala_dataset_mark()` och `skapa_uppsala_dataset_change()` uppdateras manuellt.

---

## Klimat – Temperatur

### `temperatur()`
Interaktivt Plotly-stapeldiagram (med glidande medelvärdeslinjer) som visar Uppsalas rekonstruerade årsmedeltemperatur (avvikelse från historiskt medel) från 1722 till senaste år. Staplar färgkodas rött (över medel) eller blått (under medel). Visar 10- och 30-åriga glidande medelvärden som separata linjer.

- **Indata:** `Data/uppsala_tm_1722-2022.dat`
- **Filter:** `Id == 1` (Uppsala stationens ID)
- **Returneras** som interaktivt Plotly-objekt.

> **OBS!** Filnamnet `"Data/uppsala_tm_1722-2022.dat"` och filtret `Id == 1` är hårdkodade och måste uppdateras när ny data laddas ned. Detta är markerat med kommentarer i koden.

---

### `temp_prog()`
Statiskt ggplot2-linjediagram som visar temperaturprognos (avvikelse från referensperiod, °C) för Uppsala län under tre utsläppsscenarier (RCP 2.6, 4.5 och 8.5) fram till 2100. Inkluderar ensemble-medelvärde. En röd streckad linje markerar var prognosen börjar. Sparar även en variant med konfidensband.

- **Indata (manuell):** `Data/tasAnom_rcp26_ANN_yr_1951_2100_uppsala_lan.csv`, `Data/tasAnom_rcp45_ANN_yr_...csv`, `Data/tasAnom_rcp85_ANN_yr_...csv`
- **Sparas som:** `Figurer/temp_prog.svg/.png`, `Figurer/temp_prog_band.svg/.png`

---

## Energi – Fordon

### `fordon_antal()`
Statiskt ggplot2-linjediagram som visar antal bilar per 1 000 invånare per kommun och bilkategori.

- **Indata:** `Data/df_bil.csv`
- **Sparas som:** `Figurer/fordon_antal.svg/.png`

---

### `korstracka()`
Statiskt ggplot2-linjediagram som visar genomsnittlig körsträcka med personbil per invånare och kommun.

- **Indata:** `Data/df_stracka.csv`
- **Sparas som:** `Figurer/korstracka.svg/.png`

---

### `korstracka_bil()`
Statiskt ggplot2-linjediagram som visar andelen fossiloberoende personbilar (%) per kommun.

- **Indata:** `Data/df_andel_bil.csv`
- **Sparas som:** `Figurer/korstracka_bil.svg/.png`

---

---

# `create_tables.R` – Tabellskapande

## Syfte

Skapar interaktiva och statiska tabeller med `gt` och `reactable` för konsumtionsbaserade utsläpp och elpriser. Tabellerna är avsedda för direkt inbäddning i Quarto-rapport.

---

## `Fotavtryck_per_konsumtionskategori()`
Skapar en `gt`-tabell med konsumtionsbaserat koldioxidavtryck (kg CO₂-ekv) per konsumtionskategori, per Uppsala och varje kommun, för senaste tillgängliga år (hårdkodat `ar <- 2022`). Alla numeriska kolumner färgkodas med en grön–röd skala (låga → höga utsläpp) baserat på det globala värdeintervallet. Sorterar kommunerna alfabetiskt. Cellbredd standardiseras.

- **Indata (manuell):** `Data/fotavtryck-per-konsumtionskategori.csv`
- **Returneras** som `gt`-tabell.

---

## `Fotavtryck_per_konsumtionskategori2()`
`reactable`-version av `Fotavtryck_per_konsumtionskategori()` med samma data och färgskala. Använder `reactablefmtr::nytimes()`-temat och `add_title()`/`add_source()` för rubrik och källhänvisning. Cellbredder och typsnittsstorlekar matchar GT-versionen (700 px totalbredd).

- **Indata (manuell):** `Data/fotavtryck-per-konsumtionskategori.csv`
- **Returneras** som `reactable`-tabell.

> Dessa två funktioner är varianter av varandra – välj den som passar bäst i rapporten. `gt`-versionen är enklare att anpassa, `reactable`-versionen är filtrerbar och mer interaktiv.

---

## `Elavtals_tabell()`
Skapar en `gt`-tabell med genomsnittligt elhandelspris (öre/kWh) per avtalstyp och kundkategori för elområde SE3. Visar två priskolumner: medelpris för hela tillgängliga perioden och medelpris efter 2022. Sorteras i stigande prisordning. Båda priskolumnerna färgkodas med grön–röd skala.

- **Indata:** `Data/df_Elhandelspriser.csv`
- **Returneras** som `gt`-tabell.

---

---

## Mappstruktur

```
Projektmapp/
├── Script/
│   ├── install_load_packages.R
│   ├── settings.R
│   ├── search_kolada.R
│   ├── load_save_data.R
│   ├── create_save_plots.R
│   └── create_tables.R
├── Data/
│   ├── Kommun_Sweref99TM/              # SCB kommungränser (Shape-fil)
│   ├── DeSO_2025.gpkg / DeSO_2018.gpkg
│   ├── kolbindning/[år]/               # SLU rasterdata
│   ├── df_emissions_data.csv
│   ├── df_vaxthusgas.csv
│   ├── df_utslapp_kv.csv / _pm / _am / _org.csv
│   ├── df_markanvandning.csv
│   ├── df_Elhandelspriser.csv
│   ├── df_Elproduktion.csv
│   ├── df_energianvändning.csv
│   ├── df_effekt_verk.csv
│   ├── df_solcell.csv
│   ├── df_energianvandning.csv
│   ├── df_slutanvandning_tjanst.csv
│   ├── df_slutanvandning_hushall.csv
│   ├── df_elavbrott.csv
│   ├── df_bil.csv / df_stracka.csv / df_andel_bil.csv
│   ├── framtida_elbehov.xlsx
│   ├── Uppsalas_temperaturserie.zip + .dat
│   ├── Stock_SOC_Uppsala_wgs.tif       # Genereras manuellt via kolbindnin_nedladdning()
│   ├── Stock_SOC_Uppsala_change.tif
│   ├── Uppsala_kommuner_wgs.shp
│   ├── Uppsala_kommuner_change.shp
│   │
│   │   # Manuellt nedladdad data (Konsumtionskompassen):
│   ├── sammanräknade-utsläpp-i-valda-konsumtionskategorier_[Kommun].csv
│   ├── fotavtryck-per-konsumtionskategori.csv
│   ├── [tidsserie-csv per kommun]
│   │
│   │   # Manuellt nedladdad data (SMHI klimatscenarier):
│   ├── tasAnom_rcp26_ANN_yr_1951_2100_uppsala_lan.csv
│   ├── tasAnom_rcp45_ANN_yr_1951_2100_uppsala_lan.csv
│   └── tasAnom_rcp85_ANN_yr_1951_2100_uppsala_lan.csv
└── Figurer/                            # Skapas automatiskt – SVG och PNG
```

---

## Datakällor

| Källa | Typ av data |
|---|---|
| Nationella emissionsdatabasen (SMHI) | Territoriella växthusgasutsläpp per sektor och kommun |
| SCB PxWeb API | Markanvändning, elhandelspriser, elproduktion |
| Energimyndigheten API | Lokaler energianvändning, vindkraft, solceller, framtida elbehov |
| Kolada / Naturvårdsverket | Växthusgaser och luftföroreningar per kommun |
| Kolada / Energimyndigheten | Slutanvändning el/fjärrvärme, elavbrott, fordonsstatistik |
| SMHI | Uppsalas temperaturserie 1722– (ZIP), klimatscenarier (manuell CSV) |
| SLU Kolkartor | Kolförråd i mark och kolförändringar (GeoTIFF-raster) |
| Konsumtionskompassen | Konsumtionsbaserade utsläpp per DeSO och konsumtionskategori (manuell CSV) |

---

## Kända noteringar

| Skript | Notering |
|---|---|
| `load_save_data.R` | Shape-filen extraheras vid varje körning även om den redan finns – saknar existenskontroll för den extraherade mappen |
| `load_save_data.R` | `func_uppsala_tm_1722_2022()` – URL:en innehåller en hårdkodad tidsstämpel som troligtvis ändras när SMHI publicerar ny data |
| `load_save_data.R` | `func_fordonsstatistik()` har dubbla `{{` i funktionsdefinitionen – fungerar men är inte idiomatisk R |
| `load_save_data.R` | `skapa_uppsala_dataset_mark()` och `skapa_uppsala_dataset_change()` är kommenterade ut och måste anropas manuellt efter kolbindningsnedladdningen |
| `create_save_plots.R` | `temperatur()` – filnamnet `"Data/uppsala_tm_1722-2022.dat"` och `Id == 1` är hårdkodade och måste uppdateras vid ny data |
| `create_save_plots.R` | `kolbindning()` – sökvägen till rasterfilerna är beroende av att `skapa_uppsala_dataset_mark/change()` körts manuellt |
| `create_tables.R` | `Fotavtryck_per_konsumtionskategori()` och `Fotavtryck_per_konsumtionskategori2()` – årtalet `ar <- 2022` måste uppdateras manuellt |
| Alla skript | Konsumtionskompassen-data kräver manuell nedladdning per kommun – ingen automatisk funktion finns |

