
######## Tillväxtverket #########

# hitta api på https://www.dataportal.se/ sök: Tillväxtverket

# Funktion som hjälper till för tillväxtverkets api
query_api <- function(
    path,
    dimensions = NULL,
    columns = NULL,
    filters = NULL,
    limit = 10000,
    offset = 0
) {
  
  base_url <- "https://oppnadata.tillvaxtverket.se/api/api/query"
  
  path_enc <- URLencode(path)
  
  params <- c()
  
  # dimensions
  if (!is.null(dimensions)) {
    params <- c(params, paste0("dimension=", dimensions))
  }
  
  # columns
  if (!is.null(columns)) {
    params <- c(params, paste0("column=", columns))
  }
  
  # filters
  if (!is.null(filters)) {
    params <- c(params, filters)
  }
  
  # window + format
  params <- c(
    params,
    paste0("limit=", format(limit, scientific = FALSE)),
    paste0("offset=", format(offset, scientific = FALSE)),
    "format=json"
  )
  
  url <- paste0(base_url, "/", path_enc, "?", paste(params, collapse = "&"))
  
  res <- GET(url)
  stop_for_status(res)
  
  fromJSON(content(res, "text", encoding = "UTF-8"), flatten = TRUE)
}

# För att ta ut all data 
fetch_all <- function(path, columns = NULL, dimensions = NULL, filters = NULL) {
  
  limit <- 500000
  offset <- 0
  
  out <- list()
  
  repeat {
    
    res <- query_api(
      path = path,
      columns = columns,
      dimensions = dimensions,
      filters = filters,
      limit = limit,
      offset = offset
    )
    
    rows <- res$rows
    
    if (is.null(rows) || nrow(as.data.frame(rows)) == 0) break
    
    out[[length(out) + 1]] <- rows
    
    # STOP condition
    if (nrow(as.data.frame(rows)) < limit) break
    
    offset <- offset + limit
  }
  
  dplyr::bind_rows(lapply(out, tibble::as_tibble))
}

gastnatter_data <-function(){
  # Api tillväxtverket
  data_raw <- fetch_all(
    path = "inkvartering/data/GuestNights_Country_Month.cbase",
    columns = c("KOMMUN_NAMN", "AR","MANAD_NAMN_LANG","LAND_NAMN","LANDGRP_20_NAMN",
                "LANDGRP_GROV_NAMN","ANLAGGNINGSTYP_NAMN", "ANTAL_GASTNATTER",
                "NIVA_NAMN","LAN_NAMN"
    )
  )
  
  df <- data_raw
  
  df_lan <- df %>%  filter(NIVA_NAMN== "Län", AR>= 2019 )
  
  df_kom <- df %>%  filter(KOMMUN_NAMN %in% kommuner, AR >= 2019 )
  
  # sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
  write.csv(df_lan, "Data/df_gastlan.csv", row.names = F)
  
  print('Nedladdning av "df_gastlan.csv" har gått igenom')
  
  # sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
  write.csv(df_kom, "Data/df_gastkom.csv", row.names = F)
  
  print('Nedladdning av "df_gastkom.csv" har gått igenom')
  
  
  
} 




belagning_data <-function(){
  # Api tillväxtverket
  data_raw <- fetch_all(
    path = "inkvartering/data/GuestNights_Capacity_Year.cbase",
    columns = c("KOMMUN_NAMN", "AR","ANLAGGNINGSTYP_NAMN", "ANTAL_GASTNATTER",
                "NIVA_NAMN","LAN_NAMN","BELAGDA_BADDAR","BELAGDA_RUM",
                "DISPONIBLA_BADDAR", "DISPONIBLA_RUM","DAGTYP_NAMN"
    )
  )
  
  df <- data_raw
  
  df_kom <- df %>%  filter(LAN_NAMN =='Uppsala', AR >= 2019 )
  
  # sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
  write.csv(df_kom, "Data/df_belagning.csv", row.names = F)
  
  print('Nedladdning av "df_belagning.csv" har gått igenom')
} 


logii_data <-function(){
  # Api tillväxtverket
  data_raw <- fetch_all(
    path = "inkvartering/data/GuestNights_Capacity_Revenue_Month.cbase",
    columns = c("KOMMUN_NAMN", "AR","ANLAGGNINGSTYP_NAMN", "ANTAL_GASTNATTER",
                "NIVA_NAMN","LAN_NAMN","LOGIINTAKT", "DISPONIBLA_BADDAR", "DISPONIBLA_RUM",
                "ANKOMSTER_SVE", "ANKOMSTER_UTL","MANAD_LANG_SVE", "PERIOD"
    )
  )
  
  df <- data_raw
  
  df_kom <- df %>%  filter(LAN_NAMN =='Uppsala', AR >= 2019 )
  
  # sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
  write.csv(df_kom, "Data/df_logii.csv", row.names = F)
  
  print('Nedladdning av "df_logii.csv" har gått igenom')
} 







