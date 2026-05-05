sjalvforsorjande <- function(){
  # Läser in, filtrerar och gör om variabel till factor
  df <- read.csv('Data/df_sjalvforsorjande.csv')
  df <- df %>% filter(födelseregion != 'utrikes född')
  ordr <- c( "uppgift om utbildningsnivå saknas","förgymnasial utbildning", "gymnasial utbildning",
             "eftergymnasial utbildning")
  
  df$utbildningsnivå <- factor(df$utbildningsnivå, levels = ordr)
  
  # loopar över alla kommuner
  for(r in unique(df$region)){
    
    # filtrarar kommun
    temp <- df %>% filter(region ==r)
    
    #En heatmap per kommun
    p <- ggplot(temp, aes(x = utbildningsnivå , y = födelseregion, fill = Andel.ej.självförsörjande)) +
      geom_tile(color = "black", size = 0.5) +
      geom_text(aes(label = paste0(round(Andel.ej.självförsörjande, 1), "%")), 
                color = 'black', fontface = "bold", size = 3.1) +
      scale_fill_gradient2(low = "white", mid = "#F4DCE8", high = "#B81867", 
                           midpoint = 50, name = "Andel ej självförsörjande\n(%)") +
      facet_wrap(~kön, ncol = 2,labeller = labeller(kön = str_to_title)) +
      scale_x_discrete(labels = str_to_title) + 
      scale_y_discrete(labels = str_to_title) +  
      labs(title = str_wrap(paste("Andel som inte är självförsörjande efter utbildningsnivå och födelseregion i",r ,', år',unique(df$år)),width=50),
           x = "", y = "") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, color = "black", size=12),
            plot.title = element_text(size = 16, face = "bold", hjust=0.5, color="#B81867"),
            strip.text = element_text(size = 12, face = "bold"),
            axis.text.y = element_text(color = "black", size=13),
            text = element_text(family = "sourcesanspro"),
            plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
    
    # Sparar data
    svg_filename <- paste0("Figurer/heatsjalv_", gsub(" ", "_", r), ".svg")
    ggsave(svg_filename, plot = p, device = "svg", width = 8, height = 6) # sparar plot
    png_filename <- paste0("Figurer/heatsjalv_", gsub(" ", "_", r), ".png")
    ggsave(png_filename, plot = p, device = "png", width = 8, height = 6, dpi = 96) # sparar plot
    
    
  }   
  
}
