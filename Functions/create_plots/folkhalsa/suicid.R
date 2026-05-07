
suicid <- function(){
  # Läser in data
  df <- read.csv("Data/df_suicid.csv")
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  
  # Loopar över varje kommun i läne
  for (r in kommuner) {
    temp <- df %>% filter(Region == r)
    
    p <- ggplot(temp, aes(x =År, y = X25..åldersstandardiserad, color=Kön, group=Kön))+
      geom_line(linewidth=2)+ geom_point(size=3)+scale_color_manual(values = kon_col)+
      
      labs(x="",
           title = str_wrap(paste("Suicid per 100 000 invånare –", r), width=50),
           caption = "Källa: Folkhälsomyndigheten, Socialstyrelsen, Dödsorsaksregistret",
           y = "Antal per 100 000",
           color="")+
      theme(plot.caption = element_text(hjust=0),
            axis.text.x = element_text(angle = 45, hjust=1))
    
    p
    
    
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/suicid_",r,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/suicid_",r,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
    
  }
  
  
}

