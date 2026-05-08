# Dokumentation – R-skript för kulturanalys
*Uppsala län – bibliotek, kulturskola, bio, studieförbund, fritidskort och företagsregistret*

---

## Översikt

Projektet består av fem skript som tillsammans laddar hem, bearbetar och visualiserar statistik om kultur och fritid i Uppsala läns kommuner. Data hämtas från Kolada, SCB, Kulturanalys, Kulturdatabasen (KDB), KB:s biblioteksstatistik (Bibstat), E-hälsomyndigheten och Regeringen.se.

| Skript | Syfte |
|---|---|
| `load_save_data.R` | Hämtar data från externa källor och sparar lokalt |
| `create_save_plots.R` | Skapar och sparar ggplot2-diagram samt interaktiva kartor |
| `create_tables.R` | Skapar `gt`- och `reactable`-tabeller för Quarto-rapporten |
| `bibliotek_downloader.R` | Laddar ned biblioteksstatistik (Bibstat) inkrementellt |
| `skrapa_fritidskortsdata.R` | Skrapar fritidskort-data per län från Regeringen.se |
| `skapa_nya_sni.R` | Konverterar branschreferensfil från SNI 2007 till SNI 2025 |

---

## Gemensam konfiguration

`load_save_data.R`, `create_save_plots.R`, `create_tables.R` och `skrapa_fritidskortsdata.R` laddar gemensamma inställningar via:

```r
source("Script/install_load_packages.R")
source("Script/settings.R")
install_and_load()
settings <- get_settings()
```

Variabler som används genomgående:

| Variabel | Beskrivning |
|---|---|
| `kommunkod` | Kommunkoder för Uppsala läns kommuner |
| `kommuner` | Kommunnamn |
| `kommun_colors` | Färgpalett per kommun |
| `lanskod` | Länets kod |
| `lan` | Länets namn |

### Manuellt hanterad data

Flera datakällor kräver manuell hantering:

| Data | Källa | Notering |
|---|---|---|
| Företagsregistret | Flera CSV-filer | Genereras externt och sparas manuellt i `Data/` |
| Fritidskort per förening | `Fritidskortet_foreningar_[år].csv` | Genereras av `skrapa_fritidskortsdata.R` |

---

---

# `load_save_data.R` – Datainladdning

## Syfte

Hämtar kulturstatistik från Kolada, Kulturanalys och SCB och sparar som CSV-filer i `Data/`. Innehåller även funktionen `fritidskortsdata()` för att hämta fritidskortstatistik från E-hälsomyndighetens PDF-rapport. Varje funktion anropas direkt efter sin definition.

---

## Geografiska filer

Hämtar DeSO-geografifiler via GitHub-skript samt laddar ned SCB:s kommun- och länsgränser (SWEREF99TM) till `Data/Kommun_Sweref99TM/` och `Data/Lan_Sweref99TM/`. Existenskontroll finns för Shape-filen.

---

## Kolada – medborgarundersökning

### `func_df_enkat_kultur()`
Hämtar andelen som svarat "bra eller mycket bra" på frågan om det lokala kultur- och nöjeslivet, från SCB:s medborgarundersökning, från år 2010 och framåt. Inkluderar osäkerhetstal. Pivoteras till wide-format med andel och osäkerhetstal som separata kolumner. Kön kodas om till svenska etiketter (K→Kvinnor, M→Män, övriga→Total). Filtrerar på Uppsala läns kommuner och Region Uppsala.

- **Källa:** Kolada (`"Det lokala kultur- och nöjeslivet i kommunen är bra, andel (%)"`)
- **Sparas som:** `Data/df_enkat_kultur.csv`

---

## Kolada – kostnader och intäkter

### `func_df_nettokostnad()`
Hämtar nettokostnader (kr/inv) för fem kulturverksamheter: kulturverksamhet totalt, allmän kulturverksamhet, bibliotek, musik- och kulturskola samt stöd till studieorganisationer. Slår ihop alla fem och filtrerar på Uppsala läns kommuner och Riket. Exkluderar KPI `N85004`.

- **Sparas som:** `Data/df_nettokostnad.csv`

---

### `func_df_Kostnad_intakt()`
Hämtar bruttokostnader och intäkter (kr/inv) för samma fem kulturverksamheter som `func_df_nettokostnad()`. Hämtar kostnader och intäkter i separata API-anrop och slår ihop till ett dataset. Filtrerar på Uppsala läns kommuner och Riket. Exkluderar KPI `N85014`.


- **Sparas som:** `Data/df_Kostnad_intakt.csv`

---

## Kolada – deltagande och kulturskola

### `func_df_deltagande()`
Hämtar andelen som deltar i kultur (%) per region. Filtrerar på kommuner (`municipality_type == "L"`), år från 2010 och framåt.

- **Sparas som:** `Data/df_deltagande.csv`

---

### `func_df_elever()`
Hämtar tre mått på elever i musik- eller kulturskola: andel 6–19 år (%), andel 6–15 år (%) och totalt antal. Filtrerar på år 2010 och framåt.

- **Sparas som:** `Data/df_elever.csv`

---

### `func_df_oppen_skola()`
Hämtar om kommunen har öppen verksamhet i kulturskolan (Ja=1, Nej=0), år 2010 och framåt.

- **Sparas som:** `Data/df_oppen_skola.csv`

---

### `func_df_amne()`
Hämtar om tolv ämneskurser erbjuds i musik- eller kulturskolan (Ja=1, Nej=0): musik/ensemble, dans, teater/drama, bild och form, musikal, cirkus, film/animation, foto, slöjd/hantverk, skrivande/berättande, övriga samt antal ämnesområden totalt.

- **Sparas som:** `Data/df_amne.csv`

---

### `df_skola_kon()`
Hämtar andelen flickor i kulturskolan (6–19 år, %) per kommun, år 2010 och framåt.


- **Sparas som:** `Data/df_skola_kon.csv`

---

### `func_df_genomkost()`
Hämtar genomsnittlig elevavgift i musik- eller kulturskola (kr/elever 6–19 år) per kommun, år 2010 och framåt.

- **Sparas som:** `Data/df_genomkost.csv`

---

## Kolada – kommunens köp av kultur

### `func_df_kost_andel()`
Hämtar andelen gemensamma kostnader fördelade till kulturverksamhet (%) för Uppsala läns kommuner och Riket, från år 2010.

- **Sparas som:** `Data/df_kost_andel.csv`

---

### `func_df_kop_kf()`
Hämtar kommunens köp av kultur och fritid (%) uppdelat på fyra kategorier: totalt, från offentliga utförare, från privata utförare och från privatägda företag. Filtrerar från år 2015.

- **Sparas som:** `Data/df_kop_kf.csv`

---

## Kolada – sysselsättning

### `func_df_sysselkolada()`
Hämtar andelen sysselsatta inom kulturella och personliga tjänster per kön och belägenhet (arbetsställets resp. bostadens belägenhet), år 2010 och framåt.

- **Sparas som:** `Data/df_sysselkolada.csv`

---

## Kulturanalys – biografdata

### `func_kommun_biodata()`
Hämtar biografstatistik (antal biografer) per Uppsala-kommunkod och år från Kulturanalys API. Värdena kan inte extraheras via `as.data.frame()` direkt utan hämtas manuellt ur `px_data$data` med `vapply()`.

- **Källa:** Kulturanalys PxWeb API (FPB_MUNICIPA.Px)
- **Sparas som:** `Data/df_kommun_bio.csv`

---

### `func_df_region_bio()`
Hämtar biografstatistik per region och år med alla tillgängliga mått (besök/inv, biografer/miljon inv, salonger/miljon inv, visningar/1000 inv m.fl.). Bygger dataframe manuellt ur `px_data$data` med `lapply()` och transponerar värdevektorn till kolumner.

- **Källa:** Kulturanalys PxWeb API (FPB_REGION.Px)
- **Sparas som:** `Data/df_region_bio.csv`

---

## SCB – studieförbund

### `func_df_studieforbund()`
Hämtar studieförbundsstatistik (deltagare, arrangmang, studietimmar, deltagartimmar) per region, verksamhetsform och år för Uppsala läns kommuner. Filtrerar på totalt studieförbund (`TOTFORB`), totalt arrangemangstyp och totalt distans/ej distans. Tar bort NA-värden.

- **SCB-tabell:** StudieforbHelarLanKo (KU0402)
- **Sparas som:** `Data/df_studieforbund.csv`

---

## E-hälsomyndigheten – fritidskort

### `fritidskortsdata(year = 2025)`
Laddar ned E-hälsomyndighetens PDF-rapport om fritidskort per kommun för angivet år, extraherar tabellen med `pdftools::pdf_text()` via regex och sparar som CSV. Hoppar över kommuner med värdet `<20` (sekretessbelagt). Tar bort rader där parsningen misslyckades (`complete.cases()`).

- **Källa:** E-hälsomyndigheten (`ehalsomyndigheten.se`)
- **Parameter:** `year` – publiceringsåret (default 2025)
- **Sparas som:** `Data/fritidskort_[år].csv`

> **OBS!** URL:en är konstruerad dynamiskt baserat på år, men om E-hälsomyndigheten ändrar sin URL-struktur måste `url`-strängen i funktionen uppdateras manuellt.

---

---

# `create_save_plots.R` – Diagramskapande

## Syfte

Läser in lokalt sparad data och skapar statiska ggplot2-diagram (sparas i `Figurer/` som SVG/PNG) samt interaktiva Plotly- och Leaflet-objekt (returneras för inbäddning i Quarto). Skriptet innehåller även diagram från `create_tables_plots.R` (dokumenteras i dokument 7).

---

## Medborgarundersökning

### `medborgarund_kultur()`
Skapar ett diagram per region (alla kommuner + Uppsala län) som visar andelen nöjda med kultur- och nöjeslivet. Väljer automatiskt diagramtyp: om en region har mer än ett mätår skapas ett **linjediagram** med konfidensband per kön; om bara ett år finns skapas ett **stapeldiagram** med felstaplar. Konfidensintervall beräknas som andel ± osäkerhetstal. För totalvärdet (ej kön) nollställs banden.

- **Indata:** `Data/df_enkat_kultur.csv`
- **Sparas som:** `Figurer/medborgarund_kultur_[Region].svg/.png`

---

## Kostnader och intäkter

### `kostnad_intakt()`
Skapar ett linjediagram per typ (kostnad/intäkt) för kulturverksamhet totalt, med alla Uppsala-kommuner och Riket. Y-axeln börjar vid 0. Var 2:e år visas på x-axeln.

- **Indata:** `Data/df_Kostnad_intakt.csv`
- **Filter:** Enbart `"Kulturverksamhet"` (totalnivån)
- **Sparas som:** `Figurer/kostnad_intakt_kostnad.svg/.png`, `Figurer/kostnad_intakt_intäkt.svg/.png`

---

### `nettokostnad_kultur()`
Interaktivt Plotly-linjediagram med nettokostnader (kr/inv) per kulturverksamhetstyp för alla kommuner och Riket. Dropdown-meny för att välja verksamhetstyp. Riket visas i svart, kommunerna i sina respektive färger.

- **Indata:** `Data/df_nettokostnad.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

## Deltagande och kulturskola

### `deltagande()`
Linjediagram som visar deltagarandelen inom kultur för alla svenska regioner. Uppsala markeras i mörkrosa med tjockare linje och stor punkt. Regioner med lägst och högst värde i senaste år märks ut med textetiketter till höger (nudge_x). Alla övriga visas i grått.

- **Indata:** `Data/df_deltagande.csv`
- **Sparas som:** `Figurer/deltagande.svg/.png`

---

### `elever_mk()`
Linjediagram per åldersgrupp (6–15 år resp. 6–19 år) som visar andelen barn i musik- eller kulturskoleverksamhet per kommuner i Uppsala, från år 2018. Y-axeln är fast vid 0–30%.

- **Indata:** `Data/df_elever.csv`
- **Filter:** Exkluderar totalt antal, filtrerar kön `T` (totalt)
- **Sparas som:** `Figurer/elever_mk_6-15.svg/.png`, `Figurer/elever_mk_6-19.svg/.png`

---

### `andel_kost_kult()`
Linjediagram som visar andelen gemensamma kostnader fördelade till kulturverksamhet (%) för alla kommuner och Riket. Y-axeln är –5 till 15%.

- **Indata:** `Data/df_kost_andel.csv`
- **Sparas som:** `Figurer/kost_andel.svg/.png`

---

### `kop_kf()`
Linjediagram per kommun som visar kommunens köp av kultur och fritid uppdelat på utförartyp (offentlig, privat, privatägda företag). Totalt exkluderas. Skapar en fil per kommuner i länet.

- **Indata:** `Data/df_kop_kf.csv`
- **Sparas som:** `Figurer/kop_kf_[KommunNamn].svg/.png`

---

### `amneskurs()`
Heat map (geom_tile) per kommun som visar vilka ämneskurser som erbjuds i kulturskolan (Ja=grön, Nej=röd) per år. Variabelnamnen rensas från `"(Ja=1, Nej=0)"` och liknande.

- **Indata:** `Data/df_amne.csv`
- **Sparas som:** `Figurer/amneskurs_[KommunNamn].svg/.png`

---

### `genom_elevkost()`
Linjediagram som visar genomsnittlig elevavgift (kr/elever) i musik- eller kulturskolan per kommuner i länet.

- **Indata:** `Data/df_genomkost.csv`
- **Sparas som:** `Figurer/genom_elevkost.svg/.png`

---

## Sysselsättning

### `syssel_kol()`
Linjediagram per kommuner med facets (arbetsställets belägenhet / bostadens belägenhet) för andelen sysselsatta inom kulturella och personliga tjänster, uppdelat på kön. Y-axeln är gemensam för alla kommuner (global max + 0.5).

- **Indata:** `Data/df_sysselkolada.csv`
- **Filter:** Exkluderar kön `T` (totalt)
- **Sparas som:** `Figurer/syssel_kol_[KommunNamn].svg/.png`

---

## Biografdata (Kulturanalys)

### `biosalonger_region()`
Scatterplot som jämför alla svenska läns biosalongsdata för senaste år: besök/inv, biografer/miljon inv, salonger/miljon inv och visningar/1000 inv – i fyra facets. Uppsala markeras i mörkrosa med större punkt. Riket exkluderas. Kommunerna sorteras i fallande bokstavsordning på y-axeln.

- **Indata:** `Data/df_region_bio.csv`
- **Filter:** Senaste år, enbart länsnivå (exkl. Riket)
- **Sparas som:** `Figurer/biosalonger_region.svg/.png`

---

## Företagsregistret – arbetsställen

### `andel_arbets()`
Stapeldiagram som visar andelen aktiva arbetsställen inom kultur (%) per kommuner i länet, sorterat i fallande bokstavsordning. Y-axeln 0–20%.

- **Indata:** `Data/df_antal_arbets_kultur.csv`
- **Sparas som:** `Figurer/andel_arbets.svg/.png`

---

### `karta_anst_b_s()`
Interaktiv Leaflet-karta med kulturarbetsställen i Uppsala som punkter, färgkodade per branschkategori. Lagerkontrollen filtrerar på storleksklass (antal anställda). Popup visar bransch, storleksklass och kommun.

- **Indata:** `Data/sf_pts_uppsala.gpkg` (layer: `firmor`), länsgränser Shape-fil
- **Returneras** som interaktiv Leaflet-karta.

---

### `karta_anst_b()`
Samma karta som `karta_anst_b_s()` men med lagerkontrollen baserad på **branschkategori** istället för storleksklass.

- **Indata:** `Data/sf_pts_uppsala.gpkg`, länsgränser Shape-fil
- **Returneras** som interaktiv Leaflet-karta.

---

### `andel_storlek_kom()`
Horisontellt stapeldiagram som visar fördelningen av kulturarbetsställen per storleksklass och kommuner i länet.

- **Indata:** `Data/df_antal_arbets_kultur_storlek.csv`
- **Sparas som:** `Figurer/andel_storlek_kom.svg/.png`

---

### `andel_bransch_kom()`
Horisontellt stapeldiagram som visar fördelningen av kulturarbetsställen per branschkategori och kommuner i länet.

- **Indata:** `Data/df_kulturkategori_per_kom.csv`
- **Sparas som:** `Figurer/andel_bransch_kom.svg/.png`

---

## Företagsregistret – företag

### `andel_foretag()`
Stapeldiagram som visar andelen aktiva kulturföretag (%) per kommuners säteskommun.

- **Indata:** `Data/df_antal_firm_kultur.csv`
- **Sparas som:** `Figurer/andel_firm.svg/.png`

---

### `andel_storlek_kom_firm()`
Horisontellt stapeldiagram: fördelning av kulturföretag per storleksklass och säteskommun.

- **Indata:** `Data/df_antal_firm_kultur_storlek.csv`
- **Sparas som:** `Figurer/andel_storlek_kom_firm.svg/.png`

---

### `andel_bransch_kom_frim()`
Horisontellt stapeldiagram: fördelning av kulturföretag per branschkategori och säteskommun.

> **OBS!** Funktionsnamnet har ett stavfel (`frim` istället för `firm`).

- **Indata:** `Data/df_kulturkategori_firm_per_kom.csv`
- **Sparas som:** `Figurer/andel_bransch_kom_firm.svg/.png`

---

### `omsattning_per_storlek_och_bransch()`
Horisontellt stapeldiagram som visar fördelningen av kulturföretag per omsättningsstorleksklass och branschkategori för Uppsala län. Antal och andel per omsättningsklass visas som textetiketter till höger om staplarna (utanför 100%-linjen, med `coord_cartesian(clip = "off")`).

- **Indata:** `Data/df_kulturkategori_firm_per_lan_storlek.csv`
- **Sparas som:** `Figurer/andel_bransch_omsatt.svg/.png`

---

## Kulturdatabasen (KDB)

> Alla KDB-funktioner läser från `Data/KDB-Uppsala.xlsx`. Filen måste laddas ned manuellt från Kulturrådet. Dataparsningen är komplex: kolumnnamn hämtas från rad 6 (skip=5), och datablocket lokaliseras via `which()` på radinnehållet.

### `forestallning_konsert()`
Visar publiksnittet per föreställning/konsert (Publik / Föreställningar) uppdelat på typ (Egen och samproduktion / Gästspel) för varje intern plats (totalt i länet, övriga interna m.fl.). Skapar ett diagram per plats.

- **KDB-sheet:** `3 - Tidsserier`, sektion `4.3`
- **Sparas som:** `Figurer/forestallning_konsert_[Plats].svg/.png`


---

### `forestallning_konsert_ant()`
Visar antal föreställningar/konserter (ej publik) uppdelat på typ, per plats. Annars samma pipeline som `forestallning_konsert()`.

- **Sparas som:** `Figurer/forestallning_konsert_ant_[Plats].svg/.png`

---

### `forestallning_konsert_pub()`
Visar publiktotalen (antal åskådare) per föreställningstyp och plats. Annars samma pipeline.

- **Sparas som:** `Figurer/forestallning_konsert_pub_[Plats].svg/.png`

---

### `museer_konsthallar2()`
Visar antal anläggnings- och verksamhetsbesök per museum och år. Läser från `Data/kulturdatabasen.xlsx` (sheet: `Museer - Data`). Skapar ett totaldiagram för "totalt i länet". Inkluderar bara museer som har data för senaste eller näst senaste år. Hoppar inte över enstaka observationer (till skillnad från `inkomst_per_verksamhet_1()`).

- **Sparas som:** `Figurer/besok_museer2_[Museum].svg/.png`

---

### `inkomst_per_verksamhet_1()`
Visar intäktsutvecklingen per museum från `kulturdatabasen.xlsx`. Hoppar över museum med bara en observation. Inkluderar bara museer med data för senaste eller näst senaste år.

- **Sparas som:** `Figurer/inkomst_per_verksamhet_[Museum].svg/.png`

---

### `inkomst_per_verksamhet_2()`
Visar intäkter och kostnader per intern plats från `KDB-Uppsala.xlsx` (sektion `4.1`). Avgränsar datablocket till att sluta före sektion `4.2`. Hoppar över platser med bara en observation.

- **Sparas som:** `Figurer/inkomst_per_verksamhet_[Plats].svg/.png`

---

### `bidrag_per_verksamhet()`
Visar intäktskategorier (bidrag m.m.) per intern KDB-plats för senaste tillgängliga år som horisontella staplar. Lovar textetiketter med antal kr till höger om staplarna. Läser sektion `2.1` från sheet `4 - Org, ekonomi och personal`, avgränsat till raden `2.1b Årliga bidrag`.

- **Sparas som:** `Figurer/intakt_bidrag_[Plats].svg/.png`

---

## Studieförbund

### `studiefordelning_kon()`
Stapeldiagram per region med könsfördelning (Kvinnor/Män) bland studieförbundens deltagare per år. Procentandelen visas som textetikett ovanför varje stapel.

- **Indata:** `Data/df_studieforbund.csv`
- **Filter:** `verksamhetsform == "Totalt"`
- **Sparas som:** `Figurer/studieforbund_kon_[Region].svg/.png`

---

### `studiefordelning()`
Linjediagram per region med antal arrangemang per verksamhetsform (Studiecirkel, Kulturprogram, Annan folkbildningsverksamhet, Fri) över tid. Exkluderar "Totalt" och "Uppsökande verksamhet".

- **Indata:** `Data/df_studieforbund.csv`
- **Sparas som:** `Figurer/studieforbund_[Region].svg/.png`

---

### `forbund_kvot()`
Linjediagram per kommuner med facets (deltagare per studietimme / genomsnittlig studietid) för att visualisera effektivitetsmått i studieförbundsverksamheten. Y-axeln är global (max av alla kommuner + 0.5).

- **Indata:** `Data/df_studieforbund.csv`
- **Filter:** `verksamhetsform == "Totalt"`
- **Sparas som:** `Figurer/forbund_kvot_[KommunNamn].svg/.png`

---

## Fritidskort

### `fritidskort_kommun(year = 2025)`
Skapar tre stapeldiagram per numerisk kolumn (antal beviljade, antal använda, kvot använda/beviljade) för Uppsala-kommunerna. Varje diagram visar riksmedian, nedre kvartil och övre kvartil (beräknade på rikets alla kommuner) som referenslinjer.

- **Indata:** `Data/fritidskort_[år].csv`
- **Sparas som:** `Figurer/fritidskort_kommun_[kolumn].svg/.png`

---

### `fritidskort_lan(year = 2025)`
Stapeldiagram för Uppsala läns fritidskort per förening, med riksmedian och kvartiler som referenslinjer. Sparar också ett filtrerat dataset för Uppsala till CSV.

- **Indata:** `Data/Fritidskortet_foreningar_[år].csv`
- **Sparas som:** `Figurer/fritidskort_lan.svg/.png`, `Data/fritidskort_uppsala.csv`

---

## Bibliotek

### `biblioteks_folk()`
Linjediagram per folkbibliotek i Uppsala med facets för tre mått: antal fysiska besök, totalt antal lån och antal aktiva låntagare. Var 2:e år visas på x-axeln.

- **Indata:** `Data/bibstat_uppsala_kommuner.csv`
- **Filter:** `Bibliotekstyp == "folkbib"`
- **Sparas som:** `Figurer/biblioteks_folk_[Biblioteksnamn].svg/.png`

---

### `biblioteks_antal_lan()`
Staplat stapeldiagram per kommuner som visar totalt antal lån av fysiskt medium uppdelat på bibliotekstyp (folkbibliotek, skolbibliotek, universitetsbibliotek m.fl.) och år. Hämtar kommunnamn via SCB:s API (BE0101A) och matchar mot kommunkoder. Legenden anpassas automatiskt (2 eller 3 rader beroende på antal bibliotekstyper).

- **Indata:** `Data/bibstat_uppsala_kommuner.csv`
- **SCB API:** Enbart för kommunnamnsuppslag (BE0101A)
- **Sparas som:** `Figurer/biblioteks_antal_lan_[KommunNamn].svg/.png`

---

---

# `create_tables.R` – Tabellskapande

## Syfte

Skapar `gt`- och `reactable`-tabeller för Quarto-rapporten. Alla tabeller använder en gemensam rosa färgskala (`#F4DCE8` → `#B81867`). Tabeller returneras som objekt (renderas direkt i Quarto, sparas ej som filer).

---

## `kostnad_intakt()`
`reactable`-tabell med kostnader och intäkter (kr/inv) per kulturverksamhetstyp och kommuner för senaste tillgängliga år. Visar också andel av totalbudgeten. Filtrerbara kommuner via klickbara knappar ovan tabellen (`Reactable.setFilter`). Knappraden skapas med `htmltools::div()` och `tags$button()`.

- **Indata:** `Data/df_Kostnad_intakt.csv`
- **Kolumner:** Verksamhet, Kommun, Kostnad (kr/inv), Andel kostnad (%), Intäkt (kr/inv), Andel intäkt (%)
- **Returneras** som `div` med knappar + `reactable`.

---

## `antal_arbets()`
`gt`-tabell med antal och andel aktiva kulturarbetsställen per kommuner. Färgkodas med rosa skala. Visar hämtningsår som undertitel.

- **Indata:** `Data/df_antal_arbets_kultur.csv`
- **Returneras** som `gt`-tabell.

---

## `antal_foretag()`
`gt`-tabell med antal och andel aktiva kulturföretag per säteskommun. Samma upplägg som `antal_arbets()`.

- **Indata:** `Data/df_antal_firm_kultur.csv`
- **Returneras** som `gt`-tabell.

---

## `antal_storlek_kom_t()`
`gt`-tabell med antal kulturarbetsställen per storleksklass (0–200+ anställda) och kommuner i wide-format. Färgkodas kolumnvis.

- **Indata:** `Data/df_antal_arbets_kultur_storlek.csv`
- **Returneras** som `gt`-tabell.

---

## `antal_storlek_kom_t_firm()`
`gt`-tabell med antal kulturföretag per storleksklass och säteskommun. Samma upplägg som `antal_storlek_kom_t()`.

- **Indata:** `Data/df_antal_firm_kultur_storlek.csv`
- **Returneras** som `gt`-tabell.

---

## `antal_bransch_kom_t()`
`gt`-tabell med antal kulturarbetsställen per branschkategori och kommuner i wide-format.

- **Indata:** `Data/df_kulturkategori_per_kom.csv`
- **Returneras** som `gt`-tabell.

---

## `antal_bransch_kom_t_firm()`
`gt`-tabell med antal kulturföretag per branschkategori och säteskommun.

- **Indata:** `Data/df_kulturkategori_firm_per_kom.csv`
- **Returneras** som `gt`-tabell.

---

## `konsfordelning_skola()`
`gt`-tabell med andelen flickor i kulturskolan (6–19 år, %) per kommuner i wide-format för senaste 9 år (max år – 8 till max år). Färgkodas med ett fast värdeintervall baserat på hela det filtrerade datasetet.

- **Indata:** `Data/df_skola_kon.csv`
- **Returneras** som `gt`-tabell.

---

## `biografer()`
`gt`-tabell med antal biografer per Uppsala-kommunerna i wide-format (år som kolumner). Färgkodas med rosa skala.

- **Indata:** `Data/df_kommun_bio.csv`
- **Returneras** som `gt`-tabell.

---

## `biosalong_trend_region()`
Returnerar **två** `gt`-tabeller i en lista:

1. Besök per invånare för Uppsala och Riket per år
2. Visningar per 1 000 invånare för Uppsala och Riket per år

Båda tabellerna har fast färgdomän baserad på respektive mått.

- **Indata:** `Data/df_region_bio.csv`
- **Filter:** Enbart `"Riket"` och `"Uppsala län"`
- **Returneras** som `list(t1, t2)`.

---

## `forestallning_konsert_tbl()`
`gt`-tabell med scenföreställningsdata (publik och föreställningar uppdelat på typ och plats) för senaste tillgängliga år från KDB. Dataparsning identisk med diagramfunktionerna. Färgkodas med global min/max.

- **Indata:** `Data/KDB-Uppsala.xlsx`, sheet `3 - Tidsserier`, sektion `4.3`
- **Returneras** som `gt`-tabell.

---

---

# `bibliotek_downloader.R` – Inkrementell biblioteksnedladdning

## Syfte

Fristående skript (kräver inte `settings.R`) som automatiskt laddar ned Bibstat-data (KB:s biblioteksstatistik) för Uppsala läns kommuner och uppdaterar en lokal CSV-fil inkrementellt – dvs. enbart saknade år laddas ned.

---

## `biblioteks_data(kommunkod, datafil)`

Yttre funktion med två inbäddade hjälpfunktioner:

### `hamta_tillgangliga_ar()`
Skrapar tillgängliga statistikår från `bibstat.kb.se` via `rvest`. Returnerar en sorteradvektor av heltal. Filtrerar sedan bort år före 2014 (annorlunda datastruktur).

### `hamta_ar(ar)`
Laddar ned ett enstaka år som Excel-fil via Bibstats exportlänk (`bibstat.kb.se/export?sample_year=[år]`), läser med `read_excel()`, hittar kommunkolumnen automatiskt via mönstermatchning (`kommunkod|municipality_code|kommun_kod`) och filtrerar på angivna kommunkoder. Returnerar `NULL` vid misslyckad nedladdning eller saknad kommunkolumn (med `warning()`).

### Logik för inkrementell uppdatering:
1. Om CSV-filen redan finns: läs in befintliga år och beräkna saknade år (`setdiff(alla_ar, ar_i_fil)`)
2. Om CSV-filen saknas: ladda ned alla tillgängliga år från 2014 och framåt
3. Lägg till nya data med `bind_rows()` och skriv över filen

- **Standardparametrar:** Uppsala läns åtta kommunkoder (`0305`, `0319`, `0330`, `0331`, `0360`, `0380`, `0381`, `0382`)
- **Sparas som:** `Data/bibstat_uppsala_kommuner.csv`

---

---

# `skrapa_fritidskortsdata.R` – Fritidskort per län (Regeringen.se)

## Syfte

Skrapar tabellen med antal nedladdade fritidskort och antal föreningar per **län** från Regeringskansliets pressmeddelande och sparar som CSV. Kompletterar `fritidskortsdata()` i `load_save_data.R` som hämtar per-**kommun**-data från E-hälsomyndigheten.

---

## `hamta_fritidskort_data(year = 2025)`

Hämtar Regeringens HTML-sida via `rvest::read_html()`, extraherar första `<table>`-element och rensar kolumnnamnen. Konverterar tal (tar bort tusenavgränsare och mellanslag). Lägger till `år` som metadatakolumn. Sorterar på fallande antal nedladdade kort.

**Felhantering:**
- Nätverksfel fångas med `tryCatch` och ger ett tydligt felmeddelande
- Om tabellen saknas (sidstruktur ändrad): `stop()`
- Om antalet kolumner avviker från förväntat (3): `warning()`

- **Parameter:** `year` – publiceringsår (default 2025)
- **Källa:** Regeringen.se pressmeddelande (december det aktuella året)
- **Sparas som:** `Data/Fritidskortet_foreningar_[år].csv`

> **OBS!** URL:en är konstruerad dynamiskt och förutsätter att pressmeddelandet publiceras i december varje år med samma URL-mönster. Om Regeringen.se ändrar strukturen måste `url_template` uppdateras.

---

---

# `skapa_nya_sni.R` – Konvertering av SNI-koder

## Syfte

Engångsskript som konverterar en befintlig branschreferensfil (`nyckel_bransch.txt`) från SNI 2007 till SNI 2025 via en kopplingsnyckel. Resultatet används av övriga skript för att klassificera kulturföretag och arbetsställen.

---

## Flöde

1. Läser in `nyckel_bransch.txt` (kolumnerna: `branschkod`, `branschkategori`, `branschnamn`)
2. Läser in `nyckel_yrke.txt` (kolumnerna: `SSYK4_2012`, `Kulturskapare`, `Namn`, `yrkeskategori`)
3. Läser in kopplingsfilen `nyckel-sni2007---sni2025.xlsx` och byter namn på kolumnerna till `SNI2007` och `SNI2025`
4. Gör ett vänster-join på `branschkod = SNI2007` och ersätter `branschkod` med `SNI2025`
5. Kontrollerar antal NA-värden efter matchningen (`sum(is.na(fil1_ny$branschkod))`)
6. Sparar resultatet som `nyckel_bransch_SNI2025.txt`

> **OBS!** Yrkesmatchningsblocket (`fil2_ny`) är kommenterat ut (`"..."`) med en fråga "Behövs ej?" och körs inte. Utdataraden `write_tsv(fil2_ny, ...)` refererar till ett objekt som aldrig skapas och ger fel om den kommenterade koden tas bort.

- **Indata:** `nyckel_bransch.txt`, `nyckel_yrke.txt`, `nyckel-sni2007---sni2025.xlsx`
- **Sparas som:** `nyckel_bransch_SNI2025.txt`

---

## Ej offentlig funktionalitet

Projektet innehåller ytterligare analys- och visualiseringsfunktioner som inte ingår i den publika dokumentationen.

Dessa komponenter behandlar känsliga eller sekretessreglerade data och har därför exkluderats från det öppna repositoriet. De omfattar bland annat:

- ej offentliga databaser

De interna funktionerna följer samma övergripande arkitektur som övriga diagramfunktioner:
- datainläsning
- ggplot-/plotly-baserad visualisering
- export till SVG/PNG

Publik dokumentation beskriver endast de delar som kan delas öppet utan risk för röjande av känslig information.


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
│   ├── create_tables.R
│   ├── bibliotek_downloader.R
│   ├── skrapa_fritidskortsdata.R
│   └── skapa_nya_sni.R
├── Data/
│   ├── Kommun_Sweref99TM/           # SCB kommungränser
│   ├── Lan_Sweref99TM/              # SCB länsgränser
│   ├── DeSO_2025.gpkg               # DeSO-geografi
│   ├── bibstat_uppsala_kommuner.csv # Biblioteksstat (genereras av bibliotek_downloader.R)
│   │
│   │   # Genereras av load_save_data.R:
│   ├── df_enkat_kultur.csv
│   ├── df_nettokostnad.csv
│   ├── df_Kostnad_intakt.csv
│   ├── df_deltagande.csv
│   ├── df_elever.csv
│   ├── df_oppen_skola.csv
│   ├── df_amne.csv
│   ├── df_skola_kon.csv
│   ├── df_genomkost.csv
│   ├── df_kost_andel.csv
│   ├── df_kop_kf.csv
│   ├── df_sysselkolada.csv
│   ├── df_kommun_bio.csv
│   ├── df_region_bio.csv
│   ├── df_studieforbund.csv
│   ├── fritidskort_[år].csv         # Genereras av fritidskortsdata()
│   │
│   │   # Genereras av skrapa_fritidskortsdata.R:
│   └── Fritidskortet_foreningar_[år].csv
│
│   # Manuellt placerade (från Företagsregistret):
│   ├── df_antal_arbets_kultur.csv
│   ├── df_antal_arbets_kultur_storlek.csv
│   ├── df_kulturkategori_per_kom.csv
│   ├── df_antal_firm_kultur.csv
│   ├── df_antal_firm_kultur_storlek.csv
│   ├── df_kulturkategori_firm_per_kom.csv
│   └── df_kulturkategori_firm_per_lan_storlek.csv
└── Figurer/                         # Skapas automatiskt – SVG och PNG
```

---

## Datakällor

| Källa | Typ av data |
|---|---|
| Kolada | Medborgarundersökning, nettokostnader, elever, sysselsättning |
| SCB PxWeb API | Studieförbundsstatistik (KU0402) |
| Kulturanalys PxWeb API | Biografstatistik per region och kommun |
| KB Bibstat | Biblioteksstatistik per bibliotek och år |
| E-hälsomyndigheten (PDF) | Fritidskort per kommuner |
| Regeringen.se (HTML-skrapning) | Fritidskort per förening och län |
| Databasen / DATA | Kulturskapare (ej publik, manuell uppladdning) |
---

## Kända noteringar

| Skript | Notering |
|---|---|
| `load_save_data.R` | `fritidskortsdata()` – URL behöver uppdateras om E-hälsomyndigheten ändrar sin URL-struktur |
| `create_save_plots.R` | `inkomst_per_verksamhet_1()` och `_2()` kan skapa filnamnskrockar om museum och KDB-plats har samma namn, blir rätt om de körs i ordning |
| `skapa_nya_sni.R` | `write_tsv(fil2_ny, ...)` på sista raden refererar till ett objekt som aldrig skapas (yrkesskpet är kommenterat ut) – ger fel om raden körs |
| `skrapa_fritidskortsdata.R` | URL förutsätter publicering i december varje år med samma URL-mönster |