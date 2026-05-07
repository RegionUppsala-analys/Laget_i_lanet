########################## Växthusgaser #####################

vaxthusgaser <- function(){
  # Läser in data
  df <- read.csv('Data/df_vaxthusgas.csv')
  df <- na.omit(df)
  
  # Skapar plot
  p <-  ggplot(df, aes(x = year, y = value, color = municipality)) +
    geom_line(linewidth = 1.5) +
    geom_point(size = 2)+ # linje och punkter
    labs(
      title = paste((str_wrap('Växthusgaser utsläppt till luft, anges per capita', width = 60))), # bryter titeln
      x = " ",
      y = expression("Ton CO"[2]*"e / capita"),
      color = ""
    ) + scale_color_manual(values = kommun_colors)+
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "bottom",
      plot.title.position = "plot",
      plot.caption.position = "plot", 
      legend.direction = "horizontal",
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada, SMHI och SCB') +
    guides(color = guide_legend(nrow = 2)) # delar legenden i 2 
  p
  # Save each plot separately
  filename <- paste0("Figurer/vaxthusgas", ".svg")
  ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
  
  # png
  
  filename <- paste0("Figurer/vaxthusgas", ".png")
  ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
  
}

vaxthus_perkategori <- function(){
  # Läser in data
  emissions_data <- read.csv('Data/df_emissions_data.csv')
  
  # Tar bort X från kolumnnamn
  names(emissions_data) <- sub("^X", "", names(emissions_data))
  
  # Filtrera data för att endast inkludera rader där Kommun och Undersektor är "Alla" och välj en rad per huvudsektor
  filtered_data <- emissions_data %>%
    filter(Undersektor == "Alla",
           Huvudsektor != 'Alla')  # Håll en unik rad per Huvudsektor
  
  max_ar <- names(emissions_data)[ncol(emissions_data)] # tar ut senaste året
  
  # Omvandla data från bred till lång format för att använda i ggplot
  long_data <- filtered_data %>%
    pivot_longer(cols = `1990`:max_ar,  # Kolumnerna för årtalen
                 names_to = "År",
                 values_to = "Värde") %>%
    mutate(År = as.numeric(År))  # Konvertera År till numerisk för att göra det enklare att plotta
  
  # Färgschema
  cols <- c( "#D57667" , "#F9B000" , "#019CD7" , '#CCEBF7' , "#4AA271" ,
             "#6F787E" , "#8B4A9C" , "#E67E22","#D0342C" )
  
  # Delar namnet på grupperna
  long_data$Huvudsektor <- str_wrap(long_data$Huvudsektor, width=25)
  
  # En plot per kommun
  for(k in unique(long_data$Kommun)){
    
    tmp <- long_data %>% filter(Kommun ==k)
    
    if(k == 'Alla'){
      k <- 'Länet' # byter ut k till länet för plotten är  'Alla' i datat
    }
    
    # Skapa linjediagram och placera labels på högersidan
    p <- ggplot(tmp, aes(x = År, y = Värde, color = Huvudsektor)) +
      geom_line(linewidth = 1.5) + geom_point(size=2)+
      scale_color_manual(values=cols)+
      scale_y_continuous(labels = comma) + # utan scientific notaion
      labs(title = paste("Förändring över tid för olika huvudsektorer i", k),
           x = " ",
           y = expression("Ton CO"[2]*"e"),
           color = "Huvudsektor") +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.legend.position = "plot",
        plot.caption.position = "plot", 
        legend.direction = "horizontal",
        plot.margin = ggplot2::margin(t=10, 20, 15, 20) ,
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SMHI') +
      guides(color = guide_legend(nrow = 5))
    p  
    # Sparar plottarna
    filename <- paste0("Figurer/vaxthusgas_forandring_", k,".svg")
    ggsave(filename, plot = p, device = "svg", width = 8, height = 8)
    
    filename <- paste0("Figurer/vaxthusgas_forandring_", k,".png")
    ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
  }
}

vaxthus_perkategori_plotly <- function(){
  # Läser in data
  emissions_data <- read.csv('Data/df_emissions_data.csv')
  
  # Tar bort X från kolumnnamn
  names(emissions_data) <- sub("^X", "", names(emissions_data))
  
  # Filtrera data för att endast inkludera rader där Kommun och Undersektor är "Alla" och välj en rad per huvudsektor
  filtered_data <- emissions_data %>%
    filter(Undersektor == "Alla",
           Huvudsektor != 'Alla',
           Huvudsektor != "Utrikes transporter")  # Håll en unik rad per Huvudsektor
  
  max_ar <- names(emissions_data)[ncol(emissions_data)] # tar ut senaste året
  
  # Omvandla data från bred till lång format för att använda i ggplot
  long_data <- filtered_data %>%
    pivot_longer(cols = `1990`:max_ar,  # Kolumnerna för årtalen
                 names_to = "År",
                 values_to = "Värde") %>%
    mutate(År = as.numeric(År))  # Konvertera År till numerisk för att göra det enklare att plotta
  
  
  
  # Delar namnet på grupperna och fixar variabler till plotten
  long_data$Huvudsektor <- str_wrap(long_data$Huvudsektor, width=25)
  
  long_data$Kommun <- ifelse(long_data$Kommun == 'Alla', "Länet",long_data$Kommun)
  
  long_data <- long_data %>% mutate(Kommun = factor(long_data$Kommun, levels = c('Länet', kommuner)))
  
  regioner <- unique(long_data$Kommun)
  
  sektor <- unique(long_data$Huvudsektor)
  
  # Färgschema
  cols <- c("Arbetsmaskiner"="#D57667" ,"Avfall (inkl.avlopp)"="#F9B000" ,
            "Egen uppvärmning av\nbostäder och lokaler"="#019CD7" ,
            "El och fjärrvärme" ='#CCEBF7' ,
            "Industri (energi +\nprocesser)" ="#4AA271" ,
            "Jordbruk"= "#6F787E" ,"Produktanvändning (inkl.\nlösningsmedel)"="#8B4A9C" ,
            "Transporter" ="#D0342C" )
  
  
  # Bygg plotly-objekt
  fig <- plot_ly()
  
  # loopar över alla kommuner
  for (reg in regioner) {
    
    for (s in sektor){
      
      # Filtrerar bort kategorier som endast har na eller 0 för kommunen
      df_region <- long_data %>% 
        filter(Kommun == reg, Huvudsektor==s) 
      
      
      
      fig <- fig %>%
        add_trace(
          x = df_region$År,
          y = df_region$Värde,
          type = "scatter",
          mode = "lines+markers",
          name = s,
          line = list(color = cols[s],width = 5),
          marker = list(color = cols[s],size = 8),
          visible = ifelse(reg == regioner[1], TRUE, FALSE)
        )
    }
  }
  
  # Skapa dropdown-knappar
  buttons <- lapply(seq_along(regioner), function(i) {
    visible_vec <- rep(FALSE, length(sektor)*length(regioner)) # Antal frågor * antal platser
    visible_vec[((i-1)*length(sektor) + 1):(i*length(sektor))] <- TRUE # Index på rätt plats för att rätt linje ska synas
    
    list(
      method = "update",
      args = list(
        list(visible = visible_vec),
        list(title = paste('<b>Utsläpp från olika huvudsektorer i',regioner[i],'</b>')) # Ny titel 
      ),
      label = regioner[i]
    )
  })
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 80,b=50),
      title = list(text = paste('<b>Utsläpp av växthusgaser från olika huvudsektorer i',regioner[1],'</b>'), y = 0.95, x = 0.55,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = " ", tickangle = 0),
      yaxis = list(title = paste("<b>Ton CO2e </b>"), 
                   rangemode = "tozero"),
      hovermode = 'x unified',
      updatemenus = list(
        list(
          y = 1.05,
          x= 0,
          buttons = buttons,
          direction = "down"
        )),
      annotations = list(
        text ='Källa: SMHI',
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


utslapp_till_luft <- function(){
  # Läser in 4 dataset
  df_utslapp_kv <- read.csv('Data/df_utslapp_kv.csv') 
  df_utslapp_am <- read.csv('Data/df_utslapp_am.csv')   
  df_utslapp_org <- read.csv('Data/df_utslapp_org.csv') 
  df_utslapp_pm <- read.csv('Data/df_utslapp_pm.csv') 
  
  
  df_utslapp_org$value <- df_utslapp_org$value * 1000 # Ändrar från ton till kg så alla matchar
  
  
  # slår ihop
  df <- rbind(df_utslapp_kv,df_utslapp_am,df_utslapp_org,df_utslapp_pm)
  
  # kortar ner titlarna
  df$title <- sub(",.*", "", df$title)
  df$title <- sub("\\.\\s*kg/inv$", "", df$title)
  
  
  # Ändrar titlar till /inv, då det är den variabeln som används
  df$title <- str_wrap(df$title, width=50)
  # Färgskala
  col <- c("#D57667" , "#F9B000" , "#019CD7" ,"#4AA271") 
  
  #ymin <- min(df$value, na.rm = T) -5 # variabler för skala på y axeln(samma för alla kommuner)
  #ymax <- max(df$value,na.rm = T) +5 
  
  df <- na.omit(df)
  
  # En plot per kommun
  for(reg in unique(df$municipality)){
    
    # Filtrerar data och skapar plot
    df_sub <- df %>% filter(municipality == reg)
    
    p <- ggplot(df_sub, aes(x = year, y = value, colour = title)) +
      geom_line(linewidth = 1.5) + geom_point(size = 2)+
      #ylim(ymin, ymax) +
      labs(
        title = paste('Utlsläpp till luft i', reg),
        x = " ",
        y = 'Kg per capita',
        colour = ' '
      ) +
      scale_color_manual(values=col) +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.caption.position = "plot",
        legend.direction = "horizontal",
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada, SMHI och SCB') +
      guides(color = guide_legend(nrow = 4))
    
    # Save each plot separately
    filename <- paste0("Figurer/utslapp_", reg, ".svg")
    ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
    
    
    # png
    filename <- paste0("Figurer/utslapp_", reg, ".png")
    ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
  }
}
