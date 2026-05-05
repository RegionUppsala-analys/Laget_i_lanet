######### Demografi ############
## Befolkningsöknings plot i plotly 
##################### Befolkningsökning och pyramider #####################


befolkningsokning_plot <- function(){ 
  # Läser in data
  df_fram <- read.csv('Data/df_folkmangdfram.csv')
  
  minar <- min(df_fram$år) # sorterar bort senaste året plus att jag tar total av inrikes utrikes
  df_fram <- df_fram %>% filter(år > minar, år <= minar + 20, inrikes.utrikes.född == 'inrikes och utrikes födda') 
  
  # Summerar för att få data för länet
  regionfram <- df_fram %>% group_by(år) %>% 
    summarise(Total = sum(Antal), .groups = 'drop')
  
  # Faktisk folkmängd
  df <- read.csv('Data/df_folkmangd.csv')
  df <- df %>% filter(år > 2001)                 # Väljer 2002 som basår
  
  region <- df %>% group_by(år) %>% 
    summarise(Total = sum(Folkmängd), .groups = 'drop') # Summerar per år
  
  # Maxår för prognosstart
  regionmax <- max(region$år)
  # Region, total folkmängd per kön 1986 - 2070
  region <- rbind(region, regionfram)
  
  # Dummy-variabel för att se vilka som är framskrivning eller ej
  region$framskrivning <- ifelse(region$år > regionmax, 1, 0)
  region$region <- "Länet"
  
  #  Summerar för varje kommun, faktiskt och framskrivning
  df_kommunfram <- df_fram %>% group_by(region, år) %>% 
    summarise(Total = sum(Antal), .groups = 'drop')
  
  df_kommun <- df %>% group_by(region, år) %>% 
    summarise(Total = sum(Folkmängd), .groups = 'drop')
  
  # Slårihop dataseten
  kommun <- rbind(df_kommunfram, df_kommun)
  
  # Dummt för prognos
  kommun$framskrivning <- ifelse(kommun$år > regionmax, 1, 0)
  
  # Kombinera Region + Kommun
  df_plot <- rbind(
    region %>% select(år, Total, framskrivning, region),
    kommun %>% select(år, Total, framskrivning, region)
  )
  
  # Avrundar allt uppåt
  df_plot$Total <- ceiling(df_plot$Total)
  
  # Sortera kommuner alfabetiskt, Region först 
  alfabetiska_kommuner <- sort(kommuner)
  unika_regioner <- c("Länet", alfabetiska_kommuner)
  
  colors_with_lanet <- c('Länet' ='#B81867',kommun_colors)
  
  fig <- plot_ly()
  
  # Dummy för bakgrund
  forecast_years <- df_plot %>% 
    filter(framskrivning == 1) %>% 
    pull(år) %>% 
    unique() %>% 
    sort()
  
  prognosar <- min(forecast_years)  # start of forecast
  
  # Linje per region
  for(r in unika_regioner ){
    # filtrerar och sorterar
    df_temp <- df_plot %>% filter(region == r)
    df_temp <- df_temp[order(df_temp$år), ]
    
    # Skapar linjerna
    fig <- fig %>%
      add_trace(
        x = df_temp$år,
        y = df_temp$Total,
        type = 'scatter',               
        mode = 'lines+markers',         
        name = r,
        line = list(color = colors_with_lanet[r],
                    width = ifelse(r == 'Länet', 3, 2)),
        marker = list(color = colors_with_lanet[r],
                      size = ifelse(r == 'Länet', 6, 4)),
        hovertemplate = paste0("%{y:,}"),
        showlegend = TRUE
      )
  }
  
  # Annotering för prognos
  annotation <- list(
    text = "Prognosstart",
    x = prognosar, 
    y = 1.01,            # position på y axeln för text
    xref = 'x',
    yref = 'paper',
    showarrow = TRUE,
    arrowhead = 2,
    arrowcolor = "#6F787E",
    arrowwidth = 2,
    ax = 0,
    ay = -30,
    font = list(color = "#6F787E", size = 16),
    bgcolor = "rgba(255,255,255,0.8)"
  )
  
  # Linje för prognos
  vline <- list(
    type = "line",
    x0 = prognosar, # Plats på x axeln
    x1 = prognosar,
    y0 = 0, # Plats på y-axeln
    y1 = 1,
    xref = "x",
    yref = "paper",
    line = list(
      color = "#6F787E",
      width = 2,
      dash = "dash"
    )
  )
  
  # Layout
  fig <- fig %>% layout(
    margin = list(t = 100, r = 100,b=50), 
    title = list(
      text = "<b>Folkmängd över tid och prognos av de kommande 20 åren<b>",
      font = list(size = 20, color = "#B81867"),
      x = 0.5,
      y = 1.3
    ),
    
    xaxis = list(title = ""),
    yaxis = list(title = "<b>Folkmängd<b>", autorange = TRUE,
                 font = list(size = 16)),
    annotations = list(annotation,
                       list(
                         text = "Källa: SCB",
                         x = 0,
                         y = -0.12,
                         xref = "paper",
                         yref = "paper",
                         showarrow = FALSE,
                         xanchor = "left",
                         yanchor = "auto")
    ),
    shapes = list(vline),   # <-  dashed line
    
    legend = list(
      x = 1.02,
      y = 1,
      xanchor = "left",
      yanchor = "top"
    ),
    
    hovermode = 'x unified', # visa data för alla samtidigt vid hover
    uirevision = TRUE 
  )
  
  # Tar bort vissa knappar
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
  
  return(fig)
}
