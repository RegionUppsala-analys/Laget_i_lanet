
####### Kolbindning, manuell extrahering av zip !!!!!!!!!########
# https://www.slu.se/miljoanalys/statistik-och-miljodata/miljodatakatalogen/slu-kolkartor/
# https://gis.slu.se/data/carbon/
# https://gis.slu.se/data/carbon/2023/

# Gör allt till en funktion så att den ej körs automatiskt
# Är en nestad funktion som innehåller fukntioner och är ej optimerad för att ladda ned och extrahera allt
# Då minnet kan bli fullt pga stora filer

kolbindnin_nedladdning <- function(){
  #  Bas-URL för data
  base_url <- "https://gis.slu.se/data/carbon/"
  
  #  Läs startsidan och identifiera alla årtal
  page <- read_html(base_url)
  
  # Hitta alla årsmappningar
  years <- page %>%
    html_nodes("a") %>%
    html_text() %>%
    str_remove("/") %>%          
    str_extract("^\\d{4}$") %>%
    na.omit() %>%
    as.integer()
  
  latest_year <- max(years)
  cat("Senaste år:", latest_year, "\n")
  
  # År-URL
  year_url <- paste0(base_url, latest_year, "/")
  
  #  Läs årssidan och plocka ut alla ZIP-filer
  year_page <- read_html(year_url)
  
  files <- year_page %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    str_subset("\\.zip$")
  
  files <- files[files %in% c("Documentation.zip", "Change_All.zip","Stock_SOC.zip")]
  
  #  Skapa lokal katalog: Data/<år>/
  output_dir <- file.path("Data/kolbindning", latest_year)
  dir_create(output_dir)
  
  #  Ladda ner och extrahera ZIP-filer
  options(timeout = 1000)  # öka timeout
  
  # Kolla om zip är extraherad
  is_extracted <- function(zipfile, out_dir) {
    foldername <- str_remove(zipfile, "\\.zip$")
    dir_exists(file.path(out_dir, foldername))
  }
  
  for (file in files) {
    
    dest_zip <- file.path(output_dir, file)
    extracted_exists <- is_extracted(file, output_dir)
    
    if (file_exists(dest_zip) || extracted_exists) {
      cat("Hoppar över (finns redan):", file, "\n")
      next
    }
    
    download_url <- paste0(year_url, file)
    cat("\nLaddar ner:", file, "\n")
    
    #  FELHANTERING
    ok <- tryCatch({
      GET(download_url, write_disk(dest_zip, overwrite = TRUE), progress())
      TRUE
    }, error = function(e) {
      cat("FEL nedladdning:", file, "\n   ->", e$message, "\n")
      FALSE
    })
    
    if (!ok) next
    
    
    # Lista alla filer i zip-filen
    zip_innehall <- unzip(dest_zip, list = TRUE)$Name
    
    # Bestäm vilka filer som ska extraheras
    if (grepl("Documentation", file, ignore.case = TRUE)) {
      # Extrahera allt i Documentation
      filer_att_extrahera <- zip_innehall
    } else {
      # Extrahera endast .tif-filer
      filer_att_extrahera <- zip_innehall[grepl("\\.tif$", zip_innehall, ignore.case = TRUE)]
    }
    
    if (length(filer_att_extrahera) == 0) {
      cat("Inga filer att extrahera i", file, "\n")
      next
    }
    
    # EXTRAKTION MED FELHANTERING
    cat("Extraherar valda filer:", paste(filer_att_extrahera, collapse = ", "), "\n")
    
    ok_extract <- tryCatch({
      withCallingHandlers({
        unzip(dest_zip, files = filer_att_extrahera, exdir = output_dir)
      }, warning = function(w) {
        stop(w)   # gör warning till error
      })
      TRUE
    }, error = function(e) {
      cat("FEL extraktion:", file, "\n   ->", e$message, "\n")
      FALSE
    })
    
    if (!ok_extract) next
    
    cat("Extraherad:", file, "\n")
    
    # Radera zip-filen efter extraktion
    if (file.exists(dest_zip)) {
      file.remove(dest_zip)
      cat("Zip-fil raderad:", file, "\n")
    }
  }
  
  print("Filer nedladdade och extraherade i", output_dir, "\n")
  print("\n Loop kördes färdigt även om fel uppstod.\n")
  
  # Fixar data till plot
  print("Fixar till data till plot 'kolbindning'")
  
  skapa_uppsala_dataset_mark <- function(lanskod) {
    # Läs in rasterfilen
    rasterfil <- "Data/kolbindning/2023/Stock_SOC.tif"
    raster_data <- rast(rasterfil)
    
    # Filtrera ut Uppsala län
    lan <- st_read("Data/Kommun_Sweref99TM/Kommun_Sweref99TM.shp")
    
    uppsala <- lan[grep(paste0("^",lanskod), lan$KnKod), ]
    
    # Transformera polygoner till samma koordinatsystem som raster
    uppsala_proj <- st_transform(uppsala, crs(raster_data))
    uppsala_vect <- vect(uppsala_proj)
    
    # Beskär och maska raster till Uppsala län
    r_uppsala <- crop(raster_data, uppsala_vect)
    r_uppsala_masked <- mask(r_uppsala, uppsala_vect)
    
    # Gör raster mindre för snabbare visualisering
    r_nedskalat <- aggregate(r_uppsala_masked, fact = 10)
    
    # Transformera raster till WGS84 för Leaflet
    r_wgs <- project(r_nedskalat, "EPSG:4326")
    
    # Transformera polygoner till WGS84
    uppsala_wgs <- st_transform(uppsala, 4326)
    
    # Beräkna medelvärde av kol per hektar och kommun exkluderar vatten med att utesluta 0
    medelvärde <- terra::extract(raster_data, uppsala_vect,
                                 fun = function(x) mean(x[x != 0], na.rm = TRUE))
    
    uppsala_wgs$medel <- medelvärde$Band_1
    
    # Spara raster och polygoner
    output_dir <- "Data"
    dir.create(output_dir, showWarnings = FALSE)
    writeRaster(r_wgs, file.path(output_dir, "Stock_SOC_Uppsala_wgs.tif"), overwrite = TRUE)
    st_write(uppsala_wgs, file.path(output_dir, "Uppsala_kommuner_wgs.shp"), delete_layer = TRUE)
  }
  
  #skapa_uppsala_dataset_mark(lanskod)
  
  skapa_uppsala_dataset_change <- function(lanskod) {
    # Läs in rasterfilen
    rasterfil <- "Data/kolbindning/2023/Change_ALL.tif"
    raster_data <- rast(rasterfil)
    
    # Filtrera ut Uppsala län
    lan <- st_read("Data/Kommun_Sweref99TM/Kommun_Sweref99TM.shp")
    
    uppsala <- lan[grep(paste0("^",lanskod), lan$KnKod), ]
    
    # Transformera polygoner till samma koordinatsystem som raster
    uppsala_proj <- st_transform(uppsala, crs(raster_data))
    uppsala_vect <- vect(uppsala_proj)
    
    # Beskär och maska raster till Uppsala län
    r_uppsala <- crop(raster_data, uppsala_vect)
    r_uppsala_masked <- mask(r_uppsala, uppsala_vect)
    
    # Gör raster mindre för snabbare visualisering
    r_nedskalat <- aggregate(r_uppsala_masked, fact = 10)
    
    # Transformera raster till WGS84 för Leaflet
    r_wgs <- project(r_nedskalat, "EPSG:4326")
    
    # Transformera polygoner till WGS84
    uppsala_wgs <- st_transform(uppsala, 4326)
    
    # Beräkna medelvärde av kol per hektar och kommun exkluderar vatten med att utesluta 0
    medelvärde <- terra::extract(raster_data, uppsala_vect,
                                 fun = function(x) mean(x, na.rm = TRUE))
    
    uppsala_wgs$medel <- medelvärde$Band_1
    
    # Spara raster och polygoner
    output_dir <- "Data"
    dir.create(output_dir, showWarnings = FALSE)
    writeRaster(r_wgs, file.path(output_dir, "Stock_SOC_Uppsala_change.tif"), overwrite = TRUE)
    st_write(uppsala_wgs, file.path(output_dir, "Uppsala_kommuner_change.shp"), delete_layer = TRUE)
  }
  
  # Kör funktionen
  #skapa_uppsala_dataset_change(lanskod)
  
  print('data är sparat')
}





