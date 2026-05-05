######## Uppskattat behov av bostäder ###############

uppskatt_behov <- function(){
  # Läser in data och skapar set för basår
  folkmangd <- read.csv('Data/df_folkmangd.csv')
  folkmangd_tot <- folkmangd %>% filter(år == 2006) %>%  group_by(region) %>% 
    summarise(Total_folkmängd = sum(Folkmängd), .groups = 'drop') 
  
  df_supplatelse <- read.csv('Data/df_supplatelse.csv')
  
  # Summerar totalt antal hushåll
  df_supplatelse_2006 <- df_supplatelse %>% filter(år =='2006') %>% 
    group_by(region) %>% summarise(Total_bostader = sum(Antal), .groups='drop')
  
  # Slår ihop dataseten
  df_kvot <- left_join(df_supplatelse_2006,folkmangd_tot, by='region' )
  
  # Beräknar kvoten
  df_kvot$Kvot <- df_kvot$Total_folkmängd / df_kvot$Total_bostader # beräknar kvoten
  
  # Byter kolumnnamn och läser in data
  colnames(df_kvot) <- c('Region', 'Antal bostäder', 'Antal vuxna', 'Kvot')
  df_nybyggda <- read.csv('Data/df_nybyggda.csv')
  df_befolkf <- read.csv('Data/df_befolkf.csv')
  
  df_nybyggda$år <- as.integer(df_nybyggda$år)
  
  # Summera nybygg utan upplåtelseform
  tid_df_nybyggda_total <- df_nybyggda %>% 
    filter(as.numeric(år) > 2012) %>% 
    group_by(region, år) %>%   
    summarise(Total_nybygg = sum(Antal), .groups = "drop")
  
  # Befolkning per kommun och år
  tid_df_befolkf <- df_befolkf %>% 
    rename(Antal_personer = Antal.personer) %>%  
    filter(as.numeric(år) > 2012) %>% 
    group_by(region, år) %>%  
    summarise(Total_personer = sum(Antal_personer), .groups = "drop")
  
  # Lägg på kvot och uppskattat bostadsbehov
  tid_df <- tid_df_befolkf %>%
    left_join(tid_df_nybyggda_total, by = c("region", "år")) %>%
    left_join(df_kvot %>% select(Region, Kvot), by = c("region" = "Region")) %>%
    mutate(Uppskattat_behov = ceiling(Total_personer / Kvot))
  
  
  # Long-format för linjer
  lines_df <- tid_df %>%
    select(region, år, Total_personer, Uppskattat_behov) %>%
    pivot_longer(
      cols = c(Total_personer, Uppskattat_behov),
      names_to = "Typ",
      values_to = "Total"
    )
  
  tid_df <- tid_df %>% mutate(år = as.integer(år)) # år som heltal
  
  # Plotfunktion
  plot_tid_nybygg_befolk_tot <- function(kommun_val){
    # Filtrerar ut data
    df_plot <- tid_df %>% filter(region == kommun_val)
    
    lines_plot <- lines_df %>% 
      filter(region == kommun_val)  # Bostadsbrist är nu med
    
    p<- ggplot(df_plot, aes(x = år)) +
      # Totala nybyggda som kolumner
      geom_col(aes(y = Total_nybygg, fill = "Nybyggda bostäder"), width = 0.8) +
      # Linjer för befolkning, uppskattat behov och bostadsbrist
      geom_line(data = lines_plot,
                aes(x = år, y = Total, color = Typ, group = Typ),
                linewidth = 2) +
      geom_text(data = lines_plot,
                aes(x = år, y = Total, label = Total),
                vjust = -1, size = 6, show.legend = FALSE) +
      scale_x_continuous(breaks = seq(min(df_plot$år), max(df_plot$år), by = 2)) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.1)))+
      scale_color_manual(
        values = c(
          "Total_personer" = "#4AA271",
          "Uppskattat_behov" = "#F9B000"
        ),
        labels = c(
          "Total_personer" = "Befolkningsförändring",
          "Uppskattat_behov" = "Uppskattat bostadsbehov"
        )
      ) +scale_fill_manual(
        values = c("Nybyggda bostäder" = "#6F787E"),
        labels = c("Nybyggda bostäder" = "Nybyggda bostäder")
      ) +
      labs(title = kommun_val, x="", y = "Antal", color = "", fill = "") +
      theme_get()+ theme(
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB, bearbetat av Region Uppsala')
    
    p
  }
  
  # Kör funktionen för för alla kommuner och sparar
  for (r in sort(kommuner)){
    p <- plot_tid_nybygg_befolk_tot(r)
    
    
    # spara plot som SVG
    file_name <- paste0("Figurer/plot_bostadsbrist_", r, ".svg")
    ggsave(filename = file_name, plot = p, width = 14, height = 8, device = "svg")
    
    # png
    file_name <- paste0("Figurer/plot_bostadsbrist_", r, ".png")
    ggsave(filename = file_name, plot = p, width = 14, height = 8, device = "png",
           dpi = 96)
    
  }
  
}
