socioindex_karta <- function(){
  # läser in datasets
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_desocioindex.gpkg")
      deso_joined <- st_read("Data/df_desocioindex.gpkg", quiet = TRUE)
    })
  })
  
  #  Bygg popup-texten med andelar
  popup_text <- deso_joined %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          'Andel med endast förgymnasial utbildning: ', Andel, "%", "<br>",
          'Andel arbetslösa: ' , round(Andel_arbetslösa,1), "%", "<br>",
          'Andel med låg ekonomisk standard: ', round(Låg.ekonomisk.standard..procent,1), "%",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  # slår ihop
  deso_sf_pop_join <- deso_joined %>%
    left_join(popup_text, by = "desokod")
  
  deso_sf_pop_join$label <- paste(
    "DeSO: ", deso_sf_pop_join$desokod,  " | ",
    'Socioekonomiskt index:',
    deso_sf_pop_join$area_type_description)
  deso_sf_pop_join$area_type <- factor(deso_sf_pop_join$area_type, levels = 1:5)
  
  # färgschema
  custom_colors <- c("#D57667", "#EABAB3", "#FFFFFF", "#A4D0B8", "#4AA271")
  
  # skapar karta
  map <- mapview(
    deso_sf_pop_join,
    zcol = "area_type",
    legend = TRUE,
    layer.name = paste("Socioekonomiskt index", unique(deso_sf_pop_join$år)),
    at =  1:5,
    col.regions = custom_colors,
    popup = deso_sf_pop_join$popup,
    label =  deso_sf_pop_join$label
  )
  
  # fixar legendtexten
  map@map <- map@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  # Layer med andel som endast har förgymnasial utbildning
  
  #  Bygg popup-texten med andelar
  popup_text <- deso_joined %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          str_to_title(utbildningsnivå), ": ", Andel, "% (", Befolkning, " st)",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  # slår ihop data
  deso_sf_pop_utb <- deso_joined %>%
    left_join(popup_text, by = "desokod")
  
  
  deso_sf_pop_utb$label <- paste(
    "DeSO: ", deso_sf_pop_utb$desokod,  " | ",
    'Andel förgymnasial utbildning:',
    deso_sf_pop_utb$Andel,'%' )
  
  maxandel <- max(deso_sf_pop_utb$Andel)
  map2 <- mapview(
    deso_sf_pop_utb,
    zcol = "Andel",
    legend = TRUE,
    layer.name = paste("Andel med endast förgymnasial utbildning", unique(deso_joined$år)),
    at =  seq(0,maxandel+round(maxandel/5),round(maxandel/5)),
    col.regions = viridis::cividis(11),
    popup = deso_sf_pop_utb$popup,
    label =  deso_sf_pop_utb$label,
    hide= T
  )
  
  map2@map <- map2@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  # Layer med andel arbetslösa
  popup_text <- deso_joined %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          'Andel arbetslösa: ', round(Andel_arbetslösa,1), "%",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  
  deso_sf_pop <- deso_joined %>%
    left_join(popup_text, by = "desokod")
  
  
  deso_sf_pop$label <- paste(
    "DeSO: ", deso_sf_pop$desokod,  " | ",
    'Andel arbetslösa:',
    round(deso_sf_pop$Andel_arbetslösa,1),'%' )
  
  maxandel <- max(deso_sf_pop$Andel_arbetslösa)
  
  map3 <- mapview(
    deso_sf_pop,
    zcol = "Andel_arbetslösa",
    legend = TRUE,
    layer.name = paste("Andel arbetslösa", unique(deso_sf_pop$år)),
    at =  seq(0,maxandel+round(maxandel/5),round(maxandel/5)),
    col.regions = viridis::cividis(11),
    popup = deso_sf_pop$popup,
    label =  deso_sf_pop$label,
    hide= T
  )
  
  map3@map <- map3@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  
  #  Layer med andel låg ekonomiskt standard
  popup_text <- deso_joined %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          'Andel med låg ekonomisk standard: ', round(Låg.ekonomisk.standard..procent,1), "%",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  
  deso_sf_pop <- deso_joined %>%
    left_join(popup_text, by = "desokod")
  
  
  deso_sf_pop$label <- paste(
    "DeSO: ", deso_sf_pop$desokod,  " | ",
    'Andel med låg ekonomisk standard:',
    round(deso_sf_pop$Låg.ekonomisk.standard..procent,1),'%' )
  
  maxandel <- max(deso_sf_pop$Låg.ekonomisk.standard..procent)
  
  map4 <- mapview(
    deso_sf_pop,
    zcol = "Låg.ekonomisk.standard..procent",
    legend = TRUE,
    layer.name = paste("Andel med låg ekonomiskt standard", unique(deso_sf_pop$år)),
    at =  seq(0,maxandel+round(maxandel/5),round(maxandel/5)),
    col.regions = viridis::cividis(11),
    popup = deso_sf_pop$popup,
    label =  deso_sf_pop$label,
    hide= T
  )
  
  map4@map <- map4@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  # Slår ihop alla kartor
  combined_map <- map + map2 + map3 + map4
  
  # fixar så endast första legenden syns direkt
  combined_map@map <- combined_map@map %>%
    htmlwidgets::onRender("
    function(el, x) {
      var legends = el.querySelectorAll('.info.legend'); // bara inom detta element
      legends.forEach((lg, i) => { if (i > 0) lg.style.display = 'none'; });
    }
  
  ")
  return(combined_map)
}


scatter_socioindex <- function() {
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_desocioindex.gpkg")
      deso_sf <- st_read("Data/df_desocioindex.gpkg", quiet = TRUE)
    })
  })
  
  # droppar geometry så det tar mindre plats
  deso_sf <- deso_sf %>% st_drop_geometry()
  # Gör socioindex till factor
  deso_sf$area_type <- factor(as.character(deso_sf$area_type),levels = c("1","2","3","4","5"))
  
  # Korrelationer, använder spearman så index troligtvis inte är normalfördelat
  cor_vals <- deso_sf %>%
    summarise(
      cor_andel = cor(Socioekonomiskt_index, Andel, use = "complete.obs", method ='spearman'),
      cor_arbetslos = cor(Socioekonomiskt_index, Andel_arbetslösa, use = "complete.obs", method ='spearman'),
      cor_lag_std = cor(Socioekonomiskt_index, Låg.ekonomisk.standard..procent, use = "complete.obs", method ='spearman')
    )
  
  # text för correlation
  cor_text <- paste0(
    "Korrelation:<br>",
    "Förgymnasial utbildning: ", round(cor_vals$cor_andel, 2), "<br>",
    "Arbetslösa: ", round(cor_vals$cor_arbetslos, 2), "<br>",
    "Låg ekonomisk standard: ", round(cor_vals$cor_lag_std, 2)
  )
  
  # Färgschema
  colormap <- c("1" = "#D57667",
                "2"="#EABAB3",
                "3"="#FFFFFF",
                "4"="#A4D0B8",
                "5"="#4AA271")
  
  # Skapar plot
  fig <- plot_ly(
    data = deso_sf,
    x = ~Socioekonomiskt_index,
    y = ~area_type,
    type = 'scatter',
    mode = 'markers',
    color = ~area_type,
    colors =  colormap,
    showlegend=FALSE,
    marker = list(
      size = ~14,
      
      opacity = 1,
      line = list(width = 0.5, color = 'black')
    ),
    text = ~desokod,
    hovertemplate = paste0(
      "<b>Area: </b> %{text}<br>",
      "<b>Socioekonomiskt index: </b> %{x}<br>",
      "<b>Områdestyp: </b> %{y}<br>"
    ),
    name = ''
  )
  
  # Layout
  fig <- fig %>% layout(
    title = list(
      text = "Fördelning av socioekonomiska förutsättningar i DeSO-områden",
      font = list(size = 20, color = "#B81867")
    ),
    font = list(family = "sourcesanspro", size = 16),
    xaxis = list(
      title = list(text = "Socioekonomiskt Index", font = list(size = 16)),
      zeroline = FALSE,
      linecolor = 'rgba(128,128,128,0.5)'
    ),
    yaxis = list(
      title = list(text = "Områdestyp", font = list(size = 16)),
      zeroline = FALSE,
      linecolor = 'rgba(128,128,128,0.5)'
    ),
    plot_bgcolor = 'rgba(0,0,0,0)',
    paper_bgcolor = 'rgba(0,0,0,0)',
    hovermode = 'closest',
    margin = list(l = 60, r = 60, t = 60, b = 60)
  )
  
  # Box med text
  fig <- fig %>% layout(
    annotations = list(list(
      x = 1, y = 1,           # koordinater i ploten
      xref = "paper", yref = "paper",
      text = cor_text,
      showarrow = FALSE,
      align = "left",
      bgcolor = "rgba(255,255,255,0.8)",
      bordercolor = "black",
      borderwidth = 1,
      list(
        text = "Källa: SCB, bearbetat av Region Uppsala",
        x = 0,          
        y = -0.15,      
        xref = "paper",
        yref = "paper",
        xanchor = "left",
        yanchor = "bottom",
        showarrow = FALSE,
        font = list(size = 12)
      )
    )
    ))
  
  # tar bort plotlyfunktioner
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
    displaylogo = FALSE)   # remove plotly logo/link
  
  fig
}


scatter_socioindex2 <- function() {
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_desocioindex.gpkg")
      deso_sf <- st_read("Data/df_desocioindex.gpkg", quiet = TRUE)
      
      st_layers("Data/df_deso_fodelse_index.gpkg")
      deso_sf2 <- st_read("Data/df_deso_fodelse_index.gpkg", quiet = TRUE)
    })
  })
  
  # Lägger in kommunnamn
  komnamn <- data.frame(kommunnamn=c("Knivsta", "Heby", "Tierp", "Uppsala", "Enköping", "Östhammar", "Håbo", "Älvkarleby"), 
                        kommunkod=c("0330", "0331", "0360", "0380", "0381", "0382", "0305", "0319"))
  
  deso_sf <- deso_sf %>% left_join(komnamn, by="kommunkod" )
  deso_sf2 <- deso_sf2 %>% left_join(komnamn, by="kommunkod" )
  
  koppling <- read_excel("Data/koppling-deso2025-regso2025.xlsx", skip=2) %>% select(Kommunnamn, DeSO_2025,RegSO_2025 ) %>% 
    rename(desokod=DeSO_2025)
  
  # droppar geometry så det tar mindre plats
  deso_sf <- deso_sf %>% st_drop_geometry()
  
  deso_sf2 <- deso_sf2 %>% st_drop_geometry() 
  
  deso_sf2 <- deso_sf2 %>% filter(!grepl("totalt", födelseregion, ignore.case = TRUE)) %>%
    group_by(desokod,födelseregion ) %>% summarise(Antal = sum(Antal), .groups = "drop")
  
  # Tar ut andelar födda utanför sverige
  andelar_deso <- deso_sf2 %>%
    group_by(desokod) %>%
    mutate(
      Total = sum(Antal, na.rm = TRUE),
      Andel = round(100 * Antal / Total, 1)
    ) %>%
    ungroup()
  
  # Andelar födda utanför sverige
  andel_utanf <- andelar_deso %>%
    filter(födelseregion != "Sverige") %>%
    group_by(desokod) %>%
    summarise(Andel_utanför = sum(Andel), .groups = "drop")
  
  # Slår ihop datan
  deso_sf <- left_join(deso_sf,andel_utanf, by='desokod') %>% 
    left_join(koppling, by='desokod')
  
  deso_sf$area_type <- factor(deso_sf$area_type, levels = 1:5)
  
  # Färgschema# Farea_type_description_sdärgschema
  colormap <- c("#D57667",
                "#EABAB3",
                "#FFFFFF",
                "#A4D0B8",
                "#4AA271")
  
  # Beräknar korrelationen
  corr_val <- cor(deso_sf$Socioekonomiskt_index, deso_sf$Andel_utanför, use = "complete.obs")
  corr_text <- paste0("Korrelation = ", round(corr_val, 2))
  
  # Tickvals för procent på y axeln: 
  tick_vals <- seq(0, 100, by = 10)
  tick_texts <- paste0(tick_vals, "%")
  
  # Hoverover
  deso_sf <- deso_sf %>% group_by(desokod) %>% 
    mutate(hoveroverinfo = paste0('<b>Regso: </b>',RegSO_2025,'<br>',
                                  '<b>DeSO: </b>',desokod,'<br>',
                                  '<b>Socioekonomiskt index: </b>',round(Socioekonomiskt_index,1),' <br>',
                                  '<b>Andel utrikesfödda: </b>',Andel_utanför,' %<br>',
                                  '<b>Andel med endast förgymnasial utbildning: </b>',Andel ,' %<br>',
                                  '<b>Andel arbetslösa: </b>', round(Andel_arbetslösa,1),' %<br>',
                                  '<b>Andel med låg ekonomisk standard: </b>',Låg.ekonomisk.standard..procent,' %'
                                  
    ))
  
  
  # Skapar plot
  fig <- plot_ly(
    data = deso_sf,
    x = ~Socioekonomiskt_index,
    y = ~Andel_utanför,
    type = 'scatter',
    mode = 'markers',
    color = ~area_type,
    colors =  colormap,
    showlegend=T,
    marker = list(
      size = ~12,
      
      opacity = 1,
      line = list(width = 0.5, color = 'black')
    ),
    text = ~hoveroverinfo,
    hoverinfo = 'text'
  )
  
  # Layout
  fig <- fig %>% layout(
    title = list(
      text = "<b>Samband mellan socioekonomiskt index och födelseregion på DeSO-nivå<b>",
      font = list(size = 20, color = "#B81867")
    ),
    xaxis = list(
      title = list(text = "<b>Socioekonomiskt Index<b>", font = list(size = 18, bold=T)),
      zeroline = FALSE,
      linecolor = 'rgba(128,128,128,0.5)'
    ),
    yaxis = list(
      title = list(text = "<b>Andel utrikesfödda<b>", font = list(size = 22, bold=T)),
      zeroline = FALSE,
      linecolor = 'rgba(128,128,128,0.5)',
      tickvals = tick_vals,
      ticktext = tick_texts,
      range = c(0, 100)
    ), # Textbox med korrelation 
    annotations = list(
      list(
        xref = "paper",
        yref = "paper",
        x = 0.02,  # nära vänstra kanten
        y = 0.98,  # nära toppen
        text = paste0("<b>", corr_text, "</b>"),
        showarrow = FALSE,
        font = list(size = 16, color = "black"),
        bgcolor = "rgba(255,255,255,0.8)",  # halvtransparent vit bakgrund
        bordercolor = "rgba(0,0,0,0.3)",
        borderwidth = 1,
        borderpad = 4
      ),
      list(
        xref = "paper",
        yref = "paper",
        x = 0,  # nära vänstra kanten
        y = -0.35,  # nära toppen
        text = paste0("Källa: SCB, bearbetat av Region Uppsala"),
        showarrow = FALSE,
        font = list(size = 12)
      )
    ),
    plot_bgcolor = 'rgba(0,0,0,0)',
    paper_bgcolor = 'rgba(0,0,0,0)',
    hovermode = 'closest',
    margin = list(l = 60, r = 60, t = 60, b = 10),
    legend = list(
      orientation = "h",      
      x = 0.5,                # mitten av grafen
      y = -0.35,               # under grafen
      xanchor = "center",
      yanchor = "top",
      xref = "paper",    # viktigt! position relativt plot paper
      yref = "paper",    # viktigt! position relativt plot paper
      font = list(size = 16)
    )
  )
  
  # tar bort plotlyfunktioner
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
    displaylogo = FALSE)   # remove plotly logo/link
  
  fig
}