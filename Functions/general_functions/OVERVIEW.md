# Översikt av funktioner i general_functions
Innehåller generella funktioner som kan importeras till LiL-projekt så att samma mappar med funktioner inte behöver finnas med i alla projekt.

Dessa funktioner är nödvändiga för i stort sett alla LiL-projekt:
- install_load_packages.R
- settings.R

pxweb_url.R används för projekt som importerar data där pxweb v2 används (SCB i nuläget). När data importeras och pxweb v1 används behöver URL:en som helhet klistras in.

survey_berakning.R används för projekt där man använder sig av enkätdata, såsom *Liv och hälsa ung* och Folkhälsomyndighetens *Nationella folkhälsoenkäten*.

## install_load_packages.R
Installerar eller packar upp de paket som används i Läget i länet-rapporter.

## pxweb_url.R
Kod för att förenkla url-angivelsen vid pxweb-get.

Anpassat för pxweb v2. 

Ange bara TAB-värdet för att få en färdig URL-kod.

**OBS: Vid pxweb2-export kommer tabellinnehållet (ContentsCode) i ett annat format än vid v1, så för att få innehållet i samma format behöver man pivota den kolumnen. Se exemplet nedan.**

### Exempelkod:
```r
url <- pxweb_url("TAB4879")

px_get_list <- list(
  Region = c(riket_narliggande),
  UtbildningsNiva = "*",
  Kon = c("020","030"),
  Alder = "*",
  ContentsCode = "*",
  Tid = "*"
)

px_get <- pxweb_get(url, px_get_list)

df_livslangd <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
df_livslangd <- na.omit(df_livslangd)

df_livslangd <- df_livslangd %>%
tidyr::pivot_wider(             
    names_from = "tabellinnehåll",
    values_from = "value",
)
```

## settings.R
Ställer in vilka kommuner som ska importeras/filtreras för Uppsala län när man arbetar med data innehållandes flera kommuner/län.
Ställer in textformat och färgteman.
Ställer in närliggande län om man vill jämföra mellan länen.

## socioindex_pca.R
Kod för att visualisera socioekonomiskt index på DeSO-nivå.

## survey_berakning.R

Innehåller generella funktioner för analys av enkätdata. 
Stöd finns för viktning samt gruppering av resultat efter en eller flera variabler. 
Funktionerna är utformade för att kunna återanvändas på olika datamängder genom att variabel- och grupperingskolumner anges som funktionsargument.


### Exempelkod

Säg att du har dataramen:

```r
enkatdata <- data.frame(
  frokost = c("Ja", "Nej", "Ja", "Ja", "Nej"),
  kon = c("Kvinna", "Man", "Kvinna", "Man", "Kvinna"),
  ar = c("2024", "2024", "2025", "2025", "2025"),
  vikt = c(1.2, 0.8, 1.5, 1.1, 0.9)
)
```

Så anropar du funktionen:

```r
resultat <- survey_berakning(
  df = enkatdata,
  var = "frokost",
  group1 = "kon",
  group2 = "ar",
  weight = "vikt"
)
```

## uvas_scrape.R
Funktion för scraping av MUCF:s data om UVAS (unga som varken arbetar eller studerar).
Genererar en .csv-fil innehållandes data utifrån år, stad, kön och bakgrund.
