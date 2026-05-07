

biblioteks_folk <- function(){
  # Läser in folkbiblioteksdata
  df <- read.csv("Data/bibstat_uppsala_kommuner.csv") %>% filter(Bibliotekstyp=="folkbib")
  
  # tar ut variabler
  df <- df %>% 
    select(Bibliotek,Kommunkod, year, Stad,
           Besok01,
           Utlan301,
           Aktiv99)  
  
  # De olika biblioteken
  biblio <- unique(df$Bibliotek)
  
  # Longformat för enkel hantering med facet_wrap
  df_long <- df %>% pivot_longer(cols = c(Besok01,Utlan301,
                                          Aktiv99),
                                 names_to = "Variabel")%>% 
    mutate(Variabel = recode(Variabel,
                             "Aktiv99"  = "Totalt antal aktiva låntagare",
                             "Utlan301" = "Totalt antal lån",
                             "Besok01"  = "Antal fysiska besök"))
  
  
  # Loopar över alla bibliotek
  for (b in biblio){
    temp <- df_long %>% filter(Bibliotek == b)
    
    p <- ggplot(temp, aes(x=year, y=value))+
      geom_line(linewidth=2, color="#B81867")+ 
      geom_point(size=3,color="#B81867")+
      facet_wrap(~Variabel,ncol=1, 
                 scales="free_y")+
      scale_x_continuous(
        breaks = seq(min(temp$year), max(temp$year), by = 2)
      )+
      labs(
        title = paste("Utveckling över tid -", b),
        x = "",
        y = "Antal",
        caption = "Källa: Kungliga biblioteket (KB)"
      ) +
      theme(plot.caption = element_text(hjust=0),
            axis.text.x = element_text(angle=45))
    
    p 
    
    ggsave(
      paste0("Figurer/biblioteks_folk_", b, ".svg"),
      plot   = p,
      width  = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/biblioteks_folk_", b, ".png"),
      plot   = p,
      width  = 8,
      height = 6,
      dpi    = 96
    )
    
  }
  
  
}

biblioteks_antal_lan <- function(){
  #  Hämta metadata för variabeln Region i ett SCB API-schema
  url_meta <- "https://api.scb.se/OV0104/v1/doris/sv/ssd/BE/BE0101/BE0101A/BefolkningNy"
  
  res <- pxweb_get(url_meta)
  
  # tar ut kommun och kommunkoder
  lanskod <- res$variables[[1]]$values
  lansnamn <- res$variables[[1]]$valueTexts
  
  lan_lookup <- tibble(
    Kommunkod  = lanskod,
    Kommun = lansnamn
  ) %>%
    # behåll endast koder med exakt 2 tecken
    filter(str_length(Kommunkod) == 4,
           Kommunkod %in% kommunkod) %>% 
    mutate(Kommunkod= as.integer(Kommunkod))
  
  # Läser in folkbiblioteksdata
  df <- read.csv("Data/bibstat_uppsala_kommuner.csv")
  
  # Matcha 
  df <- df %>%
    left_join(lan_lookup, by = "Kommunkod")
  
  # tar ut variabler
  df <- df %>% 
    select(Bibliotek,Kommun, year, Stad,
           Utlan301,Bibliotekstyp ) %>% group_by(Kommun, year,Bibliotekstyp) %>% 
    summarise(Utlan301=sum(Utlan301), .groups='drop')
  
  # fixar till titlar
  df <- df %>% mutate(Bibliotekstyp = case_when(
    Bibliotekstyp =="skolbib" ~"Skolbibliotek",
    Bibliotekstyp =="friskol"~"Friskolebibliotek",
    Bibliotekstyp =="gymbib"~"Gymnasiebibliotek",
    Bibliotekstyp =="specbib"~"Specialbibliotek",
    Bibliotekstyp =="folkbib"~"Folkbibliotek",
    Bibliotekstyp =="univbib"~"Universitetsbibliotek",
    Bibliotekstyp =="frisgym"~"Friskolegymnasiumsbibliotek",
    Bibliotekstyp =="sjukbib"~"Sjukhusbibliotek"))
  
  # Färgschema
  cols <- c( "#4AA271",
             "#F9B000"  ,
             "#019CD7",
             "#D0342C",
             "#D57667" ,
             "#E67E22",
             "#8B4A9C",
             "#6F787E")
  
  names(cols) <- unique(df$Bibliotekstyp)
  
  # Loopar över alla bibliotek
  for (k in kommuner){
    # Tar ut kommunen
    temp <- df %>% filter(Kommun== k)
    
    # variabel till legenden
    nr <- length(unique(temp$Bibliotekstyp))
    
    p <- ggplot(temp, aes(x=year, y=Utlan301, fill=Bibliotekstyp))+
      geom_col()+
      scale_x_continuous(
        breaks = seq(min(temp$year), max(temp$year), by = 2)
      )+
      scale_y_continuous(labels = scales::label_number())+ 
      scale_fill_manual(values = cols)+
      labs(
        title = paste("Totalt antal lån av fysiskt medium i", k),
        x = "",
        y = "Antal",
        caption = "Källa: Kungliga biblioteket (KB)",
        fill=""
      ) +
      theme(plot.caption = element_text(hjust=0),
            axis.text.x = element_text(angle=45),
            legend.position = "bottom")+
      guides(fill = guide_legend(nrow = 
                                   ifelse(nr>4,3,2)))
    
    p 
    
    ggsave(
      paste0("Figurer/biblioteks_antal_lan_", k, ".svg"),
      plot   = p,
      width  = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/biblioteks_antal_lan_", k, ".png"),
      plot   = p,
      width  = 8,
      height = 6,
      dpi    = 96
    )
    
  }
  
  
}
