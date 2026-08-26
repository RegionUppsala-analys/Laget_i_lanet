
somn <- function(){
  # Läsa in data  
  df <- read.csv('Data/df_psykiska_variabler.csv') %>% filter(Region %in% c(
    "Riket","Uppsala län"))
  
  # Gör till wide
  df <- df %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                           names_from = `Andel.och.konfidensintervall`, 
                           values_from = c( Sömnbesvär, Lätta.sömnbesvär, Svåra.sömnbesvär))
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")

  etiketter <- df %>%
    group_by(Kön) %>%
    filter(År == max(År)) %>%
    ungroup()
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y = Sömnbesvär_Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5) + geom_point(size=2)+
    geom_ribbon(aes(ymin = `Sömnbesvär_Konfidensintervall nedre gräns`, ymax = `Sömnbesvär_Konfidensintervall övre gräns`), alpha = 0.3, color =NA) +
    geom_text_repel(data = etiketter, aes(label = round(Sömnbesvär_Andel, 1)),
            direction = "y", nudge_x = 0.3, hjust = 0,
            segment.color = NA, show.legend = FALSE) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Sömnbesvär_Andel, group = Kön, color = Kön),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=20),
                       limits = c(0,100))+
    scale_x_discrete(breaks = c(min(df$År), max(df$År)),
             expand = expansion(mult = c(0.02, 0.10))) +
    
    labs(x="",
         title = str_wrap("Andel med sömnbesvär – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         y = "Andel (%)",
         color="",
         fill="",
         subtitle = str_wrap("Streckade linjer är Riksandelen", width = 50))+
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'))
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/somn.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/somn.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}

svara_somn <-  function(){
  # Läsa in data  
  df <- read.csv('Data/df_psykiska_variabler.csv') %>% filter(Region %in% c(
    "Riket","Uppsala län"))
  
  # Gör till wide
  df <- df %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                           names_from = `Andel.och.konfidensintervall`, 
                           values_from = c( Sömnbesvär, Lätta.sömnbesvär, Svåra.sömnbesvär))
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")

  etiketter <- df %>%
    group_by(Kön) %>%
    filter(År == max(År)) %>%
    ungroup()
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y = Svåra.sömnbesvär_Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = `Svåra.sömnbesvär_Konfidensintervall nedre gräns`, ymax = `Svåra.sömnbesvär_Konfidensintervall övre gräns`), alpha = 0.3, color =NA) +
    geom_text_repel(data = etiketter, aes(label = round(Svåra.sömnbesvär_Andel, 1)),
            direction = "y", nudge_x = 0.3, hjust = 0,
            segment.color = NA, show.legend = FALSE) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Svåra.sömnbesvär_Andel, group = Kön, color = Kön),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = c(min(df$År), max(df$År)),
             expand = expansion(mult = c(0.02, 0.10))) +
    
    labs(x="",
         title = str_wrap("Andel med svåra sömnbesvär – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         y = "Andel (%)",
         color="",
         fill="",
         subtitle = str_wrap("Streckade linjer är Riksandelen", width = 50))+
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'))
  
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/svara_somn.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/svara_somn.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}


oro_angest <-  function(){
  # Läsa in data  
  df <- read.csv('Data/df_psykiska_variabler.csv') %>% filter(Region %in% c(
    "Riket","Uppsala län"))
  
  # Gör till wide
  df <- df %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                           names_from = `Andel.och.konfidensintervall`, 
                           values_from = Ängslan..oro.eller.ångest)
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")

  etiketter <- df %>%
    group_by(Kön) %>%
    filter(År == max(År)) %>%
    ungroup()
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = `Konfidensintervall nedre gräns`, ymax = `Konfidensintervall övre gräns`), alpha = 0.3, color =NA) +
    geom_text_repel(data = etiketter, aes(label = round(Andel, 1)),
            direction = "y", nudge_x = 0.3, hjust = 0,
            segment.color = NA, show.legend = FALSE) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Andel, group = Kön, color = Kön),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = c(min(df$År), max(df$År)),
             expand = expansion(mult = c(0.02, 0.10))) +
    
    labs(x="",
         title = str_wrap("Andel med ängslan, oro eller ångest – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         y = "Andel (%)",
         color="",
         fill="",
         subtitle = str_wrap("Streckade linjer är Riksandelen", width = 50))+
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'))
  
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/oro_angest.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/oro_angest.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}

svar_oro_angest <-  function(){
  # Läsa in data  
  df <- read.csv('Data/df_psykiska_variabler.csv') %>% filter(Region %in% c(
    "Riket","Uppsala län"))
  
  # Gör till wide
  df <- df %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                           names_from = `Andel.och.konfidensintervall`, 
                           values_from = Svår.ängslan..oro.eller.ångest)
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")

  etiketter <- df %>%
    group_by(Kön) %>%
    filter(År == max(År)) %>%
    ungroup()
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = `Konfidensintervall nedre gräns`, ymax = `Konfidensintervall övre gräns`), alpha = 0.3, color =NA) +
    geom_text_repel(data = etiketter, aes(label = round(Andel, 1)),
            direction = "y", nudge_x = 0.3, hjust = 0,
            segment.color = NA, show.legend = FALSE) +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = c(min(df$År), max(df$År)),
             expand = expansion(mult = c(0.02, 0.10))) +
    labs(x="",
         title = str_wrap("Andel med svåra besvär av ängslan, oro eller ångest – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         y = "Andel (%)",
         color="",
         fill="")+
    theme(plot.caption = element_text(hjust=0))
  
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/svar_oro_angest.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/svar_oro_angest.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}