####### Hyresutveckling #########

hyres_utveck <- function(){
  # Läser in data
  df_hyra <- read.csv('Data/df_hyra.csv')
  
  # Sista året i datat
  ar_max <- max(df_hyra$år)
  
  # Byter namn, år till heltal, och ordnar, tar bort NAs
  df_hyra_clean <- df_hyra %>%
    mutate(
      år = as.integer(år),
      medianhyra = Medianhyra.i.hyreslägenhet
    ) %>%
    filter(!is.na(medianhyra), !is.na(år)) %>%
    arrange(region, år)
  
  df_hyra_clean$region <- ifelse(df_hyra_clean$region == 'Uppsala län',
                                 "Länet",df_hyra_clean$region )
  
  
  lan_col <- c('Länet'="#B81867",kommun_colors)
  # Skapa plotly-figuren
  fig <- plot_ly()
  
  # Lägg till en linje för varje kommun
  for(kommun in unique(df_hyra_clean$region)) {
    # filtrerar ut kommun
    kommun_data <- df_hyra_clean %>% filter(region == kommun)
    
    # skapa linje
    fig <- fig %>%
      add_trace(
        data = kommun_data,
        x = ~år,
        y = ~medianhyra,
        type = 'scatter',
        mode = 'lines+markers',
        name = kommun,
        line = list(
          color = lan_col[[kommun]], 
          width = ifelse(kommun== 'Länet',5,3)
        ),
        marker = list(
          color = lan_col[[kommun]],
          size = ifelse(kommun== 'Länet',7,6)
        )
      )
    
  }
  
  # Konfigurera layout
  fig <- fig %>%
    layout(
      title = list(
        text = paste("<b>Medianhyresutveckling per kommun, 2016 -", ar_max,"<b>"),
        font = list(size = 20, color = "#B81867")
      ),
      xaxis = list(
        title = " ",
        tickfont = list(size = 14),
        gridcolor = 'rgba(211,211,211,0.5)',
        showgrid = TRUE
      ),
      yaxis = list(
        title = "<b>Medianhyra (kr/kvm/månad)<b>",
        titlefont = list(size = 16, family = "Arial"),
        tickfont = list(size = 14),
        gridcolor = 'rgba(211,211,211,0.5)',
        showgrid = TRUE
      ),
      legend = list(
        orientation = "v",
        x = 1.05,
        y = 1,
        font = list(size = 12)
      ),
      hovermode = "x unified", # Så att man ser alla kommuners data vid hoverover
      plot_bgcolor = 'white',
      paper_bgcolor = 'white',
      margin = list(l = 60, r = 150, t = 80, b = 60)
    )
  
  # En mer interaktiv version där du kan klicka på legenden för att highlighta en specifik kommun
  fig <- fig %>%
    layout(
      legend = list(
        orientation = "v",
        x = 1.05,
        y = 1,
        font = list(size = 12)
      ),
      annotations  = list(x=0,
                          y=-0.15,
                          text = 'Källa: SCB', 
                          showarrow = F, 
                          xref='paper', 
                          yref='paper')
    )
  
  # Tar bort plotlyknappar
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
      filename = "hyres_utveckling"),
    displaylogo = FALSE)   # remove plotly logo/link
  
  # Visa den interaktiva versionen
  fig
}

