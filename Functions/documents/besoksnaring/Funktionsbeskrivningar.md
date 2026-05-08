# Dokumentation – R-skript för turism- och besöksnäringsanalys
*Uppsala län*

---

## Översikt

Projektet består av fyra skript som tillsammans förbereder referensfiler, hämtar statistik och skapar visualiseringar för en rapport om turism och besöksnäring i Uppsala län. Data hämtas från SCB, Tillväxtverkets API, Kolada och Visit Sweden, samt från interna datafiler (databasen/DATA).
| Skript | Syfte |
|---|---|
| `skapa_ssyk_fil.R` | Skapar en referensfil med turismrelaterade SSYK-yrken |
| `sni_xl_to_txt.R` | Konverterar SNI-branschkoder från Excel till textfil med SNI 2025-koder |
| `load_save_data.R` | Hämtar turism- och befolkningsdata från externa källor och sparar lokalt |
| `create_save_plots.R` | Skapar och sparar diagram och kartor för rapporten |

---

## Gemensam konfiguration

`load_save_data.R` och `create_save_plots.R` laddar gemensamma inställningar via:

```r
source("Script/install_load_packages.R")
source("Script/settings.R")
source("Script/search_kolada.R")
install_and_load()
settings <- get_settings()
```

Följande variabler används:

| Variabel | Beskrivning |
|---|---|
| `kommunkod` | Kommunkoder för Uppsala läns kommuner |
| `kommuner` | Kommunnamn |
| `kommun_colors` | Färgpalett per kommun |
| `lanskod` | Länets kod |
| `lan` | Länets namn |
| `riket_narliggande` | Riket och närliggande regioner (för jämförelser) |

En intern konstant `mellan_sverige` definieras i `load_save_data.R` och innehåller Uppsala, Södermanland, Östergötland, Örebro, Västmanland, Gävleborg och Stockholm – används för regionala jämförelser.

---

---

# `skapa_ssyk_fil.R` – Referensfil för turismyrken

## Syfte

Engångsskript som skapar en referensfil med alla SSYK 2012-yrkeskoder (4-siffernivå) som klassificeras som turismrelaterade. Filen används sedan i analyser för att identifiera anställda inom besöksnäringen.

## Flöde

1. Laddar ned SCB:s officiella SSYK 2012-kodfil (Excel) direkt från SCB:s webbplats till en temporär fil.
2. Läser in fliken `4-siffer` med 4-siffriga yrkeskoder och namn.
3. Klassificerar varje yrkeskod i två kategorinivåer:

**Huvudkategori (`kategori`)** – fem turismrelaterade kategorier:

| Kategori | Beskrivning |
|---|---|
| Äta | Restaurang, kök, café/bageri, mat & dryck |
| Bo | Hotell- och logiverksamhet |
| Resa | Transport, reseledare, resebyrå |
| Göra | Event, sport, kultur, media |
| Handla | Detaljhandel |

**Underkategori (`yrkeskategori`)** – nio mer specifika grupper: Mat & dryck, Café/Bageri/Konditori, Boende, Transport, Bokning & service, Event & upplevelser, Sport & fritid, Kultur & media, Handel.

4. Filtrerar bort yrken som inte tillhör någon turismkategori (`"Övrigt"` exkluderas).
5. Sparar resultatet och skriver ut en QA-sammanfattning per kategori.

- **Källa:** SCB SSYK 2012-koder (`https://www.scb.se/...ssyk-2012-koder.xlsx`)
- **Sparas som:** `Script/nyckel_yrke.txt` (tabbseparerad textfil)

---

---

# `sni_xl_to_txt.R` – Konvertering av SNI-branschkoder

## Syfte

Engångsskript som läser in en lokal Excel-fil med SNI 2007-branschkoder och konverterar dem till SNI 2025 med hjälp av en kopplingsnyckel. Resultatet sparas som en tabbseparerad textfil för användning i övriga analyser.

## Flöde

1. Läser in `Data/SNI_Koder_OlikaUppdelningar.xlsx` – en lokal fil med kolumnerna `branschkategori`, `branschkod` och `branschnamn` (baserade på SNI 2007).
2. Läser in kopplingsfilen `Script/nyckel-sni2007---sni2025.xlsx` som mappar SNI 2007-koder till SNI 2025-koder.
3. Gör ett vänster-join på `branschkod = SNI2007` och ersätter `branschkod` med motsvarande SNI 2025-kod.
4. Filtrerar bort rader där ingen matchning hittades (saknade SNI 2025-koder).
5. Sparar utdatafilen.

- **Indata:** `Data/SNI_Koder_OlikaUppdelningar.xlsx`, `Script/nyckel-sni2007---sni2025.xlsx`
- **Sparas som:** `Script/nyckel_bransch_SNI2025.txt` (tabbseparerad textfil)

> **OBS!** Skriptet innehåller två rader som refererar till en kolumn `Aktivitetsart2007` som inte existerar i datan (`sum(is.na(...))` och filtrering på den). Dessa rader ger troligen fel och bör ses över eller tas bort.

---

---

# `load_save_data.R` – Datainladdning

## Syfte

Hämtar och sparar all statistik som behövs för turism- och besöksnäringsrapporten. Data hämtas från SCB:s PxWeb-API, Tillväxtverkets öppna API, Kolada och Visit Sweden. Mappen `Data/` skapas automatiskt om den saknas. Varje funktion anropas direkt efter sin definition.

En hjälpfunktion `print_pxwebv2(tabell)` konstruerar URL:er till SCB API v2 och används som kommenterad referens i varje funktion.

---

## Geografiska filer

### Databasen (ZIP)
En ZIP-fil från databas packas upp direkt vid körning till `Data/MyFiles/`. Innehållet är interna DATA-filer som används av diagramfunktionerna i `create_save_plots.R`.

```r
unzip("Data/MyFiles.zip", exdir = "Data/MyFiles")
```

> **OBS!** `Data/MyFiles.zip` måste finnas lokalt innan skriptet körs. Filen laddas inte ned automatiskt.

---

### `func_deso()`
Hämtar DeSO-geografifiler från SCB:s geodatatjänst via ett externt skript på GitHub. Laddar bara ned filer som inte redan finns.

```r
source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/get_deso.R")
func_deso()
```

---

### Kommungränser (Shape-fil)
Laddar ned SCB:s officiella kommun- och länsgränser (SWEREF99TM) och packar upp dem till `Data/Kommun_Sweref99TM/` och `Data/LanSweref99TM/`.

- **Källa:** `https://www.scb.se/.../shape_svenska_260225.zip`
- **Används av:** `karta_befolkning()`, `gastnatter_karta()`, `plot_uppsala_tourism()`

---

## SCB-funktioner

### `func_fritidshus_kolada()`
Hämtar antal fritidshus per 1 000 invånare per kommun från Kolada, från år 2010 och framåt.

- **Källa:** Kolada (sökordet "Fritidshus, antal/1000 inv")
- **Sparas som:** `Data/df_fritidshus.csv`

---

### `func_scb_kommunbesok_raw()`
Laddar ned SCB:s analys av befolkningsförändringar under Juli och Midsommar (2022), jämfört med oktober–november, på kommunnivå. Rensar kolumnnamnen och sparar rådata.

- **Källa:** SCB Excel-fil (`kort_analys_kommuntabell.xlsx`)
- **Kolumner:** Kommun, `bef_okt_nov`, `bef_juli`, `bef_midsommar`, `skillnad_juli`, `skillnad_midsommar`
- **Sparas som:** `Data/scb_kommunbesok_raw.csv`

---

### `func_inrikesflytt()`
Hämtar inrikes flyttningsöverskott (inflyttade minus utflyttade) per län och kön för år 2022. Summerar till länsnivå.

- **SCB-tabell:** Flyttningar97 (BE0101J)
- **Filter:** Totalt ålder, år 2022
- **Sparas som:** `Data/df_inflytt.csv`

---

### `func_hallandsbesoksrapport()`
Hämtar tre uppsättningar befolkningsdata som används för beräkning av befolkningsförändringar och logiintäkter per invånare:

1. **Folkmängd per län** – för det år som valts (2022), summerad per region.
   - SCB-tabell: FolkmangdNov (BE0101A) → `Data/df_folkm.csv`

2. **Folkmängd per region och civilstånd** – gifta, alla år, samtliga kön.
   - SCB-tabell: BefolkningCKM (BE0101A) → `Data/df_folkm_new.csv`

3. **Folkmängd per kommun och år** – Uppsala läns kommuner och länet totalt, alla tillgängliga år.
   - SCB-tabell: FolkmangdNov (BE0101A) → `Data/df_folkm_kom.csv`

---

## Visit Sweden

### `download_visitsweden_uppsala()`
Hämtar turistattraktioner och platser i Uppsala län från Visit Swedens öppna API (Linked Data / JSON-LD). Loopar genom alla sidor i API:et och extraherar:

- Namn, typ (butik, restaurang, boende, plats), beskrivning
- Koordinater (latitud/longitud)
- Webbplats-URL och bild-URL

Platser filtreras geografiskt mot Uppsala läns länsgräns med hjälp av den nedladdade Shape-filen (`st_within`). Ogiltiga koordinater rensas bort.

- **Källa:** Visit Sweden Linked Data API (`https://www.visitsweden.com/...`)
- **Sparas som:** `Data/uppsala_tourism.gpkg` (rumslig GeoPackage-fil)

---

## Tillväxtverkets API

Tillväxtverkets inkvarteringsstatistik hämtas via deras öppna API (`https://oppnadata.tillvaxtverket.se/api/api/query`). Två hjälpfunktioner hanterar API-anropen:

### `query_api(path, dimensions, columns, filters, limit, offset)`
Gör ett GET-anrop mot Tillväxtverkets API med angivna parametrar och returnerar JSON-data. Stöder paginering via `limit` och `offset`.

### `fetch_all(path, columns, dimensions, filters)`
Loopar automatiskt igenom alla sidor i API:t (offset ökas med 500 000 per anrop) tills inga fler rader returneras. Returnerar ett samlat `tibble`.

---

### `gastnatter_data()`
Hämtar antal gästnätter per kommun, månad, land, landgrupp och anläggningstyp från 2019 och framåt.

- **API-tabell:** `GuestNights_Country_Month.cbase`
- **Sparas som:** `Data/df_gastlan.csv` (länsnivå), `Data/df_gastkom.csv` (kommuner i Uppsala)

---

### `belagning_data()`
Hämtar beläggningsstatistik (disponibla och belagda bäddar/rum) per år, anläggningstyp och dagtyp för Uppsala från 2019 och framåt.

- **API-tabell:** `GuestNights_Capacity_Year.cbase`
- **Sparas som:** `Data/df_belagning.csv`

---

### `logii_data()`
Hämtar logiintäkter, disponibla bäddar/rum, svenska och utländska ankomster per månad och anläggningstyp för Uppsala från 2019 och framåt.

- **API-tabell:** `GuestNights_Capacity_Revenue_Month.cbase`
- **Sparas som:** `Data/df_logii.csv`

---

---

# `create_save_plots.R` – Diagramskapande

## Syfte

Läser in lokalt sparad data och skapar diagram och interaktiva kartor för turismrapporten. Statiska diagram sparas i `Figurer/` (skapas automatiskt) som SVG och PNG (96 dpi). Interaktiva objekt returneras för inbäddning i rapport.

Skriptet är uppdelat i fyra tematiska block: **SCB-befolkningsdata**, **Visit Sweden**, **Tillväxtverkets inkvarteringsstatistik** och **INTERNDATA** (interna databasfiler, ej publika).

---

## SCB – befolkningsförändringar

### `karta_befolkning()`
Interaktiv `mapview`-karta som visar befolkningsförändringen i Sveriges alla kommuner under Juli och Midsommar 2022, jämfört med oktober–november som basperiod. Kommunerna klassificeras i sex intervaller (minskning >20% till ökning >60%) och färgkodas. Uppsala läns kommunnamn visas som etiketter vid zoomnivå ≥ 7. Kartan har två lager (Juli och Midsommar) som kan växlas.

- **Indata:** `Data/scb_kommunbesok_raw.csv`, `Data/Kommun_Sweref99TM/Kommun_Sweref99TM.shp`
- **Returneras** som interaktiv karta.

---

### `lans_befolkning()`
Skapar två statiska ggplot2-stapeldiagram som visar befolkningsförändringen i tusental per län, ett för Juli och ett för Midsommar (jämfört med okt–nov 2022). Uppsala är markerat med mörkrosa, övriga lä med grått.

- **Indata:** `Data/scb_kommunbesok_raw.csv`
- **Sparas som:** `Figurer/befolkning_juli.svg/.png`, `Figurer/befolkning_midsommar.svg/.png`

---

### `befolkning_flyttnetto()`
Skapar två scatterplot som kombinerar befolkningsförändringen under Juli resp. Midsommar (x-axel) med inrikes flyttnetto per 1 000 invånare (y-axel), ett punkt per län. Uppsala är markerat i mörkrosa. Referenslinjer vid noll på båda axlar.

- **Indata:** `Data/df_inflytt.csv`, `Data/df_folkm.csv`, `Data/scb_kommunbesok_raw.csv`
- **Sparas som:** `Figurer/befolkning_flyttnetto_juli.svg/.png`, `Figurer/befolkning_flyttnetto_midsommar.svg/.png`

---

## Visit Sweden

### `plot_uppsala_tourism()`
Interaktiv `leaflet`-karta som visar turistattraktioner i Uppsala län, hämtade från Visit Sweden. Punkterna är uppdelade efter typ (Butik, Restaurang, Boende, Plats) och kan filtreras via lagerkontroll. Varje punkt har en hover-etikett med namn (och bild om giltig URL finns) och en popup med fullständig information inkl. beskrivning, länk och bild.

- **Indata:** `Data/uppsala_tourism.gpkg`, `Data/LanSweref99TM/Lan_Sweref99TM_region.shp`
- **Returneras** som interaktiv karta.

---

## Tillväxtverket – gästnätter

### `gastnatter_karta()`
Interaktiv `leaflet`-karta som visar gästnätter per län på riksnivå för näst senaste tillgängliga år. Kartan har flera lager som kan väljas: totalt antal gästnätter, gästnätter per invånare, och varje anläggningstyp per invånare. Legenden uppdateras automatiskt vid lagerbyte via JavaScript.

- **Indata:** `Data/df_gastlan.csv`, `Data/df_folkm_new.csv`, `Data/LanSweref99TM/Lan_Sweref99TM_region.shp`
- **Returneras** som interaktiv karta.

---

### `gastnatter_tid_tot()`
Skapar ett statiskt ggplot2-linjediagram per region (alla kommuner i Uppsala + länet totalt) som visar det totala antalet gästnätter per år, med procentuell förändring angiven som etikett vid varje datapunkt. Hoppar över regioner med färre än 2 år av data.

- **Indata:** `Data/df_gastkom.csv`, `Data/df_gastlan.csv`
- **Sparas som:** `Figurer/gastnatter_tid_tot_[Region].svg/.png`

---

### `gastnatter_tid()`
Skapar ett linjediagram per region som visar månatliga gästnätter uppdelat på anläggningstyp (Hotell, Camping, Vandrarhem, Sekretesskyddad) över tid. X-axeln är en datumaxel med automatisk tick-frekvens beroende på datamängd.

- **Indata:** `Data/df_gastkom.csv`, `Data/df_gastlan.csv`
- **Sparas som:** `Figurer/gastnatter_tid_[Region].svg/.png`

---

### `gastnatter_typ()`
Skapar ett cirkeldiagram (pie chart) för Uppsala läns fördelning av gästnätter per anläggningstyp för näst senaste tillgängliga år. Andelarna visas som textetiketter.

- **Indata:** `Data/df_gastlan.csv`
- **Sparas som:** `Figurer/gastnatter_typ.svg/.png`

---

### `gastnatter_land()`
Interaktivt Plotly-linjediagram som visar gästnätter från olika länder och landgrupper i Uppsala län över tid. Diagrammet har en dropdown-meny för att filtrera på landgrupp. Enbart kompletta år (12 månader) inkluderas och länder med endast ett år av data filtreras bort.

- **Indata:** `Data/df_gastlan.csv`
- **Returneras** som interaktivt Plotly-objekt.

---

## Tillväxtverket – beläggning

### `belagg_tid_tot()`
Skapar ett linjediagram per region med rum- och bäddbeläggning i procent per år, med procentuell förändring som etikett. Båda mått visas i samma diagram med olika färger. "Sekretesskyddad" byter namn till "Uppsala län".

- **Indata:** `Data/df_belagning.csv`
- **Sparas som:** `Figurer/belagg_tid_tot_[Region].svg/.png`

---

### `belagg_tid()`
Skapar separata linjediagram för rumsbeläggning och bäddbeläggning per region, uppdelade på anläggningstyp och dagtyp (vardag/helg). Skapar en fil per region och per måtttyp (rum/bädd).

- **Indata:** `Data/df_belagning.csv`
- **Sparas som:** `Figurer/belagg_tid_rum_[Region].svg/.png`, `Figurer/belagg_tid_badd_[Region].svg/.png`

---

## Tillväxtverket – logiintäkter

### `logi_tid_tot()`
Skapar ett linjediagram per region med total logiintäkt (kr) och logiintäkt per invånare på en sekundär axel. Skalningsfaktorn beräknas automatiskt för att passa båda serierna i samma diagram.

- **Indata:** `Data/df_logii.csv`, `Data/df_folkm_kom.csv`
- **Sparas som:** `Figurer/logi_tid_tot_[Region].svg/.png`

---

### `logi_tid()`
Skapar ett månadsvis linjediagram per region och anläggningstyp för logiintäkter, med X-axeln som en datumaxel.

- **Indata:** `Data/df_logii.csv`
- **Sparas som:** `Figurer/logi_tid_[Region].svg/.png`

---

## Kolada – fritidshus

### `fritidshus()`
Skapar ett stapeldiagram med antal fritidshus per 1 000 invånare per kommun i Uppsala län för senaste tillgängliga år.

- **Indata:** `Data/df_fritidshus.csv`
- **Sparas som:** `Figurer/fritidshus.svg/.png`

---

## Besöksnäringsarbetare

> **OBS!** Dessa funktioner använder data från databasen som laddas upp manuellt som ZIP-fil och packas upp till `Data/MyFiles/`. Filerna är **inte publika** och laddas inte ned automatiskt.

Alla diagram avser dagbefolkning (20–64 år) med yrken klassificerade som besöksnäring via SSYK 2012-kodfilen (`Script/nyckel_yrke.txt`), för år 2023 om inget annat anges.

---

### `hist_utveckling()`
Indexdiagram (basår 2014 = 100) som visar hur antalet besöksnäringsarbetare per dagbefolkning har förändrats i alla Sveriges län. Uppsala markeras i mörkrosa, lä med lägst och högst index i senaste år highlightas med grå etiketter, övriga lä visas som grå linjer.

- **Indata:** `Data/Myfiles/data_utveckling_turism_lan.csv`
- **Sparas som:** `Figurer/turismindex_lan.svg/.png`

---

### `kategorier()`
Horisontellt stapeldiagram som visar antal besöksnäringsarbetare per yrkeskategori (t.ex. Mat & dryck, Boende, Transport) i Uppsala län.

- **Indata:** `Data/Myfiles/data_kategorier_turism_lan.csv`
- **Sparas som:** `Figurer/turismantal_per_kategori.svg/.png`

---

### `konsfordelning()`
Stapeldiagram som visar könsfördelningen (Kvinnor/Män) per yrkeskategori. En ljusgrå ruta markerar det jämställda intervallet (40–60%). Sorteras efter andelen kvinnor.

- **Indata:** `Data/Myfiles/data_konsfordelning_turism_lan.csv`
- **Sparas som:** `Figurer/konsfordelning_turism.svg/.png`

---

### `fodelseland()`
Stapeldiagram som visar födelseregionsfördelningen (inrikes/utrikes född) per yrkeskategori bland besöksnäringsarbetare. Sorteras efter andelen inrikes födda.

- **Indata:** `Data/Myfiles/data_fodelseland_turism_lan.csv`
- **Sparas som:** `Figurer/fodelseland_turism.svg/.png`

---

### `alder()`
Stapeldiagram som visar åldersfördelningen (20–34, 35–49, 50–64 år) per yrkeskategori. Sorteras efter andelen 50–64-åringar. Procentetiketter visas bara om andelen överstiger 15%.

- **Indata:** `Data/Myfiles/data_alder_turism_lan.csv`
- **Sparas som:** `Figurer/alder_turism.svg/.png`

---

### `inkomst()`
Horisontellt stapeldiagram med medianinkomst (tkr) per yrkeskategori bland besöksnäringsarbetare. Värden visas som etiketter inuti staplarna.

- **Indata:** `Data/Myfiles/data_inkomst_turism_lan.csv`
- **Sparas som:** `Figurer/inkomst_turism.svg/.png`

---

### `kommun_fordelning()`
Stapeldiagram som visar andelen och antalet besöksnäringsarbetare per kommun i Uppsala (+ länet totalt) för senaste år. Hämtar kommunnamn dynamiskt via SCB:s API.

- **Indata:** `Data/Myfiles/data_utveckling_turism_kommun.csv`
- **Sparas som:** `Figurer/kommun_turism.svg/.png`

---

---

## Mappstruktur

```
Projektmapp/
├── Script/
│   ├── install_load_packages.R        # Pakethantering
│   ├── settings.R                     # Regioninställningar
│   ├── search_kolada.R                # Hjälpfunktion för Kolada
│   ├── nyckel_yrke.txt                # SSYK-referensfil (genereras av skapa_ssyk_fil.R)
│   ├── nyckel_bransch_SNI2025.txt     # SNI-referensfil (genereras av sni_xl_to_txt.R)
│   ├── nyckel-sni2007---sni2025.xlsx  # Kopplingsnyckel SNI 2007 → 2025
│   ├── skapa_ssyk_fil.R
│   ├── sni_xl_to_txt.R
│   ├── load_save_data.R
│   └── create_save_plots.R
├── Data/
│   ├── MyFiles.zip                    # Interna filer (laddas upp manuellt)
│   ├── MyFiles/                       # Packas upp vid körning
│   ├── SNI_Koder_OlikaUppdelningar.xlsx  # Lokal SNI-fil (laddas upp manuellt)
│   ├── Kommun_Sweref99TM/             # Kommungränser (Shape-fil, laddas ned)
│   ├── LanSweref99TM/                 # Länsgränser (Shape-fil, laddas ned)
│   ├── DeSO_2025.gpkg                 # DeSO-geografi (laddas ned)
│   └── *.csv / *.gpkg                 # Övriga datafiler skapade av skripten
└── Figurer/                           # Skapas automatiskt – SVG och PNG
```

---

## Datakällor

| Källa | Typ av data |
|---|---|
| SCB PxWeb API | Befolkning, inrikes flyttnetto, folkmängd |
| SCB (direkt nedladdning) | Kommunbesöksanalys (Excel), SSYK 2012-koder (Excel), kommungränser (ZIP) |
| Tillväxtverkets öppna API | Gästnätter, beläggning, logiintäkter |
| Kolada | Fritidshus per 1 000 invånare |
| Visit Sweden (Linked Data API) | Turistattraktioner i Uppsala |
| GitHub (RegionUppsala-analys) | DeSO-geografifunktion |
| Databasen / DATA | Besöksnäringsarbetare (ej publik, manuell uppladdning) |

---

## Kända noteringar

| Skript | Notering |
|---|---|
| `sni_xl_to_txt.R` | Refererar till kolumnen `Aktivitetsart2007` som inte finns i datan – dessa rader ger varningar och bör tas bort |
| `load_save_data.R` | `func_inrikesflytt()` är hårdkodad till år 2022 – uppdatera när ny data släpps för sommarflytt |
| `load_save_data.R` | `Data/MyFiles.zip` måste laddas upp manuellt innan skriptet körs |