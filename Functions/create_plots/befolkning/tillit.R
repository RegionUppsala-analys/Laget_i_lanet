######## Sociala relationer och tillit ########

tillit <- function(){
  # Läser in data
  df <- read.csv('Data/df_tillit.csv') %>% filter(year == max(year),
                                                  title != 'Sociala relationer och tillit - Kommunindex')
  
  # Fixar titlar
  df$title <-  ifelse(grepl('Män',df$title ),'Män', 'Kvinnor')
  
  kon_color <- c("Män" = "#4AA271",
                 "Kvinnor" = "#D57667")
  
  p <- ggplot(df , aes(x=municipality, y = value, fill = title))+ 
    geom_col(position= 'dodge')+facet_wrap(~title ,nrow=1)+
    scale_fill_manual(values=kon_color)+ylim(0,100)+
    labs(
      x='',
      y='Index',
      title=str_wrap(paste('Sociala relationer och tillit - Kommunindex -',unique(df$year)),width=40),
      caption = 'Källa:Tillväxtverkets, MUFC och Fohm'
    )+ 
    theme(axis.text.x = element_text(angle = 45, hjust = 1, color = "black", size=16),
          plot.title = element_text(size = 20, face = "bold", hjust=0.5),       # centrera titel
          plot.subtitle = element_text(size = 12, hjust = 0.5),    
          strip.text = element_text(size = 12, face = "bold"),
          axis.text.y = element_text(color = "black"),
          text = element_text(family = "sourcesanspro"),
          plot.caption = element_text(hjust = 0, size=12),
          legend.position = 'none')
  p
  
  svg_filename <- paste0("Figurer/tillit.svg")
  ggsave(svg_filename, plot = p, device = "svg", width = 7, height = 5) # sparar plot
  
  png_filename <- paste0("Figurer/tillit.png")
  ggsave(png_filename, plot = p, device = "png", width = 7, height = 5, dpi = 96) # sparar plot
  
}


