# Dokumentation – R-skript för bostadsanalys

*Uppsala län*

------------------------------------------------------------------------

## Översikt

Projektet består av två huvudskript som tillsammans laddar hem, bearbetar och visualiserar statistik om bostadsmarknaden i Uppsala läns kommuner. Data hämtas primärt från SCB:s API och Kolada, och resultaten sparas som diagram i SVG- och PNG-format samt som CSV-filer.

| Skript | Syfte |
|----|----|
| `load_save_data.R` | Hämtar data från externa API:er och sparar som CSV-filer lokalt |
| `create_save_plots.R` | Läser in sparad data och skapar/sparar diagram |

------------------------------------------------------------------------

## Beroenden och konfiguration

Båda skripten börjar med att hämta inställningar och ladda paket via två gemensamma källfiler:

``` r
source("Script/install_load_packages.R")  # Installerar och laddar paket
source("Script/settings.R")               # Hämtar regionspecifika inställningar
```

Följande inställningsvariabler används genomgående:

| Variabel | Beskrivning |
|----|----|
| `kommunkod` | Vektor med kommunkoder för Uppsala läns kommuner |
| `kommuner` | Vektor med kommunnamn |
| `kommun_colors` | Färgpaletten för kommuner i diagram |
| `upplat_colors` | Färger för upplåtelseformer (hyresrätt, bostadsrätt, äganderätt) |
| `lan` | Länets namn |
| `lanskod` | Länets kod (används bl.a. för DeSO-filtrering) |

------------------------------------------------------------------------

------------------------------------------------------------------------

# `load_save_data.R` – Datainladdning

## Syfte

Skriptet hämtar aktuell statistik från SCB:s och Koladades API:er och sparar resultaten som CSV-filer i mappen `Data/`. Om mappen inte finns skapas den automatiskt.

## DeSO-geografifil

Innan statistiken laddas ned hämtas en geografisk fil med DeSO-områden (demografiska statistikområden) från SCB:s geodatatjänst. Filen laddas bara ned om den inte redan finns lokalt.

-   **Källa:** SCB Geodata WFS-tjänst
-   **Sparas som:** `DeSO_2025.gpkg`

------------------------------------------------------------------------

## Funktioner

### `func_df_byggnadsperiod()`

Hämtar antal lägenheter fördelade på region, hustyp och byggnadsperiod.

-   **SCB-tabell:** BO0104T02
-   **Sparas som:** `Data/df_byggnadsperiod.csv`

------------------------------------------------------------------------

### `func_df_agarkategori()`

Hämtar antal lägenheter fördelade på region, hustyp och ägarkategori.

-   **SCB-tabell:** BO0104T03
-   **Sparas som:** `Data/df_agarkategori.csv`

------------------------------------------------------------------------

### `func_df_bostadsarea()`

Hämtar antal lägenheter fördelade på region, hustyp och bostadsarea (kvm-intervall).

-   **SCB-tabell:** BO0104T5
-   **Sparas som:** `Data/df_bostadsarea.csv`

------------------------------------------------------------------------

### `func_df_lagenhetstyp()`

Hämtar antal lägenheter fördelade på region, hustyp och lägenhetstyp (t.ex. antal rum).

-   **SCB-tabell:** BO0104T09
-   **Sparas som:** `Data/df_lagenhetstyp.csv`

------------------------------------------------------------------------

### `func_df_specialbostad()`

Hämtar antal specialbostäder (äldre/funktionshindrade, studenter, övrigt) fördelade på region, typ och bostadsarea.

-   **SCB-tabell:** BO0104T7
-   **Sparas som:** `Data/df_specialbostad.csv`

------------------------------------------------------------------------

### `func_df_supplatelse()`

Hämtar antal lägenheter fördelade på region, hustyp och upplåtelseform (hyresrätt, bostadsrätt, äganderätt).

-   **SCB-tabell:** BO0104T04
-   **Sparas som:** `Data/df_supplatelse.csv`

------------------------------------------------------------------------

### `func_boverket(ar = "2025")`

Laddar ned Boverkets Excel-rapport om läget på bostadsmarknaden för angivet år.

> **OBS!** Året i länken måste uppdateras manuellt när ny data finns tillgänglig. Detta är markerat i koden med tre upprepade kommentarer (`### Ändra år här!!`).

-   **Källa:** Boverkets webbplats
-   **Sparas som:** `Data/boverket.xlsx`

------------------------------------------------------------------------

### `func_df_lediga()`

Hämtar andel lediga lägenheter i allmännyttiga flerbostadshus, fördelade på region och lägenhetstyp.

-   **SCB-tabell:** OuthAllmLghTypKom0 (BO0303A)
-   **Sparas som:** `Data/df_lediga.csv`

------------------------------------------------------------------------

### `func_df_nybyggda()`

Hämtar antal färdigställda lägenheter i nybyggda hus, fördelade på region, hustyp och upplåtelseform.

-   **SCB-tabell:** LghReHtypUfAr (BO0101A)
-   **Sparas som:** `Data/df_nybyggda.csv`

------------------------------------------------------------------------

### `func_df_befolkf()`

Hämtar befolkningsförändring (folkökning) per region och år.

-   **SCB-tabell:** BefforandrKvRLK (BE0101G)
-   **Filter:** Totalt folkbokförda (förändringskod 110), hela år, båda kön
-   **Sparas som:** `Data/df_befolkf.csv`

------------------------------------------------------------------------

### `func_df_folkmangd_bostadsindex()`

Hämtar folkmängden per region och ålder för åren 2006 och senaste tillgängliga år. Används som bas för bostadsindex-beräkningar (kvoten personer per bostad).

-   **SCB-tabell:** BefolkningNy (BE0101A)
-   **Filter:** Ålder 20+, år 2006 och senaste år
-   **Sparas som:** `Data/df_folkmangd.csv`

------------------------------------------------------------------------

### `func_deso_upplatelse()`

Hämtar upplåtelseform på DeSO-nivå (demografiska statistikområden) för alla DeSO-koder i Uppsala län.

-   **SCB-tabell:** BO0104T01N2 (BO0104X)
-   **Sparas som:** `Data/df_deso.csv`

------------------------------------------------------------------------

### `func_df_fritidshus()`

Hämtar antal fritidshus per region och år.

-   **SCB-tabell:** BO0104T08 (BO0104H)
-   **Sparas som:** `Data/df_fritidshus.csv`

------------------------------------------------------------------------

### `func_df_hyra()`

Hämtar medianhyra (kr/kvm/månad) för hyresbostäder per region och år. Innehåller en manuell imputering av ett saknat värde för Tierp år 2017.

-   **SCB-tabell:** BO0406Tab01 (BO0406E)
-   **Sparas som:** `Data/df_hyra.csv`

------------------------------------------------------------------------

### `func_df_folkmangdfram()`

Hämtar SCB:s befolkningsprognos per region, ålder och kön för de kommande 20 åren. Används för att beräkna framtida bostadsbehov.

-   **SCB-tabell:** BefProgRegFakN (BE0401A)
-   **Bearbetning:** Åldern rensas från text ("år", "+"), görs om till heltal. Endast "inrikes och utrikes födda" (totalt) behålls.
-   **Sparas som:** `Data/df_folkmangdfram.csv`

------------------------------------------------------------------------

### `func_fastighetspris()`

Hämtar fastighetsprisstatistik från Kolada. Filtrerar på bostadsrätt (kr/kvm) och fritidshus (kr/kvm) från år 2005 och framåt.

-   **Källa:** Kolada API (via funktionen `search_and_fetch_kolada`)
-   **Sparas som:** `Data/fastighetspris.csv`

------------------------------------------------------------------------

### `func_trandboddhet()`

Hämtar trångboddhetsstatistik från Kolada, uppdelad på norm 2 och norm 3, per kön (exkl. totalt).

-   **Källa:** Kolada API
-   **Sparas som:** `Data/trandboddhet.csv`

------------------------------------------------------------------------

### `fun_df_trang()`

Hämtar SCB-data om trångboddhet i flerbostadshus uppdelad på födelseregion och åldersgrupp (0–17 år resp. 18+ år) för Uppsala län.

-   **SCB-tabell:** LE0105Boende02 (LE0105B)
-   **Filter:** Trångboddhet norm 2 och totalt, alla födelseregioner, år 2012 till senaste
-   **Sparas som:** `Data/df_trang.csv`

------------------------------------------------------------------------

### `boverket_prognos(ar = 2025)`

Laddar ned Boverkets beräkning av bostadsbyggnadsbehov för angivet år.

> **OBS!** Året i länken kan behöva uppdateras manuellt.

-   **Källa:** Boverkets webbplats
-   **Sparas som:** `Data/boverket_prognos.xlsx`

------------------------------------------------------------------------

------------------------------------------------------------------------

# `create_save_plots.R` – Diagramskapande

## Syfte

Skriptet läser in de lokalt sparade CSV-filerna och skapar diagram med hjälp av `ggplot2`, `plotly` och `mapview`. Alla diagram sparas i mappen `Figurer/` (skapas automatiskt om den inte finns) i formaten **SVG** och **PNG** (96 dpi).

------------------------------------------------------------------------

## Funktioner

### `flerbostadsarea()`

Skapar ett stapeldiagram som visar fördelningen av bostadsarea (kvm) i flerbostadshus för det senaste tillgängliga året, uppdelat per region.

-   **Indata:** `Data/df_bostadsarea.csv`
-   **Diagramtyp:** Stapeldiagram med facets per region (4 rader)
-   **Sparas som:** `Figurer/flerbostadsarea.svg` / `.png`

------------------------------------------------------------------------

### `region_utv_upp()`

Visar utvecklingen av upplåtelseformer (hyresrätt, bostadsrätt, äganderätt) över tid för hela regionen, med staplar per upplåtelseform och en linje för totalt antal bostäder.

-   **Indata:** `Data/df_supplatelse.csv`
-   **Filter:** Exkluderar specialbostäder och "uppgift saknas". År från 2013.
-   **Diagramtyp:** Kombinerat stapel- och linjediagram
-   **Sparas som:** `Figurer/region_utv_upp.svg` / `.png`

------------------------------------------------------------------------

### `kommun_utv_upp()`

Samma typ av diagram som `region_utv_upp()`, men skapar ett separat diagram per kommun. Sparar en fil per kommun.

-   **Indata:** `Data/df_supplatelse.csv`
-   **Sparas som:** `Figurer/plot_upplatelseform_[KommunNamn].svg` / `.png`

------------------------------------------------------------------------

### `nybygg_region()`

Visar nybyggda bostäder per år och upplåtelseform för hela regionen, jämfört med befolkningsförändringen. Värdena visas som etiketter på linjerna.

-   **Indata:** `Data/df_nybyggda.csv`, `Data/df_befolkf.csv`
-   **Diagramtyp:** Kombinerat stapel- och linjediagram
-   **Sparas som:** `Figurer/nybygg_region.svg` / `.png`

------------------------------------------------------------------------

### `nybygg_kommun()`

Samma som `nybygg_region()` men ett diagram per kommun.

-   **Indata:** `Data/df_nybyggda.csv`, `Data/df_befolkf.csv`
-   **Sparas som:** `Figurer/plot_tid_nybygg_befolk_[KommunNamn].svg` / `.png`

------------------------------------------------------------------------

### `uppskatt_behov()`

Beräknar och visualiserar det uppskattade bostadsbehovet per kommun baserat på befolkningsförändring och en kvot (befolkning/bostäder) beräknad från basåret 2006. Skapar ett diagram per kommun.

-   **Indata:** `Data/df_folkmangd.csv`, `Data/df_supplatelse.csv`, `Data/df_nybyggda.csv`, `Data/df_befolkf.csv`
-   **Metod:** Kvoten beräknas som `folkmängd / antal bostäder` år 2006. Uppskattat behov = `befolkningsförändring / kvot`.
-   **Diagramtyp:** Kombinerat stapel- och linjediagram med tre serier (nybyggda, befolkningsförändring, uppskattat behov)
-   **Sparas som:** `Figurer/plot_bostadsbrist_[KommunNamn].svg` / `.png`

------------------------------------------------------------------------

### `deso_upplat()`

Skapar en interaktiv karta (via `mapview`) som visar den vanligaste upplåtelseformen per DeSO-område i Uppsala län. Vid klick på ett område visas andelar för samtliga upplåtelseformer.

-   **Indata:** `Data/df_deso.csv`, `DeSO_2025.gpkg`
-   **Utdata:** Interaktiv leaflet-karta (returneras, sparas inte som bildfil). En rumslig fil sparas dessutom som `Data/deso_sf.gpkg`.

------------------------------------------------------------------------

### `byggnadsperiod_region()`

Skapar ett interaktivt stapeldiagram (Plotly) över antalet bostäder per byggnadsperiod och hustyp för hela regionen, för senaste tillgängliga år.

-   **Indata:** `Data/df_byggnadsperiod.csv`
-   **Diagramtyp:** Plotly-stapeldiagram (grupperat)
-   **Returneras** som interaktivt objekt (ingen bildfil sparas)

------------------------------------------------------------------------

### `byggnadsperiod_kommun()`

Samma som `byggnadsperiod_region()` men med en dropdown-meny för att välja kommun. Bygger upp alla kommuners data i ett och samma Plotly-objekt och styr synligheten via dropdown.

-   **Indata:** `Data/df_byggnadsperiod.csv`
-   **Diagramtyp:** Interaktivt Plotly-stapeldiagram med kommunväljare
-   **Returneras** som interaktivt objekt (ingen bildfil sparas)

------------------------------------------------------------------------

### `fritidshus_reg()`

Visar utvecklingen av totalt antal fritidshus i länet från 1998 till senaste år som en tidsserie.

-   **Indata:** `Data/df_fritidshus.csv`
-   **Diagramtyp:** Linjediagram
-   **Sparas som:** `Figurer/fritidshus_region.svg` / `.png`

------------------------------------------------------------------------

### `fritidshus_kommun()`

Visar antal fritidshus per kommun som separata paneler (facets) i ett linjediagram. Y-axeln är fri för varje panel.

-   **Indata:** `Data/df_fritidshus.csv`
-   **Diagramtyp:** Linjediagram med facets per kommun
-   **Sparas som:** `Figurer/fritidshus_kommun.svg` / `.png`

------------------------------------------------------------------------

### `hyres_utveck()`

Skapar ett interaktivt Plotly-linjediagram som visar medianhyrans utveckling (kr/kvm/månad) per kommun från 2016 till senaste år. Länet visas med tjockare linje. Unified hover visar alla kommuners värden simultant.

-   **Indata:** `Data/df_hyra.csv`
-   **Diagramtyp:** Interaktivt Plotly-linjediagram
-   **Returneras** som interaktivt objekt (ingen bildfil sparas)

------------------------------------------------------------------------

### `prognos_behov()`

Visualiserar det framtida uppskattade bostadsbehovet per kommun baserat på SCB:s befolkningsprognos för de kommande 20 åren. Använder samma kvot-metodik som `uppskatt_behov()`. Skapar ett diagram per kommun.

-   **Indata:** `Data/df_folkmangd.csv`, `Data/df_supplatelse.csv`, `Data/df_folkmangdfram.csv`
-   **Metod:** Prognostiserad befolkningsförändring delas med kvoten (befolkning/bostäder, basår 2006) för att uppskatta antalet nya bostäder som behövs.
-   **Diagramtyp:** Linjediagram med två serier (befolkningsförändring och uppskattat behov)
-   **Sparas som:** `Figurer/plot_bostadsprognos_[KommunNamn].svg` / `.png`

------------------------------------------------------------------------

### `prisfastighet()`

Visar prisutveckling för bostadsrätter och fritidshus (kr/kvm) per kommun som tidsserielinje. Skapar ett diagram per kommun.

-   **Indata:** `Data/fastighetspris.csv`
-   **Diagramtyp:** Linje- och punktdiagram
-   **Sparas som:** `Figurer/fastighetspris_[KommunNamn].svg` / `.png`

------------------------------------------------------------------------

### `trangbodd_kom()`

Visar andelen trångbodda (norm 2 och norm 3) i flerbostadshus per kön och kommun för senaste tillgängliga år. Skapar ett stapeldiagram per kommun.

-   **Indata:** `Data/trandboddhet.csv`
-   **Diagramtyp:** Stapeldiagram med facets per trångboddhetsnorm, uppdelat på kön
-   **Sparas som:** `Figurer/trangboddhet_[KommunNamn].svg` / `.png`

------------------------------------------------------------------------

### `trangboddhet_andel()`

Visar andelen trångbodda (norm 2) personer i flerbostadshus i Uppsala län över tid, uppdelat på födelseregion (Sverige/Utland) och åldersgrupp (0–17 år / 18+ år).

-   **Indata:** `Data/df_trang.csv`
-   **Diagramtyp:** Linjediagram med facets per födelseregion
-   **Sparas som:** `Figurer/trang.svg` / `.png`

------------------------------------------------------------------------

### `trangboddhet_antal()`

Samma upplägg som `trangboddhet_andel()` men visar absolut antal trångbodda istället för andel.

-   **Indata:** `Data/df_trang.csv`
-   **Diagramtyp:** Linjediagram med facets per födelseregion
-   **Sparas som:** `Figurer/trang_antal.svg` / `.png`

------------------------------------------------------------------------

## Mappstruktur

```         
Projektmapp/
├── Script/
│   ├── install_load_packages.R   # Pakethantering
│   ├── settings.R                # Regioninställningar
│   ├── load_save_data.R          # Datainladdning (detta skript)
│   └── create_save_plots.R       # Diagramskapande (detta skript)
├── Data/                         # Skapas automatiskt, innehåller CSV-filer
├── Figurer/                      # Skapas automatiskt, innehåller SVG/PNG-filer
└── DeSO_2025.gpkg                # Geografisk fil för DeSO-kartor
```

------------------------------------------------------------------------

## Datakällor

| Källa             | Typ av data                                 |
|-------------------|---------------------------------------------|
| SCB API (pxweb)   | Bostadsstatistik, befolkning, trångboddhet  |
| SCB Geodata (WFS) | DeSO-geografifil                            |
| Kolada API        | Fastighetspriser, trångboddhet (kommunnivå) |
| Boverket          | Bostadsmarknadsenkät, byggbehovsberäkning   |
