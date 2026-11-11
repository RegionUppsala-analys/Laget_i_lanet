########################################
## Ställer in kommunnamn, färger etc####
########################################

authenticate_carto_tiles <- function(map) {
  api_key <- trimws(Sys.getenv("CARTO_API_KEY"))
  if (!nzchar(api_key)) {
    stop("CARTO_API_KEY saknas. Ange CARTO:s webbnyckel i .Renviron och starta om R.", call. = FALSE)
  }
  is_mapview <- inherits(map, "mapview")
  widget <- if (is_mapview) map@map else map
  if (!inherits(widget, "leaflet")) {
    stop("Kartan måste vara ett Leaflet- eller mapview-objekt.", call. = FALSE)
  }

  styles <- c("CartoDB.Positron" = "rastertiles/positron", "CartoDB.DarkMatter" = "dark_all")
  attribution <- paste(
    '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    '&copy; <a href="https://carto.com/attributions">CARTO</a>'
  )
  tile_call <- function(style, layer_id = NULL, group = NULL, options = leaflet::tileOptions()) {
    leaflet::addTiles(
      leaflet::leaflet(),
      urlTemplate = paste0(
        "https://basemaps.cartocdn.com/", style,
        "/{z}/{x}/{y}.png?key=", utils::URLencode(api_key, reserved = TRUE)
      ),
      attribution = attribution, layerId = layer_id, group = group, options = options
    )$x$calls[[1]]
  }

  # Byt endast CARTO-anrop, på samma plats i widgetens anropslista.
  # Då bevaras lagerkontroller, andra bakgrundskartor och datalagrens ordning.
  has_carto <- FALSE
  widget$x$calls <- lapply(widget$x$calls, function(call) {
    if (identical(call$method, "addProviderTiles") &&
        startsWith(call$args[[1]], "CartoDB")) {
      provider <- call$args[[1]]
      if (!provider %in% names(styles)) {
        stop(paste("CARTO-stilen saknar autentiseringsstöd:", provider), call. = FALSE)
      }
      has_carto <<- TRUE
      options <- call$args[[4]]
      if (is.null(options$maxZoom)) options$maxZoom <- 20
      return(tile_call(styles[[provider]], call$args[[2]], call$args[[3]], options))
    }
    if (identical(call$method, "addTiles") &&
        grepl("basemaps.cartocdn.com/", call$args[[1]], fixed = TRUE)) {
      has_carto <<- TRUE
      call$args[[1]] <- sub("\\?.*$", "", call$args[[1]])
      call$args[[1]] <- paste0(call$args[[1]], "?key=", utils::URLencode(api_key, reserved = TRUE))
    }
    call
  })
  if (!has_carto) {
    widget$x$calls <- append(widget$x$calls, list(tile_call("rastertiles/positron")), after = 0L)
  }
  if (is_mapview) {
    map@map <- widget
    return(map)
  }
  widget
}

get_settings <- function() {
  kommunkod <- c("0330", "0331", "0360", "0380", "0381", "0382", "0305", "0319")
  kommuner <- c("Knivsta", "Heby", "Tierp", "Uppsala", "Enköping", "Östhammar", "Håbo", "Älvkarleby")
  
  lan <- "Uppsala län"
  lanskod <- "03"
  
  # Source Sans Pro heter numera Source Sans 3 hos Google Fonts.
  if (!"sourcesanspro" %in% sysfonts::font_families()) {
    sysfonts::font_add_google("Source Sans 3", "sourcesanspro")
  }
  if (!"Arial" %in% sysfonts::font_families()) {
    sysfonts::font_add("Arial", regular = "arial.ttf", bold = "arialbd.ttf")
  }
  showtext::showtext_auto()
  
  
  # Theme
  region_theme_pdf <- ggplot2::theme(
    text = element_text(family = "sourcesanspro", size = 12),
    plot.title = element_text(family = "Arial", face = "bold", size = 20, hjust = 0.5, color = "#B81867"),
    axis.title = element_text(size = 16, face = "bold"),
    axis.text = element_text(size = 12),
    legend.text = element_text(size = 12),
    legend.title = element_text(family = "Arial", face = "bold", size = 16),
    strip.text = element_text(family = "Arial", face = "bold", size = 14),
    plot.margin = grid::unit(c(20, 30, 20, 20), "pt")
  )
  ggplot2::theme_set(ggplot2::theme_minimal() + region_theme_pdf)
  
  kommun_colors <- c(
    "Enköping" = "#D57667",
    "Heby" = "#F9B000", 
    "Håbo" = "#019CD7",
    "Knivsta" = "#D0342C",
    "Tierp" = "#4AA271",
    "Uppsala" = "#6F787E",
    "Älvkarleby" = "#8B4A9C",
    "Östhammar" = "#E67E22"
  )
  
  riket_narliggande <- c('00','03',"04", "05", "18", "19")

  upplat_colors <- c(
    "hyresrätt" = "#D57667",
    "bostadsrätt" = "#F9B000",
    "äganderätt" = "#019CD7"
  )
  
  # Returnera allt som lista
  list(
    kommunkod = kommunkod,
    kommuner = kommuner,
    kommun_colors = kommun_colors,
    riket_narliggande=riket_narliggande,
    upplat_colors = upplat_colors,
    lanskod = lanskod,
    lan = lan
  )
}
