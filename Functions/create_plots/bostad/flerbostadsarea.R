
####### Storleksfördelning########

flerbostadsarea <- function(){
  # Läser in data
  df_bostadsarea <- read.csv('Data/df_bostadsarea.csv')
  
  # vektor med lägenhetsstorlekar så x-axeln blir i rätt spridning
  ordning <- c("< 31 kvm", "31-40 kvm", "41-50 kvm", "51-60 kvm", "61-70 kvm",
               "71-80 kvm", "81-90 kvm", "91-100 kvm", "101-110 kvm",
               "111-120 kvm", "121-130 kvm", "131-140 kvm", "141-150 kvm","151-160 kvm",
               "161-170 kvm","171-180 kvm","181-190 kvm",
               "191-200 kvm", "> 200 kvm")
  
  
  # Plockar ut senaste årets data på flerbostadshus och beräknar andel
  flerbostadsarea <- df_bostadsarea %>%  filter(hustyp=='flerbostadshus', år== max(as.numeric(år)), Antal > 0) %>% 
    group_by(region) %>%  mutate(Andel = round((Antal/ sum(Antal))*100,2),
                                 bostadsarea = factor(bostadsarea, levels = ordning))%>%
    filter(!is.na(bostadsarea)) # tar ej med övrig 
  
  # Skapar plot över fördelningen
  p <- ggplot(flerbostadsarea, aes(x = bostadsarea, y = Andel)) + 
    geom_col(fill="#B81867") +
    facet_wrap(vars(region), nrow = 4) + # delar på region, 4 rader
    ggtitle(str_wrap(paste("Fördelningen av bostadsarea i flerbostadshus år", unique(flerbostadsarea$år)),width=50)) +
    xlab("Area") +ylab("Andel (%)")+
    theme(axis.text.x = element_text(angle = 90),
          legend.position="none",
          title = element_text(hjust=0.5, size=18),
          axis.title.y = element_text(hjust = 0.5),
          axis.title.x = element_text(hjust = 0.5),
          plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
  
  p
  # sparar som svg
  ggsave('Figurer/flerbostadsarea.svg',plot = p,device = "svg", width = 8, height = 7)
  ggsave('Figurer/flerbostadsarea.png',plot = p,device = "png", width = 8, height = 7,
         dpi = 96)
  
}

