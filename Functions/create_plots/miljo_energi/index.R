###### Miljö/Hållbarhetsindex ########


miljo_index <- function(){
  
  # Läser in data 
  df <- read.csv("Data/df_miljokval.csv") %>% filter(year==max(year),
                                                     municipality_type =='K')
  
  # Tar ut kvartiler, max, min och filtrerar kommun
  quantiles <- quantile(df$value,probs = c(0.25, 0.75))
  max_p <- df[which.max(df$value),]
  min_p <- df[which.min(df$value),]
  kommun_df <- df %>% filter(municipality %in% kommuner)
  
  # Skapar barplot med flera linjer 
  p<- ggplot(kommun_df, aes(x=municipality, y=value))+ 
    geom_col(fill="#B81867")+ 
    geom_hline(yintercept = quantiles[1], color = "black", linetype = "dashed", linewidth = 1) +  # 25th 
    geom_hline(yintercept = quantiles[2], color = "black", linetype = "dashed", linewidth = 1) +   # 75th 
    geom_hline(yintercept = max_p$value, color = "black", linetype = "solid", linewidth = 1) +  
    geom_hline(yintercept = min_p$value, color = "black", linetype = "solid", linewidth = 1) +   
    annotate("text", 
             x = Inf, 
             y = quantiles[1], 
             label = "25:e percentilen", 
             hjust = -0.05, vjust = 0.2, 
             color = "black", size = 4) +
    annotate("text", 
             x = Inf, 
             y = quantiles[2], 
             label = "75:e percentilen", 
             hjust = -0.05, vjust = 0.2, 
             color = "black", size = 4) +
    annotate("text", 
             x = Inf, 
             y = max_p$value, 
             label = paste(max_p$municipality, '(max)'), 
             hjust = -0.05, vjust = 0.2, 
             color = "black", size = 4) +
    annotate("text", 
             x = Inf, 
             y = min_p$value, 
             label = paste(min_p$municipality, '(min)'), 
             hjust = -0.05, vjust = 0.2, 
             color = "black", size = 4) +
    ylim(0,100)+
    
    labs(x = "", y="Index", 
         title= paste("Miljöindex per kommun år", unique(df$year)),
         caption = 'Källa: SCB')+ 
    theme(axis.text.x = element_text(angle = 90),
          legend.position="none",
          text = element_text(family = "sourcesanspro", size = 14),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.margin = grid::unit(c(15, r=90, 15, 15), "pt"),
          plot.caption = element_text(hjust = 0))+ coord_cartesian(clip = "off")
  p
  # sparar som svg
  ggsave('Figurer/miljoindex.svg',plot = p,device = "svg", width = 7, height = 7)
  
  ggsave('Figurer/miljoindex.png',plot = p,device = "png", width = 7, height = 8, dpi =96)
}

hallbarhetsindex <- function(){
  
  # Läser in data 
  df <- read.csv("Data/df_hallbarhet.csv") %>% filter(year==max(year),
                                                      municipality_type =='K')
  
  # Tar ut kvartiler, max, min och filtrerar kommun
  quantiles <- quantile(df$value,probs = c(0.25, 0.75))
  max_p <- df[which.max(df$value),]
  min_p <- df[which.min(df$value),]
  kommun_df <- df %>% filter(municipality %in% kommuner)
  
  # Skapar barplot med flera linjer 
  p<- ggplot(kommun_df, aes(x=municipality, y=value))+ 
    geom_col(fill="#B81867")+ 
    geom_hline(yintercept = quantiles[1], color = "black", linetype = "dashed", linewidth = 1) +  # 25th 
    geom_hline(yintercept = quantiles[2], color = "black", linetype = "dashed", linewidth = 1) +   # 75th 
    geom_hline(yintercept = max_p$value, color = "black", linetype = "solid", linewidth = 1) +  
    geom_hline(yintercept = min_p$value, color = "black", linetype = "solid", linewidth = 1) +   
    annotate("text", 
             x = Inf, 
             y = quantiles[1], 
             label = "25:e percentilen", 
             hjust = -0.05, vjust = 0.2, 
             color = "black", size = 4) +
    annotate("text", 
             x = Inf, 
             y = quantiles[2], 
             label = "75:e percentilen", 
             hjust = -0.05, vjust = 0.2, 
             color = "black", size = 4) +
    annotate("text", 
             x = Inf, 
             y = max_p$value, 
             label = paste(max_p$municipality, '(max)'), 
             hjust = -0.05, vjust = 0.2, 
             color = "black", size = 4) +
    annotate("text", 
             x = Inf, 
             y = min_p$value, 
             label = paste(min_p$municipality, '(min)'), 
             hjust = -0.05, vjust = 0.2, 
             color = "black", size = 4) +
    ylim(0,100)+
    
    labs(x = "", y="Index", 
         title= paste("Hållbarhetsindex per kommun år", unique(df$year)),
         caption = 'Källa: SCB')+ 
    theme(axis.text.x = element_text(angle = 90),
          legend.position="none",
          text = element_text(family = "sourcesanspro", size = 14),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0),
          plot.margin = grid::unit(c(l=15,r=90,t=40,b=15),"pt"))+ coord_cartesian(clip = "off")
  p
  # sparar som svg
  ggsave('Figurer/hallbarhetsindex.svg',plot = p,device = "svg", width = 7, height = 7)
  
  
  ggsave('Figurer/hallbarhetsindex.png',plot = p,device = "png", width = 7, height = 7, dpi =96)
}
