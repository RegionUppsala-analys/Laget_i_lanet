
### Databasen (ZIP)
En ZIP-fil från databas packas upp direkt vid körning till `Data/MyFiles/`. Innehållet är interna DATA-filer som används av diagramfunktionerna i `create_save_plots.R`.

```r
unzip("Data/MyFiles.zip", exdir = "Data/MyFiles")
```

> **OBS!** `Data/MyFiles.zip` måste finnas lokalt innan skriptet körs. Filen laddas inte ned automatiskt.

## kKulturskapare

> **OBS!** Dessa funktioner använder data från databasen som laddas upp manuellt som ZIP-fil och packas upp till `Data/MyFiles/`. Filerna är **inte publika** och laddas inte ned automatiskt.

Alla diagram avser dagbefolkning (20–64 år) med yrken klassificerade som besöksnäring via SSYK 2012-kodfilen (`Script/nyckel_yrke.txt`), för år 2023 om inget annat anges.

---

### `hist_utveckling()`
Indexdiagram (basår 2014 = 100) som visar hur antalet kulturskapare per dagbefolkning har förändrats i alla Sveriges län. Uppsala markeras i mörkrosa, lä med lägst och högst index i senaste år highlightas med grå etiketter, övriga lä visas som grå linjer.

- **Indata:** `Data/Myfiles/data_utveckling_kultur_lan.csv`
- **Sparas som:** `Figurer/kulturindex_lan.svg/.png`

---

### `kategorier()`
Horisontellt stapeldiagram som visar antal kulturskapare per yrkeskategori (t.ex. Mat & dryck, Boende, Transport) i Uppsala län.

- **Indata:** `Data/Myfiles/data_kategorier_lan.csv`
- **Sparas som:** `Figurer/kulturantal_per_kategori.svg/.png`

---

### `konsfordelning()`
Stapeldiagram som visar könsfördelningen (Kvinnor/Män) per yrkeskategori. En ljusgrå ruta markerar det jämställda intervallet (40–60%). Sorteras efter andelen kvinnor.

- **Indata:** `Data/Myfiles/data_konsfordelning_lan.csv`
- **Sparas som:** `Figurer/konsfordelning_kultur.svg/.png`

---

### `fodelseland()`
Stapeldiagram som visar födelseregionsfördelningen (inrikes/utrikes född) per yrkeskategori bland kulturskapare. Sorteras efter andelen inrikes födda.

- **Indata:** `Data/Myfiles/data_fodelseland_lan.csv`
- **Sparas som:** `Figurer/fodelseland_kultur.svg/.png`

---

### `alder()`
Stapeldiagram som visar åldersfördelningen (20–34, 35–49, 50–64 år) per yrkeskategori. Sorteras efter andelen 50–64-åringar. Procentetiketter visas bara om andelen överstiger 15%.

- **Indata:** `Data/Myfiles/data_alder_lan.csv`
- **Sparas som:** `Figurer/alder_kultur.svg/.png`

---

### `inkomst()`
Horisontellt stapeldiagram med medianinkomst (tkr) per yrkeskategori bland kulturskapare. Värden visas som etiketter inuti staplarna.

- **Indata:** `Data/Myfiles/data_inkomst_lan.csv`
- **Sparas som:** `Figurer/inkomst_kultur.svg/.png`

---

### `kommun_fordelning()`
Stapeldiagram som visar andelen och antalet kulturskapare per kommun i Uppsala (+ länet totalt) för senaste år. Hämtar kommunnamn dynamiskt via SCB:s API.

- **Indata:** `Data/Myfiles/data_utveckling_kommun.csv`
- **Sparas som:** `Figurer/kommun_kultur.svg/.png`

---




## Datakällor

| Databasen / DATA | Besöksnäringsarbetare (ej publik, manuell uppladdning) |