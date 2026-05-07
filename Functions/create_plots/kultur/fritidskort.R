############# Fritidskort #############


fritidskort_kommun <- function(year = 2025){
  # Läser in data
  df <- read.csv(paste0("Data/fritidskort_",year,".csv"))
  
  # Beräknar kvoten
  df <- df %>% mutate(kvot = Antal_anvanda_fritidskort/Antal_beviljade_fritidskort)
  
  # tar ut kommunerna i länet
  df_lan <- df %>% filter(Kommun %in% kommuner)
  
  # Snygga namn per kolumn: titel och y-axeltext
  kolumn_info <- list(
    Antal_beviljade_fritidskort = list(
      titel = paste("Antal beviljade fritidskort per kommun år", year),
      y_axel = "Antal"
    ),
    Antal_anvanda_fritidskort = list(
      titel = paste("Antal använda fritidskort per kommun år", year),
      y_axel = "Antal"
    ),
    kvot = list(
      titel = paste("Andel använda av beviljade fritidskort per kommun år", year),
      y_axel = "Andel (%)"
    )
  )
  
  # Loopa över numeriska kolumner
  num_kol <- df_lan %>% select(where(is.numeric)) %>% colnames()
  
  for (c in num_kol) {
    
    # median och kvartiler
    rikssnitt <- median(df[[c]], na.rm = TRUE)
    kvantiler <- quantile(df[[c]],probs = c(0.25,0.75), na.rm = TRUE)
    
    
    # Hämta snygg titel och y-axel, fall tillbaka på kolumnnamnet om det saknas
    info   <- kolumn_info[[c]]
    titel  <- if (!is.null(info)) info$titel  else paste(c, year)
    y_axel <- if (!is.null(info)) info$y_axel else c
    
    p <- ggplot(df_lan, aes(x = sort(Kommun), y = .data[[c]])) +
      geom_col(fill = "#B81867") +
      geom_hline(aes(yintercept = rikssnitt, linetype = "Median"),
                 color = "black", linewidth = 0.8) +
      geom_hline(aes(yintercept = kvantiler[1], linetype = "Nedre kvartil"),
                 color = "black", linewidth = 0.6) +
      geom_hline(aes(yintercept = kvantiler[2], linetype = "Övre kvartil"),
                 color = "black", linewidth = 0.6) +
      scale_linetype_manual(
        values = c("dashed", "dotdash", "dotdash"),  # tre värden, en för varje linje
        name = NULL,
        labels = c("Median", "Nedre kvartil", "Övre kvartil")
      ) +
      labs(
        title   = str_wrap(titel, width=50),
        x       = NULL,
        y       = y_axel,
        caption = paste("Källa: E-hälsomyndigheten")
      ) +
      theme(
        axis.text.x  = element_text(angle = 45, hjust = 1),
        plot.caption = element_text(hjust=0),
        legend.position = "bottom"
      )
    
    p
    
    ggsave(
      paste0("Figurer/fritidskort_kommun_", c, ".svg"),
      plot   = p,
      width  = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/fritidskort_kommun_", c, ".png"),
      plot   = p,
      width  = 8,
      height = 6,
      dpi    = 96
    )
    
    message("Sparad graf: ", c)
  }
  
  
}

fritidskort_lan <- function(year = 2025) {
  
  #Hämta data
  df <- read.csv(paste0("Data/Fritidskortet_foreningar_", year, ".csv"))
  
  #  BERÄKNAR KVOTEN "FRITIDSKORT PER FÖRENING"
  
  df <- df %>%
    mutate(kort_per_forening = antal_nedladdade_fritidskort / antal_foreningar)
  
  #  FILTRERAR FRAM UPPSALA LÄN
  df_lan <- df %>% filter(lan == "Uppsala") %>% mutate(lan = "Uppsala län")
  
  #  BERÄKNAR RIKSSTATISTIK FRÅN HELA DATASETET
  rikssnitt <- median(df$kort_per_forening, na.rm = TRUE)
  kvantiler <- quantile(df$kort_per_forening, probs = c(0.25, 0.75), na.rm = TRUE)
  
  
  #  BYGGER DIAGRAMMET
  p <- ggplot(df_lan, aes(x = lan, y = kort_per_forening)) +
    
    # Uppsala-stapeln
    geom_col(fill = "#B81867", width = 0.4) +
    
    # Riksmedian
    geom_hline(aes(yintercept = rikssnitt,    linetype = "Median"),
               color = "black", linewidth = 0.8) +
    
    # Nedre kvartil (Q1 – 25 %)
    geom_hline(aes(yintercept = kvantiler[1], linetype = "Nedre kvartil"),
               color = "black", linewidth = 0.6) +
    
    # Övre kvartil (Q3 – 75 %)
    geom_hline(aes(yintercept = kvantiler[2], linetype = "Övre kvartil"),
               color = "black", linewidth = 0.6) +
    
    # Linjetyp-legend: tre distinkta mönster för tydlig differentiering
    scale_linetype_manual(
      values = c("Median"             = "solid",
                 "Nedre kvartil" = "dashed",
                 "Övre kvartil"  = "dotdash"),
      name   = NULL
    ) +
    
    labs(
      title  = str_wrap(paste("Fritidskort per förening - Uppsala vs rikskvartiler år", year), width=50),
      y = "Fritidskort per förening",
      x       = "",
      caption = paste0(
        "Källa: Regeringen.se\n",
        "https://www.regeringen.se/pressmeddelanden/2025/12/",
        "forsta-hosten-med-fritidskortet--sa-har-det-gatt/\n",
        "Referenslinjer baserade på riksfördelningen"
      )
    ) +
    theme(
      plot.caption    = element_text(hjust = 0),
      legend.position = "bottom"
    )
  
  p
  # SPARAR DIAGRAMMET SOM SVG OCH PNG
  ggsave(
    filename = paste0("Figurer/fritidskort_lan.svg"),
    plot     = p,
    width    = 8,
    height   = 6
  )
  
  ggsave(
    filename = paste0("Figurer/fritidskort_lan.png"),
    plot     = p,
    width    = 8,
    height   = 6,
    dpi      = 96
  )
  
  message("Sparad graf: ", c)
  
  write.csv(df_lan, file = "Data/fritidskort_uppsala.csv", row.names = FALSE, fileEncoding = "UTF-8")
  
}

