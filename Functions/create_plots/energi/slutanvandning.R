
########## Energianvändning Kolada #####################

Slutanvandning_el_fjarr <- function(){
  # läser in data
  df <- read.csv('Data/df_energianvandning.csv')
  
  # Loop över alla kommuner
  i <- 0
  
  df$title <- sub("\\,\\s*MWh/inv$", "", df$title) # tar bor MWH/inv från titeln
  
  for (var in unique(df$title)) {
    i <- i + 1
    # Filtrerar bort kategorier som endast har na eller 0 för kommunen
    df_region <- df %>% 
      filter(title == var) 
    
    # Skapar plot
    p <-  ggplot(df_region, aes(x = year, y = value, color = municipality)) +
      geom_line(linewidth = 1.5,na.rm = TRUE) + geom_point(size = 2)+
      labs(
        title = paste((str_wrap(var, width = 50))), # bryter titeln
        x = " ",
        y = "MWh per capita",
        color = "Kommun"
      ) + scale_color_manual(values = kommun_colors)+
      theme_get()+
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.caption.position = "plot", 
        legend.direction = "horizontal",
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada, Energimyndigheten, SCB') +
      guides(color = guide_legend(nrow = 2)) # delar legenden i 2 
    
    
    
    # Save as SVG
    filename <- paste0("Figurer/el_anv_", i, ".svg")
    ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
    
    # png
    
    filename <- paste0("Figurer/el_anv_", i, ".png")
    ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
  }
  
  p
}



Slutanvandning_el_fjarr_plotly <- function(){
  # läser in data
  df <- read.csv('Data/df_energianvandning.csv')
  
  
  df$title <- sub("\\,\\s*MWh/inv$", "", df$title) # tar bor MWH/inv från titeln
  
  
  # Bygg plotly-objekt
  fig <- plot_ly()
  
  for (var in unique(df$title)) {
    for (r in sort(unique(df$municipality))){
      
      # Filtrerar bort kategorier som endast har na eller 0 för kommunen
      df_region <- df %>% 
        filter(title == var, municipality==r)
      
      df_region <- df_region %>% mutate(Year = factor(year, levels = unique(year)))
      
      fig <- fig %>%
        add_trace(
          x = df_region$year,
          y = df_region$value,
          type = "scatter",
          mode = "lines+markers",
          name = r,
          line = list(color = kommun_colors[r],width = 5),
          marker = list(color = kommun_colors[r],size = 8),
          visible = ifelse(var == unique(df$title)[1], TRUE, FALSE)
        )
    }
  }
  
  # Skapa dropdown-knappar
  buttons <- lapply(seq_along(unique(df$title)), function(i) {
    visible_vec <- rep(FALSE, length(unique(df$title))*length(unique(df$municipality))) # Antal frågor * antal platser
    visible_vec[((i-1)*length(unique(df$municipality)) + 1):(i*length(unique(df$municipality)))] <- TRUE # Index på rätt plats för att rätt linje ska synas
    
    list(
      method = "update",
      args = list(
        list(visible = visible_vec),
        list(title = paste('<b>',unique(df$title)[i],'</b>')) # Ny titel 
      ),
      label = unique(df$title)[i]
    )
  })
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 80,b=50),
      title = list(text = paste('<b>',unique(df$title)[1],'</b>'), y = 0.95, x = 0.55,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = " ", tickangle = 0),
      yaxis = list(title = "<b>MWh per capita<b>", 
                   rangemode = "tozero"),
      hovermode = 'x unified',
      updatemenus = list(
        list(
          y = 1.03,
          x= 0.5,
          buttons = buttons,
          direction = "down"
        )),
      annotations = list(
        text ='Källa: Kolada, Energimyndigheten, SCB',
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

Slutanvandning_tjanst <- function(){
  # läser in data
  df <- read.csv('Data/df_slutanvandning_tjanst.csv')
  
  df$title <- sub("\\,\\s*MWh/inv$", "", df$title) # tar bor MWH/inv från titeln
  
  titles <- unique(df$title) # tar ut variabler
  
  
  # Filtrerar ut titlar
  df <- df %>% filter(title %in% titles) 
  
  # kortar ner titlar
  df <- df %>%
    mutate(title = case_when(
      title == "Slutanvändning av energi inom jordbruk, skogsbruk och fiske inom det geografiska området" ~ "Jordbruk, skogsbruk och fiske",
      title == "Slutanvändning av energi inom industri och byggverksamhet inom det geografiska området" ~ "Industri och byggverksamhet",
      title == "Slutanvändning av energi inom offentlig verksamhet inom det geografiska området" ~ "Offentlig verksamhet",
      title == "Slutanvändning av energi inom transporter inom det geografiska området" ~ "Transporter",
      title == "Slutanvändning av energi inom övriga tjänster inom det geografiska området" ~ "Övriga tjänster",
      TRUE ~ title
    ))
  
  # Bryter titlar
  df$title <- str_wrap(df$title, width = 25)
  
  # Färgschema
  cols = c("#D57667","#F9B000","#019CD7","#D0342C", "#4AA271")
  
  # loopar över alla kommuner
  for (reg in unique(df$municipality)) {
    
    # Filtrerar bort kategorier som endast har na eller 0 för kommunen
    df_region <- df %>% 
      filter(municipality == reg) 
    
    # Skapar plot
    p <-  ggplot(df_region, aes(x = year, y = value, color = title)) +
      geom_line(linewidth = 1.5,na.rm = TRUE) + geom_point(size = 2)+
      labs(
        title = str_wrap(paste('Slutanvändning av energi inom olika huvudområden i', reg),width=50), # bryter titeln
        x = " ",
        y = "MWh per capita",
        color = " "
      ) + scale_color_manual(values = cols)+
      theme_get()+
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.caption.position = "plot", 
        legend.direction = "horizontal",
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada, Energimyndigheten, SCB') +
      guides(color = guide_legend(nrow = 2)) # delar legenden i 2 
    
    
    # Save as SVG
    filename <- paste0("Figurer/energi_omrade_",reg,".svg")
    ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
    
    # png
    
    filename <- paste0("Figurer/energi_omrade_",reg,".png")
    ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
  }
  
  p  
}



Slutanvandning_tjanst_plotly <- function(){
  # läser in data
  df <- read.csv('Data/df_slutanvandning_tjanst.csv')
  
  df$title <- sub("\\,\\s*MWh/inv$", "", df$title) # tar bor MWH/inv från titeln
  
  titles <- unique(df$title) # tar ut variabler
  
  
  # Filtrerar ut titlar
  df <- df %>% filter(title %in% titles) 
  
  # kortar ner titlar
  df <- df %>%
    mutate(title = case_when(
      title == "Slutanvändning av energi inom jordbruk, skogsbruk och fiske inom det geografiska området" ~ "Jordbruk, skogsbruk och fiske",
      title == "Slutanvändning av energi inom industri och byggverksamhet inom det geografiska området" ~ "Industri och byggverksamhet",
      title == "Slutanvändning av energi inom offentlig verksamhet inom det geografiska området" ~ "Offentlig verksamhet",
      title == "Slutanvändning av energi inom transporter inom det geografiska området" ~ "Transporter",
      title == "Slutanvändning av energi inom övriga tjänster inom det geografiska området" ~ "Övriga tjänster",
      TRUE ~ title
    ))
  
  # Bryter titlar
  df$title <- str_wrap(df$title, width = 25)
  
  titles <- unique(df$title)
  
  # Färgschema
  cols = c("Industri och\nbyggverksamhet"="#D57667",
           "Jordbruk, skogsbruk och fiske"="#F9B000",
           "Offentlig verksamhet"="#019CD7",
           "Transporter"= "#D0342C",
           "Övriga tjänster"="#4AA271")
  
  regioner <- sort( unique(df$municipality))
  
  # Bygg plotly-objekt
  fig <- plot_ly()
  
  # loopar över alla kommuner
  for (reg in regioner) {
    
    for (t in titles){
      
      # Filtrerar bort kategorier som endast har na eller 0 för kommunen
      df_region <- df %>% 
        filter(municipality == reg, title==t) 
      
      
      df_region <- df_region %>% mutate(Year = factor(year, levels = unique(year)))
      
      fig <- fig %>%
        add_trace(
          x = df_region$year,
          y = df_region$value,
          type = "scatter",
          mode = "lines+markers",
          name = t,
          line = list(color = cols[t],width = 5),
          marker = list(color = cols[t],size = 8),
          visible = ifelse(reg == regioner[1], TRUE, FALSE)
        )
    }
  }
  
  # Skapa dropdown-knappar
  buttons <- lapply(seq_along(regioner), function(i) {
    visible_vec <- rep(FALSE, length(titles)*length(regioner)) # Antal frågor * antal platser
    visible_vec[((i-1)*length(titles) + 1):(i*length(titles))] <- TRUE # Index på rätt plats för att rätt linje ska synas
    
    list(
      method = "update",
      args = list(
        list(visible = visible_vec),
        list(title = paste('<b>Slutanvändning av energi inom olika huvudområden i',regioner[i],'</b>')) # Ny titel 
      ),
      label = regioner[i]
    )
  })
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 80,b=50),
      title = list(text = paste('<b>Slutanvändning av energi inom olika huvudområden i',regioner[1],'</b>'), y = 0.95, x = 0.55,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = " ", tickangle = 0),
      yaxis = list(title = "<b>MWH per capita<b>", 
                   rangemode = "tozero"),
      hovermode = 'x unified',
      updatemenus = list(
        list(
          y = 1,
          x= 0,
          buttons = buttons,
          direction = "down"
        )),
      annotations = list(
        text ='Källa: Kolada, Energimyndigheten, SCB',
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


Slutanvandning_hushall <- function(){
  # läser in data
  df <- read.csv('Data/df_slutanvandning_hushall.csv')
  
  df$title <- sub("\\,\\s*MWh/inv$", "", df$title) # tar bor MWH/inv från titeln
  
  titles <- unique(df$title) # tar ut variabler
  
  # Filtrerar ut variabler
  df <- df %>% filter(title %in% titles) 
  
  # Byter namn på variablerna
  df <- df %>%
    mutate(title = case_when(
      title == "Slutanvändning av energi bland småhus inom det geografiska området" ~ "Småhus",
      title == "Slutanvändning av energi bland flerbostadshus inom det geografiska området" ~ "Flerbostadshus",
      title == "Slutanvändning av energi bland fritidshus inom det geografiska området" ~ "Fritidshus",
      title == "Slutanvändning energi inom hushåll inom det geografiska området" ~ "Totalt",
      TRUE ~ title
    ))
  
  df$title <- str_wrap(df$title, width = 25)
  
  # Färgschema
  cols = c("#D57667","#F9B000","#019CD7","#D0342C", "#4AA271")
  
  # loopar över alla kommuner
  for (reg in unique(df$municipality)) {
    
    
    # Filtrerar bort kategorier som endast har na eller 0 för kommunen
    df_region <- df %>% 
      filter(municipality == reg) 
    
    # Skapar plot
    p <-  ggplot(df_region, aes(x = year, y = value, color = title)) +
      geom_line(linewidth = 1.5,na.rm = TRUE) + geom_point(size = 2)+
      labs(
        title = paste('Slutanvändning av energi från hushåll i', reg),
        x = " ",
        y = "MWh per capita",
        color = " "
      ) + scale_color_manual(values = cols)+
      theme_get()+
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.caption.position = "plot", 
        legend.direction = "horizontal",
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada, Energimyndigheten, SCB') +
      guides(color = guide_legend(nrow = 2)) # delar legenden i 2 
    
    
    # Save as SVG
    filename <- paste0("Figurer/energi_hushall_",reg,".svg")
    ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
    
    # png
    
    filename <- paste0("Figurer/energi_hushall_",reg,".png")
    ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
  }
  p
  
}