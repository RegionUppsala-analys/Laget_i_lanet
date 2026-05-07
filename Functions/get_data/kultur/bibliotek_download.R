# Hämta biblioteksstatistik för Uppsala läns kommuner
# Logik: Hämtar tillgängliga år från bibstat-sidan automatiskt.
#        Laddar bara ner år som saknas i den lokala CSV-filen.

# https://bibstat.kb.se/ -> Öppna data -> Excel BETA -> hämta



library(httr)
library(rvest)
library(readxl)
library(dplyr)


# Uppsalas koder och länk till filen
biblioteks_data <- function(kommunkod =  c("0330",
                                           "0331",
                                           "0360",
                                           "0380", 
                                           "0381", 
                                           "0382",
                                           "0305", 
                                           "0319"), 
                            datafil="Data/bibstat_uppsala_kommuner.csv"){
  
  
  # Hämta tillgängliga år från bibstat-hemsidan
  hamta_tillgangliga_ar <- function() {
    cat("Hämtar tillgängliga år från bibstat.kb.se...\n")
    sida <- read_html("https://bibstat.kb.se/")
    ar <- sida |>
      html_elements("select option") |>
      html_text(trim = TRUE) |>
      as.integer() |>
      na.omit() |>
      sort()
    cat("Tillgängliga år:", paste(ar, collapse = ", "), "\n")
    return(as.integer(ar))
  }
  
  # Ladda ner och filtrera ett enstaka år
  hamta_ar <- function(ar) {
    url <- paste0("https://bibstat.kb.se/export?sample_year=", ar)
    cat("  Laddar ner", ar, "...\n")
    
    tmp <- tempfile(fileext = ".xlsx")
    response <- GET(url, write_disk(tmp, overwrite = TRUE))
    
    if (http_error(response)) {
      warning(paste("  Nedladdning misslyckades för år", ar, "– hoppar över."))
      return(NULL)
    }
    
    df <- read_excel(tmp) |>
      mutate(across(everything(), as.character))
    
    # Hitta kommunkolumnen automatiskt
    kommunkolumn <- names(df)[grepl("kommunkod|municipality_code|kommun_kod",
                                    names(df), ignore.case = TRUE)][1]
    if (is.na(kommunkolumn)) {
      warning(paste("  Ingen kommunkolumn hittad för år", ar, "– hoppar över."))
      return(NULL)
    }
    
    df_filtrerad <- df |>
      filter(.data[[kommunkolumn]] %in% kommunkod)
    
    df_filtrerad$year <- ar
    
    cat("  År", ar, ":", nrow(df_filtrerad), "rader efter filtrering.\n")
    return(df_filtrerad)
  }
  
  # Hämta tillgängliga år från hemsidan
  alla_ar <- hamta_tillgangliga_ar()
  
  alla_ar <- alla_ar[alla_ar>= 2014] # innan 2014 så är är det annan struktur
  
  # Bestäm vilka år som ska laddas ner
  if (file.exists(datafil)) {
    cat("\nBefintlig fil hittad:", datafil, "\n")
    df_befintlig <- read.csv(datafil, fileEncoding = "UTF-8", colClasses = "character")
    
    arkolumn <- names(df_befintlig)[grepl("year", names(df_befintlig),
                                          ignore.case = TRUE)][1]
    if (!is.na(arkolumn)) {
      ar_i_fil <- unique(as.integer(df_befintlig[[arkolumn]]))
      cat("År redan i filen:", paste(sort(ar_i_fil), collapse = ", "), "\n")
      saknade_ar <- setdiff(alla_ar, ar_i_fil)
    } else {
      cat("Kunde inte avgöra vilka år som finns – laddar alla år.\n")
      df_befintlig <- NULL
      saknade_ar   <- alla_ar
    }
  } else {
    cat("\nIngen befintlig fil – laddar alla tillgängliga år.\n")
    if (!dir.exists("Data")) dir.create("Data")
    df_befintlig <- NULL
    saknade_ar   <- alla_ar
  }
  
  if (length(saknade_ar) == 0) {
    cat("Inga nya år att ladda ner – filen är redan aktuell.\n")
  } else {
    cat("\nLaddar ner", length(saknade_ar), "år:", paste(saknade_ar, collapse = ", "), "\n\n")
    
    nya_data <- lapply(saknade_ar, hamta_ar)
    nya_data <- Filter(Negate(is.null), nya_data)
    
    if (length(nya_data) > 0) {
      df_ny      <- bind_rows(nya_data)
      df_komplett <- bind_rows(df_befintlig, df_ny)
      write.csv(df_komplett, datafil, row.names = FALSE, fileEncoding = "UTF-8")
      cat("\nTotalt", nrow(df_komplett), "rader sparade till:", datafil, "\n")
    } else {
      cat("Inga nya data hämtades.\n")
    }
  }
  
}



