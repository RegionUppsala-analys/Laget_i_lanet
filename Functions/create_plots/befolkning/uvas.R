uvas <- function(){
  
  # Läser in data
  df <- read.csv('Data/unga_utan_studier_eller_arbete_uppsala.csv') %>% 
    select(-Antal_16_29 ,-Andel_16_29)
  
  # Byter *** till NA och tar bort % tecken
  df[df == "***"] <- NA
  percent_cols <- grep("Andel", names(df), value = TRUE)
  antal_cols <- grep("Antal", names(df), value = TRUE)
  
  df <- df %>%
    mutate(across(all_of(percent_cols), ~ gsub("%", "", .))) %>%
    mutate(across(all_of(percent_cols), ~ gsub(",", ".", .))) %>%
    mutate(across(all_of(percent_cols), as.numeric),
           across(all_of(antal_cols), as.numeric))
  
  
  
  df_long <-  df %>%
    pivot_longer(
      cols = starts_with(c("Antal", "Andel")),
      names_to = "andel_antal",
      values_to = "value"
    )
  
  # Lägg till flagga om värdet är andel eller antal
  df_long <- df_long %>%
    mutate(
      typ = ifelse(grepl("Andel", andel_antal), "Andel", "Antal")
    )
  
  # Byter namn till endast intervallen
  df_long <- df_long %>%
    mutate(
      age_group = gsub(".*_(\\d+_\\d+)$", "\\1", andel_antal),   # plockar t.ex. 16_24
      age_group = gsub("_", "-", age_group)                      # gör om 16_24 → 16-24
    )
  # Färgschema
  
  colors <- c("Kvinnor Inrikesfödd" = "#D57667", 
              "Män Inrikesfödd" = "#F9B000",
              'Män Utrikesfödd'="#4AA271",
              "Kvinnor Utrikesfödd" = "#019CD7")
  
  maxx <- max(df_long %>% filter(typ == "Andel") %>% 
                select(value), na.rm = T)
  
  # Loop över kommunerna
  for (kommun in kommuner) {
    #filtrerar data
    temp <- df_long %>% filter(Kommun == kommun)
    
    # Skapar den för antal
    p_antal <- ggplot(temp %>% filter(typ == "Antal"),
                      aes(x = År, y = value, color = Grupp)) +
      geom_line(size = 1.5) +geom_point(size=3)+
      facet_wrap(~ age_group, nrow = 1) +
      scale_color_manual(values = colors) +
      labs(
        x = '', y = 'Antal', color = '',
        title = paste("Antal UVAS –", kommun)
      ) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
            axis.text.y = element_text(angle = 45, hjust = 1, size = 14),
            plot.title = element_text(size = 20, face = "bold", hjust =0.5),
            strip.text = element_text(size = 14, face = "bold"),
            legend.text = element_text(size=14),
            legend.position = 'none'
      )
    # Andelar
    p_andel <- ggplot(temp %>% filter(typ == "Andel"),
                      aes(x = År, y = value, color = Grupp)) +
      geom_line(size = 1.5) +geom_point(size=3)+
      facet_wrap(~ age_group, nrow = 1) +
      scale_color_manual(values = colors) +
      scale_y_continuous(limits = c(0, maxx+5)) +
      labs(
        x = '', y = 'Andel (%)', color = '',
        title = paste("Andel UVAS –", kommun),
        caption = "Källa: Tillväxtverkets, MUFC och Fohm"
      ) +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
        axis.text.y = element_text(angle = 45, hjust = 1, size = 14),
        plot.title = element_text(size = 20, face = "bold", hjust =0.5),
        strip.text = element_text(size = 14, face = "bold"),
        
        legend.text = element_text(size=14),
        plot.caption = element_text(hjust = 0, size = 12),
        legend.position = "bottom"
      )+ guides(color = guide_legend(nrow = 2))
    
    #  SLÅ IHOP PLOTS 
    combined <- p_antal / p_andel + 
      plot_layout(heights = c(1, 1)) & 
      theme(plot.margin = unit(c(0.1, 0, 0, 0.1), "cm"),
            panel.spacing = unit(0.2, "lines"))
    
    
    print(combined)
    
    # Sparar plot
    svg_filename <- paste0("Figurer/uvas_",kommun,".svg")
    ggsave(svg_filename, plot =combined, device = "svg", width = 7, height = 8) # sparar plot
    
    # png 
    png_filename <- paste0("Figurer/uvas_",kommun,".png")
    ggsave(png_filename, plot =combined, device = "png", width = 7, height = 8, dpi = 96) # sparar plot
    
    
  }
  
  
}
