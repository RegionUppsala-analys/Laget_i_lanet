######### Framtida elbehov #########

future_elbehov <- function(){
  # Läser in data
  df <- read_excel("Data/framtida_elbehov.xlsx", sheet = 2, skip=1)
  
  # Tar bort kolumner som ej ska användas 
  
  df <- df[,c(1:6)]
  
  # Ger dem nya namn
  colnames(df) <- c("Scenario", "Sektor 1", "Sektor 2", "År", "Län", "Elbehov")
  
  # tar ut länet
  df <- df %>% filter(Län %in% lan)
  
  # summerar per sektor 1
  df <- df %>% group_by(Scenario,År,`Sektor 1`) %>% 
    summarize(Behov = sum(Elbehov), .groups='drop')
  
  cols <- c("Bostäder"="#4AA271" ,
            "Datacenter" = "#8B4A9C",
            "Industri" = "#019CD7",
            "Inrikes transporter" = "#D0342C",
            "Service" = "#F9B000" )
  
  
  # variabel för y
  maxim <-  df %>% group_by(Scenario,År) %>% 
    summarise(maximum = sum(Behov), .groups = 'drop')
  
  maxim <- max(maxim$maximum)
  
  # Skapar en plot per scenario
  for(s in unique(df$Scenario)){
    temp = df %>% filter(Scenario == s)
    
    p <- ggplot(temp, aes(x=År, y = Behov, fill=`Sektor 1`)) + geom_col() + 
      labs(x="", y = "Elbehov (GWh)", 
           fill = "",
           title= paste("Elbehovet per sektor för", s),
           caption = 'Källa: Energimyndigheten')+
      scale_fill_manual(values = cols)+
      scale_x_continuous(
        breaks = seq(min(temp$År), max(temp$År), by = 5)
      )+
      ylim(0, maxim+500)+ 
      theme_get() +
      theme(
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.caption.position = "plot", 
        legend.direction = "horizontal",
        plot.caption = element_text(hjust = 0))
    
    p
    # Save as SVG
    filename <- paste0("Figurer/framtid_behov_", s, ".svg")
    ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
    
    # png
    filename <- paste0("Figurer/framtid_behov_", s, ".png")
    ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
    
  }
}

future_elbehov_sektor <- function(){
  
  # Läser in data
  df <- read_excel("Data/framtida_elbehov.xlsx", sheet = 2, skip=1)
  
  # Tar bort kolumner som ej ska användas 
  
  df <- df[,c(1:6)]
  
  # Ger dem nya namn
  colnames(df) <- c("Scenario", "Sektor 1", "Sektor 2", "År", "Län", "Elbehov")
  
  # tar ut länet
  df <- df %>% filter(Län %in% lan)
  
  
  cols <- c("Beslutad Policy"="#4AA271" ,
            "Internationell Tillväxt" = "#019CD7",
            "Lokal Miljöhänsyn" = "#F9B000" )
  
  
  
  # Skapar plot -> loopar över sektorerna 
  
  fig <- plot_ly()
  
  sektorer <- sort(unique(df$`Sektor 2`))
  Scenarios <- sort(unique(df$Scenario))
  
  for(s in sektorer){
    tmp <- df %>% filter(`Sektor 2`== s)
    
    for (ss in Scenarios) { 
      temp <- tmp %>% filter(Scenario == ss)
      
      
      fig <- fig %>%
        add_trace(
          x = temp$År,
          y = temp$Elbehov,
          type = "scatter",
          mode = "lines+markers",
          name = ss,
          line = list(color = cols[ss],width = 5),
          marker = list(color = cols[ss],size = 8),
          visible = ifelse(s == sektorer[1], TRUE, FALSE)
        )
    }
  }
  
  # Skapa dropdown-knappar
  buttons <- lapply(seq_along(sektorer), function(i) {
    visible_vec <- rep(FALSE, length(Scenarios)*length(sektorer)) # Antal frågor * antal platser
    visible_vec[((i-1)*length(Scenarios) + 1):(i*length(Scenarios))] <- TRUE # Index på rätt plats för att rätt linje ska synas
    
    list(
      method = "update",
      args = list(
        list(visible = visible_vec),
        list(title = paste('<b>Elbehov (GWh) efter år och scenario</b>')) # Ny titel 
      ),
      label = sektorer[i]
    )
  })
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 80,b=50),
      title = list(text = paste('<b>Elbehov (GWh) efter år och scenario</b>'), y = 0.99, x = 0.5,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = " ", tickangle = 0),
      yaxis = list(title = paste("<b>Summerat elbehov</b>"), 
                   rangemode = "tozero"),
      hovermode = 'x unified',
      updatemenus = list(
        list(
          y = 1.07,
          x= 0.3,
          buttons = buttons,
          direction = "down"
        )),
      annotations = list(
        text ='Källa: Energimyndigheten',
        x = 0,            
        y = -0.08,        
        xref = "paper",
        yref = "paper",
        xanchor = "left",
        yanchor = "bottom",
        showarrow = FALSE,
        font = list(size = 12)
      )
    )
  
  
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



