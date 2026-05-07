

######## Fordon ########
# Antal fordon
fordon_antal <- function(){
  
  # Läser in data
  df <- read.csv('Data/df_bil.csv')
  
  # rensar titlarna
  df$title <- gsub(", antal/1000 inv","",df$title)
  
  
  df <- df %>% filter(title != "Bilar")
  
  # Färger
  cols <- kommun_colors
  
  names(cols) <- unique(df$title)
  
  for (r in unique(df$municipality)){
    
    temp <- df %>% filter(municipality == r)
    temp$year <- factor(temp$year)
    
    p <- ggplot(temp, aes(x= year, y= value, color=title, group=title))+
      geom_line(linewidth=2) + geom_point(size=4) +
      labs(y="Antal/1000 invånare",
           x="",
           title=paste("Antal bilar per 1000 invånare i",r),
           caption = "Källa: SCB",
           color=" ")+
      scale_color_manual(values = cols)+
      theme(
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.caption.position = "plot", 
        legend.direction = "horizontal",
        plot.caption = element_text(hjust = 0),
        axis.text.x = element_text(angle = 45, hjust = 1))
    
    p
    # Save as SVG
    filename <- paste0("Figurer/fordon_antal_", r, ".svg")
    ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
    
    # png
    filename <- paste0("Figurer/fordon_antal_", r, ".png")
    ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
    
    
    
    
  }
  
  
}

# mil / invånare
korstracka <- function(){
  
  # Läser in data
  df <- read.csv('Data/df_stracka.csv')
  
  # rensar titlarna
  df$title <- gsub(", mil/inv","",df$title)
  
  
  df <- df %>% filter(title != "Genomsnittlig körsträcka med personbil, mil/personbil")
  
  # Färger
  
  df$year <- factor(df$year, levels= unique(df$year))
  
  p <- ggplot(df, aes(x= year, y= value, color=municipality, group=municipality))+
    geom_line(linewidth=2) + geom_point(size=4) +
    labs(y="Mil/invånare",
         x="",
         title=paste(unique(df$title), "per kommun"),
         caption = "Källa: Trafa",
         color=" ")+
    scale_color_manual(values = kommun_colors)+
    theme(
      legend.position = "bottom",
      plot.title.position = "plot",
      plot.caption.position = "plot", 
      legend.direction = "horizontal",
      plot.caption = element_text(hjust = 0),
      axis.text.x = element_text(angle = 45, hjust = 1))
  
  p
  # Save as SVG
  filename <- paste0("Figurer/korstracka", ".svg")
  ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
  
  # png
  filename <- paste0("Figurer/korstracka", ".png")
  ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
  
  
  
  
  
  
}

# mil / personbil
korstracka_bil <- function(){
  
  # Läser in data
  df <- read.csv('Data/df_stracka.csv')
  
  # rensar titlarna
  df$title <- gsub(", mil/personbil","",df$title)
  
  
  df <- df %>% filter(title != "Genomsnittlig körsträcka med personbil, mil/inv")
  
  # Färger
  
  df$year <- factor(df$year, levels= unique(df$year))
  
  p <- ggplot(df, aes(x= year, y= value, color=municipality, group=municipality))+
    geom_line(linewidth=2) + geom_point(size=4) +
    labs(y="Mil/personbil",
         x="",
         title=paste(unique(df$title), "per kommun"),
         caption = "Källa: Trafa",
         color=" ")+
    scale_color_manual(values = kommun_colors)+
    theme(
      legend.position = "bottom",
      plot.title.position = "plot",
      plot.caption.position = "plot", 
      legend.direction = "horizontal",
      plot.caption = element_text(hjust = 0),
      axis.text.x = element_text(angle = 45, hjust = 1))
  
  p
  # Save as SVG
  filename <- paste0("Figurer/korstracka_bil", ".svg")
  ggsave(filename, plot = p, device = "svg", width = 8, height = 6)
  
  # png
  filename <- paste0("Figurer/korstracka_bil", ".png")
  ggsave(filename, plot = p, device = "png", width = 8, height = 6, dpi=96)
  
  
  
  
  
  
}

