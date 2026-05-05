

####### Beläggning #######

belagg_tid_tot <- function(){
  # Hämtar data
  df <- read.csv("Data/df_belagning.csv")
  # grupperar per kommun och månad
  df <- df %>% filter(AR <= (max(AR))-1, !(KOMMUN_NAMN == "Sekretesskyddad" & NIVA_NAMN == "Kommun")) %>% 
    group_by(AR,KOMMUN_NAMN) %>% summarize(DISPONIBLA_BADDAR = sum(DISPONIBLA_BADDAR),
                                           BELAGDA_BADDAR = sum(BELAGDA_BADDAR),
                                           DISPONIBLA_RUM = sum(DISPONIBLA_RUM),
                                           BELAGDA_RUM = sum(BELAGDA_RUM),.groups='drop')
  # Byter namn till län
  df <- df %>%
    mutate(
      KOMMUN_NAMN = ifelse(KOMMUN_NAMN == "Sekretesskyddad" ,
                           "Uppsala län", KOMMUN_NAMN),
      Belaggning_badd_pct = BELAGDA_BADDAR / DISPONIBLA_BADDAR * 100,
      Belaggning_rum_pct  = BELAGDA_RUM / DISPONIBLA_RUM * 100) 
  
  
  df <- df %>%
    pivot_longer(
      cols = c(Belaggning_rum_pct, Belaggning_badd_pct),
      names_to = "metric",
      values_to = "value"
    ) %>%
    mutate(
      metric = recode(metric,
                      Belaggning_rum_pct = "Rum",
                      Belaggning_badd_pct = "Bädd")
    )
  
  # Loopar över kommunerna
  for (r in unique(df$KOMMUN_NAMN)) {
    
    # Filter
    temp <- df %>%
      filter(KOMMUN_NAMN == r) %>%
      arrange(AR)
    
    # Om det är för få obs
    if (n_distinct(temp$AR) < 2) next
    
    # filtrerar och beräknar förändring
    temp <- temp %>% group_by(metric) %>% 
      mutate(
        Forandring_pct = (value - lag(value)) / lag(value) * 100,
        Forandring_label = case_when(
          is.na(Forandring_pct) ~ "",
          Forandring_pct > 0    ~ paste0("+", round(Forandring_pct, 1), "%"),
          TRUE                  ~ paste0(round(Forandring_pct, 1), "%")
        )
      )
    
    p <- ggplot(temp, aes(x = AR, y = value, color = metric, group = metric)) +
      geom_line(linewidth = 2) +
      geom_point(size = 3) +
      geom_text(aes(label = Forandring_label),
                vjust = -1, size = 3.5, color = "black") +
      scale_y_continuous(labels = label_number(suffix = "%"), limits = c(0, 100)) +
      scale_x_continuous(breaks = unique(temp$AR)) +
      scale_color_manual(values = c("Rum" = "#D57667", "Bädd" = "#019CD7")) +
      labs(
        title = paste("Beläggning i", r),
        x = "",
        y = "Beläggning (%)",
        color = "",
        caption = "Källa: Tillväxtverket"
      ) +
      theme(
        legend.position = "bottom",
        axis.text.x = element_text(angle = 45),
        plot.caption = element_text(hjust = 0)
      )
    
    p
    # Sparar plots
    ggsave(
      paste0("Figurer/belagg_tid_tot_", r, ".svg"),
      plot = p, width = 8, height = 5
    )
    
    ggsave(
      paste0("Figurer/belagg_tid_tot_", r, ".png"),
      plot = p, width = 8, height = 5, dpi = 96
    )
  }
}


belagg_tid <- function(){
  
  # Hämtar data
  df <- read.csv("Data/df_belagning.csv")
  # grupperar per kommun och månad
  df <- df %>% filter(AR <= (max(AR))-1, !(KOMMUN_NAMN == "Sekretesskyddad" & NIVA_NAMN == "Kommun")) %>% 
    group_by(AR,DAGTYP_NAMN,KOMMUN_NAMN, ANLAGGNINGSTYP_NAMN) %>% summarize(DISPONIBLA_BADDAR = sum(DISPONIBLA_BADDAR),
                                                                            BELAGDA_BADDAR = sum(BELAGDA_BADDAR),
                                                                            DISPONIBLA_RUM = sum(DISPONIBLA_RUM),
                                                                            BELAGDA_RUM = sum(BELAGDA_RUM),.groups='drop')
  # Byter namn till län
  df <- df %>%
    mutate(
      KOMMUN_NAMN = ifelse(KOMMUN_NAMN == "Sekretesskyddad" ,
                           "Uppsala län", KOMMUN_NAMN),
      Belaggning_badd_pct = BELAGDA_BADDAR / DISPONIBLA_BADDAR * 100,
      Belaggning_rum_pct  = BELAGDA_RUM / DISPONIBLA_RUM * 100) 
  
  colmap <- c("Sekretesskyddad" ="#B81867" ,
              "Hotell" = "#D57667",
              "Camping" = "#4AA271"  , 
              "Vandrarhem" = "#019CD7" )
  
  # Loopar över varje kommun
  for (r in unique(df$KOMMUN_NAMN)) {
    
    temp <- df %>%
      filter(KOMMUN_NAMN == r) %>%
      arrange(AR)
    
    if (n_distinct(temp$AR) < 2) next
    for (metric in c("Belaggning_rum_pct", "Belaggning_badd_pct")) {
      
      titel <- ifelse(metric == "Belaggning_rum_pct",
                      "Rumsbeläggning per år",
                      "Bäddbeläggning per år")
      
      filnamn <- ifelse(metric == "Belaggning_rum_pct",
                        "rum",
                        "badd")
      
      p <- ggplot(
        temp,
        aes(
          x = factor(AR),
          y = .data[[metric]],
          color = ANLAGGNINGSTYP_NAMN,
          linetype = DAGTYP_NAMN,
          group = interaction(ANLAGGNINGSTYP_NAMN, DAGTYP_NAMN)
        )
      ) +
        geom_line(linewidth = 1.5) +
        geom_point(size = 2) +
        scale_color_manual(values = colmap) +
        scale_y_continuous(labels = label_number(suffix = "%"),
                           limits = c(0, 100)) +
        labs(
          title = paste(titel, "i", r),
          x = "",
          y = "Beläggning (%)",
          color = "",
          linetype = "",
          caption = "Källa: Tillväxtverket"
        ) +
        theme(
          legend.position = "bottom",
          axis.text.x = element_text(angle = 45),
          plot.caption = element_text(hjust = 0)
        )
      
      ggsave(paste0("Figurer/belagg_tid_", filnamn, "_", r, ".svg"),
             plot = p, width = 8, height = 5)
      ggsave(paste0("Figurer/belagg_tid_", filnamn, "_", r, ".png"),
             plot = p, width = 8, height = 5, dpi = 96)
    }
  }
}
