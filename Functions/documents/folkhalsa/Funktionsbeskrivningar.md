# Dokumentation – R-skript för folkhälsoanalys

*Uppsala län*

------------------------------------------------------------------------

## Översikt

Projektet består av tre skript som tillsammans hämtar, bearbetar och visualiserar folkhälsostatistik för Uppsala läns kommuner och närliggande regioner. Data hämtas från SCB, Folkhälsomyndigheten och Kolada. Alla diagram sparas i `Figurer/` som SVG och PNG.

| Skript | Syfte |
|------------------------------------|------------------------------------|
| `load_save_data.R` | Hämtar data från SCB, Folkhälsomyndigheten och Kolada och sparar lokalt |
| `create_save_plots.R` | Skapar och sparar diagram utifrån sparad data |
| `survey_berakning.R` | Hjälpfunktion för surveybaserade proportionsskattningar med viktad design |

------------------------------------------------------------------------

## Gemensam konfiguration

`load_save_data.R` och `create_save_plots.R` laddar gemensamma inställningar via:

``` r
source("Script/install_load_packages.R")
source("Script/settings.R")
source("Script/search_kolada.R")   # endast load_save_data.R
source("Script/survey_berakning.R") # endast create_save_plots.R
install_and_load()
settings <- get_settings()
```

Följande variabler används genomgående:

| Variabel | Beskrivning |
|------------------------------------|------------------------------------|
| `kommunkod` | Kommunkoder för Uppsala läns kommuner |
| `kommuner` | Kommunnamn |
| `kommun_colors` | Färgpalett per kommun |
| `lanskod` | Länets kod |
| `lan` | Länets namn |
| `riket_narliggande` | Riket + närliggande regioner (Dalarna, Gävleborg, Uppsala, Västmanland) |

Mappen `Data/` skapas automatiskt om den saknas.

### Diagramkonventioner

De flesta diagram delar gemensamma designval:

-   **Färgschema kön:** Män = `#4AA271` (grön), Kvinnor = `#D57667` (röd)
-   **Riket:** Visas som streckad linje i samma färg som Uppsala läns solida linje
-   **Konfidensintervall:** Visas som halvtransparent band (`alpha = 0.3`) runt linjen
-   **Tidsaxel:** Vart 3–4 år visas som tick beroende på serielängd
-   **Källa:** Anges i figurens caption, vänsterställd

------------------------------------------------------------------------

------------------------------------------------------------------------

# `load_save_data.R` – Datainladdning

## Geografiska filer

### DeSO-geografi

Hämtar DeSO-geografifiler via ett externt GitHub-skript från RegionUppsala-analys. Laddar bara ned om filer saknas.

``` r
source("https://raw.githubusercontent.com/RegionUppsala-analys/.../get_deso.R")
func_deso()
```

### Kommungränser (Shape-fil)

Laddar ned SCB:s officiella kommun- och länsgränser (SWEREF99TM) som ZIP och packar upp till `Data/Kommun_Sweref99TM/` och `Data/Lan_Sweref99TM/`. Hoppas över om filen redan finns.

-   **Källa:** `scb.se` (shape_svenska_250121.zip)

------------------------------------------------------------------------

## SCB

### `func_df_livslangd()`

Hämtar femårig livslängdstabell (återstående medellivslängd vid 30 och 65 år) per utbildningsnivå, kön, ålder och region för Riket och närliggande regioner. NA-värden tas bort (uppgift saknas gäller endast Riket).

-   **SCB-tabell:** LivslUtbLan (BE0701)
-   **Sparas som:** `Data/df_livslangd.csv`

------------------------------------------------------------------------

## Folkhälsomyndigheten – livslängd

### `func_livslangd_kom()`

Hämtar medellivslängd (5-årsmedelvärden vid födseln) per kön och år för Uppsala läns kommuner. Siffror rensas bort från regionnamnen.

-   **FoHM-tabell:** MedlivsYreg
-   **Sparas som:** `Data/df_livslangd_kom.csv`

------------------------------------------------------------------------

## Folkhälsomyndigheten – psykisk hälsa

### `func_psykiskt()`

Hämtar andelen med gott eller mycket gott psykiskt välbefinnande (Warwick-skalan) per region och kön. Pivoteras till wide-format med andel och konfidensintervall som separata kolumner.

-   **FoHM-tabell:** warwickyreg
-   **Sparas som:** `Data/df_psykiskt.csv`

------------------------------------------------------------------------

### `func_df_psykisk_halsa()`

Hämtar andelen med allvarlig psykisk påfrestning (Kessler 6-skalan) per region och kön. Pivoteras till wide-format.

-   **FoHM-tabell:** psykessler6yreg
-   **Sparas som:** `Data/df_psykisk_halsa.csv`

------------------------------------------------------------------------

### `func_df_sjalvrapporterad()`

Hämtar andelen barn med minst 2 återkommande fysiska eller psykiska besvär (psykosomatiska besvär), per kön och region. Kön: Pojkar (`'1'`) och Flickor (`'2'`).

-   **FoHM-tabell:** halbBaReg
-   **Sparas som:** `Data/df_sjalvrapporterad.csv`

------------------------------------------------------------------------

### `func_df_livstillfresstallelse()`

Hämtar andelen barn med hög livstillfredsställelse per kön och region. Kön: Pojkar/Flickor.

-   **FoHM-tabell:** tillfrBaReg
-   **Sparas som:** `Data/df_livstillfresstallelse.csv`

------------------------------------------------------------------------

### `func_suicid()`

Hämtar antal säkra självmord per 100 000 invånare per kön och ålder för Uppsala läns kommuner. Pivoteras till wide med åldersgrupper som kolumner.

-   **FoHM-tabell:** SuicidVuxReg
-   **Sparas som:** `Data/df_suicid.csv`

------------------------------------------------------------------------

### `func_df_psykiska_variabler()`

Hämtar samlad data för flera psykiska hälsovariabler (stress, sömnbesvär, ängslan/oro/ångest m.fl.) per region och kön. Pivoteras till wide med variabeltyp som kolumner och andel/konfidensintervall som rader.

-   **FoHM-tabell:** hlv1psyxreg (B_HLV)
-   **Sparas som:** `Data/df_psykiska_variabler.csv`
-   **Används av:** `Psykisk_stress()`, `svar_psykisk_stress()`, `somn()`, `svara_somn()`, `oro_angest()`, `svar_oro_angest()`

------------------------------------------------------------------------


### `func_df_tillit_till_andra()`

Hämtar andelen som har svårt att lita på andra, per region och kön.

-   **FoHM-tabell:** litaYreg
-   **Sparas som:** `Data/df_tillit_till_andra.csv`

------------------------------------------------------------------------

### `func_emotionellt_stod()`

Hämtar andelen som saknar emotionellt stöd per region och kön.

-   **FoHM-tabell:** emstod (HLVkn)
-   **Sparas som:** `Data/emotionellt_stod.csv`

------------------------------------------------------------------------

### `func_praktiskt_stod()`

Hämtar andelen som saknar praktiskt stöd per region och kön.

-   **FoHM-tabell:** praksto (HLVkn)
-   **Sparas som:** `Data/praktiskt_stod.csv`

------------------------------------------------------------------------

## Folkhälsomyndigheten – fysisk hälsa

### `func_f_fysisk_aktivitet()`

Hämtar andelen fysiskt aktiva (minst 150 min/vecka, uppdelat på aktivitetsnivå) per region och kön.

-   **FoHM-tabell:** fysakyreg
-   **Sparas som:** `Data/df_fysisk_aktivitet.csv`

------------------------------------------------------------------------

### `func_tandhalsa()`

Hämtar andelen med dålig respektive bra tandhälsa per region och kön. Pivoteras med tandhälsokategori och konfidensintervall.

-   **FoHM-tabell:** tanhal (HLVkn)
-   **Sparas som:** `Data/df_tandhalsa.csv`

------------------------------------------------------------------------

### `func_df_tandhalsa_avsta()`

Hämtar andelen som avstått tandläkarvård trots behov (totalt och av ekonomiska skäl) per region och kön.

-   **FoHM-tabell:** tlejsok (HLVkn)
-   **Sparas som:** `Data/df_tandhalsa_avsta.csv`

------------------------------------------------------------------------

### `func_stillasittande()`

Hämtar andelen med stillasittande fritid uppdelat på stillasittandekategori och kön. Filtrerar data från år 2017–2020 och framåt.

-   **FoHM-tabell:** stilla (HLVkn)
-   **Sparas som:** `Data/df_stillasittande.csv`

------------------------------------------------------------------------

### `func_diabetes()`

Hämtar nyregistrerade fall av typ 2-diabetes per 100 000 invånare per ålder och kön för Riket och närliggande regioner.

-   **FoHM-tabell:** DiabetfallReg
-   **Sparas som:** `Data/df_diabetes.csv`

------------------------------------------------------------------------

### `func_sjukdom_besvar()`

Hämtar andelen med olika sjukdomar och besvär (högt blodtryck, allergi, astma, tinnitus, yrsel m.fl.) per region och kön. Pivoteras med sjukdomskategori och konfidensintervall.

-   **FoHM-tabell:** hlv1sjuxreg (B_HLV)
-   **Sparas som:** `Data/df_sjukdomar_besvar.csv`

------------------------------------------------------------------------

### `func_df_obesitas()`

Hämtar andelen per viktstatus (BMI-kategori: undervikt, normalvikt, övervikt, obesitas) per region och kön.

-   **FoHM-tabell:** hlv1bmixreg (B_HLV)
-   **Sparas som:** `Data/df_obesitas.csv`

------------------------------------------------------------------------

## Folkhälsomyndigheten – levnadsvanor

### `func_df_alkohol()`

Hämtar andelen riskkonsumenter av alkohol per region och kön.

-   **FoHM-tabell:** alkriskyreg
-   **Sparas som:** `Data/df_alkohol.csv`

------------------------------------------------------------------------

### `func_frukt_gront()`

Hämtar andelen som äter frukt respektive grönsaker minst 2 gånger per dag, per region och kön.

-   **FoHM-tabell:** fruktgront (HLVkn)
-   **Sparas som:** `Data/df_frukt_gront.csv`

------------------------------------------------------------------------

### `func_tobak()`

Hämtar andelen dagligrökare och dagligsnusare (tobakskonsumtion) per region och kön.

-   **FoHM-tabell:** tobak (HLVkn)
-   **Sparas som:** `Data/df_rokning.csv`

------------------------------------------------------------------------

### `func_socker_dryck()`

Hämtar andelen som dricker sötad dryck minst 2 gånger per vecka per region och kön. Kolumnnamn normaliseras med `make.names()` p.g.a. specialtecken i API-svaret.

-   **FoHM-tabell:** laskyreg
-   **Sparas som:** `Data/df_dryck.csv`

------------------------------------------------------------------------

### `func_spelande()`

Hämtar andelen med riskabelt spelande (spelat senaste 12 månaderna) per region och kön.

-   **FoHM-tabell:** riskspelyreg
-   **Sparas som:** `Data/df_spel.csv`

------------------------------------------------------------------------

### `func_narkotika()`

Hämtar andelen som använt annan narkotika uppdelat på frekvens och kön, per region.

-   **FoHM-tabell:** narkotika4 (HLVkn)
-   **Sparas som:** `Data/df_narkotika.csv`

------------------------------------------------------------------------

### `func_cannabis()`

Hämtar andelen som använt cannabis uppdelat på frekvens och kön, per region.

-   **FoHM-tabell:** cannabis4 (HLVkn)
-   **Sparas som:** `Data/df_cannabis.csv`

------------------------------------------------------------------------

## Kolada

### `func_soc_tillit()`

Hämtar kommunindex för sociala relationer och tillit (totalt, Män och Kvinnor) för Uppsala läns kommuner.

-   **Källa:** Kolada (`"Sociala relationer och tillit - Kommunindex"`)
-   **Sparas som:** `Data/df_tillit.csv`

------------------------------------------------------------------------

------------------------------------------------------------------------

# `create_save_plots.R` – Diagramskapande

## Syfte

Läser in lokalt sparad data och skapar statiska ggplot2-diagram och ett interaktivt Plotly-diagram. Statiska diagram sparas i `Figurer/` (skapas automatiskt) som SVG och PNG (96 dpi). Skriptet laddar också `survey_berakning.R` för eventuella surveybaserade beräkningar.

------------------------------------------------------------------------

## Livslängd (SCB + FoHM)

### `livslangd()`

Interaktivt Plotly-stapeldiagram med återstående medellivslängd från 30 års ålder, uppdelat på utbildningsnivå och kön. Dropdown-meny för att välja region (Riket, Dalarna, Gävleborg, Uppsala, Västmanland). Y-axeln är fast (0–70 år) för jämförbarhet. Färger per utbildningsnivå: förgymnasial (röd), gymnasial (gul), eftergymnasial (blå), uppgift saknas (grön).

-   **Indata:** `Data/df_livslangd.csv`
-   **Returneras** som interaktivt Plotly-objekt.

------------------------------------------------------------------------

### `livslangd_tid()`

Tidsserieplot per region som visar återstående medellivslängd från 30 år per utbildningsnivå och kön (facets). Enbart Riket visar kategorin "Uppgift Saknas". Skapar en fil per region.

-   **Indata:** `Data/df_livslangd.csv`
-   **Sparas som:** `Figurer/livslangd_[Region].svg/.png`

------------------------------------------------------------------------

### `livslangd_kom()`

Tidsserieplot per kommun med medellivslängd vid födseln (5-årsmedelvärden) uppdelat på kön. Var 3:e år visas på x-axeln.

-   **Indata:** `Data/df_livslangd_kom.csv`
-   **Sparas som:** `Figurer/livslangd_kom_[KommunNamn].svg/.png`

------------------------------------------------------------------------

## Psykisk hälsa

### `psykist_valbefinnande()`

Linjediagram med konfidensband för andelen med gott eller mycket gott psykiskt välbefinnande i Uppsala län (4-årsmedelvärden), uppdelat på kön.

-   **Indata:** `Data/df_psykiskt.csv`
-   **Sparas som:** `Figurer/psykisk_valbefinnande.svg/.png`

------------------------------------------------------------------------

### `psykisk_pafrestning()`

Linjediagram med konfidensband för andelen med allvarlig psykisk påfrestning i Uppsala län (4-årsmedelvärden), uppdelat på kön.

-   **Indata:** `Data/df_psykisk_halsa.csv`
-   **Sparas som:** `Figurer/psykisk_halsa.svg/.png`

------------------------------------------------------------------------

### `Psykisk_stress()`

Linjediagram för andelen stressade i Uppsala län jämfört med Riket (streckad linje), uppdelat på kön. Var 2:e år visas på x-axeln.

-   **Indata:** `Data/df_psykiska_variabler.csv`
-   **Sparas som:** `Figurer/psykisk_stress.svg/.png`

------------------------------------------------------------------------

### `svar_psykisk_stress()`

Samma upplägg som `Psykisk_stress()` men för andelen *mycket* stressade. Riket visas ej som jämförelselinje här.

-   **Indata:** `Data/df_psykiska_variabler.csv`
-   **Sparas som:** `Figurer/svar_psykisk_stress.svg/.png`

------------------------------------------------------------------------

### `suicid()`

Linjediagram per kommun med suicid per 100 000 invånare (25%-åldersstandardiserat), uppdelat på kön. Skapar en fil per kommun.

-   **Indata:** `Data/df_suicid.csv`
-   **Sparas som:** `Figurer/suicid_[KommunNamn].svg/.png`


------------------------------------------------------------------------

### `sjalvrapporterad_halsa()`

Linjediagram med konfidensband för andelen barn med minst 2 återkommande fysiska eller psykiska besvär, per kön (Pojkar/Flickor). Filtrerar på senaste tillgängliga år. X-axeln är regionsortering.

-   **Indata:** `Data/df_sjalvrapporterad.csv`
-   **Sparas som:** `Figurer/sjalvrapporterad_halsa.svg/.png`

------------------------------------------------------------------------

### `livstillfresstallelse()`

Linjediagram med konfidensband för andelen barn med hög livstillfredsställelse, per kön. X-axeln är regionsortering.

-   **Indata:** `Data/df_livstillfresstallelse.csv`
-   **Sparas som:** `Figurer/livstillfresstallelse.svg/.png`

------------------------------------------------------------------------

### `somn()`

Linjediagram för andelen med sömnbesvär (totalt) i Uppsala län jämfört med Riket (streckad), uppdelat på kön.

-   **Indata:** `Data/df_psykiska_variabler.csv`
-   **Sparas som:** `Figurer/somn.svg/.png`

------------------------------------------------------------------------

### `svara_somn()`

Samma upplägg som `somn()` men för andelen med *svåra* sömnbesvär.

-   **Indata:** `Data/df_psykiska_variabler.csv`
-   **Sparas som:** `Figurer/svara_somn.svg/.png`

------------------------------------------------------------------------

### `oro_angest()`

Linjediagram för andelen med ängslan, oro eller ångest i Uppsala län jämfört med Riket (streckad), uppdelat på kön.

-   **Indata:** `Data/df_psykiska_variabler.csv`
-   **Sparas som:** `Figurer/oro_angest.svg/.png`

------------------------------------------------------------------------

### `svar_oro_angest()`

Samma upplägg som `oro_angest()` men för andelen med *svåra* besvär. Riket visas ej som jämförelselinje.

-   **Indata:** `Data/df_psykiska_variabler.csv`
-   **Sparas som:** `Figurer/svar_oro_angest.svg/.png`

------------------------------------------------------------------------

### `tillit_till_andra()`

Linjediagram för andelen som har svårt att lita på andra i Uppsala län jämfört med Riket (streckad), uppdelat på kön.

-   **Indata:** `Data/df_tillit_till_andra.csv`
-   **Sparas som:** `Figurer/tillit_till.svg/.png`

------------------------------------------------------------------------

### `em_prak_stod()`

Kombinerat linjediagram med facets (Emotionellt / Praktiskt stöd) för andelen som saknar respektive stödtyp i Uppsala jämfört med Riket (streckad), uppdelat på kön. Slår ihop `emotionellt_stod.csv` och `praktiskt_stod.csv`.

-   **Indata:** `Data/emotionellt_stod.csv`, `Data/praktiskt_stod.csv`
-   **Sparas som:** `Figurer/em_prak_stod.svg/.png`

------------------------------------------------------------------------

## Fysisk hälsa

### `fysisk_aktivitet()`

Linjediagram för andelen fysiskt aktiva (minst 150 min/vecka) i Uppsala jämfört med Riket (streckad), uppdelat på kön.

-   **Indata:** `Data/df_fysisk_aktivitet.csv`
-   **Filter:** `Fysisk.aktivitet == "Aktiv minst 150 min/vecka"`, NA-värden tas bort
-   **Sparas som:** `Figurer/fysisk_aktivitet.svg/.png`

------------------------------------------------------------------------

### `tandhalsa()`

Linjediagram med facets (dålig/bra tandhälsa) för Uppsala jämfört med Riket (streckad), uppdelat på kön.

-   **Indata:** `Data/df_tandhalsa.csv`
-   **Sparas som:** `Figurer/tandhalsa.svg/.png`

------------------------------------------------------------------------

### `tandhalsa_behov()`

Linjediagram med facets (totalt avstått / av ekonomiska skäl) för andelen som avstått tandläkarvård trots behov, Uppsala jämfört med Riket (streckad), uppdelat på kön.

-   **Indata:** `Data/df_tandhalsa_avsta.csv`
-   **Sparas som:** `Figurer/tandhalsa_behov.svg/.png`

------------------------------------------------------------------------

### `stillasittande()`

Linjediagram med facets per kön för fördelningen av stillasittandegrupper per region. Skapar ett diagram per region. X-axeln glesas ut automatiskt om tidsserien är lång (\>6 år).

-   **Indata:** `Data/df_stillasittande.csv`
-   **Sparas som:** `Figurer/stillasittande_[Region].svg/.png`

------------------------------------------------------------------------

### `diabetes()`

Linjediagram med facets per kön för nyregistrerade fall av typ 2-diabetes per 100 000, för Riket och närliggande regioner. Uppsala markeras i mörkrosa (`#B81867`), övriga regioner i fasta färger.

-   **Indata:** `Data/df_diabetes.csv`
-   **Filter:** `Ålder == "Totalt 25- åldersstandardiserad"`
-   **Sparas som:** `Figurer/diabetes.svg/.png`

------------------------------------------------------------------------

### `hogt_blodtryck()`

Linjediagram med facets per blodtryckstyp för Uppsala jämfört med Riket (streckad), uppdelat på kön. Filtrerar rader där `Sjukdomar.och.besvär` innehåller "blodtryck".

-   **Indata:** `Data/df_sjukdomar_besvar.csv`
-   **Sparas som:** `Figurer/blodtryck.svg/.png`

------------------------------------------------------------------------

### `allergi()`

Linjediagram med facets (besvär / svåra besvär) för allergi i Uppsala jämfört med Riket (streckad), uppdelat på kön. Filtrerar rader innehållande "allergi".

-   **Indata:** `Data/df_sjukdomar_besvar.csv`
-   **Sparas som:** `Figurer/allergi.svg/.png`

------------------------------------------------------------------------

### `astma()`

Samma upplägg som `allergi()` men för astmabesvär. Filtrerar rader innehållande "astma".

-   **Indata:** `Data/df_sjukdomar_besvar.csv`
-   **Sparas som:** `Figurer/astma.svg/.png`

------------------------------------------------------------------------

### `huvudvark_tinnitus()`

Skapar separata linjediagram för sex besvärskategorier: Huvudvärk, Svår huvudvärk, Tinnitus, Svåra besvär av tinnitus, Yrsel och Svåra besvär av yrsel. Y-axeln sätts automatiskt till 0–10 om max-andelen understiger 5%, annars 0–100.

-   **Indata:** `Data/df_sjukdomar_besvar.csv`
-   **Sparas som:** `Figurer/[besvärskategori_i_lowercase].svg/.png` (6 filer)

------------------------------------------------------------------------

### `obesitas()`

Linjediagram med facets per kön för fördelningen av viktstatus (BMI-kategori) per region. Skapar ett diagram per region.

-   **Indata:** `Data/df_obesitas.csv`
-   **Sparas som:** `Figurer/obesitas_[Region].svg/.png`

------------------------------------------------------------------------

### `undervikt()`

Samma upplägg som `obesitas()` men visar enbart undervikt (BMI \< 18,5). Y-axeln är skalad till 0–10%.

-   **Indata:** `Data/df_obesitas.csv`
-   **Sparas som:** `Figurer/undervikt_[Region].svg/.png`

------------------------------------------------------------------------

## Levnadsvanor

### `alkohol()`

Linjediagram för andelen riskkonsumenter av alkohol i Uppsala jämfört med Riket (streckad), uppdelat på kön.

-   **Indata:** `Data/df_alkohol.csv`
-   **Sparas som:** `Figurer/alkohol.svg/.png`

------------------------------------------------------------------------

### `frukt_gront()`

Linjediagram med facets per kön för andelen som äter frukt respektive grönsaker minst 2 gånger/dag per region. Skapar ett diagram per region.

-   **Indata:** `Data/df_frukt_gront.csv`
-   **Filter:** Frukt/bär minst 2 ggr/dag och grönsaker/rotfrukter minst 2 ggr/dag
-   **Sparas som:** `Figurer/frukt_gront_[Region].svg/.png`

------------------------------------------------------------------------

### `rokning()`

Linjediagram för andelen dagligrökare i Uppsala jämfört med Riket (streckad), uppdelat på kön.

-   **Indata:** `Data/df_rokning.csv`
-   **Filter:** `Tobakskonsumtion == "Röker tobak dagligen"`
-   **Sparas som:** `Figurer/rokning.svg/.png`

------------------------------------------------------------------------

### `snus()`

Samma upplägg som `rokning()` men för andelen dagligsnusare.

-   **Indata:** `Data/df_rokning.csv`
-   **Filter:** `Tobakskonsumtion == "Snusar dagligen"`
-   **Sparas som:** `Figurer/snus.svg/.png`

------------------------------------------------------------------------

### `dryck()`

Linjediagram för andelen som dricker sötad dryck minst 2 gånger/vecka i Uppsala jämfört med Riket (streckad), uppdelat på kön.

-   **Indata:** `Data/df_dryck.csv`
-   **Sparas som:** `Figurer/dryck.svg/.png`

------------------------------------------------------------------------

### `spel()`

Linjediagram för andelen med riskabelt spelande i Uppsala jämfört med Riket (streckad), uppdelat på kön. Y-axeln är skalad till 0–20%.

-   **Indata:** `Data/df_spel.csv`
-   **Sparas som:** `Figurer/spel.svg/.png`

------------------------------------------------------------------------

### `narkotika()`

Linjediagram med facets per kön för narkotikabruk uppdelat på frekvens, Uppsala jämfört med Riket (streckad).

-   **Indata:** `Data/df_narkotika.csv`
-   **Sparas som:** `Figurer/narkotika.svg/.png`

------------------------------------------------------------------------

### `cannabis()`

Linjediagram med facets per kön för cannabisbruk uppdelat på frekvens, Uppsala jämfört med Riket (streckad).

-   **Indata:** `Data/df_cannabis.csv`
-   **Sparas som:** `Figurer/cannabis.svg/.png`

------------------------------------------------------------------------

## Sociala relationer

### `tillit()`

Stapeldiagram med facets per kön för kommunindex för sociala relationer och tillit, senaste tillgängliga år. Y-axeln 0–100.

-   **Indata:** `Data/df_tillit.csv`
-   **Filter:** Senaste år, exkluderar `"Sociala relationer och tillit - Kommunindex"` (totalt)
-   **Sparas som:** `Figurer/tillit.svg/.png`

------------------------------------------------------------------------

------------------------------------------------------------------------

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

------------------------------------------------------------------------


## Mappstruktur

```         
Projektmapp/
├── Script/
│   ├── install_load_packages.R   # Pakethantering
│   ├── settings.R                # Regioninställningar
│   ├── search_kolada.R           # Hjälpfunktion för Kolada
│   ├── survey_berakning.R        # Surveyberäkningsfunktion
│   ├── load_save_data.R
│   └── create_save_plots.R
├── Data/                         # Skapas automatiskt – CSV-filer
│   ├── Kommun_Sweref99TM/        # Kommungränser (laddas ned)
│   └── Lan_Sweref99TM/           # Länsgränser (laddas ned)
└── Figurer/                      # Skapas automatiskt – SVG och PNG
```

------------------------------------------------------------------------

## Datakällor

| Källa | Typ av data |
|------------------------------------|------------------------------------|
| SCB PxWeb API | Femårig livslängdstabell per utbildningsnivå |
| SCB (direktnedladdning) | Kommun- och länsgränser (Shape-fil) |
| Folkhälsomyndigheten API | Psykisk hälsa, fysisk aktivitet, levnadsvanor, sjukdomar |
| Kolada | Sociala relationer och tillit – kommunindex |
| GitHub (RegionUppsala-analys) | DeSO-geografifunktion |

------------------------------------------------------------------------

## Kända noteringar

| Skript | Notering |
|------------------------------------|------------------------------------|
| `create_save_plots.R` | Funktionsnamnet `livsland_tid()` är troligen ett stavfel – bör heta `livslangd_tid()` |
