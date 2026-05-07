alkohol <- function(){
  # Läser in data
  df <- read.csv("Data/df_alkohol.csv") 
  
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
    geom_line(linewidth=1.5)+ geom_point(size=2)+
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
         title = str_wrap("Andel riskkonsumenter av alkohol – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/alkohol.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/alkohol.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
  
}

frukt_gront <- function(){
  # Läser in data
  df <- read.csv("Data/df_frukt_gront.csv") %>% 
    filter(Frukt.och.grönt %in% c("Frukt och bär minst 2 gånger/dag" ,
                                  "Grönsaker och rotfrukter minst 2 gånger/dag"))
  
  cols <- c( "#F9B000" , "#019CD7" )
  
  names(cols) <- unique(df$Frukt.och.grönt)
  
  # Graf per region
  for(r in unique(df$Region)){
    
    temp <- df %>% filter(Region == r)
    
    # om tidsserien är tillräkligt lång
    ara <- unique(temp$År)
    visa_ar <- if(length(ara)> 6)ara[seq(1, length(ara), by = 3)]else ara
    
    # skapa plot 
    p <- ggplot(temp, aes(x=År, y =Andel, color = Frukt.och.grönt, group=Frukt.och.grönt, fill=Frukt.och.grönt))+
      geom_line(linewidth=1.5 )+facet_wrap(~Kön, ncol=2)+
      geom_point(size=2)+
      geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3) +
      scale_color_manual(values = cols)+
      scale_fill_manual(values = cols)+
      scale_y_continuous(breaks = seq(0,100,by=10),
                         limits = c(0,100))+
      scale_x_discrete(breaks = visa_ar) +
      labs(x="",
           title = str_wrap(paste("Andel som äter frukt och grönt minst 2 gånger/dag –", r), width=50),
           caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
           y = "Andel (%)",
           color="",
           fill="")+
      theme(plot.caption = element_text(hjust=0),
            axis.text.x = element_text(angle =45, hjust=1),
            legend.position = "bottom")+ 
      guides(color = guide_legend(nrow = 2))
    
    
    p
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/frukt_gront_",r,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/frukt_gront_",r,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
  }
  
  
}

rokning <- function(){
  # Läser in data
  df <- read.csv("Data/df_rokning.csv") %>% 
    filter(Tobakskonsumtion == "Röker tobak dagligen")
  
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
    geom_line(linewidth=1.5)+ geom_point(size=2)+
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
         title = str_wrap("Andel dagligrökare – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/rokning.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/rokning.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
  
}

snus <- function(){
  # Läser in data
  df <- read.csv("Data/df_rokning.csv") %>% 
    filter(Tobakskonsumtion == "Snusar dagligen")
  
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
    geom_line(linewidth=1.5)+ geom_point(size=2)+
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
         title = str_wrap("Andel dagligsnusare – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/snus.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/snus.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
  
}

dryck <- function(){
  # Läser in data
  df <- read.csv("Data/df_dryck.csv") 
  
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
  # Visa vart 5:e år på x-axeln
  ara <- unique(df$År)
  visa_ar <- ara[seq(1, length(ara), by = 1)]
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
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
         title = str_wrap("Andel som dricker sötad dryck minst 2 gånger/vecka – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/dryck.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/dryck.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
  
}

spel <- function(){
  # Läser in data
  df <- read.csv("Data/df_spel.csv") 
  
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
  # Visa vart 5:e år på x-axeln
  ara <- unique(df$År)
  visa_ar <- ara[seq(1, length(ara), by = 1)]
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3, color =NA) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Andel, group = Kön, color = Kön),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,20,by=10),
                       limits = c(0,20))+
    scale_x_discrete(breaks = visa_ar) +
    
    labs(x="",
         title = str_wrap("Andel med riskabelt spelande – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/spel.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/spel.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
  
}


narkotika <- function(){
  # Läser in data
  df <- read.csv("Data/df_narkotika.csv") 
  
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
  # Visa vart 5:e år på x-axeln
  ara <- unique(df$År)
  visa_ar <- ara[seq(1, length(ara), by = 2)]
  
  # Färgschema
  kon_col <- c("#019CD7",
               "#E67E22")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Frekvens, color =Frekvens, fill=Frekvens))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+facet_wrap(~Kön)+
    geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3, color =NA) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Andel, group = Frekvens, color = Frekvens),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = visa_ar) +
    
    labs(x="",
         title = str_wrap("Narkotikabruk per frekvens och kön – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/narkotika.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/narkotika.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
  
}

cannabis <- function(){
  # Läser in data
  df <- read.csv("Data/df_cannabis.csv") 
  
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
  kon_col <- c("#019CD7",
               "#E67E22")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Använt.cannabis, color =Använt.cannabis, fill=Använt.cannabis))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+facet_wrap(~Kön)+
    geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3, color =NA) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Andel, group = Använt.cannabis, color = Använt.cannabis),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = visa_ar) +
    
    labs(x="",
         title = str_wrap("Cannabisbruk per frekvens och kön – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/cannabis.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/cannabis.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
  
}