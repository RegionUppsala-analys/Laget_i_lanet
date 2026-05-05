#################################
# installerar och läser in paket#
#################################


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
    'htmlwidgets',
    'htmltools',
    "leaflet.extras2",
    "janitor",
    'purrr',
    'ggrepel',
    'stringi',
    'readr',
    'glue'
    
  )
  
  # Installera och ladda CRAN-paket
  for (pkg in cran_packages) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }

}





