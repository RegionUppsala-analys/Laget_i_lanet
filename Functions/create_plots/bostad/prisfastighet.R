###### Prisutveckling ########

prisfastighet <- function(){
  # Läser in data
  df <- read.csv("Data/fastighetspris.csv")
  
  # fixar snyggare titlar: 
  df$title <- gsub("Fastighetspris |, kr/kvm", "", df$title)
  
  df$title <- tools::toTitleCase(df$title)
  
  # Färgtema
  cols <- c('Bostadsrätt' = "#F9B000",
            'Fritidshus' = "#4AA271",
            'Småhus' = "#019CD7")
  
  # loopar över alla kommuner
  for (r in unique(df$municipality)){
    
    # Filtrerar kommun
    temp <- df %>% filter(municipality == r)
    
    # Tidserieplots
    p<- ggplot(temp, aes(x = year, y = value, color= title))+
      geom_line(linewidth=1.5) + geom_point(size=3)+ 
      labs(title=paste0('Fastighetspris i ', r, '\nKr/kvm'), 
           y='kr/kvm', x='', color = '')+
      scale_color_manual(values=cols)+ 
      scale_x_continuous(breaks=seq(min(df$year), max(df$year),by=3 ))+
      theme(legend.position = 'bottom', 
            axis.text.x = element_text(angle=45),
            plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada och SCB')
    
    # Sparar en plot per kommun
    filename <- paste0('Figurer/fastighetspris_',r ,'.svg')
    ggsave(filename,plot = p,device = "svg", width = 7, height = 5)
    
    # png
    filename <- paste0('Figurer/fastighetspris_',r ,'.png')
    ggsave(filename,plot = p,device = "png", width = 7, height = 5,
           dpi = 96)
  }
  
}