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

karta_landareal <- function(){
  df <- read.csv("Data/df_deso_land_vatten.csv")
  
  suppressMessages({
    suppressWarnings({
      st_layers("Data/DeSO_2025.gpkg")
      deso_sf <- st_read("Data/DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE) %>%
        filter(lanskod == !!lanskod)
    })
  })
  
  df <- df %>%
    rename(desokod = region) %>%
    select(desokod, år, arealtyp, Hektar) %>%
    pivot_wider(names_from = arealtyp, values_from = Hektar) %>%
    group_by(desokod) %>%
    mutate(andel_sjo = `inlandsvatten exkl de fyra stora sjöarna` / totalt * 100) %>%
    ungroup()
  
  deso_sf_pop <- deso_sf %>%
    left_join(df, by = "desokod") %>%
    left_join(
      df %>%
        group_by(desokod) %>%
        summarise(
          popup_text = paste0(
            desokod, " år ", år, "<br>",
            "Landareal: ", round(landareal, 2), " ha (", round(landareal / totalt * 100, 1), "%)<br>",
            "Inlandsvatten: ", round(`inlandsvatten exkl de fyra stora sjöarna`, 2), " ha (", round(`inlandsvatten exkl de fyra stora sjöarna` / totalt * 100, 1), "%)<br>",
            "De fyra stora sjöarna: ", round(`de fyra stora sjöarna`, 2), " ha (", round(`de fyra stora sjöarna` / totalt * 100, 1), "%)<br>",
            "Havsvatten: ", round(havsvatten, 2), " ha (", round(havsvatten / totalt * 100, 1), "%)"
          ),
          .groups = "drop"
        ),
      by = "desokod"
    )
  
  mapview(
    deso_sf_pop,
    zcol = "andel_sjo",
    legend = TRUE,
    color = viridis::viridis(20),
    layer.name = paste("Andel sjöareal", max(df$år, na.rm = TRUE)),
    popup = deso_sf_pop$popup_text,
    label = paste("DeSO:", deso_sf_pop$desokod)
  )
}