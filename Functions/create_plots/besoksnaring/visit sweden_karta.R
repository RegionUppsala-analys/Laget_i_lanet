#### visist sweden ######


plot_uppsala_tourism <- function(){
  
  # Läser in data
  tourism_sf <- suppressMessages(
    suppressWarnings(
      st_read(
        "Data/uppsala_tourism.gpkg",
        quiet = TRUE
      )
    )
  ) %>%
    st_transform(crs = 4326)
  
  lan_shape <- suppressMessages(
    suppressWarnings(
      st_read(
        "Data/LanSweref99TM/Lan_Sweref99TM_region.shp",
        quiet = TRUE
      )
    )
  ) %>%
    st_transform(crs = 4326)
  
  uppsala <- lan_shape %>%
    dplyr::filter(grepl("Uppsala", LnNamn))
  
  # original types
  type_values <- c("schema:Store", "schema:FoodEstablishment", "schema:LodgingBusiness", "schema:Place")
  
  # mapping to Swedish
  type_labels <- c(
    "schema:Store" = "Butik",
    "schema:FoodEstablishment" = "Restaurang",
    "schema:LodgingBusiness" = "Boende",
    "schema:Place" = "Plats"
  )
  
  # apply mapping
  type_values_swe <- type_labels[type_values]
  tourism_sf$type <- type_labels[tourism_sf$type]
  
  # unique tourism types
  type_values <- unique(tourism_sf$type)
  
  # color palette
  pal <- colorFactor(
    palette = RColorBrewer::brewer.pal(min(8, length(type_values)), "Set2"),
    domain = tourism_sf$type
  )
  
  # Lägg till label och popup med bild och länk
  
  
  # Function to check if a URL is valid
  check_url <- function(url) {
    if(is.na(url) || url == "") return(NA_character_)
    res <- try(HEAD(url), silent = TRUE)
    if(inherits(res, "try-error")) return(NA_character_)
    if(status_code(res) >= 400) return(NA_character_)  # invalid URL
    return(url)
  }
  
  tourism_sf <- tourism_sf %>%
    mutate(
      image_clean = map_chr(image, check_url),
      
      label_text = map2(name, image_clean, ~{
        if(is.na(.y)) {
          HTML(.x)
        } else {
          HTML(paste0(
            "<div style='width:150px;height:100px;overflow:hidden;'>",
            "<img src='", .y, "' style='width:150px;height:100px;object-fit:cover;'>",
            "</div><br><b>", .x, "</b>"
          ))
        }
      }),
      
      popup_text = pmap(list(name, type, description, url, image_clean),
                        function(n, t, d, u, img){
                          HTML(
                            paste0(
                              if(!is.na(img))
                                paste0(
                                  "<div style='width:200px;height:130px;overflow:hidden;'>",
                                  "<img src='", img,
                                  "' style='width:200px;height:130px;object-fit:cover;'>",
                                  "</div><br>"
                                ) else "",
                              "<b>", n, "</b><br>",
                              "<i>", t, "</i><br><br>",
                              d, "<br>",
                              if(!is.na(u) && u != "")
                                paste0("<a href='", u, "' target='_blank'>Mer info</a>")
                              else ""
                            )
                          )
                        }
      )
    )
  
  # Bas-karta med länsgränser
  m <- leaflet(tourism_sf) |>
    addProviderTiles("CartoDB.Positron") |>
    addPolygons(
      data = uppsala,
      color = "#B81867",
      fill = FALSE,
      weight = 3
    )
  
  # Lägg till punkter grupperade på typ
  for (t in type_values) {
    
    
    m <- m |>
      addCircleMarkers(
        data = tourism_sf |> filter(type == t),
        group = t,
        radius = 6,
        color = ~pal(type),
        fillColor = ~pal(type),
        fillOpacity = 0.7,
        stroke = FALSE,
        label = ~label_text,   # Hover visar bilden
        popup = ~popup_text    # Popup med namn, typ, beskrivning och länk
      )
  } 
  
  # Legend för typ
  m <- m |>
    addLegend(
      "bottomright",
      pal = pal,
      values = tourism_sf$type,
      title = "Tourism type",
      opacity = 1
    )
  
  # Lagerkontroll
  m <- m |>
    addLayersControl(
      overlayGroups = type_values,
      options = layersControlOptions(collapsed = FALSE)
    )
  
  # Justera legend och kontrollvänsterjustering
  m <- m %>%
    htmlwidgets::prependContent(
      tags$style(HTML("
      .info.legend { 
        text-align: left !important;
        padding: 8px 12px;
      }

      .leaflet-control-layers-list { 
        text-align: left !important;
        padding: 6px 5px;
      }

      .leaflet-control-layers label { 
        display: block; 
        margin-bottom: 5px; 
        text-align: left !important; 
      }

      .leaflet-control-layers input[type='checkbox'] { 
        margin-right: 5px; 
      }

      .leaflet-popup-content-wrapper { 
        border-radius: 15px;
      }

      .leaflet-popup-content {
        padding: 10px;
      }

      .leaflet-popup-tip { 
        border-radius: 20px; 
      }

      .leaflet-tooltip { 
        border-radius: 4px;
        padding: 4px 8px;
      }
    "))
    )
  
  m
  
}

