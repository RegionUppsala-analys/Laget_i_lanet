##### logiintäkter #######

logi_tid_tot <- function(){
  # Hämtar data
  df <- read.csv("Data/df_logii.csv")
  
  # grupperar per kommun och månad
  df <- df %>% filter(AR <= (max(AR))-1,!(KOMMUN_NAMN == "Sekretesskyddad" & NIVA_NAMN == "Kommun")) %>% 
    group_by(AR,KOMMUN_NAMN) %>% summarize(intakt = sum(LOGIINTAKT), .groups='drop')
  
  ar <- unique(df$AR)
  
  df <- df %>%
    mutate(
      KOMMUN_NAMN = ifelse(KOMMUN_NAMN == "Sekretesskyddad" ,
                           "Uppsala län", KOMMUN_NAMN))
  
  # Tar in befolkningsdata
  df_befolk <- read.csv("Data/df_folkm_kom.csv") %>% filter(år %in% ar) 
  
  df <- df %>% left_join(df_befolk, by = c('KOMMUN_NAMN'='region',
                                           'AR' = 'år'))
  
  if (any(is.na(df$Folkmängd))) {
    warning("Join misslyckades för: ",
            paste(unique(df$KOMMUN_NAMN[is.na(df$Folkmängd)]), collapse = ", "))
  }
  # per invånare
  df <- df %>% mutate(per_inv = intakt/Folkmängd)
  
  # Loopar över varje kommun
  for (r in unique(df$KOMMUN_NAMN)) {
    
    temp <- df %>% filter(KOMMUN_NAMN == r) %>%
      arrange(AR)
    
    if (n_distinct(temp$AR) < 2) next
    
    # Beräkna skalningsfaktor för sekundär axel
    scale_factor <- max(temp$intakt, na.rm = TRUE) / max(temp$per_inv, na.rm = TRUE)
    
    p <- ggplot(temp, aes(x = AR)) +
      geom_line(aes(y = intakt, color = "Logiintäkt (kr)"), linewidth = 2) +
      geom_point(aes(y = intakt, color = "Logiintäkt (kr)"), size = 3) +
      geom_line(aes(y = per_inv * scale_factor, color = "Intäkt per invånare (kr)"), linewidth = 2, linetype = "dashed") +
      geom_point(aes(y = per_inv * scale_factor, color = "Intäkt per invånare (kr)"), size = 3) +
      scale_y_continuous(
        labels = label_number(big.mark = " "),
        expand = expansion(mult = c(0.1, 0.15)),
        sec.axis = sec_axis(
          transform = ~ . / scale_factor,
          name = "Intäkt per invånare",
          labels = label_number(accuracy = 1)
        )
      ) +
      scale_color_manual(
        values = c("Logiintäkt (kr)" = "#B81867", "Intäkt per invånare (kr)" = "#4AA271")
      )+
      scale_x_continuous(breaks = unique(temp$AR)) +
      labs(
        title = paste("Logiintäkter i", r),
        x = "",
        y = "Logiintäkt (kr)",
        color = "",
        caption = "Källa: Tillväxtverket, SCB"
      ) +
      theme(
        legend.position = "bottom",
        axis.text.x = element_text(angle = 45),
        axis.title.y.right = element_text(color = "#4AA271"),
        axis.text.y.right  = element_text(color = "#4AA271"),
        axis.title.y.left  = element_text(color = "#B81867"),
        axis.text.y.left   = element_text(color = "#B81867"),
        plot.caption = element_text(hjust = 0)
      )
    p
    
    # sparar plot
    ggsave(paste0("Figurer/logi_tid_tot_", r, ".svg"), plot = p, width = 8, height = 5)
    ggsave(paste0("Figurer/logi_tid_tot_", r, ".png"), plot = p, width = 8, height = 5, dpi = 96)
  }
}

logi_tid <- function(){
  # Hämtar data
  df <- read.csv("Data/df_logii.csv")
  
  # Grupperar per kommun, månad och anläggningstyp (samma filter som logi_tid_tot)
  df <- df %>%
    filter(AR <= (max(AR)) - 1,
           !(KOMMUN_NAMN == "Sekretesskyddad" & NIVA_NAMN == "Kommun")) %>%
    group_by(AR, MANAD_LANG_SVE, KOMMUN_NAMN, ANLAGGNINGSTYP_NAMN) %>%
    summarize(intakt = sum(LOGIINTAKT), .groups = "drop")
  
  ar <- unique(df$AR)
  
  df <- df %>%
    mutate(KOMMUN_NAMN = ifelse(KOMMUN_NAMN == "Sekretesskyddad",
                                "Uppsala län", KOMMUN_NAMN))
  
  # Tar in befolkningsdata
  df_befolk <- read.csv("Data/df_folkm_kom.csv") %>% filter(år %in% ar)
  
  df <- df %>% left_join(df_befolk, by = c("KOMMUN_NAMN" = "region", "AR" = "år"))
  
  if (any(is.na(df$Folkmängd))) {
    warning("Join misslyckades för: ",
            paste(unique(df$KOMMUN_NAMN[is.na(df$Folkmängd)]), collapse = ", "))
  }
  
  df <- df %>% mutate(per_inv = intakt / Folkmängd)
  
  # Datumkonvertering (samma som gamla logi_tid)
  month_map <- c(
    "Januari" = "01", "Februari" = "02", "Mars" = "03",
    "April"   = "04", "Maj"      = "05", "Juni"  = "06",
    "Juli"    = "07", "Augusti"  = "08", "September" = "09",
    "Oktober" = "10", "November" = "11", "December"  = "12"
  )
  
  df <- df %>%
    mutate(
      month_num = unname(month_map[MANAD_LANG_SVE]),
      date = as.Date(paste0(AR, "-", month_num, "-01"))
    )
  
  colmap <- c(
    "Sekretesskyddad" = "#B81867",
    "Hotell"          = "#D57667",
    "Camping"         = "#4AA271",
    "Vandrarhem"      = "#019CD7"
  )
  
  # Loopar över varje kommun
  for (r in unique(df$KOMMUN_NAMN)) {
    
    temp <- df %>% filter(KOMMUN_NAMN == r) %>% arrange(date)
    
    if (n_distinct(temp$AR) < 2) next
    
    # Skalningsfaktor baseras på max över alla anläggningstyper
    scale_factor <- max(temp$intakt, na.rm = TRUE) / max(temp$per_inv, na.rm = TRUE)
    
    x_tik <- ifelse(nrow(temp) < 4, "1 month", "4 months")
    
    p <- ggplot(temp, aes(x = date, color = ANLAGGNINGSTYP_NAMN)) +
      geom_line(aes(y = intakt), linewidth = 2, alpha=0.5) +
      geom_line(aes(y = per_inv * scale_factor),
                linewidth = 1, linetype = "dashed") +
      scale_color_manual(values = colmap) +
      scale_y_continuous(
        labels = label_number(big.mark = " "),
        expand = expansion(mult = c(0.1, 0.15)),
        sec.axis = sec_axis(
          transform = ~ . / scale_factor,
          name = "Intäkt per invånare (kr)",
          labels = label_number(big.mark = " ", accuracy = 1)
        )
      ) +
      scale_x_date(
        date_breaks = x_tik,
        date_labels = "%b %Y"
      ) +
      labs(
        title   = paste("Logiintäkter per anläggningstyp i", r),
        x       = "",
        y       = "Logiintäkt (kr)",
        color   = "",
        caption = "Källa: Tillväxtverket, SCB \nHeldragna linjer = total intäkt, streckade = intäkt per invånare"
      ) +
      theme(
        legend.position    = "bottom",
        axis.text.x        = element_text(angle = 45, hjust = 1),
        axis.title.y.right = element_text(color = "grey40"),
        axis.text.y.right  = element_text(color = "grey40"),
        axis.title.y.left  = element_text(color = "black"),
        plot.caption       = element_text(hjust = 0)
      )
    p
    ggsave(paste0("Figurer/logi_tid_", r, ".svg"), plot = p, width = 8, height = 5)
    ggsave(paste0("Figurer/logi_tid_", r, ".png"), plot = p, width = 8, height = 5, dpi = 96)
  }
}