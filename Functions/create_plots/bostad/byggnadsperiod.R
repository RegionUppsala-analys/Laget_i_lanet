####### Byggnadsperiod #########

# region
byggnadsperiod_region <- function(){
  # Läser in data
  df_byggnadsperiod <- read.csv('Data/df_byggnadsperiod.csv')
  
  # år som heltal och summerar antalet per period och typ
  df_byggnadsperiod$år <- as.integer(df_byggnadsperiod$år)
  df_byggnadsperiod_plot <- df_byggnadsperiod%>%filter(byggnadsperiod != 'uppgift saknas', år== max(as.numeric(år))) %>%  
    group_by(hustyp, byggnadsperiod) %>% 
    summarise(Total = sum(Antal),.groups = "drop")
  
  # Gör om titlarna 
  df_byggnadsperiod_plot <- df_byggnadsperiod_plot %>%
    mutate(hustyp_label = tools::toTitleCase(hustyp))
  
  # Egna färger för hustyp
  my_colors <- c(
    "Småhus" = "#019CD7",
    "Flerbostadshus" = "#D57667",
    "Övriga Hus" = "#6F787E"
  )
  
  # skapar plot
  fig <- plot_ly(
    data = df_byggnadsperiod_plot,
    x = ~byggnadsperiod,
    y = ~Total,
    color = ~hustyp_label,
    colors = my_colors,
    type = "bar"
  ) %>%
    layout(margin = list(t = 100),
           barmode = "group",   # staplar bredvid varandra (alt. "stack")
           title =list(
             text = "<b>Byggnadsperioder per hustyp år 2024<b>",
             font=list(size=20, color = "#B81867")),
           xaxis = list(title = "<b>Byggnadsperiod<b>", titlefont=list(size=16)),
           yaxis = list(title = "<b>Antal<b>",  titlefont=list(size=16)),
           annotations  = list(x=0,
                               y=-0.2,
                               text = 'Källa: SCB', 
                               showarrow = F, 
                               xref='paper', 
                               yref='paper')
    )
  
  # Tar bort knappar från plotly 
  fig <- plotly::config(
    fig,
    modeBarButtonsToRemove = c(
      'zoom2d',     # zoom button
      'pan2d',      # pan button
      'select2d',   # box select
      'lasso2d',    # lasso select
      'zoomIn2d',   # zoom in
      'zoomOut2d'   # zoom out
    ),toImageButtonOptions = list(
      format = "svg",
      filename = "byggnadsperiod_region"),
    displaylogo = FALSE)   # remove plotly logo/link
  
  fig
}

# kommun
byggnadsperiod_kommun <- function(){
  # Läser in data
  df_byggnadsperiod <- read.csv('Data/df_byggnadsperiod.csv')
  
  # år till heltal
  df_byggnadsperiod$år <- as.integer(df_byggnadsperiod$år)
  
  # Summerar per kommun, period och typ
  df_byggnadsperiod_plot <- df_byggnadsperiod%>%filter(byggnadsperiod != 'uppgift saknas', år== max(as.numeric(år))) %>%  
    group_by(hustyp, byggnadsperiod, region) %>% 
    summarise(Total = sum(Antal),.groups = "drop")%>%
    mutate(hustyp_label = tools::toTitleCase(hustyp),
           hustyp_label = factor(hustyp_label, levels = c("Flerbostadshus","Småhus","Övriga Hus")))
  
  
  
  # Egna färger för hustyp
  my_colors <- c(
    "Småhus" = "#019CD7",
    "Flerbostadshus" = "#D57667",
    "Övriga Hus" = "#6F787E"
  )
  
  kommuner <- unique(df_byggnadsperiod_plot$region)
  
  # Lista som håller spårindex per kommun
  spår_per_kommun <- list()
  idx <- 1
  
  fig <- plot_ly()
  ar_max <- max(as.integer(df_byggnadsperiod$år))
  
  # loopar över alla kommuner
  for (k in kommuner) {
    # Filtrerar kommunen
    filtered <- df_byggnadsperiod_plot %>% filter(region == k)
    # antal spår som kommer fyllas
    n_spår <- n_distinct(filtered$hustyp_label)
    
    # Lägger in bars
    fig <- fig %>%
      add_bars(
        data = filtered,
        x = ~byggnadsperiod,
        y = ~Total,
        color = ~hustyp_label,
        colors = my_colors,
        visible = ifelse(k == kommuner[1], TRUE, FALSE) # Första regionen som visas från början
      )
    # Fyller listan med med antal spår per kommun
    spår_per_kommun[[k]] <- idx:(idx + n_spår - 1)
    idx <- idx + n_spår 
  }
  
  # Layout på plotten med titlar och dropdown
  fig <- fig %>%
    layout(
      margin = list(t = 100),
      title =list(
        text = "<b>Byggnadsperioder per hustyp år 2024<b>",
        font=list(size=20, color = "#B81867")),
      xaxis = list(title = "<b>Byggnadsperiod<b>" ,titlefont=list(size=16)),
      yaxis = list(title = "<b>Antal<b>",titlefont=list(size=16)),
      barmode = "group",
      legend = list(title = list(text = "Hustyp")),
      
      # Dropdown
      updatemenus = list(
        list(
          buttons = lapply(kommuner, function(k) { # loopar över alla kommuner
            vis <- rep(FALSE, length(unlist(spår_per_kommun)))
            vis[spår_per_kommun[[k]]] <- TRUE # Fyller i med true på rätt plats()
            list(
              method = "update", 
              args = list(list(visible = vis)),
              label = k
            )
          }),
          direction = "down", # Plats på dropdownen
          x = -0.1, y = 1,
          pad = list(r = 10, t = 10),
          showactive = TRUE
        )
      ),
      
      # Label till dropdown
      annotations = list(
        list(
          text = "Kommun",
          x = -0.2, y = 1.032,
          xref = "paper", yref = "paper",
          xanchor = "right", yanchor = "top",
          showarrow = FALSE,
          font = list(size = 16)
        ),
        list(
          text = "Källa: SCB",
          x = 0,
          y = -0.2,
          xref = "paper",
          yref = "paper",
          xanchor = "left",
          yanchor = "auto",
          showarrow = FALSE,
          font = list(size = 12)
        )
      )
    )
  
  # Tar bort knappar från plotly
  fig <- plotly::config(
    fig,
    modeBarButtonsToRemove = c(
      'zoom2d',     # zoom button
      'pan2d',      # pan button
      'select2d',   # box select
      'lasso2d',    # lasso select
      'zoomIn2d',   # zoom in
      'zoomOut2d'   # zoom out
    ),toImageButtonOptions = list(
      format = "svg",
      filename = "byggnadsperiod_kommun"),
    displaylogo = FALSE)   # remove plotly logo/link
  
  
  fig
  
}
