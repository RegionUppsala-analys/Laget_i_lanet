medel_loner <- function(){
  # Läser in data och filtrerar
  df <- read.csv('Data/df_genom_lon.csv')
  df <- df %>% filter(yrkesgrupper..SSYK.2012. == 'Samtliga yrken') %>% 
    mutate(region = factor(region, levels = unique(region)))
  
  # Beräkna mittpunkt mellan män & kvinnor för textplacering
  df_labels <- df %>%
    tidyr::pivot_wider(
      id_cols = region,
      names_from = kön,
      values_from = c(Månadslön, Kvinnors.lön.i.procent.av.mäns.lön)
    ) %>%
    mutate(
      x_mid = (Månadslön_män + Månadslön_kvinnor) / 2,
      label = paste0(100 - Kvinnors.lön.i.procent.av.mäns.lön_kvinnor, "%")
    )
  
  fig <- plot_ly()
  
  # Män
  fig <- fig %>%
    add_trace(
      data = df %>% filter(kön == "män"),
      x = ~Månadslön,
      y = ~region,
      type = "scatter",
      mode = "markers",
      name = "Män",
      marker = list(color = "#4AA271", size = 12),
      hovertemplate = ~paste(
        "Region:", region,
        "<br>Kön: Män",
        "<br>Månadslön:", Månadslön, " SEK",
        "<br>Kvinnors lön i % av mäns:", Kvinnors.lön.i.procent.av.mäns.lön, "%"
      )
    )
  
  # Kvinnor
  fig <- fig %>%
    add_trace(
      data = df %>% filter(kön == "kvinnor"),
      x = ~Månadslön,
      y = ~region,
      type = "scatter",
      mode = "markers",
      name = "Kvinnor",
      marker = list(color = "#D57667", size = 12),
      hovertemplate = ~paste(
        "Region:", region,
        "<br>Kön: Kvinnor",
        "<br>Månadslön:", Månadslön, " SEK",
        "<br>Kvinnors lön i % av mäns:", Kvinnors.lön.i.procent.av.mäns.lön, "%"
      )
    )
  
  # Text i mitten
  fig <- fig %>%
    add_trace(
      data = df_labels,
      x = ~x_mid,
      y = ~region,
      type = "scatter",
      mode = "text",
      text = ~label,
      textposition = "middle", # kan bytas till "top center" el. liknande
      showlegend = FALSE
    )
  
  # Layout
  fig <- fig %>%
    layout(margin = list(t = 40, b=100),font = list(family = "sourcesanspro", size =16 ),
           title = list(text=paste("<b>Könsskillnader i Månadslön per region år", unique(df$år),'<b>'),
                        font = list(size = 20, color = "#B81867")),
           xaxis = list(title = "<b>Månadslön (SEK)<b>"),
           yaxis = list(title = ""),
           legend = list(title = list(text = ""),
                         itemclick = FALSE,
                         itemdoubleclick = FALSE),
           annotations = list(list(
             text = "Källa: SCB",
             x = 0,          
             y = -0.17,      
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
