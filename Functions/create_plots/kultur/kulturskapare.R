####### Kod för att skapa efterliknande plots som region halland ######


hist_utveckling <- function(){
  # Har ej med länsnamnen i df
  #  Hämta metadata för variabeln Region i ett SCB API-schema
  url_meta <- "https://api.scb.se/OV0104/v1/doris/sv/ssd/BE/BE0101/BE0101A/BefolkningNy"
  
  res <- pxweb_get(url_meta)
  
  lanskod <- res$variables[[1]]$values
  lansnamn <- res$variables[[1]]$valueTexts
  lan_lookup <- tibble(
    AstLan  = lanskod,
    lan_namn = lansnamn
  ) %>%
    # behåll endast koder med exakt 2 tecken
    filter(str_length(AstLan) == 2) %>%
    mutate(AstLan = as.integer(AstLan))
  
  
  
  # läser in data
  df <- read.csv("Data/Myfiles/data_utveckling_kultur_lan.csv")
  
  # Matcha
  df <- df %>%
    left_join(lan_lookup, by = "AstLan")
  
  
  # Skapar index
  df_index <- df %>%
    mutate(
      total_kkb = Kulturskapare + `Ej.kulturskapare.men.företagare.inom.KKB`
    ) %>%
    arrange(AstLan, year) %>%
    group_by(AstLan) %>%
    mutate(
      index = 100 * total_kkb / first(total_kkb)
    ) %>%
    ungroup()
  
  # Identifiera sista året
  last_year <- max(df_index$year)
  
  df_last <- df_index %>%
    filter(year == last_year)
  
  # Län med lägst och högst index sista året (namn)
  lowest_lan  <- df_last %>% slice_min(index, n = 1) %>% pull(lan_namn)
  highest_lan <- df_last %>% slice_max(index, n = 1) %>% pull(lan_namn)
  
  # Län som ska highlightas (namn istället för kod)
  highlight_lan <- unique(c("Riket", "Uppsala län" ,lowest_lan, highest_lan))  # "03" = AstLan 3
  
  # Skapa färggrupp baserat på lan_namn
  df_index <- df_index %>%
    mutate(
      line_group = case_when(
        AstLan == 3 ~ "Uppsala län" ,
        lan_namn %in% highlight_lan ~ "highlight",
        TRUE ~ "other"
      )
    )
  
  # Etiketter
  df_labels <- df_index %>%
    filter(year == last_year, lan_namn %in% highlight_lan)
  
  #  Plot 
  p <- ggplot(df_index, aes(x = year, y = index, group = lan_namn)) +
    # Alla andra län (ljusgrå)
    geom_line(
      data = df_index %>% filter(line_group == "other"),
      colour = "grey80",
      size = 0.6
    )+ 
    geom_hline(yintercept = 100, linetype = "dashed", colour = "black")+
    # Highlightade grå län
    geom_line(
      data = df_index %>% filter(line_group == "highlight"),
      colour = "grey40",
      size = 1.1
    ) +
    geom_line(
      data = df_index %>% filter(line_group == "Uppsala län"),
      colour = "#B81867",
      size = 1.3
    ) +
    # Textetiketter
    geom_text(
      data = df_labels,
      aes(label = lan_namn),
      hjust = -0.05,
      size = 4,
      colour = ifelse(df_labels$AstLan == 3, "#B81867", "grey30")
    ) +
    coord_cartesian(clip = "off") +  
    labs(
      title = str_wrap("Utveckling i antal av dagbefolkning 20-64 år, med kulturella och kreativa yrken",width=50),
      subtitle =  "Basår = 2014",
      x = "",
      y = "Index (2014 = 100)",
      caption = "Källa: Databearbetning av Region Uppsala, SCB"
    )+theme(
      plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
      plot.margin =grid::unit(c(15, 100, 15, 15), "pt"),
      plot.caption = element_text(hjust=0))
  
  p
  
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/kulturindex_lan.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/kulturindex_lan.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}


kategorier <- function(){
  # läser in data
  df <- read.csv("Data/Myfiles/data_kategorier_lan.csv")
  
  df <- df %>% arrange(Antal) %>%   # sortera efter värde
    mutate(Kategori = factor(Kategori, levels = Kategori)) # fixera ordning
  
  p <- ggplot(df, aes(x=Antal, y=Kategori))+
    geom_col(fill = "#B81867")+ 
    geom_text(aes(label = Antal), 
              hjust = 1.2,    # lite utanför baren
              size = 4,        # textstorlek
              colour = "white") +
    labs(
      y="",
      title=str_wrap("Antal kulturskapare i Uppsala län efter ämnesområde, år 2023", width=60),
      subtitle = "Dagbefolkning (20-64 år)",
      caption = "Källa: Databearbetning av Region Uppsala, SCB"
    )+theme(plot.title = element_text(hjust=1),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0))
  
  
  p  
  
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/kulturantal_per_kategori.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/kulturantal_per_kategori.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
}

konsfordelning <- function(){
  # läser in data
  df <- read.csv("Data/Myfiles/data_konsfordelning_lan.csv")
  
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  df <- df %>%
    group_by(Kategori) %>%
    mutate(andel_kvinnor = Andel[Kon_txt == "Kvinnor"],
           Andel= Andel*100) %>%
    ungroup() %>%
    mutate(Kategori = factor(Kategori, levels = df %>%
                               filter(Kon_txt == "Kvinnor") %>%
                               arrange(Andel) %>%
                               pull(Kategori)))
  
  
  n_kat <- length(unique(df$Kategori))
  
  # Skapa barplot med “dimma” i x-led (0.4–0.6)
  p<-ggplot(df, aes(x = Andel, y = Kategori, fill = Kon_txt)) +
    
    
    geom_col(position = "stack") +        # staplade barer
    scale_fill_manual(values = kon_col) + # använd din färgskala
    # Dimma bakom barerna
    geom_rect(
      xmin = 40, xmax = 60,
      ymin = 0.55, ymax = n_kat +0.45,
      fill = "lightgrey", alpha = 0.05,
      inherit.aes = FALSE
    ) +
    # Lägg till text på varje bar
    geom_text(aes(label = paste0(round(Andel,1), "%")),
              position = position_stack(vjust = 0),
              hjust=-0.05,
              size = 4,
              colour = "black") +
    labs(
      x = "Andel (%)",
      y = "",
      title = "Könsfördelning bland kulturskaparna, år 2023",
      subtitle = str_wrap("Dagbefolkning (20-64 år), grå area markerar jämställd fördelning",width=50),
      caption = "Källa: Databearbetning av Region Uppsala, SCB",
      fill=""
    )+theme(plot.title = element_text(hjust=1),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            legend.position = "top")
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/konsfordelning_kultur.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/konsfordelning_kultur.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
}

fodelseland <- function(){
  # läser in data
  df <- read.csv("Data/Myfiles/data_fodelseland_lan.csv")
  
  kon_col <- c("Inrikes född" = "#F9B000",
               "Utrikes född" = "#4AA271")
  
  df <- df %>%
    group_by(Kategori) %>%
    mutate(andel_inr = Andel[UtlSvBakg == "Inrikes född"],
           Andel = Andel*100) %>%
    ungroup() %>%
    mutate(Kategori = factor(Kategori, levels = df %>%
                               filter(UtlSvBakg == "Inrikes född") %>%
                               arrange(Andel) %>%
                               pull(Kategori)))
  
  
  n_kat <- length(unique(df$Kategori))
  
  # Skapa barplot med “dimma” i x-led (0.4–0.6)
  p<-ggplot(df, aes(x = Andel, y = Kategori, fill = UtlSvBakg)) +
    
    
    geom_col(position = "stack") +        # staplade barer
    scale_fill_manual(values = kon_col) + # använd din färgskala
    # Lägg till text på varje bar
    geom_text(aes(label = paste0(round(Andel,1), "%")),
              position = position_stack(vjust = 0),
              hjust=-0.05,
              size = 4,
              colour = "black") +
    labs(
      x = "Andel (%)",
      y = "",
      title = "Födelseregionsfördelning bland kulturskaparna, år 2023",
      subtitle = "Dagbefolkning (20-64 år)",
      caption = "Källa: Databearbetning av Region Uppsala, SCB",
      fill=""
    )+theme(plot.title = element_text(hjust=1),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            legend.position = "top")
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/fodelseland_kultur.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/fodelseland_kultur.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
}

alder <- function(){
  # läser in data
  df <- read.csv("Data/Myfiles/data_alder_lan.csv")
  
  kon_col <- c("20 - 34 år" = "#F9B000",
               "35 - 49 år" = "#4AA271",
               "50 - 64 år" ="#D57667")
  
  df <- df %>% mutate(aldersgrupp = factor(aldersgrupp,
                                           levels =c("20 - 34 år","35 - 49 år",
                                                     "50 - 64 år" )))
  
  df <- df %>%
    group_by(Kategori) %>%
    mutate(andel_inr = Andel[aldersgrupp      == "50 - 64 år"]) %>%
    ungroup() %>%
    mutate(Kategori = factor(Kategori, levels = df %>%
                               filter(aldersgrupp      == "50 - 64 år") %>%
                               arrange(Andel) %>%
                               pull(Kategori)))
  
  
  n_kat <- length(unique(df$Kategori))
  
  # Skapa barplot med “dimma” i x-led (0.4–0.6)
  p<-ggplot(df, aes(x = Andel, y = Kategori, fill = aldersgrupp     )) +
    
    
    geom_col(position = position_stack(reverse = TRUE)) +        # staplade barer
    scale_fill_manual(values = kon_col) + # använd din färgskala
    # Lägg till text på varje bar
    geom_text(aes(label = paste0(round(Andel,1), "%")),
              position = position_stack(vjust = 0, reverse = TRUE),
              hjust=-0.05,
              size = 4,
              colour = "black") +
    labs(
      x = "Andel (%)",
      y = "",
      title = "Åldersfördelning bland kulturskaparna, år 2023",
      subtitle = "Dagbefolkning (20-64 år)",
      caption = "Källa: Databearbetning av Region Uppsala, SCB",
      fill=""
    )+theme(plot.title = element_text(hjust=1),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            legend.position = "top")
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/alder_kultur.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/alder_kultur.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
}


inkomst <- function(){
  # läser in data
  df <- read.csv("Data/Myfiles/data_inkomst_lan.csv")
  
  df <- df %>% arrange(Median_Inkomst ) %>%   # sortera efter värde
    mutate(Kategori = factor(Kategori, levels = Kategori)) # fixera ordning
  
  p <- ggplot(df, aes(x=Median_Inkomst , y=Kategori))+
    geom_col(fill = "#B81867")+ 
    geom_text(aes(label = round(Median_Inkomst/1000,0)), 
              hjust = 1.2,    # lite utanför baren
              size = 4,        # textstorlek
              colour = "white") +
    labs(
      y="",
      title=str_wrap("Kulturskaparnas inkomst från arbete, arbetsinkomst före skatt | lön eller inkomst från näringsverksamhet, år 2023", width=60),
      subtitle = "Dagbefolkning (20-64 år), tusental kronor",
      caption = "Källa: Databearbetning av Region Uppsala, SCB",
      x="Medianinkomst (tkr)"
    )+theme(plot.title = element_text(hjust=1),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            axis.text.x = element_blank())
  
  
  p  
  
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/inkomst_kultur.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/inkomst_kultur.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
}

kommun_fordelning <- function(){
  #  Hämta metadata för variabeln Region i ett SCB API-schema
  url_meta <- "https://api.scb.se/OV0104/v1/doris/sv/ssd/BE/BE0101/BE0101A/BefolkningNy"
  
  res <- pxweb_get(url_meta)
  
  lanskod <- res$variables[[1]]$values
  lansnamn <- res$variables[[1]]$valueTexts
  
  lan_lookup <- tibble(
    AstKommun  = lanskod,
    Kommun = lansnamn
  ) %>%
    # behåll endast koder med exakt 2 tecken
    filter(str_length(AstKommun) == 4)
  
  
  # läser in data
  df <- read.csv("Data/Myfiles/data_utveckling_kultur_kommun.csv") %>%
    filter(year ==max(year )) %>% mutate(AstKommun = paste0(0,AstKommun))
  
  # Matcha 
  df <- df %>%
    left_join(lan_lookup, by = "AstKommun")
  
  df[df$AstKommun== '03',6] <- "Uppsala län"
  
  df <- df %>% mutate(Kommun = factor(Kommun, levels = sort(Kommun,decreasing =T)),
                      Andel =(totalt_kulturskapare /totalt)*100 ) # fixera ordning
  
  p <- ggplot(df, aes(x=Andel  , y=Kommun))+
    geom_col(fill = "#B81867")+ 
    geom_text(aes(label = round(totalt_kulturskapare)), 
              hjust = 1.2,    # lite utanför baren
              size = 4,        # textstorlek
              colour = "white") +
    labs(
      y="",
      title=str_wrap("Kulturskaparnas geografiska spridning, dagbefolkning (20-64 år), år 2023", width=50),
      subtitle = "Stapelnslängd visar andelen och siffran antalet",
      caption = "Källa: Databearbetning av Region Uppsala, SCB",
      x="Andel (%)"
    )+theme(plot.title = element_text(hjust=0.5),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0))
  
  
  p  
  
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/kommun_kultur.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/kommun_kultur.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
}
