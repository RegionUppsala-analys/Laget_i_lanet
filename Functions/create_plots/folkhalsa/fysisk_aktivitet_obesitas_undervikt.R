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

  # etikettdata
  etiketter <- df %>%
  group_by(Kön) %>%
  filter(År == max(År)) %>%
  ungroup()
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3, color =NA) +
    geom_text_repel(
      data = etiketter,
      aes(label = round(Andel, 1)),
      direction = "y",
      nudge_x = 0.3,
      hjust = 0,
      segment.color = NA,
      show.legend = FALSE
      ) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Andel, group = Kön, color = Kön),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(
      breaks = visa_ar,
      expand = expansion(mult = c(0.02, 0.10))
    ) +
    
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

  df <- na.omit(read.csv("Data/df_stillasittande.csv"))

  cols <- c("#F9B000", "#019CD7", "#4AA271", "#D57667")
  names(cols) <- unique(df$Stillasittande)
  stillasittande_levels = c("Sitter högst 3 timmar/dygn",
             "Sitter 4-6 timmar/dygn",
             "Sitter 7-9 timmar/dygn",
             "Sitter minst 10 timmar/dygn")
  df$Stillasittande <- factor(
    df$Stillasittande, levels = stillasittande_levels
  )

  # Uppsala län används som referens i alla figurer
  df_uppsala <- df %>%
    filter(Region == "Uppsala län")

  for(r in unique(df$Region)){

    # Hoppa över Uppsala län mot sig själv
    if(r == "Uppsala län") next

    df_jmf <- df %>%
      filter(Region == r)

    # Matcha år så att båda serierna har samma tidsperiod
    gemensamma_ar <- intersect(
      unique(df_uppsala$År),
      unique(df_jmf$År)
    )

    upp <- df_uppsala %>%
      filter(År %in% gemensamma_ar)

    jmf <- df_jmf %>%
      filter(År %in% gemensamma_ar)

    etiketter <- upp %>%
      group_by(Kön, Stillasittande) %>%
      filter(År == max(År)) %>%
      ungroup()

    visa_ar <- gemensamma_ar

    p <- ggplot() +

      # Uppsala län
      geom_ribbon(
        data = upp,
        aes(
          x = År,
          ymin = Konfidensintervall.nedre.gräns,
          ymax = Konfidensintervall.övre.gräns,
          fill = Stillasittande,
          group = Stillasittande
        ),
        alpha = 0.3,
        colour = NA
      ) +
      geom_line(
        data = upp,
        aes(
          x = År,
          y = Andel,
          colour = Stillasittande,
          group = Stillasittande
        ),
        linewidth = 1.5
      ) +
      geom_point(
        data = upp,
        aes(
          x = År,
          y = Andel,
          colour = Stillasittande
        ),
        size = 2
      ) +
      geom_text_repel(
        data = etiketter,
        aes(
          x = År,
          y = Andel,
          label = round(Andel, 1),
          color = Stillasittande
        ),
        direction = "y",
        nudge_x = 0.5,
        hjust = 0,
        segment.color = NA,
        fontface = "bold",
        show.legend = FALSE
      ) +

      # Jämförelseregion
      geom_line(
        data = jmf,
        aes(
          x = År,
          y = Andel,
          colour = Stillasittande,
          group = Stillasittande
        ),
        linewidth = 1.2,
        linetype = "dashed"
      ) +

      facet_wrap(~Kön, ncol = 2) +

      scale_color_manual(values = cols) +
      scale_fill_manual(values = cols) +

      scale_y_continuous(
        breaks = seq(0, 50, by = 5),
        limits = c(0, 50)
      ) +

      scale_x_discrete(
        breaks = visa_ar,
        expand = expansion(mult = c(0.02, 0.10))
      ) +

      labs(
        x = "",
        title = str_wrap(
          paste("Fördelning av stillasittande tid per grupp – Uppsala län jämfört med", r),
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
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom"
      ) +

      guides(colour = guide_legend(nrow = 2))

    ggsave(
      paste0("Figurer/stillasittande_", r, ".svg"),
      plot = p,
      width = 8,
      height = 6
    )

    ggsave(
      paste0("Figurer/stillasittande_", r, ".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
  }
}


obesitas <- function(){

  df <- read.csv("Data/df_obesitas.csv") %>%
    filter(
      Viktstatus..BMI. %in% c(
        "Övervikt (BMI 25,0 - 29,9)",
        "Obesitas (BMI 30,0 eller högre)",
        "Undervikt (BMI 18,4 eller lägre)",
        "Normalvikt (BMI 18,5-24,9)"
      )
    )

  cols <- c(
    "#D57667",
    "#4AA271",
    "#F9B000",
    "#019CD7"
  )

  names(cols) <- unique(df$Viktstatus..BMI.)

    bmi_levels <- c(
    "Undervikt (BMI 18,4 eller lägre)",
    "Normalvikt (BMI 18,5-24,9)",
    "Övervikt (BMI 25,0 - 29,9)",
    "Obesitas (BMI 30,0 eller högre)"
  )

  df$Viktstatus..BMI. <- factor(
    df$Viktstatus..BMI.,
    levels = bmi_levels
  )

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

    etiketter <- upp %>%
      group_by(Kön, Viktstatus..BMI.) %>%
      filter(År == max(År)) %>%
      ungroup()

    p <- ggplot() +

      # Uppsala län
      geom_ribbon(
        data = upp,
        aes(
          x = År,
          ymin = Konfidensintervall.nedre.gräns,
          ymax = Konfidensintervall.övre.gräns,
          fill = Viktstatus..BMI.,
          group = Viktstatus..BMI.
        ),
        alpha = 0.3,
        colour = NA
      ) +

      geom_line(
        data = upp,
        aes(
          x = År,
          y = Andel,
          colour = Viktstatus..BMI.,
          group = Viktstatus..BMI.
        ),
        linewidth = 1.5
      ) +

      geom_point(
        data = upp,
        aes(
          x = År,
          y = Andel,
          colour = Viktstatus..BMI.
        ),
        size = 2
      ) +

      geom_text_repel(
        data = etiketter,
        aes(
          x = År,
          y = Andel,
          label = round(Andel, 1),
          color = Viktstatus..BMI.
        ),
        direction = "y",
        nudge_x = 2,
        hjust = 0,
        segment.color = NA,
        fontface = "bold",
        show.legend = FALSE
      ) +

      # Jämförelseregion
      geom_line(
        data = jmf,
        aes(
          x = År,
          y = Andel,
          colour = Viktstatus..BMI.,
          group = Viktstatus..BMI.
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

      scale_x_discrete(
        breaks = c(min(gemensamma_ar), max(gemensamma_ar)),
        expand = expansion(mult = c(0.02, 0.10))
      ) +

      labs(
        x = "",
        title = str_wrap(
          paste(
            "Fördelning av viktstatus (BMI) – Uppsala län jämfört med",
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
      paste0("Figurer/obesitas_", r, ".svg"),
      plot = p,
      width = 8,
      height = 6
    )

    ggsave(
      paste0("Figurer/obesitas_", r, ".png"),
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
    
    # om tidsserien är tillräckligt lång
    ara <- unique(temp$År)
    visa_ar <- if(length(ara)> 6)ara[seq(1, length(ara), by = 3)]else ara

    etiketter <- temp %>%
      group_by(Kön, Viktstatus..BMI.) %>%
      filter(År == max(År)) %>%
      ungroup()
    
    # skapa plot 
    p <- ggplot(temp, aes(x=År, y =Andel, color = Viktstatus..BMI., group=Viktstatus..BMI., fill=Viktstatus..BMI.))+
      geom_line(linewidth=1.5 )+facet_wrap(~Kön, ncol=2)+
      geom_point(size=2)+
      geom_ribbon(aes(ymin = `Konfidensintervall.nedre.gräns`, ymax = `Konfidensintervall.övre.gräns`), alpha = 0.3) +
      geom_text_repel(
        data = etiketter,
        aes(label = round(Andel, 1)),
        direction = "y",
        nudge_x = 0.3,
        hjust = 0,
        segment.color = NA,
        show.legend = FALSE
      ) +
      scale_color_manual(values = cols)+
      scale_fill_manual(values = cols)+
      scale_y_continuous(breaks = seq(0,10,by=1),
                         limits = c(0,10))+
      scale_x_discrete(
        breaks = visa_ar,
        expand = expansion(mult = c(0.02, 0.10))
      ) +
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