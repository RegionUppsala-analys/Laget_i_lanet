

install_and_load <- function() {
  # CRAN-paket
  cran_packages <- c(
    "pxweb",
    "dplyr",
    "ggplot2",
    "tidyr",
    "cowplot",
    "readxl",
    "stringr",
    "leaflet",
    "sf",
    "mapview",
    "showtext",
    "gt",
    "plotly",
    "remotes", 
    'htmltools',
    'sf',
    'reactable',
    'forcats',
    'scales',
    'RColorBrewer',
    'magick',
    'GGally',
    'kableExtra',
    'jsonlite',
    'httr',
    'rKolada',
    'checkmate',
    'utils',
    'zoo',
    'svglite',
    'rKolada',
    'rvest',
    'purrr',
    'xml2'
  )
  
  # Installera och ladda CRAN-paket
  for (pkg in cran_packages) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }
  
}
install_and_load()





### För atom-flöde
load_geodata_atom <- function(url, file_path){
  dir.create(file_path, showWarnings = FALSE, recursive = TRUE)
  
  # Läs huvudfeed
  feed <- tryCatch(read_xml(url),
                   error = function(e) stop("Kunde inte läsa URL: ", url))
  
  ns <- xml_ns(feed)
  
  message("📥 Läser huvudfeed: ", url)
  
  #  Hämta datasetFeeds från <entry><content> (CDATA HTML)
  content_nodes <- xml_find_all(feed, ".//d1:content", ns)
  if (length(content_nodes) == 0)
    content_nodes <- xml_find_all(feed, ".//content")  # fallback utan namespace
  
  htmls <- xml_text(content_nodes)
  
  # Extrahera alla länkar till dataset-feeds
  dataset_feeds <- str_extract_all(htmls, "https?://[^\"']+\\.xml") |> unlist()
  
  # Hämta även <link rel='alternate'> om de finns
  alt_links <- xml_find_all(feed, ".//d1:link[@rel='alternate']", ns)
  if (length(alt_links) == 0)
    alt_links <- xml_find_all(feed, ".//link[@rel='alternate']")
  
  alt_urls <- xml_attr(alt_links, "href")
  
  # Kombinera allt
  dataset_feeds <- unique(c(dataset_feeds, alt_urls))
  
  if (length(dataset_feeds) == 0) {
    stop("Ingen dataset-feed hittades i feeden.")
  }
  
  message("📂 Hittade ", length(dataset_feeds), " dataset-feeds.")
  
  # Loopar över alla datafeeds
  for (feed_url in dataset_feeds) {
    message("\n Läser feed: ", feed_url)
    
    # Testar att ladda ned
    subfeed <- tryCatch(
      read_xml(feed_url),
      error = function(e) {
        message("Kunde inte läsa dataset-feed (404 etc.): ", feed_url)
        return(NULL)
      }
    )
    
    if (is.null(subfeed)) next # hoppar till nästa om det inte gick
    
    # Ignorera namespace (viktigt!)
    content_nodes <- xml_find_all(subfeed, ".//d1:content", xml_ns(subfeed))
    if (length(content_nodes) == 0) {
      content_nodes <- xml_find_all(subfeed, ".//content")  # fallback utan prefix
    }
    content_nodes <- xml_find_all(subfeed, ".//d1:id", xml_ns(subfeed))
    
    # Tar ut gml/zip-filer
    htmls <- xml_text(content_nodes)
    links <- str_extract_all(htmls, "https?://[^\"'>]+(\\.zip|\\.gml(?:\\.gz)?|\\.gml)(\\?[^\"'>]*)?") |> unlist()
    
    if (length(links) == 0) {
      message("Ingen fil hittades i feeden.") # går vidare om inget hittades
      next
    }
    
    # Loopar över filerna och laddar hem
    for (f in links) {
      dest <- file.path(file_path, basename(f))
      
      if (!file.exists(dest)) {
        message("Försöker ladda ned: ", basename(f))
        
        success <- tryCatch({
          download.file(f, dest, mode = "wb")
          TRUE
        }, warning = function(w) {
          message("Kunde inte ladda ned (varning): ", f)
          FALSE
        }, error = function(e) {
          message("Fel vid hämtning: ", f)
          FALSE
        })
        
        #  fallback via <id> om nedladdning misslyckas
        if (!success) {
          id_nodes <- xml_find_all(subfeed, ".//id")
          if (length(id_nodes) == 0)
            id_nodes <- xml_find_all(subfeed, ".//d1:id", xml_ns(subfeed))
          
          id_links <- xml_text(id_nodes)
          id_links <- str_extract_all(id_links, "https?://[^\"'>]+(\\.zip|\\.gml(?:\\.gz)?|\\.gml)(\\?[^\"'>]*)?") |> unlist()
          if (length(id_links) > 0) {
            fallback_url <- id_links[1]  # ta första id-länken
            fallback_dest <- file.path(file_path, basename(fallback_url))
            message("Försöker fallback via <id>: ", basename(fallback_url))
            
            tryCatch({
              download.file(fallback_url, fallback_dest, mode = "wb")
            }, warning = function(w) {
              message("Kunde inte ladda ned fallback: ", fallback_url)
            }, error = function(e) {
              message("Fel vid hämtning av fallback: ", fallback_url)
            })
          }
        }
        
      } else {
        message("Redan nedladdad: ", basename(f))
      }
    }
  }
  
  # Hämta ZIP-filer
  zip_files <- list.files(file_path, pattern = "\\.zip$", full.names = TRUE)
  
  # Kör unzip endast om det finns ZIP-filer
  if (length(zip_files) > 0) {
    
    message("Extraherar ", length(zip_files), " ZIP-fil(er).")
    
    # Unzip
    for (z in zip_files) {
      unzip(z, exdir = file_path)
      
      # Tar bort zip filerna
      message("Tar bort ZIP-filer efter extrahering...")
      file.remove(z)
    }
  } 
  
  
}


# Example use
# load_geodata_atom(url='https://geodata.naturvardsverket.se/atom/inspire/ps/SE_ProtectedSites_serviceFeed.xml',file_path ="Data/ProtectedSites")
# load_geodata_atom(url='https://geodata.naturvardsverket.se/atom/inspire/pf/SE_PF_EURegistry_serviceFeed.xml',file_path ="Data/test")


################# GEOdata atom  #############
# Denna funktion är endast skapad för att inte köra koden nedan, kör varje del manuellt om ny data finns tillgänglig.
geo_data <- function(){
  ############# Skyddade områden: naturvårdsområden ##########
  # https://www.geodata.se/geodataportalen/srv/swe/catalog.search#/metadata/dd8371a0-f692-44e3-bd0b-25de8dee8906
  load_geodata_atom(url='https://geodata.naturvardsverket.se/atom/inspire/ps/SE_ProtectedSites_serviceFeed.xml',file_path ="Data/ProtectedSites")
  
}