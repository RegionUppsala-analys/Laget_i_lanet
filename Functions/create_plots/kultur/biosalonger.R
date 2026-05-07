######### kulturanalys biodata ############



biosalonger_region <- function() {
  # Hämtar data 
  df <- read.csv("Data/df_region_bio.csv")
  index1 <- grepl("län", df$region)
  index2 <- grepl("Riket", df$region)
  
  # Tar ut län och highlightar region uppsala
  df <- df[index1 | index2, ]
  df <- df %>% filter(year == max(year), region != "Riket")
  
  # Transformerar till long format
  df_long <- df %>%
    select(region, besök.per.invånare, biografer.per.miljon.invånare, 
           salonger.per.miljon.invånare, visningar.per.tusen.invånare) %>%
    pivot_longer(-region, names_to = "metric", values_to = "value") %>%
    mutate(is_uppsala = region == "Uppsala län",
           metric = gsub("\\.", " ", str_to_sentence(metric)))
  
  # Factorvariabel
  df_long <- df_long %>% 
    mutate(region = factor(region, levels = sort(unique(region), decreasing=T)))
  
  # Versaler
  colnames(df_long) <- str_to_sentence(colnames(df_long))
  
  
  
  # Skapar plot
  p <- ggplot(df_long, aes(x = Value, 
                           y = Region,
                           color = Is_uppsala,
                           size = Is_uppsala)) +
    geom_point() +
    scale_color_manual(values = c("gray50", "#B81867")) +
    scale_size_manual(values = c(2, 3.5)) +
    facet_wrap(~Metric, scales = "free_x") +
    labs(title = paste("Biosalongsdata i Sverige år", max(df$year)),
         caption = "Källa: Kulturanalys",
         x = NULL, y = NULL) +
    theme(legend.position = "none",
          plot.title = element_text(face = "bold"),
          strip.text = element_text(face = "bold",size=16),
          plot.caption = element_text(hjust=0))
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/biosalonger_region", ".svg"),
    plot = p,
    width = 8,
    height = 8
  )
  
  ggsave(
    paste0("Figurer/biosalonger_region",  ".png"),
    plot = p,
    width = 8,
    height = 8,
    dpi = 96
  )
  
}
