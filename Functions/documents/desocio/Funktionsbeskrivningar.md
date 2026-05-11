# Dokumentation – R-skript för socioekonomisk och demografisk analys
*Uppsala län*

---

## Översikt

Projektet består av fem skript som tillsammans hämtar, bearbetar, visualiserar och indexerar socioekonomisk och demografisk statistik för Uppsala läns kommuner och DeSO-områden. Data hämtas från SCB:s API, Kolada och MUCF. Resultat sparas som diagram (SVG/PNG), interaktiva Plotly-figurer, tabeller och rumsliga filer (GeoPackage).

| Skript | Syfte |
|---|---|
| `load_save_data.R` | Hämtar data från externa API:er och sparar lokalt |
| `create_save_plots.R` | Skapar och sparar diagram och interaktiva visualiseringar |
| `create_tables.R` | Skapar interaktiva tabeller med `reactable` och `gt` |
| `socioindex_pca.R` | Beräknar ett PCA-baserat socioekonomiskt index på DeSO-nivå |
| `UVAS.R` | Skrapar MUCF:s statistik om unga som varken arbetar eller studerar |

---

## Gemensam konfiguration

Alla skript laddar gemensamma inställningar via:

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
| `lanskod` | Länets kod (t.ex. `"03"`) |
| `lan` | Länets namn |

---

---

# `load_save_data.R` – Datainladdning

## Syfte

Hämtar statistik från SCB:s PxWeb-API och Kolada, bearbetar datan och sparar den som CSV- eller GeoPackage-filer i mappen `Data/` (skapas automatiskt). Innehåller även beräkning av det simpla socioekonomiska indexet direkt i skriptet. Varje funktion anropas direkt efter sin definition.

En hjälpfunktion `print_pxwebv2(tabell)` konstruerar URL:er till SCB:s API v2 och används som kommenterad referens till varje tabells alternativa källa.

---

## Demografifunktioner

### `func_df_folkmangdfram()`
Hämtar SCB:s befolkningsprognos per region, ålder, kön och födelseregion för de kommande 20 åren.

- **SCB-tabell:** BefProgRegFakN (BE0401A)
- **Bearbetning:** Åldern rensas från text ("år", "+"), görs om till heltal. Filtrerar på totalt (inrikes och utrikes födda).
- **Sparas som:** `Data/df_folkmangdfram.csv`

---

### `func_df_folkmangd()`
Hämtar faktisk folkmängd per region, ålder och kön.

- **SCB-tabell:** BefolkningNy (BE0101A)
- **Sparas som:** `Data/df_folkmangd.csv`

---

### `func_df_folkmangd_fodd()`
Hämtar folkmängd uppdelad på födelseregion (inrikes/utrikes), ålder och kön per region.

- **SCB-tabell:** InrUtrFoddaRegAlKon (BE0101E)
- **Sparas som:** `Data/df_folkmangd_fodd.csv`

---

### `func_foddadoda_inut_flytt()`
Hämtar antal födda och döda per region, kön och år, samt nettotal. Hämtar in- och utflyttning per region, kön och födelseregion.

- **SCB-tabell:** BE0101 (födelseöverskott)
- **Sparas som:** `Data/df_foddadoda.csv`
- **Sparas som:** `Data/df_inut_flytt.csv`

---

### `func_deso()`
Hämtar DeSO-geografifiler (2025 och 2018) samt kopplingsfiler (DeSO→RegSO) från SCB:s geodatatjänst. Laddar bara ned om filerna saknas lokalt.

- **Sparas som:** `Data/DeSO_2025.gpkg`, `Data/DeSO_2018.gpkg`, `Data/koppling-deso2025-regso2025.xlsx`, `Data/koppling-deso2018-regso2020.xlsx`

---

### `func_alder_hushall_fodelse25()`
Hämtar hushållsdata på DeSO 2025-nivå: hushållstyp, ålder och antal per DeSO-område. Inkluderar befolkning per kön och födelseregion.

- **SCB-tabeller:** HushallDesoTyp (BE0101Y), FolkmDesoLandKon (BE0101Y)
- **Sparas som:** `Data/df_deso_hushall.gpkg`, `Data/df_deso_alder.gpkg`

---

### `func_alder_hushall_fodelse18()`
Samma som ovan men för DeSO 2018-geografi (historiska data t.o.m. 2023).

- **Sparas som:** `Data/df_deso_hushall_2018.gpkg`, `Data/df_deso_alder_2018.gpkg`

---

### `func_forsorjningskvot()`
Hämtar försörjningskvoten (antal icke-arbetsföra per 100 arbetsföra) per region och år.

- **SCB-tabell:** BE0101
- **Sparas som:** `Data/df_forsorjningskvot.csv`

---

### `func_df_livslangd()`
Hämtar medellivslängd per region och kön.

- **SCB-tabell:** Livslängd (BE0701)
- **Sparas som:** `Data/df_livslangd.csv`

---

## Utbildningsfunktioner

### `func_df_utbildning()`
Hämtar utbildningsnivå (andel med olika nivåer) per region, kön och åldersgrupp.

- **SCB-tabell:** Utbildningsnivå
- **Sparas som:** `Data/df_utbildning.csv`

---

### `func_df_deso_utbildning()`
Hämtar utbildningsnivå per DeSO-område (25–64 år) uppdelat på utbildningsnivå.

- **SCB-tabell:** UtbSUNBefDesoRegsoN (UF0506D)
- **Sparas som:** `Data/df_deso_utbildning.gpkg`

---

### `func_gymnasie_behorighet()`
Hämtar andel gymnasiebehöriga elever per region och kön.

- **SCB-tabell:** AM9906
- **Sparas som:** `Data/df_behorig.csv`

---

### `func_df_hogskole_overgang()`
Hämtar andel avgångna gymnasieelever som påbörjat högskolestudier inom tre år, per region och kön.

- **SCB-tabell:** RegionInd19R4 (AM9906D)
- **Sparas som:** `Data/df_hogskole_overgang.csv`

---

### `func_df_utbildningsniva()`
Hämtar utbildningsnivåer för befolkningen i länet uppdelat på kön och bakgrund (inrikes/utrikes född, EU/EES, övriga världen).

- **SCB-tabell:** IntGr3LanKONS (AA0003E)
- **Sparas som:** `Data/df_utbildningsniva.csv`

---

## Hälsa och ekonomi

### `func_df_ohalso()`
Hämtar ohälsotal per region, kön och födelseregion (Sverige, Norden exkl. Sverige, EU/EES, övriga världen).

- **SCB-tabell:** IntGr10LanKon (AA0003I)
- **Sparas som:** `Data/df_ohalso.csv`

---

### `func_df_sjalvforsorjande()`
Hämtar andelen självförsörjande (20–65 år) per region, kön, ålder, födelseregion och utbildningsnivå för senaste tillgängliga år.

- **SCB-tabell:** HE0000Tab01
- **Bearbetning:** NA-värden sätts till 0.
- **Sparas som:** `Data/df_sjalvforsorjande.csv`

---

### `func_df_genom_lon()`
Hämtar genomsnittlig grund- och månadslön per region, yrkesgrupp (SSYK 2012) och kön för senaste år.

- **SCB-tabell:** LonYrkeRegionAN (AM0110B)
- **Sparas som:** `Data/df_genom_lon.csv`

---

### `func_df_sos_ersatt()`
Hämtar andel och antal personer som försörjs med sociala ersättningar och bidrag, per region och kön, för senaste 12 månader. Beräknar årsmedelvärden.

- **SCB-tabell:** HE0000T02N2 (HE0112)
- **Sparas som:** `Data/df_sos_ersatt.csv`

---

## Socioekonomiskt index (simpelt)

### `simpelt_soe_index()`
Beräknar ett enkelt (icke-PCA-baserat) socioekonomiskt index för varje DeSO-område i Uppsala län och sparar det som GeoPackage. Indexet bygger på tre indikatorer:

- Andel med förgymnasial utbildning
- Andel arbetslösa (20–65 år)
- Andel med låg ekonomisk standard

**Metod:** Medelvärde av de tre andelarna samt en standardiserad variant (z-poäng). Områden klassificeras i fem klasser baserat på medelvärde ± standardavvikelse.

| Klass | Beskrivning |
|---|---|
| 1 | Områden med stora socioekonomiska utmaningar |
| 2 | Områden med socioekonomiska utmaningar |
| 3 | Socioekonomiskt blandade områden |
| 4 | Områden med goda socioekonomiska förutsättningar |
| 5 | Områden med mycket goda socioekonomiska förutsättningar |

- **Sparas som:** `Data/df_deso_arbetslos.gpkg`, `Data/df_deso_lag_standard.gpkg`, `Data/df_deso_utbildning23.gpkg`, `Data/df_desocioindex.gpkg`, `Data/df_deso_fodelse_index.gpkg`

---

## Ekonomiska strukturdata

### `func_df_inkomstklass()`
Hämtar andel av befolkningen i olika inkomstklasser per DeSO-område, inkomsttyp och kön.

- **SCB-tabell:** Tab1InkDesoRegso (HE0110I)
- **Sparas som:** `Data/df_inkomstklass.gpkg`

---

### `func_df_inkomststruktur()`
Hämtar inkomststruktur (nettoinkomst per inkomstkomponent) per DeSO-område och kön.

- **SCB-tabell:** Tab2InkDesoRegso (HE0110I)
- **Sparas som:** `Data/df_inkomststruktur.gpkg`

---

### `func_df_arbetsplats()`
Hämtar antal anställda med arbetsplats i länet per näringsgrensnivå (SNI 2007), yrkesgrupp (SSYK 2012) och kön. Summerar till näringsgrensnivå.

- **SCB-tabell:** YREG56BAS (AM0208D)
- **Sparas som:** `Data/df_arbetsplats.csv`

---

### `func_df_syssel_utb()`
Hämtar sysselsättningsstatus per utbildningsnivå, bakgrund (födelseregion) och kön för Uppsala läns kommuner.

- **SCB-tabell:** IntGr1KomUtbBAS (AA0003B)
- **Sparas som:** `Data/df_syssel_utb.csv`

---

## SFI och sociala indikatorer

### `func_SFI_antal()`
Hämtar antal elever i SFI-utbildning (kommunal och total regi) från Kolada.

- **Sparas som:** `Data/df_SFI_antal.csv`

---

### `func_SFI()`
Hämtar andelen SFI-elever som klarat minst två kurser respektive inte klarat kurser, inom två år efter nybörjande. Data från Kolada.

- **Sparas som:** `Data/df_SFI.csv`

---

### `func_soc_tillit()`
Hämtar kommunindex för sociala relationer och tillit, uppdelat på kön. Data från Kolada.

- **Sparas som:** `Data/df_tillit.csv`

---

### `fun_df_trang()`
Hämtar trångboddhet (norm 2) i Uppsala län uppdelat på födelseregion, från år 2012 till senaste tillgängliga år.

- **SCB-tabell:** LE0105Boende02 (LE0105B)
- **Sparas som:** `Data/df_trang.csv`

---

### `ladda_ner_arbetsmarknadsstatus(filnamn, senaste_manader)`
Hämtar månadsvis arbetsmarknadsstatus (andel sysselsatta, arbetslösa m.m.) för riket och Uppsala län, uppdelat på kön, åldersgrupp och födelseregion.

- **SCB-tabell:** ArbStatusM (AM0210A)
- **Parameter `senaste_manader`:** Antal månader bakåt att hämta (NULL = alla tillgängliga).
- **Sparas som:** `Data/arbetsmarknadsstatus.rds`

---

---

# `create_save_plots.R` – Diagramskapande

## Syfte

Läser in lokalt sparad data och skapar interaktiva Plotly-diagram, `mapview`-kartor och statiska `ggplot2`-diagram (sparade som SVG/PNG i `Figurer/`). De flesta diagram har dropdown-menyer för att välja region.

---

## Demografidiagram

### `befolkningsokning_plot()`
Interaktivt Plotly-linjediagram som visar faktisk folkmängdsutveckling och SCB:s 20-åriga befolkningsprognos för länet och varje kommun. En streckad linje markerar prognosstarten.

- **Indata:** `Data/df_folkmangdfram.csv`, `Data/df_folkmangd.csv`
- **Returneras** som interaktivt objekt.

---

### `agestructure()`
Interaktivt Plotly-diagram som visar befolkningsutvecklingen per åldersgrupp (0–19, 20–39, 40–59, 60–79, 80+) med prognos, med dropdown för region.

- **Indata:** `Data/df_folkmangdfram.csv`, `Data/df_folkmangd.csv`
- **Returneras** som interaktivt objekt.

---

### `befolknigstree()`
Interaktiv befolkningspyramid (åldersstruktur uppdelad på kön) per region med dropdown.

- **Indata:** `Data/df_folkmangd.csv`
- **Returneras** som interaktivt objekt.

---

### `befolknigstree_fodelse()`
Befolkningspyramid uppdelad på födelseregion (inrikes/utrikes) per region.

- **Indata:** `Data/df_folkmangd_fodd.csv`
- **Returneras** som interaktivt objekt.

---

### `antal_fodda_doda_plot()`
Visar antal födda, döda och födelseöverskott per år och region som kombinerat stapel- och linjediagram med dropdown.

- **Indata:** `Data/df_foddadoda.csv`
- **Returneras** som interaktivt objekt.

---

### `antal_in_ut_flytt_plot()`
Visar in- och utflyttning samt nettomigration per region och år med dropdown.

- **Indata:** `Data/df_inut_flytt.csv`
- **Returneras** som interaktivt objekt.

---

### `antal_in_ut_vand_plot()`
Visar in- och utvandring samt nettovandring per region, kön och födelseregion med dropdown och filterval.

- **Indata:** `Data/df_inut_flytt.csv`
- **Returneras** som interaktivt objekt.

---

### `f_kvot()`
Visar försörjningskvotens (beroende/arbetsför befolkning) utveckling per region över tid.

- **Indata:** `Data/df_forsorjningskvot.csv`
- **Returneras** som interaktivt objekt.

---

### `livslangd()`
Visar medellivslängdens utveckling per region och kön.

- **Indata:** `Data/df_livslangd.csv`
- **Returneras** som interaktivt objekt.

---

## DeSO-kartor

### `Deso_husall()`
Interaktiv `mapview`-karta med den vanligaste hushållstypen per DeSO-område. Popup visar andelar för alla hushållstyper. Jämför DeSO 2025 (nyast år) och DeSO 2018 (äldre data) sida vid sida.

- **Indata:** `Data/df_deso_hushall.gpkg`, `Data/df_deso_hushall_2018.gpkg`, DeSO-geografifiler
- **Returneras** som interaktiv karta.

---

### `Deso_kon()`
Karta som visar könsfördelning per DeSO-område.

- **Indata:** `Data/df_deso_alder.gpkg`
- **Returneras** som interaktiv karta.

---

### `Deso_alder()`
Karta som visar den vanligaste åldersgruppen per DeSO-område.

- **Indata:** `Data/df_deso_alder.gpkg`
- **Returneras** som interaktiv karta.

---

### `Deso_fodd()`
Karta som visar andelen utrikesfödda per DeSO-område.

- **Indata:** `Data/df_deso_alder.gpkg` (födelseregionsdata)
- **Returneras** som interaktiv karta.

---

## Utbildningsdiagram

### `utbildnings_niv()`
Visar utbildningsnivåns fördelning (förgymnasial, gymnasial, eftergymnasial) per region och kön med dropdown.

- **Indata:** `Data/df_utbildning.csv`
- **Returneras** som interaktivt objekt.

---

### `utbildnings_karta()`
Interaktiv karta som visar andelen med förgymnasial utbildning per DeSO-område.

- **Indata:** `Data/df_deso_utbildning.gpkg`
- **Returneras** som interaktiv karta.

---

### `andel_behoerig()`
Visar andelen gymnasiebehöriga elever per region och kön över tid.

- **Indata:** `Data/df_behorig.csv`
- **Returneras** som interaktivt objekt.

---

### `hogskole_overgang()`
Visar andelen gymnasieelever som börjat högskolestudier inom tre år, per region och kön.

- **Indata:** `Data/df_hogskole_overgang.csv`
- **Returneras** som interaktivt objekt.

---

### `utbildningsniva_fodelse()`
Visar utbildningsnivå uppdelat på födelseregion och kön för länet.

- **Indata:** `Data/df_utbildningsniva.csv`
- **Returneras** som interaktivt objekt.

---

### `SFI_antal()`
Visar antalet SFI-elever per kommun och år.

- **Indata:** `Data/df_SFI_antal.csv`
- **Returneras** som interaktivt objekt.

---

### `SFI()`
Visar andelen SFI-elever som klarat resp. inte klarat kurser.

- **Indata:** `Data/df_SFI.csv`
- **Returneras** som interaktivt objekt.

---

## Hälsa och ekonomidiagram

### `ohalsotal()`
Visar ohälsotalets utveckling per region, kön och födelseregion.

- **Indata:** `Data/df_ohalso.csv`
- **Returneras** som interaktivt objekt.

---

### `Andel_ohalso()`
Visar andelen med ohälsa per region uppdelat på bakgrund och kön.

- **Indata:** `Data/df_ohalso.csv`
- **Returneras** som interaktivt objekt.

---

### `sjalvforsorjande()`
Visar andelen självförsörjande per region, utbildningsnivå, födelseregion och kön.

- **Indata:** `Data/df_sjalvforsorjande.csv`
- **Returneras** som interaktivt objekt.

---

### `medel_loner()`
Visar genomsnittslöner per yrkesgrupp (SSYK) och kön med löneskillnad i procent.

- **Indata:** `Data/df_genom_lon.csv`
- **Returneras** som interaktivt objekt.

---

### `sos_ersattning()`
Interaktivt diagram som visar andel och antal med sociala ersättningar per region och kön.

- **Indata:** `Data/df_sos_ersatt.csv`
- **Returneras** som interaktivt objekt.

---

### `sos_ersattning_static()`
Statisk ggplot2-version av `sos_ersattning()`.

- **Indata:** `Data/df_sos_ersatt.csv`
- **Sparas som:** `Figurer/sos_ersattning.svg` / `.png`

---

### `deso_inkomstklass()`
Interaktiv karta som visar inkomstklassfördelning per DeSO-område.

- **Indata:** `Data/df_inkomstklass.gpkg`
- **Returneras** som interaktiv karta.

---

### `loneskillnad_deso()`
Visar löneskillnader mellan kön på DeSO-nivå med scatter- eller kartvisualisering.

- **Indata:** `Data/df_inkomststruktur.gpkg`
- **Returneras** som interaktivt objekt.

---

### `samband_inkomster()` och `samband_inkomster2()`
Visar samband mellan olika inkomstkomponenter och socioekonomiska variabler på DeSO-nivå via scatterplot.

- **Indata:** `Data/df_inkomststruktur.gpkg`, `Data/df_desocioindex.gpkg`
- **Returneras** som interaktiva objekt.

---

## Socioindexdiagram

### `socioindex_karta()`
Interaktiv `mapview`-karta med det simpla socioekonomiska indexets klasser per DeSO-område.

- **Indata:** `Data/df_desocioindex.gpkg`
- **Returneras** som interaktiv karta.

---

### `scatter_socioindex()`
Scatterplot som visar sambandet mellan det simpla indexet och andelen utrikesfödda per DeSO-område.

- **Indata:** `Data/df_desocioindex.gpkg`, `Data/df_deso_fodelse_index.gpkg`
- **Returneras** som interaktivt Plotly-objekt.

---

### `scatter_socioindex_standardized()` och `scatter_socioindex2()`
Varianter av `scatter_socioindex()` med standardiserade indexvärden och alternativa variabler på axlarna.

- **Returneras** som interaktiva Plotly-objekt.

---

## Övriga diagram

### `tillit()`
Visar kommunindex för sociala relationer och tillit per kön och kommuner.

- **Indata:** `Data/df_tillit.csv`
- **Returneras** som interaktivt objekt.

---

### `uvas()`
Visar andelen unga (16–29 år) som varken arbetar eller studerar (UVAS), uppdelat på kön, ursprung och åldersgrupp per kommunerna.

- **Indata:** `Data/unga_utan_studier_eller_arbete_uppsala.csv`
- **Returneras** som interaktivt objekt.

---

### `trangboddhet_andel()`
Visar andelen trångbodda (norm 2) i Uppsala län uppdelat på födelseregion och åldersgrupp över tid.

- **Indata:** `Data/df_trang.csv`
- **Returneras** som interaktivt objekt.

---

### `arbetsmarknad_arbetsloshet_plot()`
Visar arbetsmarknadsstatus (arbetslöshet, sysselsättning) per region, kön och åldersgrupp som tidsserieplot.

- **Indata:** `Data/arbetsmarknadsstatus.rds`
- **Returneras** som interaktivt Plotly-objekt.

---

### `arbetsmarknad_arbetsloshet_plot_kon_reg()`
Variant av ovanstående med jämförelse mellan regioner och kön.

- **Indata:** `Data/arbetsmarknadsstatus.rds`
- **Returneras** som interaktivt Plotly-objekt.

---

---

# `create_tables.R` – Tabelläskapande

## Syfte

Skapar interaktiva tabeller med `reactable` och `gt` för demografiska och ekonomiska data. Tabellerna är tänkta att bäddas in i rapporter eller webbsidor.

---

## Funktioner

### `tab_alder_class()`
Skapar en filtrerbar `reactable`-tabell med befolkningsfördelning per åldersgrupp (0–19, 20–39, 40–59, 60–79, 80+) och region för senaste år. Andelen är färgkodad från ljusrosa till mörkrosa.

- **Indata:** `Data/df_folkmangd.csv`
- **Gränssnitt:** Klickbara knappar för att filtrera per region (länet + alla kommuner)
- **Returneras** som `div` med knappar och tabell.

---

### `tab_hushall()`
Skapar en `gt`-tabell som jämför de 10 DeSO-områden med högst andel ensamstående med barn för tre referensår: 2014, 2019 och senaste tillgängliga år. Andelarna är färgkodade, och tabellen har kolumnspänner per år.

- **Indata:** `Data/df_deso_hushall.gpkg`, `Data/df_deso_hushall_2018.gpkg`, `Data/koppling-deso2025-regso2025.xlsx`, `Data/koppling-deso2018-regso2020.xlsx`
- **Returneras** som `gt`-tabell.

---

### `tab_kon()`
Skapar en `gt`-tabell med de 10 DeSO-områden som har störst könsojämn fördelning (högst andel av ett kön). Andelen är färgkodad.

- **Indata:** `Data/df_deso_alder.gpkg`, `Data/koppling-deso2025-regso2025.xlsx`
- **Returneras** som `gt`-tabell.

---

### `inkomst_summary()`
Skapar en `gt`-tabell med sammanfattande statistik (medelvärde, median, standardavvikelse) för tio inkomstkomponenter (lön, kapital, pension, bidrag m.m.), uppdelat på kön. Kolumnspänner visar Män och Kvinnor separat.

- **Indata:** `Data/df_inkomststruktur.gpkg`
- **Inkomstkomponenter:** Löneinkomst, näringsinkomst, kapital, pensioner, sjuk-/aktivitetsersättning, sjukpenning, föräldrapenning, arbetsmarknadsstöd, ekonomiskt bistånd, barnbidrag
- **Returneras** som `gt`-tabell.

---

---

# `socioindex_pca.R` – PCA-baserat socioekonomiskt index

## Syfte

Beräknar ett socioekonomiskt index för DeSO-områden i Uppsala län med hjälp av principalkomponentanalys (PCA). Indexet täcker flera år och gör det möjligt att följa socioekonomisk förändring över tid. Skriptet innehåller även funktioner för att ladda hem nödvändig data, visualisera indexet och jämföra det med det simpla indexet från `load_save_data.R`.

> **OBS!** Skriptet innehåller globala variabler (`lan`, `lanskod` m.fl.) som åsidosätts av inladdningen från `settings.R`. De hårdkodade värdena i toppen av filen är kvarglömda och behövs ej.

---

## Datafunktioner

### `download_data_deso()`
Laddar ned DeSO-geografifiler (2025 och 2018), kopplingsfiler och tätortsgränser från SCB:s geodatatjänst. Hoppar över filer som redan finns lokalt.

- **Sparas som:** `Data/DeSO_2025.gpkg`, `Data/DeSO_2018.gpkg`, kopplingsfiler, `Data/Tatorter_2018.gpkg`

---

### `skapa_index_laddaned_data_tid()`
Hämtar och kombinerar alla variabler som används i PCA-indexet, för alla tillgängliga år:

| Variabel | SCB-tabell | Beskrivning |
|---|---|---|
| Andel arbetslösa (20–65 år) | ArRegDesoStatusN (AM0210G) | Totalt, båda kön |
| Andel med låg ekonomisk standard | Tab4InkDesoRegso (HE0110I) | Totalt |
| Andel med förgymnasial utbildning | UtbSUNBefDesoRegsoN (UF0506D) | 25–64 år |
| Andel boende i flerbostadshus | Bostadsbyggnad3 (MI0803B) | Andel i procent |
| Andel ensamstående med barn | HushallDesoTyp (BE0101Y) | Andel av hushåll |
| Andel med ekonomiskt bistånd | Tab2InkDesoRegso (HE0110I) | Inkomstkomponent 170 |

Väljer det senaste år där alla tre primärvariabler (arbetslöshet, låg standard, utbildning) har data. Använder DeSO 2025 för år efter 2023, annars DeSO 2018.

Hämtar också andel utrikesfödda per DeSO (används ej i indexet, utan som jämförelsevariabel):

- **Sparas som:** `Data/df_data_till_index_pca.csv`, `Data/df_deso_fodelse_index_tid.gpkg`

---

## Indexberäkningsfunktioner

### `pca_func()`
Utför PCA separat för varje tillgängligt år på de sex indexvariablerna (skalade och centrerade). Returnerar medelvektorn av PC1-laddningarna över åren. Denna vektor används för att vikta variablerna stabilt oavsett enstaka årseffekter.

- **Indata:** `Data/df_data_till_index_pca.csv`
- **Returnerar:** Medelvektorn av PC1-laddningar (ett viktat medelvärde per variabel)

---

### `create_index()`
Beräknar det slutliga PCA-indexet för alla DeSO-områden och år med hjälp av viktvektorn från `pca_func()`. Klassar varje område i sex klasser baserat på medelvärde och standardavvikelse:

| Klass | Gräns |
|---|---|
| 6 | Bättre än medel – 1 SD (bäst) |
| 5 | Medel – 1 SD till medel – 0,5 SD |
| 4 | Nära medel (± 0,5 SD) |
| 3 | Medel + 0,5 SD till + 1,5 SD |
| 2 | Medel + 1,5 SD till + 2,5 SD |
| 1 | Sämre än medel + 2,5 SD (sämst) |

- **Indata:** `Data/df_data_till_index_pca.csv`
- **Sparas som:** `Data/df_data_index_pca.csv`

---

### `breaks()`
Räknar ut och returnerar klassgränserna för indexet (medelvärde ± standardavvikelse).

---

### `index_stats()`
Returnerar medelvärde och standardavvikelse för indexet som en vektor.

---

## Visualiseringsfunktioner

### `index_density()`
Skapar histogramdiagram för indexfördelningen, ett för riket och ett för Uppsala län, med klassgränserna inritade som streckade linjer.

- **Indata:** `Data/df_data_index_pca.csv`
- **Sparas som:** `Figurer/density_PCA_Simpelt_index.svg` / `.png`

---

### `socioindex_karta_tid()`
Skapar en interaktiv `mapview`-karta med sida-vid-sida-jämförelse av PCA-indexets klassning för det första och senaste tillgängliga året. Popup innehåller alla ingående variabler per DeSO.

- **Indata:** `Data/df_data_index_pca.csv`, DeSO-geografifil
- **Returneras** som interaktiv karta.

---

### `socioindex_karta_tid_temp()`
Jämförelsekarta som visar simpelt index (vänster) och PCA-index (höger) sida vid sida. Används tills ny data finns tillgänglig för båda indexen.

- **Indata:** `Data/df_data_index_pca.csv`, `Data/df_desocioindex.gpkg`
- **Returneras** som interaktiv karta.

---

### `scatter_socioindex_tid()`
Animerad Plotly-scatterplot (per år via slider) som visar sambandet mellan PCA-indexet och andelen utrikesfödda per DeSO-område. Visar korrelationsvärde och hovertext med alla ingående variabler.

- **Indata:** `Data/df_data_index_pca.csv`, `Data/df_deso_fodelse_index_tid.gpkg`
- **Returneras** som interaktivt animerat Plotly-objekt.

---

### `table_switches()`
Skapar tre `gt`-tabeller som visar DeSO-områden som bytt indexklass över tid:

1. Frekvenstabellen för alla klassbyten
2. Förbättringar (grön färgkodning)
3. Försämringar (röd färgkodning)

Filtrerar bort oscillationer (områden som återgått till ursprungsklassen).

- **Indata:** `Data/df_data_index_pca.csv`, DeSO-geografifil
- **Returnerar:** Lista med tre `gt`-tabeller.

---

### `table_diff()`
Skapar en `gt`-tabell med de 10 DeSO-områden som haft störst indexförändring (absolut) från första till senaste år. Skillnaden färgkodas grönt (förbättring) eller rött (försämring).

- **Indata:** `Data/df_data_index_pca.csv`, DeSO-geografifil, `Data/df_deso_fodelse_index_tid.gpkg`
- **Returneras** som `gt`-tabell.

---

### `korrelation_index()`
Skapar ett ggplot2-punktdiagram som jämför PCA-indexet med det simpla indexet för det år som finns i det simpla indexet. Beräknar och skriver ut Pearson- och Spearman-korrelation.

- **Indata:** `Data/df_data_index_pca.csv`, `Data/df_desocioindex.gpkg`
- **Sparas som:** `Figurer/Relation_PCA_Simpelt_index.svg` / `.png`

---

### `korrelation_index_temp()`
Samma som `korrelation_index()` men matchar på alla gemensamma år istället för ett specifikt. Används tills data finns för samma år i båda indexen.

- **Sparas som:** `Figurer/Relation_PCA_Simpelt_index.svg` / `.png`

---

---

# `UVAS.R` – Unga som varken arbetar eller studerar

## Syfte

Skrapar statistik om UVAS (Unga Vuxna som varken Arbetar eller Studerar) från MUCF:s webbplats för Uppsala läns kommuner och sparar som CSV.

---

## Kommuner och år

Skriptet täcker samtliga kommuner i Uppsala län med MUCF:s interna ID:n och hämtar data från 2007 till angivet slutår. Data bryts ned på kön (Kvinnor/Män), ursprung (Inrikesfödd/Utrikesfödd) och åldersgrupp (16–24, 25–29, 16–29).

---

## Funktioner

### `uvas_scrape_old(senaste_ar = 2023)`
Äldre version som skrapar MUCF:s tidigare webbplats via direkta HTML-formulärpostningar. Fungerar ej längre då MUCF bytt till en ny Drupal-baserad sajt.

- **Sparas som:** `Data/unga_utan_studier_eller_arbete_uppsala.csv`

---

### `uvas_scrape(senaste_ar = 2023, save_path = "...")`
Nuvarande aktiv version. Anpassad till MUCF:s nya webbplats som använder Drupal AJAX. Hämtar `form_build_id` och `form_id` från startsidan och skickar sedan POST-förfrågningar till AJAX-endpointen för varje kombination av kommun och år. Extraherar HTML-tabellen ur JSON-svaret.

- **Flöde:** Hämta token → loop per kommun och år → POST → parsa JSON → extrahera tabell → lägg till metadata
- **Felhantering:** Hoppar över kombination om HTTP-status ≠ 200 eller ingen tabell hittas. En kort paus (`Sys.sleep(1)`) används mellan anrop för att undvika att överbelasta servern.
- **Sparas som:** `Data/unga_utan_studier_eller_arbete_uppsala.csv` (eller angiven sökväg)

> **OBS!** Slutåret (`senaste_ar`) behöver uppdateras manuellt när ny data publiceras av MUCF.

---

---

## Mappstruktur

```
Projektmapp/
├── Script/
│   ├── install_load_packages.R   # Pakethantering
│   ├── settings.R                # Regioninställningar
│   ├── search_kolada.R           # Hjälpfunktion för Kolada-sökningar
│   ├── load_save_data.R          # Datainladdning
│   ├── create_save_plots.R       # Diagramskapande
│   ├── create_tables.R           # Tabellskapande
│   ├── socioindex_pca.R          # PCA-index
│   └── UVAS.R                    # MUCF-skrapning
├── Data/                         # Skapas automatiskt – CSV, RDS och GeoPackage
├── Figurer/                      # Skapas automatiskt – SVG och PNG
├── DeSO_2025.gpkg                # DeSO-geografi 2025
└── DeSO_2018.gpkg                # DeSO-geografi 2018
```

---

## Datakällor

| Källa | Typ av data |
|---|---|
| SCB PxWeb API | Demografi, utbildning, inkomst, arbetsmarknad, hälsa |
| SCB Geodata (WFS) | DeSO- och tätortsgeografier |
| Kolada API | SFI, fastighetspriser, sociala indikatorer |
| MUCF (webbskrapning) | UVAS-statistik per kommun och år |

---

## Kända noteringar

| Skript | Problem | Åtgärd |
|---|---|---|
| `socioindex_pca.R` | Hårdkodade globala variabler i toppen åsidosätts av `settings.R` | Ta bort eller kommentera bort de hårdkodade värdena |
| `UVAS.R` | `senaste_ar` måste uppdateras manuellt vid ny data | Sätt korrekt år vid körning |
| `load_save_data.R` | `func_soc_tillit()` anropas aldrig i skriptet | Lägg till anropet `func_soc_tillit()` vid behov |
|Lägg in mer SFI-data|  Det är intressant mest intressant att kolla på andelar och hur många som klarar/ej klarar utbildningen. 