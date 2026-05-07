########### Studieförbundsdata #########


studiefordelning_kon <- function(){
  # Hämtar data
  df <- read.csv("Data/df_studieforbund.csv")
  
  # färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  
  df <- df %>% mutate(Andel_k = Deltagare..kvinnor/Deltagare,
                      Andel_m = Deltagare..män/Deltagare)
  
  for (r  in unique(df$region)) {
    
    
    p <-  df %>% 
      filter(region == r, verksamhetsform == "Totalt") %>%
      pivot_longer(cols = c(Deltagare..kvinnor, Deltagare..män),
                   names_to = "Kön", values_to = "Antal") %>%
      mutate(Kön = case_when(Kön == "Deltagare..kvinnor"~'Kvinnor',
                             TRUE ~ 'Män'),
             Andel = case_when(Kön == "Kvinnor" ~ Andel_k,   # <-- pick the right share
                               TRUE ~ Andel_m)) %>% 
      ggplot(aes(x = år, y = Antal, fill = Kön)) +
      geom_col(position = "dodge") +
      geom_text(                                          # <-- text layer
        aes(label = scales::percent(Andel, accuracy = 0.1)),
        position = position_dodge(width = 0.9),
        vjust = -0.4,
        size = 3
      ) +
      scale_fill_manual(values = kon_col)+
      labs(title = str_wrap(paste("Könsfördelning bland studieförbundens deltagare -", r), width=50),
           x="", fill="",
           caption = "Källa SCB")+
      theme(
        plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
        plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
        plot.caption = element_text(hjust=0))
    
    
    
    p
    # Sparar plot 
    ggsave(
      paste0("Figurer/studieforbund_kon_",r,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/studieforbund_kon_",r,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
  }
}


studiefordelning <- function(){
  # Hämtar data
  df <- read.csv("Data/df_studieforbund.csv") %>% 
    filter(verksamhetsform != "Uppsökande verksamhet")
  
  # Färgschema
  cols <- c("Kulturprogram"= "#019CD7","Annan folkbildningsverksamhet" ="#D57667" ,
            "Studiecirkel"="#F9B000", "Fri" = "#4AA271"
  )
  
  for (r  in unique(df$region)) {
    
    p <-  df %>% 
      filter(region == r, verksamhetsform != "Totalt") %>%
      ggplot(aes(x = år, y = Arrangemang, color = verksamhetsform)) +
      geom_line(linewidth = 2) +
      geom_point(size = 3) +
      scale_color_manual(values = cols)+
      labs(title = paste("Arrangemang per verksamhetsform -", r),
           y = "Antal arrangemang",
           color = "",
           x="",
           caption = "Källa SCB")+
      theme(
        plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
        plot.caption = element_text(hjust=0),
        legend.position = "bottom")
    
    
    
    p  
    
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/studieforbund_",r,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/studieforbund_",r,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
  }
}


forbund_kvot <- function(){
  # Hämtar data
  df <- read.csv("Data/df_studieforbund.csv")
  
  # Kvoter
  df_kvoter <- df %>%
    filter(verksamhetsform == "Totalt") %>%
    mutate(
      deltagare_per_studietimme = Deltagare / Studietimmar,
      genomsnittlig_studietid = Deltagartimmar / Deltagare
    ) %>%
    pivot_longer(
      cols = c(deltagare_per_studietimme, genomsnittlig_studietid),
      names_to = "Mått",
      values_to = "Värde"
    ) %>%
    mutate(Mått = case_when(
      Mått == "deltagare_per_studietimme" ~ "Deltagare per studietimme",
      Mått == "genomsnittlig_studietid" ~ "Genomsnittlig studietid"
    ))
  
  
  for (r in kommuner) {
    
    temp <- df_kvoter %>%  filter(region  == r)
    
    p <- ggplot(temp, aes(x = år, y = Värde)) +
      geom_line(linewidth = 1,color =  "#B81867" ) +
      geom_point(size = 2,color =  "#B81867" ) +
      facet_wrap(~Mått, ncol=1) +
      ylim(0,max(df_kvoter$Värde)+0.5)+
      labs(
        title = paste("Effektivitetsmått för studieverksamhet i",r),
        x = "",
        y = "",
        caption = "Källa SCB")+
      theme(axis.text.x = element_text(angle=45, vjust=0.5),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            legend.position = "bottom")
    
    p  
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/forbund_kvot_",r,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/forbund_kvot_",r,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
    
  }
}