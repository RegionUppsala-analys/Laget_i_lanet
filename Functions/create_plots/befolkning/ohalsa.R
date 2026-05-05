ohalsotal <- function(){
  # Läser in data
  df <- read.csv('Data/df_ohalso.csv')
  
  # Tar bort "samtliga", och tar senaste året
  df <- df %>% filter(bakgrundsvariabel != 'samtliga', år == max(år))%>%
    rename(antal_dagar = Ohälsotalet..antal.dagar) %>% 
    mutate(bakgrundsvariabel = tools::toTitleCase(bakgrundsvariabel) )
  
  # plockar ut år för titeln
  ar <- unique(df$år)
  
  # medel för riket
  avg_df <- df %>%
    group_by(kön, bakgrundsvariabel) %>%
    summarise(antal_dagar = round(mean(antal_dagar),1), .groups = "drop") %>%
    mutate(region = "Riket")
  
  # Extract Uppsala län
  uppsala_df <- df %>%
    filter(region == lan) %>% 
    mutate(region = ifelse(region == lan, "Länet", region))
  
  color_map <- c(
    "Män – Länet" = "#4AA271",
    "Män – Riket" = "#DBECE3",
    "Kvinnor – Länet" = "#D57667",
    "Kvinnor – Riket" = "#F7E4E1"
  )
  # Combine
  plot_df <- bind_rows(uppsala_df, avg_df)
  
  # Ny kolumn för legendnamnen
  plot_df <- plot_df %>%
    mutate(legend_group = paste0(tools::toTitleCase(kön), " – ", region))
  
  # Function för att göra en plot per kön
  make_plot <- function(data, gender) {
    
    gender_data <- data %>% filter(kön == gender) # filter kön
    
    # custom hoverover text
    hover_text <- paste0(
      gender_data$region,':',
      gender_data$antal_dagar
    )
    # lägger in trace
    plot_ly(
      gender_data,
      x = ~bakgrundsvariabel,
      y = ~antal_dagar,
      color = ~legend_group,
      colors = color_map,
      type = "bar",
      text = hover_text,
      hoverinfo = "text"
    ) %>%
      layout(
        barmode = "group",
        title = gender,
        xaxis = list(title = ""),
        yaxis = list(title = "<b>Antal dagar<b>")
      )
  }
  
  # En subplot för män och en för kvinnor
  fig <- subplot(
    make_plot(plot_df, "män"),
    make_plot(plot_df, "kvinnor"),
    nrows = 1, # sida vid sida
    shareY = TRUE, # samma skala på y
    titleX = TRUE,
    titleY = TRUE
  ) %>%
    layout(margin = list(t = 40), 
           hovermode = 'x unified',
           title = list(text=paste("<b>Ohälsotal (antal dagar) –", lan,"vs Riksgenomsnitt år",ar,'<b>'),
                        font = list(size = 20, color = "#B81867")),
           annotations = list(list(
             text = "Källa: SCB",
             x = 0,          
             y = -0.25,      
             xref = "paper",
             yref = "paper",
             xanchor = "left",
             yanchor = "bottom",
             showarrow = FALSE,
             font = list(size = 12)
           )))
  
  # tar bort plotly-funktioner
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


Andel_ohalso <- function(){
  # Läser in data
  df <- read.csv('Data/df_ohalso.csv')
  
  # tar bort "samtliga"
  df <- df %>% filter(bakgrundsvariabel != 'samtliga', år > 2004)%>%
    rename(Andel =Andel.som.bidrar.till.ohälsotalet...procent) %>% 
    mutate(bakgrundsvariabel = tools::toTitleCase(bakgrundsvariabel), 
           kön = tools::toTitleCase(kön))
  
  # medel för riket
  # Extract Uppsala län
  uppsala_df <- df %>%
    filter(region == lan)
  
  # Färgschema
  color_map <- c("Sverige"="#F9B000",
                 "Norden Exkl. Sverige" = "#4AA271",
                 "EU/EFTA Exkl. Norden" = "#D57667",
                 "Övriga Världen" = "#019CD7"
  )
  
  # Tar bort födelseregion från texten
  uppsala_df$bakgrundsvariabel <- str_remove(uppsala_df$bakgrundsvariabel,'Födelseregion: ')
  
  #  Skapar traces, en för män och en för kvinnor
  fig <- plot_ly() %>%
    add_trace(
      x = c(), y = c(), 
      type = "scatter", mode = "lines",
      xaxis = "x", yaxis = "y"
    ) %>%
    add_trace(
      x = c(), y = c(),
      type = "scatter", mode = "lines", 
      xaxis = "x", yaxis = "y2"
    )
  
  # Loop över födelseregioner
  for (u in unique(uppsala_df$bakgrundsvariabel)){
    
    # Trace för män
    temp_man <- uppsala_df %>% filter(bakgrundsvariabel == u, kön == "Män")
    
    if(nrow(temp_man) > 0) {
      fig <- fig %>% add_trace(
        data = temp_man,
        x = ~år,
        y = ~Andel,
        name = u,
        type = "scatter",
        mode = "lines+markers",
        marker = list(color = color_map[u], size =8),
        line = list(color = color_map[u], width =5),
        legendgroup = u,
        yaxis = "y" # Y-axeln män utgår ifrån
      )
      
    }
    
    # Trace för kvinnor
    temp_kvinna <- uppsala_df %>% filter(bakgrundsvariabel == u, kön == "Kvinnor")
    
    if(nrow(temp_kvinna) > 0) {
      fig <- fig %>% add_trace(
        data = temp_kvinna,
        x = ~år,
        y = ~Andel,
        name = u,
        type = "scatter",
        mode = "lines+markers",
        marker = list(color = color_map[u], size =8),
        line = list(color = color_map[u], width =5),
        legendgroup = u,
        showlegend = FALSE,
        yaxis = "y2" # Y-axeln kvinnor utgår ifrån
      )
      
      
    }
  }
  
  
  fig <- fig %>% # Lägger till layout
    layout( 
      margin = list(t=100,b=50),
      hovermode = 'x unified',
      barmode = "group",
      title = list(text=paste("<b>Andel som bidrar till ohälsotalet - ",lan,"<b>"),
                   font = list(size = 20, color = "#B81867")),
      # Top subplot (Män)
      xaxis = list(
        title = "",
        domain = c(0, 1),
        anchor = "y" # namn som las in på trace tidigare
      ),
      yaxis = list(
        title = "<b>Andel (%)<b>", 
        domain = c(0.55, 1),
        anchor = "x",
        range = c(0, 40) 
      ),
      # Bottom subplot (Kvinnor)
      xaxis2 = list(
        title = "År",
        domain = c(0, 1),
        anchor = "y2" # namn som las in på trace tidigare
      ),
      yaxis2 = list(
        title = "<b>Andel (%)<b>", 
        domain = c(0, 0.45),
        anchor = "x2",
        range = c(0, 40)
      ) ,
      # Titlar för subplots
      annotations = list(
        list(
          x = 0.5, y = 1.04, 
          text = "<b>Män</b>", 
          showarrow = FALSE, 
          xref = "paper", yref = "paper",
          font = list(size = 14)
        ),
        list(
          x = 0.5, y = 0.48, 
          text = "<b>Kvinnor</b>", 
          showarrow = FALSE, 
          xref = "paper", yref = "paper",
          font = list(size = 14)
        ),
        list(
          text = "Källa: SCB",
          x = -0.05,          
          y = -0.1,      
          xref = "paper",
          yref = "paper",
          xanchor = "left",
          yanchor = "bottom",
          showarrow = FALSE,
          font = list(size = 12)
        )
      ),
      # Placering/layout av legenden 
      legend = list(
        orientation = "h",   
        x = 0.5,             
        y = -0.05,           
        xanchor = "center",
        yanchor = "top"
      ),
      margin = list(b = 40, t=50) # extra bottom space
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
    displaylogo = FALSE)   # remove plotly logo/link
  
  fig
}


