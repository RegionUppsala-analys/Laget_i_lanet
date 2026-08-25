alkohol <- function(){
  # Läser in data
  df <- read.csv("Data/df_alkohol.csv") 
  
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
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
    scale_x_discrete(breaks = c(min(df$År), max(df$År))) +
    
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

  df <- read.csv("Data/df_frukt_gront.csv") %>%
    filter(
      Frukt.och.grönt %in% c(
        "Frukt och bär minst 2 gånger/dag",
        "Grönsaker och rotfrukter minst 2 gånger/dag"
      )
    )

  cols <- c("#F9B000", "#019CD7")
  names(cols) <- unique(df$Frukt.och.grönt)

  # Referensregion
  df_uppsala <- df %>%
    filter(Region == "Uppsala län")

  for(r in unique(df$Region)){

    if(r == "Uppsala län") next

    df_jmf <- df %>%
      filter(Region == r)

    gemensamma_ar <- intersect(
      unique(df_uppsala$År),
      unique(df_jmf$År)
    )

    upp <- df_uppsala %>%
      filter(År %in% gemensamma_ar)

    jmf <- df_jmf %>%
      filter(År %in% gemensamma_ar)

    p <- ggplot() +

      # Uppsala län
      geom_ribbon(
        data = upp,
        aes(
          x = År,
          ymin = Konfidensintervall.nedre.gräns,
          ymax = Konfidensintervall.övre.gräns,
          fill = Frukt.och.grönt,
          group = Frukt.och.grönt
        ),
        alpha = 0.3,
        colour = NA
      ) +

      geom_line(
        data = upp,
        aes(
          x = År,
          y = Andel,
          colour = Frukt.och.grönt,
          group = Frukt.och.grönt
        ),
        linewidth = 1.5
      ) +

      geom_point(
        data = upp,
        aes(
          x = År,
          y = Andel,
          colour = Frukt.och.grönt
        ),
        size = 2
      ) +

      # Jämförelseregion
      geom_line(
        data = jmf,
        aes(
          x = År,
          y = Andel,
          colour = Frukt.och.grönt,
          group = Frukt.och.grönt
        ),
        linewidth = 1.2,
        linetype = "dashed"
      ) +

      facet_wrap(~Kön, ncol = 2) +

      scale_color_manual(values = cols) +
      scale_fill_manual(values = cols) +

      scale_y_continuous(
        breaks = seq(0, 100, by = 10),
        limits = c(0, 100)
      ) +

      scale_x_discrete(breaks = c(min(gemensamma_ar), max(gemensamma_ar))) +

      labs(
        x = "",
        title = str_wrap(
          paste(
            "Andel som äter frukt och grönt minst 2 gånger/dag – Uppsala län jämfört med",
            r
          ),
          width = 50
        ),
        subtitle = paste("Streckade linjer visar", r),
        caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
        y = "Andel (%)",
        colour = "",
        fill = ""
      ) +

      theme(
        plot.caption = element_text(hjust = 0),
        plot.subtitle = element_text(
          hjust = 0.5,
          colour = "#B81867",
          face = "bold"
        ),
        axis.text.x = element_text(
          angle = 45,
          hjust = 1
        ),
        legend.position = "bottom"
      ) +

      guides(colour = guide_legend(nrow = 2))

    ggsave(
      paste0("Figurer/frukt_gront_", r, ".svg"),
      plot = p,
      width = 8,
      height = 6
    )

    ggsave(
      paste0("Figurer/frukt_gront_", r, ".png"),
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
    scale_x_discrete(breaks = c(min(df$År), max(df$År))) +
    
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
    scale_x_discrete(breaks = c(min(df$År), max(df$År))) +
    
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
    scale_x_discrete(breaks = c(min(df$År), max(df$År))) +
    
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
    scale_x_discrete(breaks = c(min(df$År), max(df$År))) +
    
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