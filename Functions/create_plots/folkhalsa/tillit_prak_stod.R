tillit_till_andra <-  function(){
  # Läsa in data  
  df <- read.csv('Data/df_tillit_till_andra.csv') %>% filter(Region %in% c(
    "Riket","Uppsala län"))
  
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)

  etiketter <- df %>%
    group_by(Kön) %>%
    filter(År == max(År)) %>%
    ungroup()
  
  # Visa vart 5:e år på x-axeln
  ara <- unique(df$År)
  visa_ar <- ara[seq(1, length(ara), by = 3)]
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3, color =NA) +
    geom_text_repel(data = etiketter, aes(label = round(Andel, 1)),
            direction = "y", nudge_x = 0.3, hjust = 0,
            segment.color = NA, show.legend = FALSE) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Andel, group = Kön, color = Kön),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = visa_ar,
             expand = expansion(mult = c(0.02, 0.10))) +
    
    labs(x="",
         title = str_wrap("Andel som har svårt att lita på andra – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/tillit_till.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/tillit_till.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}


em_prak_stod <- function(){
  # Hämtar data
  df1 <- read.csv("Data/praktiskt_stod.csv") %>% mutate(variable = "Praktiskt")%>% filter(Region %in% c(
    "Riket","Uppsala län"))
  
  df2 <- read.csv("Data/emotionellt_stod.csv")%>% mutate(variable = "Emotionellt")%>% filter(Region %in% c(
    "Riket","Uppsala län"))
  # slår ihop dataseten
  df <- rbind(df1,df2)  
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)

  etiketter <- df %>%
    group_by(variable, Kön) %>%
    filter(År == max(År)) %>%
    ungroup()
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+facet_wrap(~variable, ncol=2)+
    geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3, color =NA) +
    geom_text_repel(data = etiketter, aes(label = round(Andel, 1)),
            direction = "y", nudge_x = 0.3, hjust = 0,
            segment.color = NA, show.legend = FALSE) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Andel, group = Kön, color = Kön),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = c(min(df$År), max(df$År)),
             expand = expansion(mult = c(0.02, 0.10))) +
    
    labs(x="",
         title = str_wrap("Andel som saknar emotionellt respektive praktiskt stöd – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/em_prak_stod.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/em_prak_stod.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}