tandhalsa <- function(){
  # läser in data
  df <- read.csv("Data/df_tandhalsa.csv")
  
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
  # Visa vart 5:e år på x-axeln
  ara <- unique(df$År)
  visa_ar <- ara[seq(1, length(ara), by = 4)]
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+facet_wrap(~Tandhälsa, ncol=2)+
    geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3, color =NA) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Andel, group = Kön, color = Kön),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = visa_ar) +
    
    labs(x="",
         title = str_wrap("Uppskattad tandhälsa – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         y = "Andel (%)",
         color="",
         fill="",
         subtitle = str_wrap("Streckade linjer är Riksandelen", width = 50))+
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'),
          axis.text.x = element_text(angle = 45, hjust=1))
  
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/tandhalsa.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/tandhalsa.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
}

tandhalsa_behov <- function(){
  # läser in data
  df <- read.csv("Data/df_tandhalsa_avsta.csv") %>%
    mutate(Avstått.tandläkarvård = case_when(
      Avstått.tandläkarvård=="Avstått tandläkarvård trots behov"~"Totalt",
      TRUE ~"Ekonomiska skäl"))
  
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
  # Visa vart 5:e år på x-axeln
  ara <- unique(df$År)
  visa_ar <- ara[seq(1, length(ara), by = 4)]
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+facet_wrap(~Avstått.tandläkarvård, ncol=2)+
    geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3, color =NA) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Andel, group = Kön, color = Kön),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = visa_ar) +
    
    labs(x="",
         title = str_wrap("Andel som avstått tandläkarvård trots behov – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         y = "Andel (%)",
         color="",
         fill="",
         subtitle = str_wrap("Streckade linjer är Riksandelen", width = 50))+
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'),
          axis.text.x = element_text(angle = 45, hjust=1))
  
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/tandhalsa_behov.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/tandhalsa_behov.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
}
