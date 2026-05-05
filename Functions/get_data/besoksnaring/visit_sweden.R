func_hallandsbesoksrapport()

######## VISIT SWEDENDATA ###########

download_visitsweden_uppsala <- function(output_csv = "Data/uppsala_tourism.csv",
                                         limit = 100,
                                         max_pages = 200) {
  
  base_url <- "https://data.visitsweden.com/store/search"
  
  query <- "public:true+AND+(rdfType:http%5C%3A%2F%2Fschema.org%2FFoodEstablishment+OR+rdfType:http%5C%3A%2F%2Fschema.org%2FEvent+OR+rdfType:http%5C%3A%2F%2Fschema.org%2FPlace+OR+rdfType:http%5C%3A%2F%2Fschema.org%2FStore+OR+rdfType:http%5C%3A%2F%2Fschema.org%2FLodgingBusiness+OR+rdfType:http%5C%3A%2F%2Fschema.org%2FTrip)"
  
  results <- list()
  
  for(i in seq_len(max_pages)){
    
    offset <- (i-1) * limit
    
    url <- paste0(
      base_url,
      "?type=solr",
      "&query=", query,
      "&limit=", limit,
      "&offset=", offset,
      "&rdfFormat=application/ld+json"
    )
    
    message("Downloading offset: ", offset)
    
    res <- GET(url)
    
    if(status_code(res) != 200) break
    
    json <- fromJSON(content(res, "text", encoding="UTF-8"),
                     simplifyVector = FALSE)
    
    children <- json$resource$children
    
    if(length(children) == 0) break
    
    
    
    page_df <- map_dfr(children, function(x){
      
      graph <- x$metadata$`@graph`
      main <- graph[[1]]
      
      # Hitta geometri
      geo <- graph[sapply(graph, function(y) "schema:GeoCoordinates" %in% y$`@type`)]
      lat <- NA; lon <- NA
      if(length(geo) > 0){
        lat <- as.numeric(geo[[1]]$`schema:latitude`)
        lon <- as.numeric(geo[[1]]$`schema:longitude`)
      }
      
      # Funktion för att extrahera språk och fallback
      extract_lang_value <- function(x, preferred = "sv") {
        if (is.null(x)) return(NA_character_)
        if (is.list(x) && !is.null(x$`@value`)) return(x$`@value`)
        if (is.list(x) && length(x) > 1){
          langs <- sapply(x, function(v) v$`@language` %||% NA)
          if (preferred %in% langs) return(x[[which(langs == preferred)[1]]]$`@value`)
          return(x[[1]]$`@value`)
        }
        if (is.character(x)) return(x[1])
        return(NA_character_)
      }
      
      # Funktion för att extrahera en bild
      extract_image <- function(x){
        if(is.null(x)) return(NA_character_)
        if(is.list(x) && !is.null(x$`@id`)) return(x$`@id`)
        if(is.list(x) && length(x) > 1) return(paste(sapply(x, function(v) v$`@id`), collapse = ","))
        if(is.character(x)) return(x[1])
        return(NA_character_)
      }
      
      extract_url <- function(x) {
        if (is.null(x)) return(NA_character_)
        if (is.list(x) && !is.null(x$`@id`)) return(x$`@id`)   # lista med @id
        if (is.character(x)) return(x[1])                       # atomisk string
        return(NA_character_)
      }
      
      extract_type <- function(types) {
        # Flatten to character
        type_clean <- unlist(types)
        type_clean <- sub(".*schema\\.org/", "", type_clean)
        type_clean <- type_clean[type_clean != ""]  # remove empty
        
        if(length(type_clean) == 0) return(NA_character_)
        
        # Return all types as comma-separated string
        paste(unique(type_clean), collapse = ",")
      }
      
      tibble(
        entryId    = x$entryId,
        type       = extract_type(main$`@type`),
        name       = extract_lang_value(main$`schema:name`),
        description= extract_lang_value(main$`schema:description`),
        latitude   = lat,
        longitude  = lon,
        url        = extract_url(main$`schema:url`),
        image      = extract_image(main$`schema:image`)
      )
      
    })
    results[[i]] <- page_df
  }
  
  df <- bind_rows(results)
  
  
  points <- points %>%
    filter(!is.na(latitude), !is.na(longitude),
           latitude >= -90 & latitude <= 90,
           longitude >= -180 & longitude <= 180)
  
  lan_shape <- suppressMessages(
    suppressWarnings(
      st_read(
        "Data/LanSweref99TM/Lan_Sweref99TM_region.shp",
        quiet = TRUE
      )
    )
  ) 
  
  uppsala <- lan_shape %>%
    filter(str_detect(LnNamn, "Uppsala"))
  
  points <- st_transform(points, 3006)
  uppsala <- st_transform(uppsala, 3006)
  points_uppsala <- st_join(points, uppsala, join = st_within)
  
  points_uppsala <- st_transform(points_uppsala, 4326)
  
  points_uppsala <- points_uppsala %>%
    filter(!is.na(LnNamn))
  
  sf::st_write(
    points_uppsala,
    "Data/uppsala_tourism.gpkg",
    delete_dsn = TRUE
  )
  
  #return(points_uppsala)
}

