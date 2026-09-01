######### Skrapa MUCF för data om UVAS 
{
  source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/general_functions/install_load_packages.R")
  source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/general_functions/settings.R")
  install_and_load()
  settings <- get_settings()
  
  kommunkod <- settings$kommunkod
  kommuner <- settings$kommuner
  kommun_colors <- settings$kommun_colors
  lanskod <- settings$lanskod
  lan <- settings$lan
  
}

# Byt år om ny data finns (Den här fungerade på gammal hemsida)
uvas_scrape_old <- function(senaste_ar = 2023){
  # Url till data
  url <- 'https://www.mucf.se/verktyg/statistik-om-unga-som-varken-arbetar-eller-studerar'
  
  # Lista med kommun-ID:n och namn för Uppsala län (kan ändras för andra län)
  kommuner <- list(
    "Älvkarleby" = "68",
    "Håbo"      = "67",
    "Heby"      = "70",
    "Knivsta"   = "69",
    "Tierp"     = "71",
    "Uppsala"   = "72",
    "Enköping"  = "73",
    "Östhammar" = "74"
  )
  # År att loopa över
  ar <- 2007:senaste_ar
  
  # Skapa tom dataframe för resultat
  all_data <- data.frame()
  
  # Loopar över alla kommuner och år
  for (kommun_namn in names(kommuner)) {
    kommun_id <- kommuner[[kommun_namn]]
    
    for (year in ar) {
      
      # Strukturen på hemsidan
      post_data <- list(
        "filters[columns][column_1][year]" = as.character(year),
        "filters[columns][column_1][county]" = '21',
        "filters[columns][column_1][city]" = kommun_id,
        "filters[columns][column_2][gender][Kvinnor]" = "Kvinnor",
        "filters[columns][column_2][gender][Män]" = "Män",
        "filters[columns][column_2][origin][Inrikesfödd]" = "Inrikesfödd",
        "filters[columns][column_2][origin][Utrikesfödd]" = "Utrikesfödd",
        "filters[columns][column_3][age][16-24]" = "16-24",
        "filters[columns][column_3][age][25-29]" = "25-29",
        "filters[columns][column_3][age][16-29]" = "16-29",
        "filters[columns][column_3][general_category]" = "Master",
        "op" = "Välj"
      )
      
      # Läser in data
      res <- POST(url, body = post_data, encode = "form")
      html <- content(res, as = "parsed")
      table <- html %>% html_node("table") %>% html_table(fill = TRUE)
      
      if(!is.null(table)) {
        # Ta bort rubrikrader
        table <- table[-c(1,2), ]
        
        # Rätta kolumnnamn
        colnames(table) <- c("Grupp",
                             "Antal_16_24","Andel_16_24",
                             "Antal_25_29","Andel_25_29",
                             "Antal_16_29","Andel_16_29")
        
        # Lägg till år, län och kommun
        table <- table %>%
          mutate(År = year,
                 Län = "Uppsala län",
                 Kommun = kommun_namn)
        
        all_data <- bind_rows(all_data, table)
      }
      
      Sys.sleep(0.5)  # kort paus så vi inte spammar servern
    }
  }
  
  # Spara till CSV
  write.csv(all_data, "Data/unga_utan_studier_eller_arbete_uppsala.csv", row.names = FALSE)
  
}



# Ny funktion efter att hemsidan uppdaterats
uvas_scrape <- function(senaste_ar = 2023, save_path = "Data/unga_utan_studier_eller_arbete_uppsala.csv") {
  
  # URL: Startsidan och AJAX-endpoint
  base_url <- "https://www.mucf.se/rapporter-och-statistik/statistik-om-unga-som-varken-arbetar-eller-studerar"
  ajax_url <- paste0(base_url, "?ajax_form=1&_wrapper_format=drupal_ajax")
  
  # Kommuner i Uppsala län
  kommuner <- list(
    "Älvkarleby" = "68",
    "Håbo"      = "67",
    "Heby"      = "70",
    "Knivsta"   = "69",
    "Tierp"     = "71",
    "Uppsala"   = "72",
    "Enköping"  = "73",
    "Östhammar" = "74"
  )
  
  ar <- 2007:senaste_ar
  all_data <- data.frame()
  
  # Hämta startsidan för form_build_id och form_token
  page <- GET(base_url)
  html <- read_html(page)
  
  form_build_id <- html %>% html_node("input[name='form_build_id']") %>% html_attr("value")
  form_id       <- html %>% html_node("input[name='form_id']") %>% html_attr("value")
  
  if(is.na(form_build_id) ) {
    stop("Kunde inte hitta form_build_id. Sidan kanske ändrat struktur.")
  }
  
  # Loop över kommuner och år
  for (kommun_namn in names(kommuner)) {
    kommun_id <- kommuner[[kommun_namn]]
    
    for (year in ar) {
      message("Hämtar: ", kommun_namn, " - ", year)
      
      # POST-data
      post_data <- list(
        form_build_id = form_build_id,
        form_id       = form_id,
        "filters[columns][column_1][year]" = as.character(year),
        "filters[columns][column_1][county]" = "21",
        "filters[columns][column_1][city]" = kommun_id,
        "filters[columns][column_2][gender][Kvinnor]" = "Kvinnor",
        "filters[columns][column_2][gender][Män]" = "Män",
        "filters[columns][column_2][origin][Inrikesfödd]" = "Inrikesfödd",
        "filters[columns][column_2][origin][Utrikesfödd]" = "Utrikesfödd",
        "filters[columns][column_3][age][16-24]" = "16-24",
        "filters[columns][column_3][age][25-29]" = "25-29",
        "filters[columns][column_3][age][16-29]" = "16-29",
        "filters[columns][column_3][general_category]" = "Master",
        "op" = "Välj"
      )
      
      # POST till AJAX-endpoint
      res <- POST(ajax_url, body = post_data, encode = "form")
      
      if(status_code(res) != 200) {
        message("Hoppar över: ", kommun_namn, " - ", year, " (status: ", status_code(res), ")")
        next
      }
      
      # Drupal AJAX returnerar en lista med JSON-objekt, tabellen ligger i 'data' -> 'table'
      json_resp <- fromJSON(content(res, "text", encoding = "UTF-8"), simplifyVector = FALSE)
      
      # Leta efter table HTML i JSON (Drupal returnerar array med 'command':'insert')
      table_html <- NULL
      for (cmd in json_resp) {
        if(!is.null(cmd$command) && cmd$command == "insert") {
          if(str_detect(cmd$data, "<table")) {
            table_html <- cmd$data
            break
          }
        }
      }
      
      if(is.null(table_html)) {
        message("Ingen tabell hittad för ", kommun_namn, " - ", year)
        next
      }
      
      # Läs tabell
      table <- read_html(table_html) %>% html_node("table") %>% html_table(fill = TRUE)
      
      if(nrow(table) < 1) next
      
      # Ta bort rubrikrader
      table <- table[-c(1,2), ]
      
      # Rätta kolumnnamn
      colnames(table) <- c(
        "Grupp",
        "Antal_16_24","Andel_16_24",
        "Antal_25_29","Andel_25_29",
        "Antal_16_29","Andel_16_29"
      )
      
      # Lägg till metadata
      table <- table %>%
        mutate(
          År = year,
          Län = "Uppsala län",
          Kommun = kommun_namn
        )
      
      all_data <- bind_rows(all_data, table)
      
      Sys.sleep(1) # kort paus för att ej sapamma server
    }
  }
  
  # Spara CSV
  dir.create(dirname(save_path), showWarnings = FALSE, recursive = TRUE)
  write.csv(all_data, save_path, row.names = FALSE)
  
  message("parad till ", save_path)
  return(all_data)
}

