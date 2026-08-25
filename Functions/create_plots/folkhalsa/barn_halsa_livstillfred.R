# Självrapporterad hälsa, barn: 

sjalvrapporterad_halsa <- function(){
  
  df <- read.csv("Data/df_sjalvrapporterad.csv") %>% filter(År == max(År))
  
  
  df <- df %>% mutate(Region = factor(Region, levels = sort(unique(df$Region))))
  
  ar <- unique(df$År)
  
  # Färgschema
  kon_col <- c("Pojkar" = "#4AA271",
               "Flickor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(
  df,
  aes(
    x = Region,
    y = Andel,
    fill = Kön
  )
) +
  geom_col(
    position = position_dodge(width = 0.9)
  ) +
  geom_errorbar(
    aes(
      ymin = Konfidensintervall.nedre.gräns,
      ymax = Konfidensintervall.övre.gräns
    ),
    width = 0.4,
    linewidth = 1,
    position = position_dodge(width = 0.9)
  ) +
  scale_fill_manual(values = kon_col) +
  scale_y_continuous(
    breaks = seq(0, 100, by = 10),
    limits = c(0, 100)
  ) +
  labs(
    x = "",
    title = str_wrap(
      paste(
        "Andel barn med minst två återkommande fysiska eller psykiska besvär –",
        ar
      ),
      width = 50
    ),
    caption = "Källa: Folkhälsomyndigheten, SCB",
    y = "Andel (%)",
    fill = ""
  ) +
  theme(
    plot.caption = element_text(hjust = 0),
    axis.text.x = element_text(
      angle = 45,
      vjust = 0.5
    )
  )

  # Sparar plot 
  ggsave(
    paste0("Figurer/sjalvrapporterad_halsa.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/sjalvrapporterad_halsa.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}


# livstillfredsställelse, barn

livstillfredsstallelse <- function(){
  # Läsa in data  
  df <- read.csv('Data/df_livstillfredsstallelse.csv')
  
  
  df <- df %>% mutate(Region = factor(Region, levels = sort(unique(df$Region))))
  
  ar <- unique(df$År)
  
  # Färgschema
  kon_col <- c("Pojkar" = "#4AA271",
               "Flickor" = "#D57667")
  
  p <- ggplot(
    df,
    aes(
      x = Region,
      y = Andel,
      fill = Kön
    )
  ) +
    geom_col(
      position = position_dodge(width = 0.9)
    ) +
    geom_errorbar(
      aes(
        ymin = Konfidensintervall.nedre.gräns,
        ymax = Konfidensintervall.övre.gräns
      ),
      width = 0.4,
      linewidth = 1,
      position = position_dodge(width = 0.9)
    ) +
    scale_fill_manual(values = kon_col) +
    scale_y_continuous(
      breaks = seq(0, 100, by = 10),
      limits = c(0, 100)
    ) +
    labs(
      x = "",
      title = str_wrap(
        paste("Andel barn med hög livstillfredsställelse –", ar),
        width = 50
      ),
      caption = "Källa: SCB",
      y = "Andel (%)",
      fill = ""
    ) +
    theme(
      plot.caption = element_text(hjust = 0),
      axis.text.x = element_text(
        angle = 45,
        vjust = 0.5
      )
    )

  # Sparar plot 
  ggsave(
    paste0("Figurer/livstillfredsstallelse.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/livstillfredsstallelse.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
}
