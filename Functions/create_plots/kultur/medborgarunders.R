###### Medborgarundersökningen kolada ###########

medborgarund_kultur <- function(){
  
  df <- read.csv("Data/df_enkat_kultur.csv")
  
  # en kolumn för lower och en för upper till intervallet
  df_plot <- df %>%
    mutate(
      lower = Medborgarundersökningen...Det.lokala.kultur..och.nöjeslivet.i.kommunen.är.bra..andel.... -
        Osäkerhetstal...Det.lokala.kultur..och.nöjeslivet.i.kommunen.är.bra..andel....,
      upper = Medborgarundersökningen...Det.lokala.kultur..och.nöjeslivet.i.kommunen.är.bra..andel.... +
        Osäkerhetstal...Det.lokala.kultur..och.nöjeslivet.i.kommunen.är.bra..andel....,
      year <- factor(year, levels = unique(year))
    )
  
  
  
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667",
               "Total" = "#B81867")
  
  df_plot$municipality <- ifelse(df_plot$municipality == "Region Uppsala", "Uppsala län", df_plot$municipality)
  
  # Skapar en plot per kommun   
  
  for (r in unique(df_plot$municipality)){
    
    temp <- df_plot %>% filter(municipality == r)
    
    # hur många år finns per kön?
    n_years <- temp %>%
      count(gender) %>%
      pull(n) %>%
      min()
    
    # om det endast finns ett år så skapas en barplot, annars tidsserie
    if (n_years > 1) {
      temp$lower <-
        ifelse(temp$gender=="Total",0, temp$lower  )
      temp$upper <-
        ifelse(temp$gender=="Total",0, temp$upper  )
      
      # ===== TIDSSERIE =====
      p <- ggplot(
        temp,
        aes(
          x = year,
          y = Medborgarundersökningen...Det.lokala.kultur..och.nöjeslivet.i.kommunen.är.bra..andel....,
          color = gender,
          fill = gender,
          group = gender
        )
      ) +
        geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, color = NA) +
        geom_line(linewidth = 1) +
        geom_point(size = 2) +
        scale_fill_manual(values=kon_col)+
        scale_color_manual(values=kon_col)+
        ylim(0,100)+
        labs(
          x = "",
          y = "Andel (%)",
          color = "",
          fill = "",
          title = str_wrap(paste("Andelen som svarat bra eller mycket bra angående det lokala kultur- och nöjeslivet –", r), width=45),
          subtitle = "Med osäkerhetsintervall",
          caption = "Källa: SCB:s medborgarundersökning"
        ) + theme(plot.caption = element_text(hjust = 0),
                  plot.subtitle = element_text(hjust = 0.5))
      
    } else {
      # ===== BARPLOT =====
      p <- ggplot(
        temp,
        aes(
          x = gender,
          y = Medborgarundersökningen...Det.lokala.kultur..och.nöjeslivet.i.kommunen.är.bra..andel....,
          fill = gender
        )
      ) +
        geom_col(width = 0.6) +
        geom_errorbar(
          aes(ymin = lower, ymax = upper),
          width = 0.15
        ) +
        scale_fill_manual(values=kon_col)+
        ylim(0,100)+
        labs(
          x = NULL,
          y = "Andel (%)",
          fill = "",
          title = str_wrap(paste0("Andelen som svarat bra eller mycket bra angående det lokala kultur- och nöjeslivet –",
                                  r, ", år ",max(temp$year)), width=45),
          subtitle = "Med osäkerhetsintervall",
          caption = "Källa: SCB:s medborgarundersökning"
        ) + theme(plot.caption = element_text(hjust = 0),
                  plot.subtitle = element_text(hjust = 0.5))
    }
    
    print(p)
    # Sparar plot 
    ggsave(
      paste0("Figurer/medborgarund_kultur_", r, ".svg"),
      plot = p,
      width = 7,
      height = 5
    )
    
    ggsave(
      paste0("Figurer/medborgarund_kultur_", r, ".png"),
      plot = p,
      width = 7,
      height = 5,
      dpi = 96
    )
  }
  
}