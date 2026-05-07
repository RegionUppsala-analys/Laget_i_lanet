# Självrapporterad hälsa, barn: 

sjalvrapporterad_halsa <- function(){
  
  df <- read.csv("Data/df_sjalvrapporterad.csv") %>% filter(År == max(År))
  
  
  df <- df %>% mutate(Region = factor(Region, levels = sort(unique(df$Region))))
  
  ar <- unique(df$År)
  
  # Färgschema
  kon_col <- c("Pojkar" = "#4AA271",
               "Flickor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=Region, y = Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = Konfidensintervall.nedre.gräns, ymax = Konfidensintervall.övre.gräns), alpha = 0.3, color =NA) +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    
    labs(x="",
         title = str_wrap(paste("Andel barn med minst 2 återkommande fysiska eller psykiska besvär –", ar), width=50),
         caption = "Källa: Folkhälsomyndigheten, SCB",
         y = "Andel (%)",
         color="",
         fill="")+
    theme(plot.caption = element_text(hjust=0),
          axis.text.x = element_text(angle = 45, vjust=0.5))
  
  
  p
  
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


# livstillfresstallelse, barn


livstillfresstallelse <- function(){
  # Läsa in data  
  df <- read.csv('Data/df_livstillfresstallelse.csv')
  
  
  df <- df %>% mutate(Region = factor(Region, levels = sort(unique(df$Region))))
  
  ar <- unique(df$År)
  
  # Färgschema
  kon_col <- c("Pojkar" = "#4AA271",
               "Flickor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=Region, y = Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = Konfidensintervall.nedre.gräns, ymax = Konfidensintervall.övre.gräns), alpha = 0.3, color =NA) +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    
    labs(x="",
         title = str_wrap(paste("Andel barn med hög livstillfredsställelse –", ar), width=50),
         caption = "Källa: SCB",
         y = "Andel (%)",
         color="",
         fill="")+
    theme(plot.caption = element_text(hjust=0),
          axis.text.x = element_text(angle = 45, vjust=0.5))
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/livstillfresstallelse.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/livstillfresstallelse.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
}
