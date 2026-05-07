############ Fritidskort #########
# Här måste du nog troligtvis ändra länken för att hämta den senaste pdf:en
# https://fritidskortet.se/statistik   -> "Så användes fritidskortet 202* per län och kommun
# https://www.ehalsomyndigheten.se/om-ehalsomyndigheten/aktuellt/nyheter/2025/sa-har-fritidskortet-anvants-2025
# -> Antal beviljade och använda fritidskort per kommun

# funktion som tillfälligt laddar ned en pdf och tar ut tabellen i den och sparar som csv
fritidskortsdata <-function(year=2025){
  # url till pdfen
  url <- paste0("https://www.ehalsomyndigheten.se/siteassets/ehm/3_om-ehalsomyndigheten/aktuellt/nyheter/",
                year,"/sa-har-fritidskortet-anvants-",
                year,"/kommun-antal-beviljade-och-anvanda-fritidskort.pdf")
  
  tmp <- tempfile(fileext = ".pdf")
  tryCatch(
    download.file(url, destfile = tmp, mode = "wb", quiet = TRUE),
    error = function(e) stop("Kunde inte ladda ned PDF: ", conditionMessage(e))
  )
  
  # Läs in all text från PDF:en, sida för sida
  sidor <- pdf_text(tmp)
  unlink(tmp)
  
  # Dela upp varje sida i rader och kombinera alla sidor
  rader <- sidor |>
    lapply(function(sida) str_split(sida, "\n")[[1]]) |>
    unlist() |>
    str_trim()
  
  # Datarader har mönstret: Kommunnamn följt av två tal (med möjliga mellanslag i talen)
  data_rader <- rader[str_detect(rader, "^[A-ZÅÄÖ][a-zåäö].*\\d")]
  
  # Kommuner med värdet <20 tas ej med 
  parsed <- str_match(data_rader, "^(.+?)\\s{2,}([\\d\\s]+?)\\s{2,}([\\d\\s]+)$")
  
  data <- data.frame(
    Kommun                       = str_trim(parsed[, 2]),
    Antal_beviljade_fritidskort  = as.numeric(str_remove_all(parsed[, 3], "\\s")),
    Antal_anvanda_fritidskort    = as.numeric(str_remove_all(parsed[, 4], "\\s")),
    stringsAsFactors = FALSE
  )
  
  # Ta bort rader där parsningen misslyckades
  data <- data[complete.cases(data), ]
  
  # Spara till CSV
  filnamn <- file.path(paste0("Data/fritidskort_", year, ".csv"))
  write.csv(data, file = filnamn, row.names = FALSE, fileEncoding = "UTF-8")
  message("Filen sparad: ", filnamn)
  
  invisible(NULL)
  
  
}

# Ställer in settings paket mm
{
  source("Script/install_load_packages.R")
  source("Script/settings.R")
  install_and_load()
  settings <- get_settings()
  
  kommunkod <- settings$kommunkod
  kommuner <- settings$kommuner
  kommun_colors <- settings$kommun_colors
  lanskod <- settings$lanskod
  lan <- settings$lan
  
  
}



# ==============================================================================
# Skript: scrape_fritidskortet.R
# Syfte:  Automatisk inhämtning av fritidskorts-statistik per län från
#         Regeringen.se och sparar resultatet som CSV.
#
# Källa:  "Första hösten med fritidskortet – så har det gått"
# URL:    https://www.regeringen.se/pressmeddelanden/2025/12/
#         forsta-hosten-med-fritidskortet--sa-har-det-gatt/
# ==============================================================================

# ------------------------------------------------------------------------------
# Funktion: hamta_fritidskort_data
#
# Beskrivning:
#   Hämtar tabellen med antal nedladdade fritidskort och antal föreningar per
#   län från Regeringskansliets pressmeddelande. URL:en är konstruerad dynamiskt
#   baserat på det angivna året, eftersom pressmeddelanden publiceras årsvis.
#
# Parametrar:
#   year  (integer) – Publiceringsåret för pressmeddelandet. Standard: 2025.
#   output_path (character) – Sökväg för den sparade CSV-filen.
#
# Returnerar:
#   En data frame med kolumnerna: lan, antal_nedladdade_fritidskort,
#   antal_foreningar, ar.
#
# Notera:
#   - Sidans URL innehåller publiceringsår; om Regeringen.se ändrar
#     URL-strukturen måste url_template uppdateras.
#   - Funktionen förväntar sig att första HTML-tabellen på sidan innehåller
#     länsdata. Om sidan omstruktureras kan table_index behöva justeras.
# ------------------------------------------------------------------------------
hamta_fritidskort_data <- function(year = 2025) {
  # Käll-URL (pressmeddelande publicerat december det aktuella året):
  # https://www.regeringen.se/pressmeddelanden/2025/12/
  #   forsta-hosten-med-fritidskortet--sa-har-det-gatt/
  url_template <- paste0(
    "https://www.regeringen.se/pressmeddelanden/",
    year,
    "/12/forsta-hosten-med-fritidskortet--sa-har-det-gatt/"
  )
  
  message("Hämtar data från: ", url_template)
  
  # rvest::read_html() hämtar och parsar HTML-dokumentet.
  # Fångar eventuella nätverks- eller HTTP-fel med tryCatch.
  page <- tryCatch(
    read_html(url_template),
    error = function(e) {
      stop("Kunde inte hämta sidan. Kontrollera URL och internetanslutning.\n",
           "Felmeddelande: ", conditionMessage(e))
    }
  )
  
  # html_table() konverterar <table>-element till R data frames.
  # fill = TRUE hanterar eventuella tomma celler.
  tabeller <- page %>%
    html_elements("table") %>%
    html_table(fill = TRUE)
  
  if (length(tabeller) == 0) {
    stop("Inga tabeller hittades på sidan. Kontrollera om sidans struktur har förändrats.")
  }
  
  # Tabellen innehåller kolumnerna: Län, Antal nedladdade fritidskort,
  # Antal föreningar. Se sidan:
  # https://www.regeringen.se/pressmeddelanden/2025/12/
  #   forsta-hosten-med-fritidskortet--sa-har-det-gatt/
  df_raw <- tabeller[[1]]
  
  #  Validera att förväntade kolumner finns
  expected_cols <- 3
  if (ncol(df_raw) != expected_cols) {
    warning("Tabellen har ", ncol(df_raw), " kolumner (förväntade ", expected_cols,
            "). Kontrollera att rätt tabell valts.")
  }
  
  # Rensa och byt namn på kolumner till maskinsäkra namn
  df_clean <- df_raw %>%
    # Byt namn: standardisera kolumnnamn (ta bort mellanslag och specialtecken)
    rename(
      lan                          = 1,
      antal_nedladdade_fritidskort = 2,
      antal_foreningar             = 3
    ) %>%
    # Ta bort headerraden om den råkade läsas in som datarad
    filter(lan != "Län") %>%
    # Konvertera talkolumner: ta bort eventuella tusenavgränsare och mellanslag
    mutate(
      antal_nedladdade_fritidskort = as.integer(
        gsub("[^0-9]", "", antal_nedladdade_fritidskort)
      ),
      antal_foreningar = as.integer(
        gsub("[^0-9]", "", antal_foreningar)
      ),
      # Lägg till år som metadata-kolumn för spårbarhet
      år = as.integer(year)
    ) %>%
    # Sortera på flest nedladdade kort (fallande) för bättre läsbarhet
    arrange(desc(antal_nedladdade_fritidskort))
  
  #  Skapa output-katalogen om den inte redan existerar 
  output_dir <- dirname(paste0("Data/Fritidskortet_foreningar_",year,".csv"))
  output_path <- paste0("Data/Fritidskortet_foreningar_",year,".csv")
  if (!dir.exists(output_dir) && output_dir != ".") {
    dir.create(output_dir, recursive = TRUE)
    message("Skapade katalogen: ", output_dir)
  }
  
  # Spara data som CSV med UTF-8 encoding 
  # write_csv() från readr garanterar korrekt hantering av svenska tecken (å, ä, ö).
  write_csv(df_clean, output_path)
  message("Data sparad till: ", output_path)
  message("Antal rader: ", nrow(df_clean))
  
  
}


# ==============================================================================
# Körexempel
# ==============================================================================


#fritidskort_data <- hamta_fritidskort_data(year = 2025)




