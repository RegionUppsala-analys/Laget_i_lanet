########### Elavbrott Kolada #####################


Elavbrott <- function(){
  # läser in data
  df <- read.csv('Data/df_elavbrott.csv')
  
  # Byter namn på variabler
  df <- df %>%
    mutate(title = case_when(
      title == "Elavbrott,  genomsnittlig avbrottstid per kund (SAIDI), minuter/kund" ~ "Genomsnittlig avbrottstid per kund (SAIDI)",
      title == "Elavbrott,  andel kunder som drabbats av 4 eller fler oaviserade långa avbrott under året (CEMI-4), andel (%)" ~ "Andel kunder som drabbats av 4 eller fler oaviserade långa avbrott under året (CEMI-4)",
      TRUE ~ title
    ))
  
  # index till loop
  i <- 0
  
  # Loop över de två variablerna
  for (var in unique(df$title)) {
    i <- i + 1
    # Filtrerar bort kategorier som endast har na eller 0 för kommunen
    df_region <- df %>% 
      filter(title == var) 
    
    # Ändrar y-axeln titel beroende på variabel
    y_axis <- ifelse(grepl("Genomsnittlig", var), "Minuter/kund",
                     "Andel (%)")
    
    # Skapar plot
    p <-  ggplot(df_region, aes(x = year, y = value, color = municipality)) +
      geom_line(linewidth = 1.5,na.rm = TRUE) + geom_point(size = 2)+
      labs(
        title = paste((str_wrap(var, width = 50))),
        x = " ",
        y = y_axis,
        color = ""
      ) + scale_color_manual(values = kommun_colors)+
      theme_get()+
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.caption.position = "plot", 
        legend.direction = "horizontal",
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada och Energimyndigheten') + 
      guides(color = guide_legend(nrow = 2)) # delar legenden i 2 
    
    
    # Save as SVG
    filename <- paste0("Figurer/elavbrott_", i, ".svg")
    ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
    
    # png
    
    filename <- paste0("Figurer/elavbrott_", i, ".png")
    ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
  }
  
  
  
}



###################### Vindkraft #####################

Effektverk <- function(){
  # Läserin data
  df <- read.csv('Data/df_effekt_verk.csv')
  
  # Skapar plot
  p <- ggplot(df, aes(x = År, y = Antal.verk.och.installerad.effekt.per.kommun..2003., fill=Kommun))+ 
    geom_col() + # Barplot delat på variablerna i datat
    facet_wrap(~Kategori,scales = "free_y", nrow=2,
               labeller = labeller(Kategori = c(
                 "Antal" = "Antal verk",
                 "Effekt" = "Installerad effekt (MW)"
               )))+ 
    labs(
      title = paste("Antal verk och installerad effekt per kommun"),
      x = " ",
      y = "",fill=""
    ) + scale_fill_manual(values = kommun_colors) +
    theme_get()+
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "bottom",
      plot.title.position = "plot",
      plot.caption.position = "plot", 
      legend.direction = "horizontal",
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Energimyndigheten') +
    guides(color = guide_legend(nrow = 3)) # 3 rader i legenden
  
  p
  # Sparar plot
  filename <- paste0("Figurer/Effektverk", ".svg")
  
  ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
  
  # png
  filename <- paste0("Figurer/Effektverk", ".png")
  ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
}

######################## Solcell #####################

solcell <- function(){
  # Läser in data
  df <- read.csv('Data/df_solcell.csv')
  
  # kortare namn
  df <- df %>% mutate(value =Nätanslutna.solcellsanläggningar..installerad.effekt.per.capita.och.landareal..fr.o.m..år.2016.. )
  
  # kategorierna
  kategorier <- unique(df$Kategori)
  
  # En plot per kategori
  for (kat in kategorier) {
    
    df_sub <- df %>% filter(Kategori == kat)
    
    # Label för y-axeln
    y_label <- ifelse(
      kat == "Installerad effekt per capita (Watt per person)", 
      "Effekt per capita (W/capita)", 
      "Effekt per landareal (W/km²)"
    )
    
    # Skapar plot
    p <- ggplot(df_sub, aes(x = År, y = value, colour = Område)) +
      geom_line(linewidth = 1.5) + geom_point(size = 2)+
      labs(
        title = "Nätanslutna solcellsanläggningar",
        x = " ",
        y = y_label,
        colour = ''
      ) +
      scale_color_manual(values = kommun_colors)+
      theme_get() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.caption.position = "plot",
        legend.direction = "horizontal",
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Energimyndigheten') +
      guides(color = guide_legend(nrow = 3))
    
    # Save each plot separately
    filename <- paste0("Figurer/solcell_", kat, ".svg")
    ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
    
    # png
    
    filename <- paste0("Figurer/solcell_", kat, ".png")
    ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
    
  }
  
}