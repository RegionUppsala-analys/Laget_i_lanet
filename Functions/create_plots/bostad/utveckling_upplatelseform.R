###### Utvekling upplåtelseformer #######
# region
region_utv_upp <- function(){
  df_supplatelse <- read.csv('Data/df_supplatelse.csv')
  # Liknande kod som ovan men summering över hela regionen
  tid_bostad_befolk <- df_supplatelse %>% 
    filter(
      hustyp != "specialbostäder",
      upplåtelseform != "uppgift saknas",
      as.numeric(år) > 2012
    ) %>% 
    group_by(upplåtelseform, år) %>%   # <-- no region grouping
    summarise(Total = sum(Antal), .groups = "drop")
  
  tid_bostad_befolk_totals <- tid_bostad_befolk %>%
    group_by(år) %>%
    summarise(Total_all = sum(Total), .groups = "drop")
  
  tid_bostad_befolk <- tid_bostad_befolk_totals %>%
    left_join(tid_bostad_befolk, by = "år")
  
  
  
  # Se till att år är numeriskt
  tid_bostad_befolk <- tid_bostad_befolk %>%
    mutate(
      år = as.integer(år),
      upplåtelseform = factor(upplåtelseform,
                              levels = c("hyresrätt","bostadsrätt","äganderätt"))
    )
  
  # Gör long-df för linjerna
  lines_df <- tid_bostad_befolk %>%
    select(år, Total_all) %>%
    distinct() %>%        # undvik dubbletter från flera upplåtelseformer
    tidyr::pivot_longer(
      cols = c(Total_all),
      names_to = "Typ",
      values_to = "Total"
    )
  
  # Plot
  p <- ggplot() +
    # staplar
    geom_col(data = tid_bostad_befolk,
             aes(x = år, y = Total, fill = upplåtelseform),
             position = position_dodge(width = 0.9), width = 0.8) +
    
    # linje för total
    geom_line(data = lines_df,
              aes(x = år, y = Total, color = Typ, group = Typ),
              linewidth = 1.2) +
    
    # x-axel varannat år
    scale_x_continuous(
      breaks = seq(min(tid_bostad_befolk$år, na.rm = TRUE),
                   max(tid_bostad_befolk$år, na.rm = TRUE),
                   by = 2)
    ) +
    
    # färger för staplar (upplåtelseformer)
    scale_fill_manual(
      values = upplat_colors,
      labels = tools::toTitleCase(names(upplat_colors))
    ) +
    
    # färger för linjen (total)
    scale_color_manual(
      values = c("Total_all" = "#B81867"),
      labels = c("Total_all" = "Totalt")
    ) +
    
    labs(
      title = "Utveckling av upplåtelseformer",
      x="", y = "Antal",
      fill = "Upplåtelseform",
      color = ""   # rubrik för linjen
    ) +theme(
      text = element_text(family = "sourcesanspro", size = 14),
      axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
  
  p
  
  ggsave('Figurer/region_utv_upp.svg',plot = p,device = "svg", width = 8, height = 5)
  ggsave('Figurer/region_utv_upp.png',plot = p,device = "png", width = 8, height = 5,
         dpi = 96)
  
}

# kommun 

kommun_utv_upp <- function(){
  df_supplatelse <- read.csv('Data/df_supplatelse.csv')
  # plockar ut alla ägande småhus, hyresbostäder i flerbostadshus och småhus från 2012(då knivsta blev egen kommun)
  tid_bostad_befolk <- df_supplatelse %>% filter(hustyp != 'specialbostäder',upplåtelseform != 'uppgift saknas', as.numeric(år) > 2012) %>% 
    group_by(region, upplåtelseform, år)  %>%
    summarise(Total = sum(Antal), .groups = "drop")
  
  tid_bostad_befolk_totals <- tid_bostad_befolk %>%
    group_by(region, år) %>%
    summarise(Total_all = sum(Total), .groups = "drop")
  
  
  
  tid_bostad_befolk <- tid_bostad_befolk_totals %>% left_join(tid_bostad_befolk, by = c('region', 'år'))
  #ggplot(tid_bostad_befolk, aes(x = år, y = Total, fill=upplåtelseform)) + geom_col()
  
  tid_bostad_befolk$upplåtelseform <- factor(
    tid_bostad_befolk$upplåtelseform,
    levels = c("hyresrätt", "bostadsrätt", "äganderätt")  # ordning som du vill ha
  )
  
  upplatelse_plot_func <- function(kommun_val){
    
    # filtrera för vald kommun
    df <- tid_bostad_befolk %>%
      filter(region == kommun_val) %>%
      mutate(år = as.integer(år))
    
    # egen df för linjen (så vi inte får dubletter)
    lines_df <- df %>%
      select(år, Total_all) %>%
      distinct() %>%
      tidyr::pivot_longer(
        cols = c(Total_all),
        names_to = "Typ",
        values_to = "Total"
      )
    
    p <- ggplot() +
      # staplar per upplåtelseform
      geom_col(data = df,
               aes(x = år, y = Total, fill = upplåtelseform),
               position = position_dodge(width = 0.9), width = 0.8) +
      
      # linje för Totalt
      geom_line(data = lines_df,
                aes(x = år, y = Total, color = Typ, group = Typ),
                linewidth = 1.2) +
      
      scale_x_continuous(
        breaks = seq(min(df$år, na.rm = TRUE),
                     max(df$år, na.rm = TRUE),
                     by = 2)
      ) +
      
      # färger för staplar (upplåtelseformer)
      scale_fill_manual(
        values = upplat_colors,
        labels = tools::toTitleCase(names(upplat_colors))
      ) +
      
      # färger för linjen
      scale_color_manual(
        values = c("Total_all" = "black"),
        labels = c("Total_all" = "Totalt")
      ) +
      
      labs(
        title = kommun_val,
        x="", y = "Antal",
        fill = "Upplåtelseform",
        color = ""  # rubrik för linjen i legend
      ) +
      theme_get() + theme(
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
    
    p
  }
  
  
  for (r in unique(tid_bostad_befolk$region)) {
    p <- upplatelse_plot_func(r)
    
    
    # spara plot som SVG
    file_name <- paste0("Figurer/plot_upplatelseform_", r, ".svg")
    ggsave(filename = file_name, plot = p, width = 14, height = 8, device = "svg")
    
    # png
    # spara plot som SVG
    file_name <- paste0("Figurer/plot_upplatelseform_", r, ".png")
    ggsave(filename = file_name, plot = p, width = 14, height = 8, device = "png",
           dpi = 96)
    
    
  }
  
  
}


