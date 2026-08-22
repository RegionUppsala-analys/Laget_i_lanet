#################################
# installerar och läser in paket#
#################################


install_and_load <- function() {
  # Installera pxweb v2 från GitHub då det inte hämtas från CRAN i nuläget.
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }

  if (!requireNamespace("pxweb", quietly = TRUE)) {
    # Installera eller uppdatera pxweb från GitHub
    remotes::install_github("ropengov/pxweb")
  }

  library(pxweb)

  # CRAN-paket
  cran_packages <- c(
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
    'glue',
    'survey',
    'zoo',
    'svglite',
    'haven',
    'lubridate'
  )
  
  # Installera och ladda CRAN-paket
  for (pkg in cran_packages) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }

}





