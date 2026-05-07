############ Föroreningar ##########
############# Kalmarksareal #########

kalmark <- function(){
  
  # Läser in data och ta bort siffror från länsnamn
  df <- read.csv("Data/df_kalmarksareal.csv") %>% 
    mutate(value = X8a..Medel..median.och.95.e.percentilen.i.hektar.för.sammanhängande.kalmarksareal)
  df$Region <- str_remove_all(df$Region, "[0-9]+ ")
  
  # Spara bara percentil på median för uppsala, plotta alla linjer som grå förutom uppsala i ploly så att man kan markera och se vilken 
  # linje som är vilken
  
  # Tar ut uppsala
  df_uppsala <- df %>% filter(Region == "Uppsala län",Variabel  == 'Median')
  df_median <-   df %>% filter(Region != "Uppsala län", Variabel  == 'Median')
  
  
  
  # Skapar plot
  fig <- plot_ly()
  
  #  Lägg till alla län (grå linjer)
  for (region in unique(df_median$Region)) {
    
    temp <- df_median %>% filter(Region == region)
    
    fig <- fig %>%
      add_trace(
        data = temp,
        x = ~År,
        y = ~value,
        type = "scatter",
        mode = "lines",
        line = list(color = "#6F787E", width = 1.2),
        name = region,
        hoverinfo = "text",
        text = I(paste(temp$Region, "<br>År:",temp$År, "<br>Median:", round(temp$value, 1))),
        showlegend = FALSE
      )
  }
  
  # Lägg till Uppsala median
  fig <- fig %>%
    add_trace(
      data = df_uppsala ,
      x = ~År,
      y = ~value,
      type = "scatter",
      mode = "lines+markers",
      line = list(color = "#B81867", width = 5),
      marker = list(color = "#B81867", size = 8),
      hoverinfo = "text",
      text = I(paste(df_uppsala$Region,"<br>År:",temp$År, "<br>Median:", round(df_uppsala$value, 1)))
    )
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 50),
      title = list(text = paste("<b>Medianen för sammanhängande kalmarksareal<b>"), y = 0.95, x = 0.55,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = "", tickangle = -45,
                   tickmode = "linear",         
                   dtick = 2),
      yaxis = list(title = "<b>Hektar<b>", 
                   rangemode = "tozero"),
      annotations = list(
        text ='Källa: Skogsstyrelsen',
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

############# Produktiv skogsmarksareal #########

prod_skog <- function(){
  
  # Läser in data och tar bort siffrar från kommun-namn
  df <- read.csv('Data/df_prod_skog.csv') %>% rename('Value' = X12..Deklarerad.produktiv.skogsmarksareal..1.000.ha...medelinnehav.och.medianinnehav.i.hektar.per.brukningsenhet..antal.brukningsenheter.och.ägare)
  
  df <- df %>%
    mutate(
      Kommun = factor(str_to_sentence(str_remove_all(Kommun, "[0-9]+ ")),
                      levels = sort(unique(str_to_sentence(str_remove_all(Kommun, "[0-9]+ "))))
      )
    )
  
  # Ordnar data
  df <- df %>% mutate(År = factor(År, levels = unique(År)))
  
  # variabler till plott  
  titles <- unique(df$Variabel)
  
  n_region <- length(unique(df$Kommun))
  
  # Bygg plotly-objekt
  fig <- plot_ly()
  
  # loop över alla variabler och kommuner
  for (title in titles) {
    df_title <- df %>% filter(Variabel == !!title)
    
    for (region in levels(df_title$Kommun)) {
      # Filtrerar ut data och lägger in trace
      df_region <- df_title %>% filter(Kommun == region)
      
      fig <- fig %>%
        add_trace(
          x = df_region$År,
          y = df_region$Value,
          type = "scatter",
          mode = "lines+markers",
          name = region,
          line = list(color = kommun_colors[region],width = 5),
          marker = list(color = kommun_colors[region],size = 8),
          visible = ifelse(title == titles[1], TRUE, FALSE)
        )
    }
  }
  
  # Skapa dropdown-knappar
  buttons <- lapply(seq_along(titles), function(i) {
    visible_vec <- rep(FALSE, length(titles)*n_region)
    visible_vec[((i-1)*n_region + 1):(i*n_region)] <- TRUE
    
    list(
      method = "update",
      args = list(
        list(visible = visible_vec),
        list(
          title = paste("<b>",titles[i],"<b>"),
          yaxis = list(
            title = paste("<b>",ifelse(titles[i] %in% c("Medelbrukningsenhet", "Medianbrukningsenhet"),
                                       "Hektar per brukningsenhet",titles[i] ),"<b>"),
            rangemode =  "tozero"
          )
        )
      ),
      label = titles[i]
    )
  })
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 50),
      title = list(text = paste("<b>",titles[1],"<b>"), y = 0.95, x = 0.55,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = "", tickangle = -45,
                   dtick = 2),
      yaxis = list(title = paste("<b>",titles[1],"<b>"), 
                   rangemode = "tozero"),
      hovermode = 'x unified',
      updatemenus = list(
        list(
          y = -0.1,
          x=1.1,
          buttons = buttons,
          direction = "up"
        )),
      annotations = list(
        text ='Källa: Skogsstyrelsen',
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
  
  return(fig)
  
}
