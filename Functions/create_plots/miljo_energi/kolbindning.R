######## Kolbindning Ändra sökväg manuellt om nytt år finns #####

kolbindning <- function(){
  
  # Läs in rasterfilen
  r_wgs <- rast("Data/Stock_SOC_Uppsala_wgs.tif")
  r_change <- rast("Data/Stock_SOC_Uppsala_change.tif")
  
  # Läs in kommun-shapefilen
  
  suppressMessages(
    suppressWarnings(
      uppsala_wgs <- st_read("Data/Uppsala_kommuner_wgs.shp", quiet = TRUE)
    ))
  
  suppressMessages(
    suppressWarnings(
      uppsala_change <- st_read("Data/Uppsala_kommuner_change.shp", quiet = TRUE)
    ))
  
  #  Per ton istället för kg
  uppsala_wgs$medel <- uppsala_wgs$medel /1000
  uppsala_change$medel_co <- uppsala_change$medel /1000
  
  uppsala_wgs <- uppsala_wgs %>% left_join(uppsala_change %>% dplyr::select(!medel) %>% st_drop_geometry()
                                           , by='KnNamn')
  
  # Definiera intervall och färger
  # Konvertera raster till ton
  r_ton <- r_wgs / 1000
  r_change <- r_change / 1000
  # Definiera intervall i ton
  breaks_ton <- c(0,1, 100, 200, 300, ceiling(max(values(r_ton), na.rm = TRUE)))
  
  # Färger för varje intervall
  colors <- c( "#DBECE3",'#4AA271', "#F9B000", "#E67E22", "#D0342C")
  
  # Kommuntexter
  kommun_centroids <- st_centroid(uppsala_wgs)
  
  
  # Skapa färgpalett
  pal <- colorBin(
    palette = colors,
    bins = breaks_ton,
    na.color = "transparent",
    pretty = FALSE
  )
  
  # Färgpalett 2
  # Se till att 0-värden i r_ton också blir 0 i r_change
  #r_change[values(r_ton) == 0] <- NA                    # Transparanta sjöar? 
  breaks_ton <- c(seq(floor(min(values(r_change), na.rm = TRUE)),0,length.out=3),seq(3 ,ceiling(max(values(r_change), na.rm = TRUE)), length.out= 4))
  
  # Färger för varje intervall
  colors <- c('#4AA271',"#DBECE3", "#F9B000", "#E67E22", "#D0342C")
  
  pal2 <- colorBin(
    palette = colors,
    bins = breaks_ton,
    na.color = "transparent",
    pretty = FALSE
  )
  
  
  # Skapa Leaflet-karta
  map <- leaflet() %>%
    addTiles() %>%
    addRasterImage(r_ton, colors = pal, opacity = 0.6,group='Markkol')  %>%
    addRasterImage(r_change, colors = pal2, opacity = 0.6,group='Förändring') %>% 
    addPolygons(
      data = uppsala_wgs,
      color = "black",
      weight = 2,
      fillColor = "transparent",
      popup = ~paste0(
        '<b>', KnNamn, '</b><br>',
        '<b>Markkol</b>: ', round(medel, 1), ' ton kol per hektar<br><br>',
        '<b>Förändring</b>: ', round(medel_co, 1), ' ton CO2-ekvavilenter per hektar och år<br><br>'
      )) %>%
    
    # Byte mellan layers
    addLayersControl(
      overlayGroups = c("Markkol", "Förändring"),
      options = layersControlOptions(collapsed = FALSE)
    ) %>% 
    addLegend(pal = pal, 
              values = values(r_ton),
              title = "Markkol <br> (ton kol/ha)",
              group='Markkol')  %>% 
    
    addLegend(
      pal = pal2,
      values = values(r_change),
      position = "bottomright",
      title = paste("Förändring totalt <br> (ton CO2-ekvavilenter per hektar och år)"),
      group = "Förändring"
    ) %>%
    hideGroup("Förändring") %>% # Gömmer deso från startvyn
    
    
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
  
  map <- map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  
  
  # Tar bort legenden för layer Deso
  map <- map %>%
    htmlwidgets::onRender("
    function(el, x) {
      // find all legend elements
      var legends = el.querySelectorAll('.info.legend');

      legends.forEach((lg) => {
        // if the legend title contains 'Förändring totalt', hide it
        if (lg.textContent.includes('Förändring totalt')) {
          lg.style.display = 'none';
        }
        // if it contains 'Markkol', make sure it's visible
        if (lg.textContent.includes('Markkol')) {
          lg.style.display = 'block';
        }
      });
    }
  ")
  
  map
}

