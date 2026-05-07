
diabetes <- function(){
  # Läser in data
  df <- read.csv("Data/df_diabetes.csv") %>% filter(Ålder == "Totalt 25- åldersstandardiserad")
  
  # Visa vart 5:e år på x-axeln
  ara <- unique(df$År)
  visa_ar <- ara[seq(1, length(ara), by = 3)]
  
  # Färger
  color_lan <- c("#019CD7","#E67E22",  "#4AA271" ,"#F9B000", "#8B4A9C", "#D57667","#6F787E"    )
  names(color_lan) <- unique(df$Region)
  color_lan["Uppsala län"] <- "#B81867"
  
  p <- ggplot(df, aes(x= År, y=Diabetes.typ.två..nya.fall.efter.kön..region.och.år.,
                      color = Region, group=Region))+ 
    geom_line(linewidth=1.5)+ geom_point(size=2)+ facet_wrap(~Kön)+
    scale_x_discrete(breaks = visa_ar) +
    scale_color_manual(values= color_lan)+
    labs(x="",
         title = str_wrap("Nyregistrerade fall av typ 2-diabetes per 100 000 – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Nationella diabetesregistret och Socialstyrelsen",
         y = "Antal per 100 000",
         color="")+
    theme(plot.caption = element_text(hjust=0),
          axis.text.x = element_text(angle = 45, hjust=1),legend.position = "bottom")+ 
    guides(color = guide_legend(nrow = 2))
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/diabetes.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/diabetes.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
}

hogt_blodtryck <- function(){
  # Läser in data
  df <- read.csv("Data/df_sjukdomar_besvar.csv") 
  
  df <- df[grepl("blodtryck", df$Sjukdomar.och.besvär),]
  
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
    geom_line(linewidth=1.5)+ geom_point(size=2)+facet_wrap(~Sjukdomar.och.besvär, ncol=2)+
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
         title = str_wrap("Andel med högt blodtryck – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         y = "Andel (%)",
         color="",
         fill="",
         subtitle = str_wrap("Streckade linjer är Riksandelen", width = 50))+
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'),
          axis.text.x = element_text(angle = -45, hjust=0))
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/blodtryck.svg"),
    plot = p,
    width = 8,
    height = 7
  )
  
  ggsave(
    paste0("Figurer/blodtryck.png"),
    plot = p,
    width = 8,
    height = 7,
    dpi = 96
  )
  
  
  
}

allergi <- function(){
  # Läser in data
  df <- read.csv("Data/df_sjukdomar_besvar.csv") 
  
  df <- df[grepl("allergi", df$Sjukdomar.och.besvär),]
  
  df$Sjukdomar.och.besvär <- ifelse(df$Sjukdomar.och.besvär=="Besvär av allergi", "Besvär", "Svåra besvär")
  
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
    geom_line(linewidth=1.5)+ geom_point(size=2)+facet_wrap(~Sjukdomar.och.besvär, ncol=2)+
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
         title = str_wrap("Andel med allergibesvär – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/allergi.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/allergi.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
  
}

astma <- function(){
  # Läser in data
  df <- read.csv("Data/df_sjukdomar_besvar.csv") 
  
  df <- df[grepl("astma", df$Sjukdomar.och.besvär),]
  
  df$Sjukdomar.och.besvär <- ifelse(df$Sjukdomar.och.besvär=="Besvär av astma", "Besvär", "Svåra besvär")
  
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
    geom_line(linewidth=1.5)+ geom_point(size=2)+facet_wrap(~Sjukdomar.och.besvär, ncol=2)+
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
         title = str_wrap("Andel med astmabesvär – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/astma.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/astma.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
  
}

huvudvark_tinnitus <- function(){
  # Läser in data
  df <- read.csv("Data/df_sjukdomar_besvar.csv") %>% 
    filter(Sjukdomar.och.besvär %in% c("Huvudvärk","Svår huvudvärk" ,
                                       "Tinnitus" ,"Svåra besvär av tinnitus" ,
                                       "Yrsel" , "Svåra besvär av yrsel"))
  
  
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  titles  <- unique(df$Sjukdomar.och.besvär)
  
  for(t in titles){
    # filtrerar ut variabeln
    temp <- df %>% filter(Sjukdomar.och.besvär == t, !is.na(Andel), 
                          Region == "Uppsala län")
    temp_r <-  df_rik%>% filter(Sjukdomar.och.besvär == t)
    
    # Tar ut år för matchning
    year <- temp$År
    
    temp_r <- temp_r %>% filter(År %in% year)
    
    # Visa vart 5:e år på x-axeln
    ara <- unique(temp$År)
    visa_ar <- ara[seq(1, length(ara), by = 1)]
    
    # Om det är väldigt låga värden
    y_limits <- ifelse(max(temp$Andel) < 5,10,100 )
    
    # skapa plot 
    p <- ggplot(temp, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
      geom_line(linewidth=1.5)+ geom_point(size=2)+
      geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3, color =NA) +
      # Riket – streckad linje
      geom_line(data = temp_r, aes(x = År, y = Andel, group = Kön, color = Kön),
                linewidth = 1, linetype = "dashed") +
      scale_color_manual(values = kon_col)+
      scale_fill_manual(values = kon_col)+
      scale_y_continuous(breaks = seq(0,y_limits,by=10),
                         limits = c(0,y_limits))+
      scale_x_discrete(breaks = visa_ar) +
      labs(x="",
           title = str_wrap(paste("Andel med", str_to_lower(t), "– Uppsala län (4-årsmedelvärden)"), width=50),
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
      paste0("Figurer/",str_to_lower(t),".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/",str_to_lower(t),".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
    
  }
  
}