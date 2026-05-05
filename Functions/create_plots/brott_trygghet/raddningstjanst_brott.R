

######### Kolada #########


# Avvikelse anmältbrott våld

avvikelse_vald <- function(){
  # filnamn med vald kommun
  df <- read.csv('Data/df_avvikelse_brott.csv')
  
  # Sätter labels och gör till faktor
  df <- df %>% mutate(value = case_when(value =="0"~"Fler än",
                                        value =="1"~"Lika många",
                                        value =="2"~"Färre än")) 
  
  df$value <- factor(df$value, levels = c("Fler än", "Lika många", "Färre än"))
  
  df$municipality <- factor(df$municipality, levels = sort(unique(df$municipality), decreasing = T))
  
  # snyggar till titeln
  df$title <- sub(",.*", "", df$title)
  
  # Färgschema
  niva_col <- c('Fler än' = "#D0342C",
                "Lika många" = "#019CD7",
                "Färre än" = "#4AA271")
  
  # Skapar i för att inte få så långt namn på bilden (tex använda t)
  i <- 0
  # skapar plot
  for(t in unique(df$title)){
    temp <- df %>%  filter(title == t)
    i <- i+1
    
    # Factorvariabel
    temp$year = factor(temp$year)
    
    p <- ggplot(temp, aes(x= year, y=municipality , fill = value)) +
      geom_tile(color = "white")+
      scale_fill_manual(values = niva_col) +
      scale_x_discrete(breaks = seq(min(df$year), max(df$year), by = 2))+
      labs(
        x = " ",
        y = NULL,
        title = str_wrap(t,width = 50),
        fill = ""
      )  + theme(
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada och MSB')
    
    
    bildnamn <- paste0("Figurer/avvikelse_brott_",i,".svg")
    
    ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
    
    bildnamn <- paste0("Figurer/avvikelse_brott_",i,".png")
    
    ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
    
  }
}

# Brandförsvar och samverkan


brandforsvar <- function(){
  # Läser in data
  df <- read.csv("Data/df_brander.csv")
  
  df$year = as.integer(df$year)
  df$municipality <- factor(df$municipality, levels = sort(unique(df$municipality), decreasing = F))
  
  # snyggar till titeln
  df$title <- sub(",.*", "", df$title)
  
  # skapar plot
  p <- ggplot(df, aes(x= year, y=value , color = municipality)) +
    geom_line(linewidth=2)+geom_point(size=3)+
    scale_color_manual(values = kommun_colors) +
    scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 2))+
    labs(
      x = " ",
      y = "Antal/1000 invånare",
      title = str_wrap(unique(df$title),width = 50),
      color = ""
    ) + theme(legend.position = 'bottom',
              plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada och MSB')
  
  
  bildnamn <- paste0("Figurer/brandforsvar.svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/brandforsvar.png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
  
}

ivpa <- function(){
  # Läser in data
  df <- read.csv("Data/df_ivpa.csv")
  # Filtrerar ut rätt variabel
  df <- df %>% filter(title =="IVPA-insatser (i väntan på ambulans), antal/1000 inv")
  
  # Fixar till variabler till rätt format
  df$year = as.integer(df$year)
  df$municipality <- factor(df$municipality, levels = sort(unique(df$municipality), decreasing = F))
  
  # snyggar till titeln
  df$title <- sub(",.*", "", df$title)
  
  # skapar plot
  p <- ggplot(df, aes(x= year, y=value , color = municipality)) +
    geom_line(linewidth=2)+geom_point(size=3)+
    scale_color_manual(values = kommun_colors) +
    scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 2))+
    labs(
      x = " ",
      y = "Antal/1000 invånare",
      title = str_wrap(unique(df$title),width = 50),
      color = ""
    ) + theme(legend.position = 'bottom',
              plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada och MSB')
  
  
  bildnamn <- paste0("Figurer/ivpa.svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/ivpa.png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}

# Tider 

responstid <- function(){
  # Läser in data
  df <- read.csv("Data/df_responstid.csv")
  
  # ficar till variabler till rätt format
  df$year = as.integer(df$year)
  df$municipality <- factor(df$municipality, levels = sort(unique(df$municipality), decreasing = F))
  
  # snyggar till titeln
  df$title <- sub(",.*", "", df$title)
  
  # skapar plot
  p <- ggplot(df, aes(x= year, y=value , color = municipality)) +
    geom_line(linewidth=2)+geom_point(size=3)+
    scale_color_manual(values = kommun_colors) +
    scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 2))+
    labs(
      x = " ",
      y = "Mediantid i minuter",
      title = str_wrap(paste(unique(df$title)),width = 50),
      color = ""
    ) + theme(legend.position = 'bottom',
              plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada och SOS Alarm')
  
  p
  bildnamn <- paste0("Figurer/responstid.svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  
  bildnamn <- paste0("Figurer/responstid.png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi = 96)
}

# Kostnader

kostnad_olycka <-  function(){
  # Läser in data
  df <- read.csv("Data/df_kost_olycka.csv")
  
  # Fixar till variabler till rätt format
  df$year = as.integer(df$year)
  df$municipality <- factor(df$municipality, levels = sort(unique(df$municipality), decreasing = F))
  
  # snyggar till titeln
  df$title <- sub(",.*", "", df$title)
  
  # skapar plot
  p <- ggplot(df, aes(x= year, y=value , color = municipality)) +
    geom_line(linewidth=2)+geom_point(size=3)+
    scale_color_manual(values = kommun_colors) +
    scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 2))+
    labs(
      x = " ",
      y = "Kr/invånare",
      title = str_wrap("Kostnad för olyckor, totalt",width = 50),
      color = ""
    ) + theme(legend.position = 'bottom',
              plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada och MSB')
  
  
  bildnamn <- paste0("Figurer/kostnad.svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/kostnad.png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi = 96)
}

# Modellberäknat värde 

avvikelse_sjukhus <- function(){
  # Läser in data
  df <- read.csv('Data/df_avvikelse_olycka.csv')
  
  # Fixar till labels
  df <- df %>% mutate(value = case_when(value =="0"~"Fler än",
                                        value =="1"~"Lika många",
                                        value =="2"~"Färre än")) 
  
  # Fixar till variabel format
  df$value <- factor(df$value, levels = c("Fler än", "Lika många", "Färre än"))
  df$year = as.integer(df$year)
  df$municipality <- factor(df$municipality, levels = sort(unique(df$municipality), decreasing = T))
  
  # snyggar till titeln
  df$title <- sub(",.*", "", df$title)
  
  niva_col <- c('Fler än' = "#D0342C",
                "Lika många" = "#019CD7",
                "Färre än" = "#4AA271")
  
  # Skapar i för att inte få så långt namn på bilden (tex använda t)
  i <- 0
  
  # tar bort na
  df <- df[!is.na(df$value),]
  
  # skapar plot
  for(t in unique(df$title)){
    temp <- df %>%  filter(title == t)
    i <- i+1
    
    
    temp$year = factor(temp$year)
    
    p <- ggplot(temp, aes(x= year, y=municipality , fill = value)) +
      geom_tile(color = "white")+
      scale_fill_manual(values = niva_col) +
      scale_x_discrete(breaks = seq(min(df$year), max(df$year), by = 2))+
      labs(
        x = " ",
        y = NULL,
        title = str_wrap(t,width = 50),
        fill = ""
      ) + theme(
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada och MSB')
    
    
    bildnamn <- paste0("Figurer/avvikelse_raddning",i,".svg")
    
    ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
    
    bildnamn <- paste0("Figurer/avvikelse_raddning",i,".png")
    
    ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi = 96)
    
  }
}


# Olyckor 

olycka <-  function(){
  # Läser in data
  df <- read.csv("Data/df_sjukhusvar_olycka.csv")
  
  # Filtrerar och fixar variabelformat
  df <- df %>% filter(title == "Sjukhusvårdade till följd av oavsiktliga skador (olyckor), antal/1000 inv" )
  df$year = as.integer(df$year)
  df$municipality <- factor(df$municipality, levels = sort(unique(df$municipality), decreasing = F))
  
  # snyggar till titeln
  df$title <- sub(",.*", "", df$title)
  
  # skapar plot
  p <- ggplot(df, aes(x= year, y=value , color = municipality)) +
    geom_line(linewidth=2)+geom_point(size=3)+
    scale_color_manual(values = kommun_colors) +
    scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 2))+
    labs(
      x = " ",
      y = "Antal/1000 invånare",
      title = str_wrap("Sjukhusvårdade till följd av oavsiktliga skador (olyckor)",width = 50),
      color = ""
    ) + theme(legend.position = 'bottom',
              plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada och Socialstyrelsen')
  
  p
  bildnamn <- paste0("Figurer/olycka.svg")
  
  ggsave(bildnamn, plot = p, device = "svg", width = 8, height = 6)
  
  bildnamn <- paste0("Figurer/olycka.png")
  
  ggsave(bildnamn, plot = p, device = "png", width = 8, height = 6, dpi=96)
}

