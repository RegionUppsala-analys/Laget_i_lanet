######### Befolkningsförändring i relation till färdigställda bostäder ##########

# region

nybygg_region <- function(){
  # Läser in data 
  df_nybyggda <- read.csv('Data/df_nybyggda.csv')
  
  df_befolkf <- read.csv('Data/df_befolkf.csv')
  
  # Summerar antal per år, efter 2012
  tid_df_nybyggda <- df_nybyggda %>% 
    filter( as.numeric(år) > 2012
    ) %>% 
    group_by(upplåtelseform, år) %>%   
    summarise(nybygg = sum(Antal), .groups = "drop")
  
  # Gör om tid till heltal
  tid_df_nybyggda$år <- as.integer(tid_df_nybyggda$år)
  
  # Totalt antal nybyggda
  nybyggda_total <- tid_df_nybyggda %>% 
    group_by(år) %>%  
    summarise(Total_nybygg = sum(nybygg))
  
  # Summerar antal personer per år
  tid_df_befolkf <- df_befolkf %>% rename(Antal_personer = Antal.personer) %>%  filter(as.numeric(år) > 2012) %>% 
    group_by(år) %>%  summarise(Total_personer = sum(Antal_personer), .groups = "drop")
  
  # slår ihop data
  tid_nybygg_befolk <- tid_df_nybyggda %>%
    left_join(tid_df_befolkf, by = "år")%>%
    left_join(nybyggda_total, by = "år")
  
  # gör long-df för linjerna
  lines_df <- tid_nybygg_befolk %>%
    select(år, Total_nybygg, Total_personer) %>%
    tidyr::pivot_longer(
      cols = c(Total_nybygg, Total_personer),
      names_to = "Typ",
      values_to = "Total"
    )
  
  # Factorvariabel av upplåtelseform
  tid_nybygg_befolk$upplåtelseform <- factor(
    tid_nybygg_befolk$upplåtelseform,
    levels = c("hyresrätt", "bostadsrätt", "äganderätt")  # ordning som du vill ha
  )
  
  # Tid till heltal
  tid_nybygg_befolk <- tid_nybygg_befolk %>%
    mutate(år = as.integer(år))
  
  lines_df <- lines_df %>%
    mutate(år = as.integer(år))
  
  # plott
  p <- ggplot() +
    # staplar
    geom_col(data = tid_nybygg_befolk,
             aes(x = år, y = nybygg, fill = upplåtelseform),
             position = position_dodge(width = 0.9), width = 0.8) +
    
    # linjer (nu kommer färgerna från Typ)
    geom_line(data = lines_df,
              aes(x = år, y = Total, color = Typ, group = Typ),
              linewidth = 1.2) +
    geom_text(data = lines_df,
              aes(x = år, y = Total, label = Total),
              vjust = -0.9, size = 4,show.legend = FALSE) +
    scale_x_continuous(
      breaks = seq(min(tid_nybygg_befolk$år), max(tid_nybygg_befolk$år), by = 2)
    ) +
    # Färg på kolumnerna
    scale_fill_manual(
      values = upplat_colors,
      labels = tools::toTitleCase(names(upplat_colors))
    ) +
    # Färg på linjerna
    scale_color_manual(
      values = c("Total_nybygg" = "#B81867",
                 "Total_personer" = "#4AA271"),
      labels = c("Total_nybygg" = "Nybyggda bostäder",
                 "Total_personer" = "Befolkningsförändring")
    ) +
    labs(
      title = lan,
      x="", y = "Antal",
      fill = "",
      color = ""   # rubrik för linjer
    ) +theme(
      text = element_text(family = "sourcesanspro", size = 14),
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
  
  p
  ggsave(filename = 'Figurer/nybygg_region.svg', plot = p, width = 8, height = 6, device = "svg")
  ggsave(filename = 'Figurer/nybygg_region.png', plot = p, width = 8, height = 6, device = "png",
         dpi = 96)
}


# Kommun

nybygg_kommun <- function(){
  # Läser in data 
  df_nybyggda <- read.csv('Data/df_nybyggda.csv')
  df_befolkf <- read.csv('Data/df_befolkf.csv')
  
  # Liknande kod som ovan men summerar per kommun
  # Summerar antal per kommu och år, efter 2012
  tid_df_nybyggda <- df_nybyggda %>% 
    filter( as.numeric(år) > 2012
    ) %>% 
    group_by(region, upplåtelseform, år) %>%   
    summarise(nybygg = sum(Antal), .groups = "drop")
  
  tid_df_nybyggda$år <- as.integer(tid_df_nybyggda$år)
  
  nybyggda_total <- tid_df_nybyggda %>% 
    group_by(år, region) %>%   
    summarise(Total_nybygg = sum(nybygg), .groups = "drop")
  
  
  tid_df_befolkf <- df_befolkf %>% rename(Antal_personer = Antal.personer) %>%  filter(as.numeric(år) > 2012) %>% 
    group_by(region, år) %>%  summarise(Total_personer = sum(Antal_personer), .groups = "drop")
  
  tid_nybygg_befolk <- tid_df_nybyggda %>%
    left_join(tid_df_befolkf, by = c('region',"år"))%>%
    left_join(nybyggda_total, by = c('region',"år"))
  
  # gör long-df för linjerna
  lines_df <- tid_nybygg_befolk %>%
    select(region, år, Total_nybygg, Total_personer) %>%
    tidyr::pivot_longer(
      cols = c(Total_nybygg, Total_personer),
      names_to = "Typ",
      values_to = "Total"
    )
  
  tid_nybygg_befolk$upplåtelseform <- factor(
    tid_nybygg_befolk$upplåtelseform,
    levels = c("hyresrätt", "bostadsrätt", "äganderätt")  # ordning som du vill ha
  )
  
  tid_nybygg_befolk <- tid_nybygg_befolk %>%
    mutate(år = as.integer(år))
  
  lines_df <- lines_df %>%
    mutate(år = as.integer(år))
  
  plot_tid_nybygg_befolk <- function(kommun_val){
    p <- tid_nybygg_befolk %>%
      filter(region == kommun_val) %>%
      ggplot(aes(x = år)) +
      
      # bars per upplåtelseform
      geom_col(aes(y = nybygg, fill = upplåtelseform),
               position = position_dodge(width = 0.9), width = 0.8) +
      
      # linjer (nu kommer färgerna från Typ)
      geom_line(data = lines_df %>% filter(region == kommun_val),
                aes(x = år, y = Total, color = Typ, group = Typ),
                linewidth = 1.2) +
      geom_text(data = lines_df%>% filter(region == kommun_val),
                aes(x = år, y = Total, label = Total),
                vjust = -1, size = 5,show.legend = FALSE) +
      scale_x_continuous(
        breaks = seq(min(tid_nybygg_befolk$år), max(tid_nybygg_befolk$år), by = 2)
      ) +
      scale_fill_manual(
        values = upplat_colors,
        labels = tools::toTitleCase(names(upplat_colors))
      ) +
      scale_color_manual(
        values = c("Total_nybygg" = "#6F787E",
                   "Total_personer" = "#4AA271"),
        labels = c("Total_nybygg" = "Nybyggda bostäder",
                   "Total_personer" = "Befolkningsförändring")
      ) +
      labs(title = kommun_val,
           x="", y = "Antal",
           fill = "",
           color = "" ) +
      theme_get()+ theme(
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
    
    p
  }
  
  # loopar över kommunerna och sparar plot
  for (r in unique(tid_nybygg_befolk$region)) {
    p <- plot_tid_nybygg_befolk(r)
    
    
    # spara plot som SVG
    file_name <- paste0("Figurer/plot_tid_nybygg_befolk_", r, ".svg")
    ggsave(filename = file_name, plot = p, width = 14, height = 8, device = "svg")
    
    # png
    file_name <- paste0("Figurer/plot_tid_nybygg_befolk_", r, ".png")
    ggsave(filename = file_name, plot = p, width = 14, height = 8, device = "png",
           dpi = 96)
    
    
  }
  
  
}

