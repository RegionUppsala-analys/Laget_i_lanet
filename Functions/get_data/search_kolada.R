########## Funktion för att söka och ladda data från Kolada ###########
{
  source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/general_functions/install_load_packages.R")
  
  source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/general_functions/settings.R")
  
  install_and_load()
  settings <- get_settings()
  
  kommunkod <- settings$kommunkod
  kommuner <- settings$kommuner
  kommun_colors <- settings$kommun_colors
  riket_narliggande <- settings$riket_narliggande
  lan <- settings$lan
  lanskod <- settings$lanskod
  
}

# Funktion för sökning 
get_kpi_lista <- function() {
  response <- httr::GET(
    "https://api.kolada.se/v3/kpi",
    query = list(page = 1, per_page = 5000)
  )
  httr::stop_for_status(response)

  kpi_lista <- jsonlite::fromJSON(
    httr::content(response, as = "text", encoding = "UTF-8")
  )$values

  if (is.null(kpi_lista) || !is.data.frame(kpi_lista)) {
    stop("Kolada API returnerade ingen KPI-lista.")
  }

  kpi_lista
}

get_kolada_values <- function(kpi, municipality, unit_type) {
  endpoint <- paste0(
    "https://api.kolada.se/v3/data/kpi/",
    paste(kpi, collapse = ","),
    "/",
    unit_type,
    "/",
    paste(municipality, collapse = ",")
  )
  response <- httr::GET(
    endpoint,
    query = list(page = 1, per_page = 5000)
  )
  httr::stop_for_status(response)

  response_values <- jsonlite::fromJSON(
    httr::content(response, as = "text", encoding = "UTF-8"),
    simplifyDataFrame = FALSE
  )$values

  if (length(response_values) == 0) {
    return(data.frame())
  }

  rows <- lapply(response_values, function(item) {
    values <- item$values
    if (length(values) == 0) {
      return(NULL)
    }

    data.frame(
      kpi = item$kpi,
      year = item$period,
      municipality = item$municipality,
      gender = vapply(values, `[[`, character(1), "gender"),
      count = vapply(values, `[[`, numeric(1), "count"),
      status = vapply(values, `[[`, character(1), "status"),
      value = vapply(values, function(value) {
        if (is.null(value$value)) NA_real_ else as.numeric(value$value)
      }, numeric(1)),
      isdeleted = vapply(values, `[[`, logical(1), "isdeleted"),
      stringsAsFactors = FALSE
    )
  })

  dplyr::bind_rows(rows)
}

search_kolada <- function(sok_ord = NULL){
  # Stopfunktioner för felinmatning
  
  # sok_ord
  if(is.null(sok_ord) || !is.character(sok_ord) || nchar(trimws(sok_ord)) == 0){
    stop("Argumentet 'sok_ord' måste vara ett icke-tomt teckensträng.")
  }
  
  # Tar hem information om alla variabler på kolada
  kpi_lista <- get_kpi_lista()
  
  # Tar ut raderna med ordet i titeln i sig eller nära 
  resultat <- kpi_lista[agrep(sok_ord, kpi_lista$title, ignore.case = TRUE, max.distance = 0.1), ]
  
  if(nrow(resultat)==0){ # om det inte finns data med sökordet så retuneras detta
    stop('Tyvärr hittas inget för det sökordet')
  }
  if(nrow(resultat) > 100){
    warning("Sökordet matchar fler än 100 KPI:er, överväg att precisera sökningen.")
  }
  return(resultat) # Returnerar ids och förklaringar
}




# Funktion för sökning och hämtning av data direkt, match avgör hur nära sökningen måste vara korrekt
search_and_fetch_kolada <- function(sok_ord = NULL, kommunniva = 'municipality', kommunkod = NULL, match= 0.1){
  # Stopfunktioner för felinmatning
  
  # sok_ord
  if(is.null(sok_ord) || !is.character(sok_ord) || nchar(trimws(sok_ord)) == 0){
    stop("Argumentet 'sok_ord' måste vara ett icke-tomt teckensträng.")
  }
  
  # kommunniva
  if(!kommunniva %in% c("municipality", "ou")) {
    stop("Argumentet 'kommunniva' måste vara 'municipality' eller 'ou'")
  }
  
  # kommunkod
  if(is.null(kommunkod)){ # kollar om kommunkod ligger som global(vilket det bör göra i LiL(Läget i Länet))
    kommunkod <- get0("kommunkod", envir = .GlobalEnv)
    if(is.null(kommunkod)){
      stop("Variabeln 'kommunkod' finns ej. Ange kommunkod som argument eller definiera den globalt.")
    }
  }
  
  # Tar hem information om alla variabler på kolada
 
  kpi_lista <- get_kpi_lista()
  # Tar ut raderna med ordet i titeln i sig / nära rätt ord
  resultat <- kpi_lista[agrep(sok_ord, kpi_lista$title, ignore.case = TRUE, max.distance = match), ]
 
  if(nrow(resultat) > 50){
    print("Sökordet matchar fler än 50 KPI:er, precisera sökningen. Retunerar listan med titlar")
    return(resultat)
    stop()
    
  }
  
  if(nrow(resultat)==0){
    stop('Tyvärr hittas inget för det sökordet')
  }

  kpi_ids <- resultat$id
  
  # Byternamn på id till kpi
  resultat <- resultat %>% rename(kpi = id)

  # Tar hem data för variablerna och kommunerna, använder felhantering om det inte går
  data <- tryCatch(
    get_kolada_values(kpi = kpi_ids, municipality = kommunkod, unit_type = kommunniva),
    error = function(e) stop("Fel vid hämtning av data: testa funktionen search_kolada(). Detaljer: ", e$message)
  )
  
  # Slår ihop data med titeln
  df <- resultat %>% dplyr::select(title, kpi) %>% left_join(data, by ='kpi')
  
  return(df)
  
}

