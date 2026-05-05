#####  Deso #######
# gpkg filer
func_deso <- function(){
  # 2025
  
  
  url <- "https://geodata.scb.se/geoserver/stat/wfs?service=WFS&REQUEST=GetFeature&version=1.1.0&TYPENAMES=stat:DeSO_2025&outputFormat=geopackage"
  output_file <- "Data/DeSO_2025.gpkg"
  
  # Kollar om den redan finns
  if (file.exists(output_file)) {
    
  } else {
    
    response <- GET(url, write_disk(output_file, overwrite = TRUE))
    
  }
  
  # 2018
  
  url <- "https://geodata.scb.se/geoserver/stat/wfs?service=WFS&REQUEST=GetFeature&version=1.1.0&TYPENAMES=stat:DeSO_2018&outputFormat=geopackage"
  output_file <- "Data/DeSO_2018.gpkg"
  
  # Kollar om den redan finns
  if (file.exists(output_file)) {
    
  } else {
    
    response <- GET(url, write_disk(output_file, overwrite = TRUE))
    
  }
  
  # Kopplingar 
  # 2025
  url <- 'https://www.scb.se/contentassets/e3b2f06da62046ba93ff58af1b845c7e/koppling-deso2025-regso2025.xlsx'
  output_file <- "Data/koppling-deso2025-regso2025.xlsx"
  
  # Kollar om den redan finns
  if (file.exists(output_file)) {
    
  } else {
    
    response <- GET(url, write_disk(output_file, overwrite = TRUE))
    
  }
  # 2018
  url <- 'https://www.scb.se/contentassets/e3b2f06da62046ba93ff58af1b845c7e/koppling-deso2018-regso2020.xlsx'
  output_file <- "Data/koppling-deso2018-regso2020.xlsx"
  
  # Kollar om den redan finns
  if (file.exists(output_file)) {
    
  } else {
    
    response <- GET(url, write_disk(output_file, overwrite = TRUE))
    
  }
  print('Nedladdning av "Deso och kopplingar" genomfördes')
}

