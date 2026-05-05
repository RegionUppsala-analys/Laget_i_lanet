####### Prognos bostadsbehov #########

prognos_behov <- function(){
  # Läser in data och skapar set för basår
  folkmangd <- read.csv('Data/df_folkmangd.csv')
  
  # Summerar folkmängden per kommun
  folkmangd_tot <- folkmangd %>% filter(år == 2006) %>%  group_by(region) %>% 
    summarise(Total_folkmängd = sum(Folkmängd), .groups = 'drop') 
  
  # Läser in data
  df_supplatelse <- read.csv('Data/df_supplatelse.csv')
  
  # Summerar antal
  df_supplatelse_2006 <- df_supplatelse %>% filter(år =='2006') %>% 
    group_by(region) %>% summarise(Total_bostader = sum(Antal), .groups='drop')
  
  # Slår ihop set
  df_kvot <- left_join(df_supplatelse_2006,folkmangd_tot, by='region' )
  
  # Beräknar kvoten
  df_kvot$Kvot <- df_kvot$Total_folkmängd / df_kvot$Total_bostader # beräknar kvoten
  
  # Ändrar kolumnnamnen
  colnames(df_kvot) <- c('Region', 'Antal bostäder', 'Antal vuxna', 'Kvot')
  
  # Läser in data och tar bort första året
  df_befolkf <- read.csv('Data/df_folkmangdfram.csv') %>% filter(år > min(år))
  
  # Minst 20 år, och 20 år framåt summeras
  tid_df_befolkf <- df_befolkf %>% 
    filter(ålder >= 20, as.numeric(år) < (min(år)+ 20)) %>%  # 20 år framåt och alla över 20
    group_by(region, år) %>%  
    summarise(Totalt = sum(Antal), .groups = "drop")
  
  # folkmängden 2024 för 20-åringar och äldre
  max_ar <- max(folkmangd$år)
  folkokning <- folkmangd %>% filter(år == max_ar) %>%  group_by(region) %>% 
    summarise(Totalt = sum(Folkmängd), .groups = 'drop') %>% 
    mutate(år = max_ar) %>% select(region, år, Totalt)
  
  # Lägger till faktiskt antal i framKoladaivningen
  tid_df_befolkf <- rbind(tid_df_befolkf,folkokning)
  
  data_diff <- tid_df_befolkf %>%
    group_by(region) %>%               # Gruppera efter region
    arrange(år, .by_group = TRUE) %>%  # Se till att åren ligger i rätt ordning
    mutate(
      diff = ceiling(Totalt - lag(Totalt))     # Beräkna skillnaden mot föregående år
    ) %>%
    filter(!is.na(diff)) %>% # tar bort första året
    ungroup()
  
  # Lägg på kvot och uppskattat bostadsbehov
  tid_df <- data_diff %>%
    left_join(df_kvot %>% select(Region, Kvot), by = c("region" = "Region")) %>%
    mutate(Uppskattat_behov = ceiling(diff / Kvot))
  
  
  # Long-format för linjer
  lines_df <- tid_df %>%
    select(region, år, diff, Uppskattat_behov) %>%
    pivot_longer(
      cols = c(diff, Uppskattat_behov),
      names_to = "Typ",
      values_to = "Total"
    )
  # Plotfunktion
  plot_tid_nybygg_befolk_tot <- function(kommun_val){
    # Filtrerar kommun
    df_plot <- tid_df %>% filter(region == kommun_val)
    
    lines_plot <- lines_df %>% 
      filter(region == kommun_val)  # Bostadsbrist är nu med
    
    p<- ggplot(lines_plot, aes(x = år, y = Total, color = Typ, group = Typ)) +
      # Linjer för befolkning, uppskattat behov och bostadsbrist
      geom_line(data = lines_plot,
                aes(x = år, y = Total, color = Typ, group = Typ),
                linewidth = 4) +
      geom_text(data = lines_plot,
                aes(x = år, y = Total, label = Total),
                vjust = -1, size = 6, show.legend = FALSE, color='black') +
      scale_x_continuous(breaks = seq(min(df_plot$år), max(df_plot$år), by = 2)) +
      scale_y_continuous(expand = expansion(mult = c(0.1, 0.1)))+
      scale_color_manual(
        values = c(
          "diff" = "#4AA271",
          "Uppskattat_behov" = "#F9B000"
        ),labels = c(
          "diff" = "Befolkningsförändring",
          "Uppskattat_behov" = "Uppskattat behov av nya bostäder" )) +
      labs(title = kommun_val, x="", y = "Antal", color = "") +
      theme_get() + theme(axis.text.x = element_text(angle=45, vjust = 0.9),
                          legend.position = "bottom",
                          plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB, bearbetat av Region Uppsala')
    
    p
  }
  
  # Loopar över alla kommuner
  for (r in sort(kommuner)){
    p <- plot_tid_nybygg_befolk_tot(r)
    
    
    # spara plot som SVG
    file_name <- paste0("Figurer/plot_bostadsprognos_", r, ".svg")
    ggsave(filename = file_name, plot = p, width = 14, height = 8, device = "svg")
    #print(p)
    
    # png
    file_name <- paste0("Figurer/plot_bostadsprognos_", r, ".png")
    ggsave(filename = file_name, plot = p, width = 14, height = 8, device = "png",
           dpi = 96)
    
  }
  
  
}


