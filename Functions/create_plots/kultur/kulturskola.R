########## Deltagande kolada #########


###### Elever i musik-kultur #######

elever_mk <- function(){
  # Hämtar data
  df <- read.csv("Data/df_elever.csv") %>% 
    filter(title != "Elever i musik- eller kulturskola totalt, antal",
           gender == "T",
           year >= 2018)
  
  # Rensar titlar
  df$title <- gsub(", andel \\(%\\)", "", df$title )
  
  # Skillnader på titlarna
  df$index <- gsub("Elever i musik- eller kulturskola, ", "", df$title )
  
  # Skapar en plot per kommun   
  
  for (r in unique(df$index)){
    
    # tar ut kostnad/intäkt
    temp <- df %>% filter(index == r)
    
    
    
    p <- ggplot(
      temp,
      aes(
        x = year,
        y = value,
        color = municipality
      )
    ) +
      geom_line(linewidth  = 2) +
      geom_point(size = 3) +
      ylim(0,30)+
      scale_color_manual(values=kommun_colors)+
      scale_x_continuous(breaks = seq(min(temp$year), max(temp$year), by = 2))+
      labs(
        x = "",
        y = "Andel (%)",
        color = "",
        title = str_wrap(paste0("Andelen barn i ålder 6-15 som deltar i musik- eller kulturskoleverksamhet, ",r), width=50),
        caption = "Källa: SCB:s Räkenskapssammandrag"
      ) + theme(axis.text.x = element_text(angle =45,hjust=1),
                legend.position = "bottom",
                plot.caption = element_text(hjust=0))
    
    r <- gsub(" år", "", r )
    
    print(p)
    # Sparar plot 
    ggsave(
      paste0("Figurer/elever_mk_", r, ".svg"),
      plot = p,
      width = 7,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/elever_mk_", r, ".png"),
      plot = p,
      width = 7,
      height = 6,
      dpi = 96
    )
  }
  
}

####### Ämneskurser inom kulturskola #########

amneskurs <- function(){
  # Hämtar data
  df <- read.csv("Data/df_amne.csv")
  
  # Rensar titlar
  df$title <- gsub("erbjuds som ämneskurs i kulturskolan", "", df$title )
  df$title <- gsub("erbjuds som ämneskurser i kulturskolan", "", df$title )
  
  df <- df %>%
    # Filtrera bort den sammanfattande variabeln
    filter(title != "Ämneskurser som erbjuds i musik- eller kulturskolan, antal ämnesområden") %>%
    # Rensa variabelnamnen från " (Ja=1, Nej=0)"
    mutate(title_clean = gsub(" \\(Ja=1, Nej=0\\)", "", title))
  
  # Plot per kommun
  for(r in kommuner){
    # temporärt data
    temp <- df %>% filter(municipality == r)
    
    # plot
    p <- ggplot(temp, aes(x = year, y = title_clean, fill = factor(value))) +
      geom_tile(color = "white", linewidth = 0.5) +
      scale_fill_manual(
        values = c("0" = "#D0342C", "1" = "#4AA271"),
        labels = c("0" = "Nej", "1" = "Ja"),
        name = "Erbjuds"
      ) +
      labs(
        title = paste("Ämneskurser i kulturskolan -", r),
        x = "",
        y = "",
        caption="Källa: Kulturrådet"
      ) +
      theme(
        legend.position = "bottom",
        plot.title = element_text( hjust = 1),
        plot.caption = element_text(hjust=0)
      )
    
    
    
    p
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/amneskurs_",r, ".svg"),
      plot = p,
      width = 8,
      height = 7
    )
    
    ggsave(
      paste0("Figurer/amneskurs_", r, ".png"),
      plot = p,
      width = 8,
      height = 7,
      dpi = 96
    )
  }
  
}
####### Genomsnittlig elevkostnad #####

genom_elevkost <- function(){
  # Hämtar data
  df <- read.csv("Data/df_genomkost.csv")
  
  # Rensar titlar
  df$title <- gsub(", kr/elever 6-19 år", "", df$title )
  
  # Skapar en plot 
  p <- ggplot(
    df,
    aes(
      x = year,
      y = value,
      color = municipality
    )
  ) +
    geom_line(linewidth  = 2) +
    geom_point(size = 3) +
    scale_color_manual(values=kommun_colors)+
    scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 2))+
    labs(
      x = "",
      y = "kr/elever",
      color = "",
      title = str_wrap(paste0(unique(df$title)), width=50),
      caption = "Källa: SCB:s Räkenskapssammandrag och Kulturrådet"
    ) + theme(axis.text.x = element_text(angle =45,hjust=1),
              legend.position = "bottom",
              plot.caption = element_text(hjust=0))
  
  
  print(p)
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/genom_elevkost", ".svg"),
    plot = p,
    width = 8,
    height = 7
  )
  
  ggsave(
    paste0("Figurer/genom_elevkost",  ".png"),
    plot = p,
    width = 8,
    height = 7,
    dpi = 96
  )
  
  
  
}
