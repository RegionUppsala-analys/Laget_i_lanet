######### Indikatorer BRÅ ##########


skadebrott <- function(kommun='Uppsala'){
  # filnamn med vald kommun
  filename <- paste0('Data/df_ind_',kommun,'.xlsx')
  
  # Sheet 2 och skippar första raden 
  df <- read_excel(filename, sheet=2, skip=1)
  
  colnames(df)[1] <- 'Region'
  
  # Gör till long, årsvariabel och type
  df_long <- df %>% pivot_longer(
    cols = -Region,
    names_to = "variable",
    values_to = "value"
  ) %>%
    mutate(
      Year = str_extract(variable, "\\d{4}"),
      Type = case_when(
        str_detect(variable, "per 100 000") ~ "Antal per 100 000",
        TRUE ~ "Antal"
      )
    )
  
  # Tar bort länet och riket från antal
  df_long <- df_long %>% filter(!(Region == 'Hela Riket' & Type == 'Antal'))
  df_long <- df_long %>% filter(!(Region == lan & Type == 'Antal'))
  
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  df_long$Year = as.integer(df_long$Year)
  
  # skapar plot
  p <- ggplot(df_long, aes(x= Year, y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+ 
    facet_wrap(~Type, ncol=1,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = "Utveckling av anmälda skadegörelsebrott",
      color = ""
    ) + theme(
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/skadebrott_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/skadebrott_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}

narkotikabrott <- function(kommun='Uppsala'){
  # filnamn med vald kommun
  filename <- paste0('Data/df_ind_',kommun,'.xlsx')
  
  # Sheet 2 och skippar första raden 
  df <- read_excel(filename, sheet=3, skip=1)
  
  colnames(df)[1] <- 'Region'
  
  # Gör till long, årsvariabel och type
  df_long <- df %>% pivot_longer(
    cols = -Region,
    names_to = "variable",
    values_to = "value"
  ) %>%
    mutate(
      Year = str_extract(variable, "\\d{4}"),
      Type = case_when(
        str_detect(variable, "per 100 000") ~ "Antal per 100 000",
        TRUE ~ "Antal"
      )
    )
  
  # Tar bort länet och riket från antal
  df_long <- df_long %>% filter(!(Region == 'Hela Riket' & Type == 'Antal'))
  df_long <- df_long %>% filter(!(Region == lan & Type == 'Antal'))
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  
  df_long$Year = as.integer(df_long$Year)
  
  # skapar plot
  p <- ggplot(df_long, aes(x= Year, y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+ 
    facet_wrap(~Type, ncol=1,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = "Utveckling av anmälda narkotikabrott",
      color = ""
    )+ theme(
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/narkotikabrott_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/narkotikabrott_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}

vald_utomhus_vuxna <- function(kommun='Uppsala'){
  # filnamn med vald kommun
  filename <- paste0('Data/df_ind_',kommun,'.xlsx')
  
  # Sheet 2 och skippar första raden 
  df <- read_excel(filename, sheet=4, skip=1)
  
  colnames(df)[1] <- 'Region'
  
  # Gör till long, årsvariabel och type
  df_long <- df %>% pivot_longer(
    cols = -Region,
    names_to = "variable",
    values_to = "value"
  ) %>%
    mutate(
      Year = str_extract(variable, "\\d{4}"),
      Type = case_when(
        str_detect(variable, "per 100 000") ~ "Antal per 100 000",
        TRUE ~ "Antal"
      )
    )
  
  # Tar bort länet och riket från antal
  df_long <- df_long %>% filter(!(Region == 'Hela Riket' & Type == 'Antal'))
  df_long <- df_long %>% filter(!(Region == lan & Type == 'Antal'))
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  df_long$Year = as.integer(df_long$Year)
  
  # skapar plot
  p <- ggplot(df_long, aes(x= Year, y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+ 
    facet_wrap(~Type, ncol=1,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = str_wrap("Utveckling av anmälda våldsbrott utomhus, vuxna", width = 40),
      color = ""
    )+ theme(
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/vald_vuxen_utomhus_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/vald_vuxen_utomhus_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}

VINR_kvinnor <- function(kommun='Uppsala'){
  # filnamn med vald kommun
  filename <- paste0('Data/df_ind_',kommun,'.xlsx')
  
  # Sheet 2 och skippar första raden 
  df <- read_excel(filename, sheet=5, skip=1)
  
  colnames(df)[1] <- 'Region'
  
  # Gör till long, årsvariabel och type
  df_long <- df %>% pivot_longer(
    cols = -Region,
    names_to = "variable",
    values_to = "value"
  ) %>%
    mutate(
      Year = str_extract(variable, "\\d{4}"),
      Type = case_when(
        str_detect(variable, "per 100 000") ~ "Antal per 100 000",
        TRUE ~ "Antal"
      )
    )
  
  # Tar bort länet och riket från antal
  df_long <- df_long %>% filter(!(Region == 'Hela Riket' & Type == 'Antal'))
  df_long <- df_long %>% filter(!(Region == lan & Type == 'Antal'))
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  df_long$Year = as.integer(df_long$Year)
  
  # skapar plot
  p <- ggplot(df_long, aes(x= Year, y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+ 
    facet_wrap(~Type, ncol=1,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = "Utveckling av anmält våld i nära relation, \nkvinnor",
      color = ""
    )+ theme(
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/VINR_k_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/VINR_k_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
  
}

VINR_man <- function(kommun='Uppsala'){
  # filnamn med vald kommun
  filename <- paste0('Data/df_ind_',kommun,'.xlsx')
  
  # Sheet 2 och skippar första raden 
  df <- read_excel(filename, sheet=6, skip=1)
  
  colnames(df)[1] <- 'Region'
  
  # Gör till long, årsvariabel och type
  df_long <- df %>% pivot_longer(
    cols = -Region,
    names_to = "variable",
    values_to = "value"
  ) %>%
    mutate(
      Year = str_extract(variable, "\\d{4}"),
      Type = case_when(
        str_detect(variable, "per 100 000") ~ "Antal per 100 000",
        TRUE ~ "Antal"
      )
    )
  
  # Tar bort länet och riket från antal
  df_long <- df_long %>% filter(!(Region == 'Hela Riket' & Type == 'Antal'))
  df_long <- df_long %>% filter(!(Region == lan & Type == 'Antal'))
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  df_long$Year = as.integer(df_long$Year)
  
  # skapar plot
  p <- ggplot(df_long, aes(x= Year, y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+ 
    facet_wrap(~Type, ncol=1,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = "Utveckling av anmält våld i nära relation, \nmän",
      color = ""
    )+ theme(
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/VINR_m_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  
  bildnamn <- paste0("Figurer/VINR_m_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}

vald_barn <- function(kommun='Uppsala'){
  
  df <- data.frame()
  for(i in as.numeric(7:10)){
    # filnamn med vald kommun
    filename <- paste0('Data/df_ind_',kommun,'.xlsx')
    
    # Sheet 2 och skippar första raden 
    df1 <- read_excel(filename, sheet=i, skip=1)
    
    colnames(df1)[1] <- 'Region'
    
    # Gör till long, årsvariabel och type
    df_long <- df1 %>% pivot_longer(
      cols = -Region,
      names_to = "variable",
      values_to = "value"
    ) %>%
      mutate(
        Year = str_extract(variable, "\\d{4}"),
        Type = case_when(
          str_detect(variable, "per 100 000") ~ "Antal per 100 000",
          TRUE ~ "Antal"
        ),
        Var = i # för att veta vilken sheet det är
      )
    df_long <- df_long %>% filter( Type != 'Antal')
    
    df <- rbind(df,df_long)
  }
  df <- df %>%
    mutate(  # Konvertera till numeric om den är factor
      Var = case_when(
        Var == 7 ~ "Våld inomhus flickor",
        Var == 8 ~ "Våld utomhus flickor",
        Var == 9 ~ "Våld inomhus pojkar",
        Var == 10 ~ "Våld utomhus pojkar"
      ))
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  
  # skapar plot
  p <- ggplot(df, aes(x= as.integer(Year), y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+
    facet_wrap(~Var, ncol=2,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = "Utveckling av anmält våld mot barn och unga \nAntal per 100 000",
      color = ""
    ) + theme(axis.text.x = element_text(angle = 45, hjust = 1),
              plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/vald_barn_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/vald_barn_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}

personran_av_barn <- function(kommun='Uppsala'){
  # filnamn med vald kommun
  filename <- paste0('Data/df_ind_',kommun,'.xlsx')
  
  # Sheet 2 och skippar första raden 
  df <- read_excel(filename, sheet=11, skip=1)
  
  colnames(df)[1] <- 'Region'
  
  # Gör till long, årsvariabel och type
  df_long <- df %>% pivot_longer(
    cols = -Region,
    names_to = "variable",
    values_to = "value"
  ) %>%
    mutate(
      Year = str_extract(variable, "\\d{4}"),
      Type = case_when(
        str_detect(variable, "per 100 000") ~ "Antal per 100 000",
        TRUE ~ "Antal"
      )
    )
  
  # Tar bort länet och riket från antal
  df_long <- df_long %>% filter(!(Region == 'Hela Riket' & Type == 'Antal'))
  df_long <- df_long %>% filter(!(Region == lan & Type == 'Antal'))
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  df_long$Year = as.integer(df_long$Year)
  
  # skapar plot
  p <- ggplot(df_long, aes(x= Year, y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+ 
    facet_wrap(~Type, ncol=1,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = "Utveckling av anmälda personrån, unga",
      color = ""
    )+ theme(
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/personran_b_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/personran_b_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}

stoldbrott <- function(kommun='Uppsala'){
  # filnamn med vald kommun
  filename <- paste0('Data/df_ind_',kommun,'.xlsx')
  
  # Sheet 2 och skippar första raden 
  df <- read_excel(filename, sheet=12, skip=1)
  
  colnames(df)[1] <- 'Region'
  
  # Gör till long, årsvariabel och type
  df_long <- df %>% pivot_longer(
    cols = -Region,
    names_to = "variable",
    values_to = "value"
  ) %>%
    mutate(
      Year = str_extract(variable, "\\d{4}"),
      Type = case_when(
        str_detect(variable, "per 100 000") ~ "Antal per 100 000",
        TRUE ~ "Antal"
      )
    )
  
  # Tar bort länet och riket från antal
  df_long <- df_long %>% filter(!(Region == 'Hela Riket' & Type == 'Antal'))
  df_long <- df_long %>% filter(!(Region == lan & Type == 'Antal'))
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  df_long$Year = as.integer(df_long$Year)
  
  # skapar plot
  p <- ggplot(df_long, aes(x= Year, y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+ 
    facet_wrap(~Type, ncol=1,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = "Utveckling av anmälda stöldbrott",
      color = ""
    ) + theme(
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/stoldbrott_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/stoldbrott_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}


bilbrott <- function(kommun='Uppsala'){
  # filnamn med vald kommun
  filename <- paste0('Data/df_ind_',kommun,'.xlsx')
  
  # Sheet 2 och skippar första raden 
  df <- read_excel(filename, sheet=13, skip=1)
  
  colnames(df)[1] <- 'Region'
  
  # Gör till long, årsvariabel och type
  df_long <- df %>% pivot_longer(
    cols = -Region,
    names_to = "variable",
    values_to = "value"
  ) %>%
    mutate(
      Year = str_extract(variable, "\\d{4}"),
      Type = case_when(
        str_detect(variable, "per 100 000") ~ "Antal per 100 000",
        TRUE ~ "Antal"
      )
    )
  
  # Tar bort länet och riket från antal
  df_long <- df_long %>% filter(!(Region == 'Hela Riket' & Type == 'Antal'))
  df_long <- df_long %>% filter(!(Region == lan & Type == 'Antal'))
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  df_long$Year = as.integer(df_long$Year)
  
  # skapar plot
  p <- ggplot(df_long, aes(x= Year, y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+ 
    facet_wrap(~Type, ncol=1,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = "Utveckling av anmälda bilbrott",
      color = ""
    ) + theme(
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/bilbrott_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/bilbrott_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}


bostadsinbrott <- function(kommun='Uppsala'){
  # filnamn med vald kommun
  filename <- paste0('Data/df_ind_',kommun,'.xlsx')
  
  # Sheet 2 och skippar första raden 
  df <- read_excel(filename, sheet=14, skip=1)
  
  colnames(df)[1] <- 'Region'
  
  # Gör till long, årsvariabel och type
  df_long <- df %>% pivot_longer(
    cols = -Region,
    names_to = "variable",
    values_to = "value"
  ) %>%
    mutate(
      Year = str_extract(variable, "\\d{4}"),
      Type = case_when(
        str_detect(variable, "per 100 000") ~ "Antal per 100 000",
        TRUE ~ "Antal"
      )
    )
  
  # Tar bort länet och riket från antal
  df_long <- df_long %>% filter(!(Region == 'Hela Riket' & Type == 'Antal'))
  df_long <- df_long %>% filter(!(Region == lan & Type == 'Antal'))
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  df_long$Year = as.integer(df_long$Year)
  
  # skapar plot
  p <- ggplot(df_long, aes(x= Year, y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+ 
    facet_wrap(~Type, ncol=1,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = "Utveckling av anmälda bostadsinbrott",
      color = ""
    ) + theme(
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/bostadsinbrott_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/bostadsinbrott_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}


trafikbrott <- function(kommun='Uppsala'){
  # filnamn med vald kommun
  filename <- paste0('Data/df_ind_',kommun,'.xlsx')
  
  # Sheet 2 och skippar första raden 
  df <- read_excel(filename, sheet=15, skip=1)
  
  colnames(df)[1] <- 'Region'
  
  # Gör till long, årsvariabel och type
  df_long <- df %>% pivot_longer(
    cols = -Region,
    names_to = "variable",
    values_to = "value"
  ) %>%
    mutate(
      Year = str_extract(variable, "\\d{4}"),
      Type = case_when(
        str_detect(variable, "per 100 000") ~ "Antal per 100 000",
        TRUE ~ "Antal"
      )
    )
  
  # Tar bort länet och riket från antal
  df_long <- df_long %>% filter(!(Region == 'Hela Riket' & Type == 'Antal'))
  df_long <- df_long %>% filter(!(Region == lan & Type == 'Antal'))
  
  kommun_colors2 <- c(
    kommun_colors,
    setNames("#B81867",lan),  # samma färg som Uppsala
    "Hela Riket"  = "black"   # valfri neutral färg, t.ex. grå
  )
  
  df_long$Year = as.integer(df_long$Year)
  
  # skapar plot
  p <- ggplot(df_long, aes(x= Year, y=value , color = Region)) +
    geom_line(linewidth=2) + geom_point(size = 3)+ 
    facet_wrap(~Type, ncol=1,scales = "free_y") +
    scale_color_manual(values = kommun_colors2) +
    labs(
      x = " ",
      y = NULL,
      title = "Utveckling av anmälda trafikbrott",
      color = ""
    ) + theme(
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: BRÅ')
  
  bildnamn <- paste0("Figurer/trafikbrott_",kommun,".svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  
  bildnamn <- paste0("Figurer/trafikbrott_",kommun,".png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}

