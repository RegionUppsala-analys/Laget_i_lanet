########## Elhandelspriser #####################

Elhandelspriser <- function(){
  # läser in data
  df <- read.csv('Data/df_Elhandelspriser.csv')
  
  # Gör kolumnnamn och kategorier till storbokstav
  colnames(df) <- str_to_sentence(colnames(df))
  df <- df %>% mutate(Avtalstyp = str_to_sentence(Avtalstyp),
                      Kundkategori = str_to_sentence(Kundkategori)) 
  
  # Gör om månaderna till date
  df <- df %>%
    mutate(
      Månad = as.Date(paste0(substr(Månad, 1, 4), "-", substr(Månad, 6, 7), "-01"))
    )
  
  # Färger
  cols = c("#D57667","#F9B000","#019CD7","#D0342C", "#4AA271")
  
  # skapar plot
  p <- ggplot(df, aes(x = Månad, y = Elhandelspriser, color = Avtalstyp)) +
    geom_line(linewidth = 1) +
    facet_wrap(~ Elområde) +
    scale_color_manual(values =cols) +
    labs(
      title = "Elpris över tid per avtalstyp och elområde",
      x = "",
      y = "Elhandelspris (öre/kWh)",
      color = "Avtalstyp"
    ) +
    theme_get()+
    theme(axis.text.x = element_text(angle = 45, hjust = 1), 
          legend.position = "bottom",
          plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')+
    guides(
      color = guide_legend(nrow = 2)  #  två rader i legenden
    )
  
  # sparar som svg
  ggsave("Figurer/elpris_plot.svg", plot = p, device = "svg", width = 8, height = 6)
  ggsave("Figurer/elpris_plot.png", plot = p, device = "png", width = 8, height = 6, dpi=96)
}

########## Elproduktion #####################

Elproduktion <- function(){
  # läser in data
  df <- read.csv('Data/df_Elproduktion.csv')
  
  # Gör kolumnnamn och kategorier till storbokstav
  df <- df %>% filter(produktionssätt != 'totalt', bränsletyp != 'totalt') %>% 
    mutate(produktionssätt = str_to_sentence(produktionssätt),
           bränsletyp    = str_to_sentence(bränsletyp)) 
  
  # Stor bokstav i början
  colnames(df) <- str_to_sentence(colnames(df))
  
  # Färger
  cols <- c(
    "Kraftvärmeverk + industriellt mottryck" = "#D57667",
    "Solkraft" = "#F9B000",
    "Vattenkraft" = "#019CD7",
    "Vindkraft" = "#D0342C",
    "Övrig värmekraft (kärnkraft, kondenKoladaaft o.dyl.)" = "#4AA271"
  )
  
  # Skapar en summering för länet
  df_region <- df %>% group_by(År,Produktionssätt,Bränsletyp) %>% 
    summarize(Elproduktion.och.bränsleanvändning..Mwh. = sum(Elproduktion.och.bränsleanvändning..Mwh., na.rm=FALSE),
              .groups = 'drop') %>% mutate(Region = 'Länet')
  
  
  # slår ihop data
  df <- bind_rows(df, df_region)
  
  kommuner_lan <- c("Länet",kommuner )
  
  # Loop över alla kommuner
  for (reg in kommuner_lan) {
    
    # Filtrerar bort kategorier som endast har na eller 0 för kommunen
    df_region <- df %>% 
      filter(Region == reg) %>%
      group_by(Produktionssätt, Bränsletyp) %>%
      filter(
        !all(is.na(Elproduktion.och.bränsleanvändning..Mwh.)) & 
          !(all(Elproduktion.och.bränsleanvändning..Mwh. == 0, na.rm = TRUE))
      ) %>%
      ungroup()
    
    df_region <- df_region %>%
      mutate(Produktionssätt = str_wrap(Produktionssätt, width = 35))  # Bryter långa namn
    
    # antal Produktionssätt:
    nr_prod <- length(unique(df_region$Produktionssätt))
    
    # skapar plot
    p <-  ggplot(df_region,aes(x = År, y = Elproduktion.och.bränsleanvändning..Mwh., color = Produktionssätt)) +
      geom_line(linewidth = 1.5) + geom_point(size = 2)+
      facet_wrap(~ Bränsletyp, scales = "free_y",nrow =3) +
      scale_y_continuous(labels = comma) + # utan scientific notaion
      labs(
        title = paste("Elproduktion per produktionssätt och bränsletyp -", reg),
        x = " ",
        y = "Megawattimme (MWh)",
        color = " "
      )+
      theme_get() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.caption.position = "plot", 
        legend.direction = "horizontal",
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')+
      guides(color = guide_legend(nrow = ifelse(nr_prod>1,2,1))) # delar legenden i 2 rader om det behövs
    
    
    # Save as SVG
    filename <- paste0("Figurer/Elproduktion_", reg, ".svg")
    ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
    
    # png
    filename <- paste0("Figurer/Elproduktion_", reg, ".png")
    ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
  }
  p
}