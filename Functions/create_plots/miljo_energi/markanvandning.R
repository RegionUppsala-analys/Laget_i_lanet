########################## Markanvändning #####################


karta_skog <- function(){
  # Läser in data
  px_markanvandning <- read.csv('Data/df_markanvandning.csv')  %>% filter(vart.5.e.år== max(vart.5.e.år))
  shapefile_path <- "Data/Kommun_Sweref99TM/Kommun_Sweref99TM.shp"
  
  suppressMessages(
    suppressWarnings(
      kommun_shape <- st_read(shapefile_path, quiet = TRUE)
    ))
  # Tar ut uppsala län
  kommun_shape <- kommun_shape[grep(paste0("^",lanskod), kommun_shape$KnKod), ]
  
  # kommun_shape och px_markanvandning kopplas ihop baserat på KnNamn och region
  kommun_shape_merged <- kommun_shape %>%
    left_join(px_markanvandning, by = c("KnNamn" = "region"))
  
  #Gör karta i Leaflet
  # Omprojicera till WGS84 (EPSG:4326) för att använda i Leaflet
  kommun_shape_leaflet <- st_transform(kommun_shape_merged, crs = 4326)
  
  # Popup text med data för alla variabler
  popup <-  kommun_shape_leaflet %>%
    group_by(KnKod) %>%
    summarise(
      popup = paste0(
        unique(KnNamn),' år ',unique(vart.5.e.år),"<br>",
        paste0(
          "Andel Skogsmark: ", round(andel.total.skogsmark,3)*100,' %',"<br>",
          "Andel jordbruksmark: ", round(andel.total.jordbruksmark,3)*100,' %',"<br>",
          "Andel bebyggd och anlagd mark: ", round(andel.bebyggd.och.anlagd.mark,3)*100,' %',"<br>",
          "Andel öppen myrmark: ", round(andel.öppen.myrmark,3)*100,' %',"<br>",
          "Andel övrig mark: ", round(andel.övrig.mark,3)*100,' %',"<br>",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  
  # Lägger in popup text
  kommun_shape_leaflet <- kommun_shape_leaflet %>%
    left_join(popup, by = c("KnKod"))
  
  
  
  # Layer för namnen på kommunerna
  kommun_centroids <- st_centroid(kommun_shape_leaflet)
  
  # Skapa den interaktiva Leaflet-kartan
  fig <- leaflet(data = kommun_shape_leaflet) %>%
    addTiles() %>%
    # Lägger in data
    addPolygons(
      fillColor = ~colorBin('viridis', andel.total.skogsmark)(andel.total.skogsmark),
      weight = 2,
      opacity = 1,
      color = "black",
      fillOpacity = 1,
      popup = ~popup,
      label = ~paste0(KnNamn, ": Andel skogsmark: ", scales::percent(andel.total.skogsmark, accuracy = 0.1)),
      highlightOptions = highlightOptions(
        weight = 3,
        color = "#666",
        fillOpacity = 0.7,
        bringToFront = TRUE
      )
    ) %>%
    # Lägger till legend
    addLegend(
      pal = colorBin('viridis', kommun_shape_merged$andel.total.skogsmark, reverse = FALSE),
      values = kommun_shape_merged$andel.total.skogsmark,
      title = paste("Andel Skogsmark",max(kommun_shape_leaflet$vart.5.e.år)),
      position = "bottomright",
      labFormat = labelFormat(suffix = "%", transform = function(x) 100 * x)
    ) %>% 
    # Kommunlabels
    addLabelOnlyMarkers(
      data = kommun_centroids,
      label = ~KnNamn ,
      labelOptions = labelOptions(
        noHide = TRUE,
        direction = 'center',
        textOnly = TRUE,
        style = list(
          "color" = "black",
          "font-size" = "12px",
          "font-weight" = "bold",
          "text-shadow" = "1px 1px 2px white, -1px 1px 2px white, 1px -1px 2px white, -1px -1px 2px white"
        )
      ))
  fig  
} 