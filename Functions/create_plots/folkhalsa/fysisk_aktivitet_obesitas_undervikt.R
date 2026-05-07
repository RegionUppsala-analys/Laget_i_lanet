fysisk_aktivitet <- function(){
  # Hämta data
  df <- na.omit(read.csv("Data/df_fysisk_aktivitet.csv")) %>% 
    filter(Fysisk.aktivitet == "Aktiv minst 150 min/vecka")
  
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
         title = str_wrap("Andel fysiskt aktiva i minst 150 min/vecka – Uppsala län (4-årsmedelvärden)", width=50),
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
    paste0("Figurer/fysisk_aktivitet.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/fysisk_aktivitet.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
}


stillasittande <- function(){
  # Hämta data
  df <- na.omit(read.csv("Data/df_stillasittande.csv"))
  
  cols <- c("#F9B000" ,"#019CD7","#4AA271","#D57667" )
  
  names(cols) <- unique(df$Stillasittande)
  
  # Graf per region
  for(r in unique(df$Region)){
    
    temp <- df %>% filter(Region == r)
    
    # om tidsserien är tillräkligt lång
    ara <- unique(temp$År)
    visa_ar <- if(length(ara)> 6)ara[seq(1, length(ara), by = 2)]else ara
    
    # skapa plot 
    p <- ggplot(temp, aes(x=År, y =Andel, color = Stillasittande, group=Stillasittande, fill=Stillasittande))+
      geom_line(linewidth=1.5 )+facet_wrap(~Kön, ncol=2)+
      geom_point(size=2)+
      geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3) +
      scale_color_manual(values = cols)+
      scale_fill_manual(values = cols)+
      scale_y_continuous(breaks = seq(0,50,by=5),
                         limits = c(0,50))+
      scale_x_discrete(breaks = visa_ar) +
      labs(x="",
           title = str_wrap(paste("Fördelning av stillasittande tid per grupp –", r), width=50),
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
      paste0("Figurer/stillasittande_",r,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/stillasittande_",r,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
  }
  
  
}


obesitas <- function(){
  # Läser in data
  df <- read.csv("Data/df_obesitas.csv") %>% 
    filter(Viktstatus..BMI. %in% c("Övervikt (BMI 25,0 - 29,9)","Obesitas (BMI 30,0 eller högre)",
                                   "Undervikt (BMI 18,4 eller lägre)" ,"Normalvikt (BMI 18,5-24,9)"    ))
  
  cols <- c("#D57667" ,"#4AA271" , "#F9B000" , "#019CD7" ,
            "#8B4A9C" , "#E67E22"  )
  
  names(cols) <- unique(df$Viktstatus..BMI.)
  
  # Graf per region
  for(r in unique(df$Region)){
    
    temp <- df %>% filter(Region == r)
    
    # om tidsserien är tillräkligt lång
    ara <- unique(temp$År)
    visa_ar <- if(length(ara)> 6)ara[seq(1, length(ara), by = 3)]else ara
    
    # skapa plot 
    p <- ggplot(temp, aes(x=År, y =Andel, color = Viktstatus..BMI., group=Viktstatus..BMI., fill=Viktstatus..BMI.))+
      geom_line(linewidth=1.5 )+facet_wrap(~Kön, ncol=2)+
      geom_point(size=2)+
      geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3) +
      scale_color_manual(values = cols)+
      scale_fill_manual(values = cols)+
      scale_y_continuous(breaks = seq(0,100,by=10),
                         limits = c(0,100))+
      scale_x_discrete(breaks = visa_ar) +
      labs(x="",
           title = str_wrap(paste("Fördelning av viktstatus (BMI) –", r), width=50),
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
      paste0("Figurer/obesitas_",r,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/obesitas_",r,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
  }
  
  
}

undervikt <- function(){
  # Läser in data
  df <- read.csv("Data/df_obesitas.csv") %>% 
    filter(Viktstatus..BMI. %in% c("Undervikt (BMI 18,4 eller lägre)" ))
  
  cols <- c("#D57667" ,"#4AA271" , "#F9B000" , "#019CD7" ,
            "#8B4A9C" , "#E67E22"  )
  
  names(cols) <- unique(df$Viktstatus..BMI.)
  
  # Graf per region
  for(r in unique(df$Region)){
    
    temp <- df %>% filter(Region == r)
    
    # om tidsserien är tillräkligt lång
    ara <- unique(temp$År)
    visa_ar <- if(length(ara)> 6)ara[seq(1, length(ara), by = 3)]else ara
    
    # skapa plot 
    p <- ggplot(temp, aes(x=År, y =Andel, color = Viktstatus..BMI., group=Viktstatus..BMI., fill=Viktstatus..BMI.))+
      geom_line(linewidth=1.5 )+facet_wrap(~Kön, ncol=2)+
      geom_point(size=2)+
      geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3) +
      scale_color_manual(values = cols)+
      scale_fill_manual(values = cols)+
      scale_y_continuous(breaks = seq(0,10,by=1),
                         limits = c(0,10))+
      scale_x_discrete(breaks = visa_ar) +
      labs(x="",
           title = str_wrap(paste("Andel underviktiga (BMI < 18,5) –", r), width=50),
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
      paste0("Figurer/undervikt_",r,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/undervikt_",r,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
  }
  
  
}