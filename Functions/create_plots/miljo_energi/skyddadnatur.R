########### Skyddade områden gis #########

# visar var alla skyddade områden är
skydd_karta <- function(){
  
  # Läser in data
  
  gml_file <- "Data/ProtectedSites/PS.protectedSites.NR.gml" 
  suppressMessages( suppressWarnings( 
    protected_sites <- st_read(gml_file, layer = "ProtectedSite",quiet = TRUE) ))
  gml_file <- "Data/ProtectedSites/PS.protectedSites.DVO.gml" 
  suppressMessages( suppressWarnings( 
    dvo_sites <- st_read(gml_file, layer = "ProtectedSite",quiet = TRUE) ))
  gml_file <- "Data/ProtectedSites/PS.protectedSites.KR.gml" 
  suppressMessages( suppressWarnings( 
    KR_sites <- st_read(gml_file, layer = "ProtectedSite",quiet = TRUE) ))
  
  # Shapefil för länet 
  shapefile_path <- "Data/Lan_Sweref99TM/Lan_Sweref99TM_region.shp" 
  suppressMessages( suppressWarnings( 
    lan_shape <- st_read(shapefile_path, quiet = TRUE) )) 
  
  # Tar ut länet 
  lan_shape <- lan_shape %>% filter(LnKod == lanskod) # Ta endast ut det som ligger i länet
  protected_sites <- st_transform(protected_sites, st_crs(lan_shape)) 
  dvo_sites <- st_transform(dvo_sites, st_crs(lan_shape)) 
  KR_sites <- st_transform(KR_sites, st_crs(lan_shape)) 
  
  # Ta endast ut det som ligger i länet
  protected_sites_lan <- st_intersection(protected_sites, lan_shape) 
  dvo_sites <- st_intersection(dvo_sites, lan_shape) 
  KR_sites <- st_intersection(KR_sites, lan_shape) 
  
  
  # Rätt format 
  
  protected_sites_lan <- st_transform(protected_sites_lan, 4326) 
  dvo_sites <- st_transform(dvo_sites, 4326) 
  KR_sites <- st_transform(KR_sites, 4326)
  lan_shape <- st_transform(lan_shape, 4326)
  
  # Färgschema
  site_colors <- list("Naturreservat" = "#4AA271",
                      "Djur- och växtskyddsområde" = "#D57667",
                      "Kulturreservat" = "#F9B000")
  
  # Label options
  my_label_options <- labelOptions(
    direction = "auto",
    style = list(
      "font-size" = "14px",
      "color" = "black",
      "background-color" = "white",
      "padding" = "2px 4px"
    )
  )
  # Skapar karta
  map <-leaflet() %>% 
    addTiles() %>%
    
    # Add polygons
    addPolygons(data = lan_shape, color = "#B81867", fill = FALSE, weight = 2) %>% 
    
    addPolygons(data = protected_sites_lan,
                color = site_colors$Naturreservat,    
                fillOpacity = 0.5, weight = 3, label = ~text, group="Naturreservat",
                labelOptions = my_label_options) %>% 
    
    addPolygons(data = dvo_sites,
                color = site_colors$`Djur- och växtskyddsområde`,
                fillOpacity = 0.5, weight = 4, label = ~text, group="Djur- och växtskyddsområde",
                labelOptions = my_label_options) %>% 
    
    addPolygons(data = KR_sites,
                color = site_colors$Kulturreservat,
                fillOpacity = 0.5, weight = 4, label = ~text, group="Kulturreservat",
                labelOptions = my_label_options) %>% 
    
    # Add legend
    addLegend(position = "topright",
              colors = site_colors,
              labels = names(site_colors),
              title = "Skyddade områden")
  map <- map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  map
  
  
}