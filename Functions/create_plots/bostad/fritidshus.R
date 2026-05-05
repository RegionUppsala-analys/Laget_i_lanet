###### Fritidshus #########


fritidshus_reg <- function(){
  # Läser in data
  df_fritidshus <- read.csv('Data/df_fritidshus.csv')
  
  # Summerar antal per år
  df_fritidshus_reg <- df_fritidshus %>% group_by(år) %>% 
    summarize(Antal = sum(Antal), .groups = "drop")
  
  # Senaste året i datan som ska in i titeln
  ar_max <- max(df_fritidshus_reg$år)
  
  # Skapar plot
  p <- ggplot(df_fritidshus_reg, aes(x=as.integer(år), y=Antal))+
    geom_line(color = '#B81867', linewidth = 2) + xlab(' ') + 
    ggtitle(paste('Totalt antal fritidshus i ', lan ,' (1998-',ar_max, ')' ,sep=""))+
    theme(
      text = element_text(family = "sourcesanspro"),
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
  
  p
  # Sparar plot
  ggsave(filename = 'Figurer/fritidshus_region.svg', plot = p, width =  7, height = 5, device = "svg")
  ggsave(filename = 'Figurer/fritidshus_region.png', plot = p, width =  7, height = 5, device = "png",
         dpi = 96)
}

fritidshus_kommun <- function(){
  # Läser in data
  df_fritidshus <- read.csv('Data/df_fritidshus.csv')
  # Senaste året i datan som ska in i titeln
  ar_max <- max(df_fritidshus$år)
  
  # Skapar plot
  p <- ggplot(df_fritidshus, aes(x=as.integer(år), y=Antal,  color = '#B81867'))+
    geom_line( linewidth = 2) +facet_wrap(vars(region), scales='free_y')+ # Delar per region
    scale_color_manual(values = '#B81867') + 
    xlab(' ') + ggtitle(paste('Antal fritidshus per kommun (1998 och ', ar_max,')', sep=""))+
    scale_x_continuous(
      breaks = seq(min(df_fritidshus$år), max(df_fritidshus$år), by = 8)
    ) + theme(legend.position="none",
              axis.text.x = element_text(angle=45, vjust=0.5),
              text = element_text(family = "sourcesanspro"),
              plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
  
  p
  # Sparar plot
  ggsave(filename = 'Figurer/fritidshus_kommun.svg', plot = p, width =  8, height = 7, device = "svg")
  ggsave(filename = 'Figurer/fritidshus_kommun.png', plot = p, width =  8, height = 7, device = "png",
         dpi = 96)
}

