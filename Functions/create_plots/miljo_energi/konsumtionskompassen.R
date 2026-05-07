########## Konsumtionskompassen #####################
####### Skapar en karta likt den från konsumtionskompassens hemsida
Deso_konsumtionskompass <- function(){
  ## Denna data laddas ned manuellt från https://konsumtionskompassen.se/
  ## 2025 laddades data för 2022 ned!
  ############################Lägger in året manuellt då det ej följer med datan
  ar <- 2022 
  ############################
  ## Data laddas ned genom att klicka på varje kommun och ladda ned desodata från kolumn : Sammanräknade utsläpp i valda konsumtionskategorier
  
  # laddar in data beroende på deso-uppdelningen (Hoppas att hemsidan uppdaterar till detta när möjlighet finns)
  if(ar >2023){
    # läser in DeSo 2025  
    suppressMessages({
      suppressWarnings({
        st_layers("Data/DeSO_2025.gpkg")
        deso_sf <- st_read("Data/DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE) %>%
          filter(lanskod == !!lanskod) # we keep only Uppsala län
      })
    })
    
  }else{
    # läser in DeSo 2018  
    suppressMessages({
      suppressWarnings({
        st_layers("Data/DeSO_2018.gpkg")
        deso_sf <- st_read("Data/DeSO_2018.gpkg", layer = "DeSO_2018", quiet = TRUE) %>%
          filter(lanskod == !!lanskod) # we keep only Uppsala län
      })
    })
    
  }
  shapefile_path <- "Data/Kommun_Sweref99TM/Kommun_Sweref99TM.shp"
  suppressMessages(
    suppressWarnings(
      kommun_shape <- st_read(shapefile_path, quiet = TRUE)
    ))
  # Tar ut uppsala län
  kommun_shape <- kommun_shape[grep(paste0("^",lanskod), kommun_shape$KnKod), ]
  
  
  
  # läser in nedladdad data
  df_deso <- data.frame() # tom dataframe som ska fyllas
  df_kommun <- data.frame()
  
  # Läser in data för alla kommuner
  for(k in kommuner){
    file <- paste0("Data/sammanräknade-utsläpp-i-valda-konsumtionskategorier_", k,'.csv')
    df <- read.csv(file)
    
    df_deso <- rbind(df_deso,df[-c(1:3), ]) # rbindar data
    if(k == 'Knivsta'){
      # Läns och riksdata finns i varje fil, sparar endast det från 1
      df_kommun <- rbind(df_kommun,df[c(1:3), ]) # Sparar endast de första raderna
    }else{
      df_kommun <- rbind(df_kommun,df[1, ])
    }
  }
  
  # Byter namn så det matcha deso
  df_kommun <- df_kommun %>% rename('kommunkod'=code) 
  df_deso <- df_deso %>% rename('desokod'=code)
  
  # Slår ihop datan
  df_deso <- left_join(deso_sf, df_deso, by = "desokod")
  df_kommun <- left_join(kommun_shape, df_kommun, by = c('KnKod'  ="kommunkod"   ))
  
  #  Bygg popup-texten med andelar
  df_pop <- df_kommun %>%
    group_by(KnKod) %>%
    summarise(
      popup = paste0(
        unique(name),"<br>",
        paste0(
          "Totalt utsläpp i ton: ", round((emissions*population)/1000,0),"<br>",
          "Per capita (kg): ",emissions,
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  
  #  Slå ihop geometri, populäraste form & popup 
  kommuner_sf <- df_kommun %>%
    left_join(df_pop, by = "KnKod")
  
  
  # centroider för kommunnamn
  kommun_centroids <- st_centroid(kommuner_sf)
  
  #  Bygg popup-texten med andelar
  df_pop2 <- df_deso %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(name),"<br>",
        paste0(
          "Totalt utsläpp i ton: ", round((emissions*population)/1000,0),"<br>",
          "Per capita (kg): ",emissions,
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  
  #  Slå ihop geometri, populäraste form & popup 
  deso_sf_pop2 <- df_deso %>%
    left_join(df_pop2, by = "desokod")
  
  # lägger in label
  deso_sf_pop2$label <- paste(
    "DeSO: ", deso_sf_pop2$name, " | ",
    "Per capita (kg): ",deso_sf_pop2$emissions)
  
  # ser till att alla är sf layer
  kommuner_sf       <- st_transform(kommuner_sf, 4326)
  deso_sf_pop2      <- st_transform(deso_sf_pop2, 4326)
  kommun_centroids  <- st_transform(kommun_centroids, 4326)
  
  # palette för lagren
  pal1 <- colorBin(
    palette = "viridis",
    domain = kommuner_sf$emissions,
    bins = 8
  )
  
  pal2 <- colorBin(
    palette = "viridis",
    domain = deso_sf_pop2$emissions,
    bins = 8
  )
  
  # skapar kartan
  map <- leaflet() %>%
    addTiles() %>%
    
    # kommun layer 1
    addPolygons(
      data = kommuner_sf,
      fillColor = ~pal1(emissions),
      fillOpacity = 0.8,
      color = NA,
      popup = ~popup,
      group = "Kommun"
    ) %>%
    
    # DESO layer 2
    addPolygons(
      data = deso_sf_pop2,
      fillColor = ~pal2(emissions),
      fillOpacity = 0.6,
      "color" = "black",
      weight = 0.6,
      opacity = 1,
      popup = ~popup,
      group = "DeSO"
    ) %>%
    
    # Borders för kommunerna 
    addPolylines(
      data = kommuner_sf,
      color = "black",
      weight = 2,
      opacity = 1,
      group = "Kommun"
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
      ),
      group = "Municipalities"
    ) %>%
    
    #  legends
    addLegend(
      pal = pal1,
      values = kommuner_sf$emissions,
      position = "bottomright",
      title = paste("Kommun: utsläpp per capita (kg),",ar),
      group = "Kommun"
    ) %>%
    
    addLegend(
      pal = pal2,
      values = deso_sf_pop2$emissions,
      position = "bottomright",
      title = paste("DeSO: utsläpp per capita (kg),",ar),
      group = "DeSO"
    ) %>%
    hideGroup("DeSO") %>% # Gömmer deso från startvyn
    
    # Byte mellan layers
    addLayersControl(
      overlayGroups = c("Kommun", "DeSO"),
      options = layersControlOptions(collapsed = FALSE)
    )
  
  # Tar bort legenden för layer Deso
  map <- map %>%
    htmlwidgets::onRender("
    function(el, x) {
      // find all legend elements
      var legends = el.querySelectorAll('.info.legend');

      legends.forEach((lg) => {
        // if the legend title contains 'DeSO: utsläpp per capita (kg)', hide it
        if (lg.textContent.includes('DeSO: utsläpp per capita (kg)')) {
          lg.style.display = 'none';
        }
        // if it contains 'Kommun emission', make sure it's visible
        if (lg.textContent.includes('Kommun emission')) {
          lg.style.display = 'block';
        }
      });
    }
  ")
  map
  
  
}


###### Tidsserie likt den från konsumtionskompassens hemsida
Utslapp_over_tid <- function(){
  ############################################################################################
  ## Denna data laddas ned manuellt från https://konsumtionskompassen.se/
  ## 2025 laddades data för 2022 ned!
  ## Data laddas ned genom att klicka på länet och ladda ned tidsserien för varje vald kommun
  ############################################################################################
  
  # Läser in data
  df <- read.csv('Data/hushållens-totala-utsläpp-över-tid.csv') 
  colnames(df) <- gsub("^X", "", colnames(df)) # Tar bort X framför varje år
  
  # Gör till longformat
  df_long <- df %>% dplyr::select(-code) %>%  pivot_longer(names_to = 'År',cols = -region,values_to = "value" )
  
  
  # Sortera kommuner alfabetiskt, Region först
  alfabetiska_kommuner <- sort(kommuner)
  unika_regioner <- c(lan, alfabetiska_kommuner)
  
  # Färgschema
  colors_with_lanet <- c(setNames("#B81867", lan),kommun_colors)
  
  fig <- plot_ly()
  
  # Tar ut y_max för att sätta y-axeln
  y_max <- max(df_long$value, na.rm = TRUE)
  
  # Trace per region
  for(r in unika_regioner ){
    # Filtrerar ut och ordnar data
    df_temp <- df_long %>% filter(region == r)
    df_temp <- df_temp[order(df_temp$År), ]
    
    # Lägger till trace
    fig <- fig %>%
      add_trace(
        x = df_temp$År,
        y = round(df_temp$value,0),
        type = 'scatter',               
        mode = 'lines+markers',         
        name = r,
        line = list(color = colors_with_lanet[r],
                    width = ifelse(r == lan, 3, 2)),
        marker = list(color = colors_with_lanet[r],
                      size = ifelse(r == lan, 6, 4)),
        hovertemplate = paste0("%{y:,} kg"),
        showlegend = TRUE
      )
  }
  
  # Layout
  fig <- fig %>% layout(
    margin = list(t = 50),
    title = list(
      font = list(size = 20 , color = "#B81867"),
      text = "<b>Hushållens totala konsumtionsutsläpp över tid<b>",
      x = 0.5,
      y = 1.3
    ),
    xaxis = list(title = "",font = list(size = 14 )),
    yaxis = list(title = "<b>kg CO₂e /capita<b>",
                 range = c(4000, y_max * 1.05),
                 font = list(size = 14 )),
    legend = list(
      x = 1.02,
      y = 1,
      xanchor = "left",
      yanchor = "top"
    ),
    hovermode = 'x unified',
    uirevision = TRUE ,
    annotations = list(
      text = 'Källa: Konsumtionskompassen',
      x = 0,            
      y = -0.1,        
      xref = "paper",
      yref = "paper",
      xanchor = "left",
      yanchor = "bottom",
      showarrow = FALSE,
      font = list(size = 12)
    ))
  
  
  
  # Tar bort plotly-funktioner
  fig <- 
    plotly::config(fig,
                   modeBarButtonsToRemove = c(
                     'zoom2d',
                     'pan2d',
                     'select2d',
                     'lasso2d',
                     'zoomIn2d',
                     'zoomOut2d'
                   ),
                   displaylogo = FALSE
    )
  
  fig
  
}

###### Fördelning av utsläpp per konsumtionskategori likt den från konsumtionskompassens hemsida
Fordelning_per_kategori <- function(){
  ################################################################################
  ## Denna data laddas ned manuellt från https://konsumtionskompassen.se/
  ## 2025 laddades data för 2022 ned!
  ############################Lägger in året manuellt då det ej följer med datan
  ar <- 2022 
  ################################################################################
  
  df <- read.csv('Data/fördelning-av-utsläpp-per-konsumtionskategori.csv')
  df[1,1] <- lan
  df_long <- df %>% dplyr::select(-code) %>%  pivot_longer(names_to = 'Konsumtionskategori',cols = -region,values_to = "value" )
  
  # beräknar andelar per kommun för kategori 
  df_long <- df_long %>% group_by(region) %>% mutate(
    share = (value/sum(value)) *100) %>% ungroup()
  
  # byter ut punkter mot mellanslag
  df_long <- df_long %>% 
    mutate(
      Konsumtionskategori = gsub("\\.", " ", Konsumtionskategori) 
    )
  
  # Sortera kommuner alfabetiskt, Region först
  alfabetiska_kommuner <- sort(kommuner, decreasing = T)
  unika_regioner <- c(alfabetiska_kommuner,lan )
  
  # Vektor med alla kategorier
  kategorier <- c(
    "Livsmedel och alkoholfria drycker",
    "Alkoholhaltiga drycker och tobak",
    "Kläder och skodon",
    "Bostäder vatten elektricitet gas och andra bränslen",
    "Inventarier hushållsutrustning och rutinunderhåll av bostaden",
    "Hälso  och sjukvård",
    "Transport",
    "Information och kommunikation",
    "Fritid sport och kultur",
    "Utbildningstjänster",
    "Hotell kaféer och restauranger",
    "Försäkrings  och finanstjänster",
    "Personlig vård socialt skydd och diverse varor och tjänster"
  )
  
  # Gör till faktorvariabel med samma ordning som vektorn
  df_long$Konsumtionskategori <- factor(df_long$Konsumtionskategori, levels = kategorier)
  
  df_long$region <- factor(df_long$region, levels = unika_regioner)
  
  # Färgpalette med 13 värden från konsumtionskompassens hemsida
  colors <- c("#00d29a","#004d33" ,"#5edddf" , "#ec7d33","#afaaff", "#3881f8", "#e4535f",
              "#efb12b", "#3f5d7d", "#ffdd0f","#5765e5",  "#2b5798", "#cc79a7")
  
  
  
  # Skapar plotten
  fig <- plot_ly(
    df_long,
    x = ~share,
    y = ~region,
    color = ~Konsumtionskategori,
    colors = colors,
    type = "bar",
    orientation = "h",
    textposition = "inside",
    customdata = ~Konsumtionskategori,
    hovertemplate = paste0(
      "Region: %{y}<br>",
      "Kategori: %{customdata}<br>",
      "Andel: %{x:.1f}%<extra></extra>"
    )
  ) %>%
    layout(
      margin = list(t = 50, b=50),
      title= list(font = list(size = 20 , color = "#B81867"),
                  text = paste("<b>Fördelning av utsläpp per konsumtionskategori år",ar,"<b>"),
                  x = 0.5,        # centrera
                  y = 0.98
      ),
      barmode = "stack", # barsen på varandra
      xaxis = list(title = "<b>Andel av totala utsläpp (%)<b>", range = c(0, 100),x = -0.1,
                   font = list(size =14)),
      yaxis = list(title = "", categoryorder = "array", categoryarray = sort(unique(df_long$region)),
                   tickfont = list(size =14)),
      showlegend = FALSE,
      annotations = list(
        text = 'Källa: Konsumtionskompassen',
        x = 0,            
        y = -0.1,        
        xref = "paper",
        yref = "paper",
        xanchor = "left",
        yanchor = "bottom",
        showarrow = FALSE,
        font = list(size = 12)
      )
    )
  
  # Tar bort plotly-funktioner
  fig <- plotly::config(
    fig,
    modeBarButtonsToRemove = c(
      'zoom2d',     # zoom button
      'pan2d',      # pan button
      'select2d',   # box select
      'lasso2d',    # lasso select
      'zoomIn2d',   # zoom in
      'zoomOut2d'   # zoom out
    ),
    displaylogo = FALSE)
  
  fig
}

