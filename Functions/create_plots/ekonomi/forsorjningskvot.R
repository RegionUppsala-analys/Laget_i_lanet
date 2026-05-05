
f_kvot <- function(){
  # Läser in data
  df <- read.csv('Data/df_fkvot.csv')
  df$region[df$region == lan] <- 'Länet'
  
  # Gör region till faktor för snygg färgordning
  df <- df %>% mutate(region =factor(region, levels=c('Länet', sort(kommuner))))
  
  colors_lan <- c('Länet'='#B81867', kommun_colors)
  fig  <- plot_ly()
  
  # Lägg till en trace per region
  for (r in levels(df$region)) {
    df_sub <- df %>% filter(region == r)
    
    fig <- fig %>%
      add_trace(
        data = df_sub,
        x = ~år,
        y = ~Demografisk.försörjningskvot,
        type = 'scatter',
        mode = 'lines+markers',
        name = r,
        line = list(
          color = colors_lan[r],
          width = ifelse(r == 'Länet', 4, 2)
        ),
        marker = list(
          size = ifelse(r == 'Länet', 8, 5),
          color = colors_lan[r]
        )
      )
  }
  
  fig <- fig %>% layout( 
    margin = list(t = 100),
    hovermode = 'x unified',
    title=list(text='<b>Demografisk försörjningskvot<b>',
               font = list(size = 20, color = "#B81867")),
    yaxis=list(title="<b>Kvot <b>"),
    xaxis = list(title =''),
    annotations = list(list(
      text = "Källa: SCB",
      x = 0,          
      y = -0.12,      
      xref = "paper",
      yref = "paper",
      xanchor = "left",
      yanchor = "bottom",
      showarrow = FALSE,
      font = list(size = 12)
    )))
  
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


