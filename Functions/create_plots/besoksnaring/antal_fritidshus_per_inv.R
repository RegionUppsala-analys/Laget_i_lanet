###### Fritidshus kolada #########

fritidshus <- function(){
  # Hämtar data
  df <- read.csv("Data/df_fritidshus.csv") %>% filter(year == max(year))
  
  # Skapar plot
  p <- ggplot(df, aes(x = municipality, y=value)) +
    geom_col(linewidth = 2, fill="#B81867") +
    labs(
      title = str_wrap(paste("Antal fritidshus per 1000 invånare i Uppsala län år", unique(df$year)),width=50),
      x = "",
      y = "Antal per/1000 inv",
      caption = "Källa: SCB"
    ) +
    theme(
      legend.position = "bottom",
      axis.text.x = element_text(angle = 45, hjust=1),
      plot.caption = element_text(hjust = 0)
    )
  p
  
  # sparar plot
  ggsave(paste0("Figurer/fritidshus.svg"), plot = p, width = 8, height = 5)
  ggsave(paste0("Figurer/fritidshus.png"), plot = p, width = 8, height = 5, dpi = 96)
  
}



