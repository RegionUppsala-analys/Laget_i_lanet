########## Företagsregistret arbetsställen ########
#Antal arbetsställen med kulturarbeten, företagsreg
andel_arbets <- function(){
  # Läser in data
  df <- read.csv("Data/df_antal_arbets_kultur.csv")
  
  df <- df %>% mutate(kommun = factor(kommun, levels= sort(unique(df$kommun),decreasing =T)))
  
  # Skapar plot
  p <- ggplot(df, aes(x=kommun, y=Andel))+ geom_col(fill = "#B81867")+ 
    ylim(0,20)+
    labs(x="",
         y="Andel (%)",
         title=str_wrap(paste("Andel aktiva arbetsställen inom kultur, hämtat", unique(df$år)), width=50),
         caption = "Källa: Företagsregistret")+
    theme(axis.text.x = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust=0))
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/andel_arbets", ".svg"),
    plot = p,
    width = 7,
    height = 5
  )
  
  ggsave(
    paste0("Figurer/andel_arbets",  ".png"),
    plot = p,
    width = 7,
    height = 5,
    dpi = 96
  )
}

karta_anst_b_s <- function(){
  
  # Tar in data
  suppressMessages(
    suppressWarnings(
      sf_pts <- st_read("Data/sf_pts_uppsala.gpkg", layer = "firmor",
                        quiet = TRUE)
    ))
  # Shapefil för länet 
  shapefile_path <- "Data/Lan_Sweref99TM/Lan_Sweref99TM_region.shp" 
  suppressMessages( suppressWarnings( 
    lan_shape <- st_read(shapefile_path, quiet = TRUE) )) 
  
  # Tar ut länet 
  lan_shape <- lan_shape %>% filter(LnKod == lanskod) # Ta endast ut det som ligger i länet
  
  lan_shape <- st_transform(lan_shape, 4326)
  
  # skapar karta
  sf_pts <- sf_pts |>
    mutate(
      label_text =  paste(branschkategori, "i ", kommun),
      popup_text = paste0(
        "<b>",  branschkategori, "</b><br/>",
        "<b>Bransch: </b>", bransch_1, "<br/>",
        "<b>Storleksklass: </b>",storleksklass,"<br/>",
        "<b>Kommun: </b>", kommun
      )
    )
  
  
  
  
  
  branschkategori <- sort(unique(sf_pts$branschkategori))
  my_colors <- c("#D57667",  "#F9B000",  "#019CD7",  "#D0342C" , "#4AA271"  ,"#6F787E" , "#8B4A9C",  "#E67E22"
  )
  pal <- setNames(my_colors, branschkategori)
  
  #  Unika storleksklasser för filter
  storleksklass_values <- c(  "0 anställda" , "1-4 anställda" ,"5-9 anställda","10-19 anställda" , "20-49 anställda"  ,  "50-99 anställda", 
                              "100-199 anställda" ,"200-499 anställda")
  
  #  Skapa leaflet-karta
  m <- leaflet(sf_pts) |> addTiles()%>%
    # Add polygons
    addPolygons(data = lan_shape, color = "#B81867", fill = FALSE, weight = 3)
  
  # Lägg till punkter, grupperade på storleksklass
  for (s in storleksklass_values) {
    m <- m |>
      addCircleMarkers(
        data = sf_pts |> filter(storleksklass == s),
        group = s,                      # Grupp = storleksklass
        radius = 6,
        color = ~unname(pal[branschkategori]),  # färg baserat på bransch
        fillColor = ~unname(pal[branschkategori]),
        fillOpacity = 0.6,
        stroke = FALSE,
        label = ~label_text,
        popup = ~popup_text
      )
  }
  
  #  Lägg till legend för branschkategori
  m <- m |>
    addLegend(
      "bottomright",
      colors = my_colors,
      labels = branschkategori,
      title = "Branschkategori",
      opacity = 1
    )
  
  #  Lägg till lagerkontroll för storleksklass
  m <- m |>
    addLayersControl(
      overlayGroups = storleksklass_values,
      options = layersControlOptions(collapsed = FALSE)
    )
  
  m <- m %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        HTML("
        .info.legend { 
          text-align: left !important; 
        }
        .leaflet-control-layers-list { 
          text-align: left !important; 
        }
        .leaflet-control-layers label { 
          text-align: left !important; 
          display: block;
          margin-bottom: 5px;
        }
        .leaflet-control-layers input[type='checkbox'] {
          margin-right: 5px;
        }
      ")
      )
    )
  
  m
  
  
  
  
}

karta_anst_b <- function(){
  
  # Tar in data
  suppressMessages(
    suppressWarnings(
      sf_pts <- st_read("Data/sf_pts_uppsala.gpkg", layer = "firmor",
                        quiet = TRUE)
    ))
  # Shapefil för länet 
  shapefile_path <- "Data/Lan_Sweref99TM/Lan_Sweref99TM_region.shp" 
  suppressMessages( suppressWarnings( 
    lan_shape <- st_read(shapefile_path, quiet = TRUE) )) 
  
  # Tar ut länet 
  lan_shape <- lan_shape %>% filter(LnKod == lanskod) # Ta endast ut det som ligger i länet
  
  lan_shape <- st_transform(lan_shape, 4326)
  
  
  # skapar karta
  sf_pts <- sf_pts |>
    mutate(
      label_text =  paste(branschkategori,"med",storleksklass, "i ", kommun),
      popup_text = paste0(
        "<b>",  branschkategori, "</b><br/>",
        "<b>Bransch: </b>", bransch_1, "<br/>",
        "<b>Storleksklass: </b>",storleksklass,"<br/>",
        "<b>Kommun: </b>", kommun
      )
    )
  
  
  
  
  
  branschkategori <- sort(unique(sf_pts$branschkategori))
  my_colors <- c("#D57667",  "#F9B000",  "#019CD7",  "#D0342C" , "#4AA271"  ,"#6F787E" , "#8B4A9C",  "#E67E22"
  )
  pal <- setNames(my_colors, branschkategori)
  
  
  #  Skapa leaflet-karta
  m <- leaflet(sf_pts) |> addTiles()%>%
    # Add polygons
    addPolygons(data = lan_shape, color = "#B81867", fill = FALSE, weight = 3)
  
  # Lägg till punkter, grupperade på storleksklass
  for (s in branschkategori) {
    m <- m |>
      addCircleMarkers(
        data = sf_pts |> filter(branschkategori == s),
        group = s,                      # Grupp = storleksklass
        radius = 6,
        color = ~unname(pal[branschkategori]),  # färg baserat på bransch
        fillColor = ~unname(pal[branschkategori]),
        fillOpacity = 0.6,
        stroke = FALSE,
        label = ~label_text,
        popup = ~popup_text
      )
  }
  
  #  Lägg till legend för branschkategori
  m <- m |>
    addLegend(
      "bottomright",
      colors = my_colors,
      labels = branschkategori,
      title = "Branschkategori",
      opacity = 1
    )
  
  #  Lägg till lagerkontroll för storleksklass
  m <- m |>
    addLayersControl(
      overlayGroups = branschkategori,
      options = layersControlOptions(collapsed = FALSE)
    )
  
  m <- m %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        HTML("
        .info.legend { 
          text-align: left !important; 
        }
        .leaflet-control-layers-list { 
          text-align: left !important; 
        }
        .leaflet-control-layers label { 
          text-align: left !important; 
          display: block;
          margin-bottom: 5px;
        }
        .leaflet-control-layers input[type='checkbox'] {
          margin-right: 5px;
        }
      ")
      )
    )
  m
  
  
  
}

andel_storlek_kom <- function(){
  # Läser in data
  df <- read.csv("Data/df_antal_arbets_kultur_storlek.csv")
  
  
  
  #  Unika storleksklasser för filter
  df <- df %>% mutate(Storleksklass=factor(Storleksklass ,levels=c("0 anställda" , "1-4 anställda" ,"5-9 anställda","10-19 anställda" , "20-49 anställda"  ,  "50-99 anställda", 
                                                                   "100-199 anställda" ,"200-499 anställda")))
  
  df <- df %>% mutate(Kommun = factor(Kommun, levels= sort(unique(df$Kommun),decreasing =T)))
  
  # plot
  p <- ggplot(df, aes(y = Kommun, x = Andel, fill =Storleksklass  )) +
    geom_col() +scale_fill_manual(values = unname(kommun_colors))+
    labs(
      title = str_wrap(paste("Fördelningen över anställningsplatsernas storleksklasser -",unique(df$År)),width=50),
      x = "Andel (%)",
      y = "",
      caption="Källa: SCB Företagsregistret",
      fill=""
    ) +
    theme(
      legend.position = "bottom",
      plot.title = element_text(),
      plot.caption = element_text(hjust=0)
    )
  
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/andel_storlek_kom.svg"),
    plot = p,
    width = 8,
    height = 5
  )
  
  ggsave(
    paste0("Figurer/andel_storlek_kom.png"),
    plot = p,
    width = 8,
    height = 5,
    dpi = 96
  )
  
  
}

andel_bransch_kom <- function(){
  # Läser in data
  df <- read.csv("Data/df_kulturkategori_per_kom.csv")
  
  df <- df %>% mutate(Kommun = factor(Kommun, levels= sort(unique(df$Kommun),decreasing =T)))
  # plot
  p <- ggplot(df, aes(y = Kommun, x = Andel, fill =Branschkategori  )) +
    geom_col() +scale_fill_manual(values = unname(kommun_colors))+
    labs(
      title = str_wrap(paste("Fördelningen över anställningsplatserna uppdelat per bransch -",unique(df$År)),width=50),
      x = "Andel (%)",
      y = "",
      caption="Källa: SCB Företagsregistret",
      fill=""
    ) +
    theme(
      legend.position = "bottom",
      plot.title = element_text(),
      plot.caption = element_text(hjust=0)
    )+
    guides(fill = guide_legend(nrow = 4)) 
  
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/andel_bransch_kom.svg"),
    plot = p,
    width = 8,
    height = 7
  )
  
  ggsave(
    paste0("Figurer/andel_bransch_kom.png"),
    plot = p,
    width = 8,
    height = 7,
    dpi = 96
  )
  
  
}


######## Företagsregistret företag #########


andel_foretag <- function(){
  # Läser in data
  df <- read.csv("Data/df_antal_firm_kultur.csv")
  
  df <- df %>% mutate(Säteskommun = factor(Säteskommun, levels= sort(unique(df$Säteskommun),decreasing =T)))
  # Skapar plot
  p <- ggplot(df, aes(x=Säteskommun, y=Andel))+ geom_col(fill = "#B81867")+ 
    ylim(0,20)+
    labs(x="",
         y="Andel (%)",
         title=str_wrap(paste("Andel aktiva företag inom kultur, hämtat", unique(df$år)), width=50),
         caption = "Källa: Företagsregistret")+
    theme(axis.text.x = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust=0))
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/andel_firm", ".svg"),
    plot = p,
    width = 7,
    height = 5
  )
  
  ggsave(
    paste0("Figurer/andel_firm",  ".png"),
    plot = p,
    width = 7,
    height = 5,
    dpi = 96
  )
}


andel_storlek_kom_firm <- function(){
  # Läser in data
  df <- read.csv("Data/df_antal_firm_kultur_storlek.csv")
  
  
  #  Unika storleksklasser för filter
  df <- df %>% mutate(Storleksklass=factor(Storleksklass ,levels=c("0 anställda" , "1-4 anställda" ,"5-9 anställda","10-19 anställda" , "20-49 anställda"  ,  "50-99 anställda", 
                                                                   "100-199 anställda" ,"200-499 anställda")))
  
  df <- df %>% mutate(Säteskommun = factor(Säteskommun, levels= sort(unique(df$Säteskommun),decreasing =T)))
  
  # plot
  p <- ggplot(df, aes(y = Säteskommun, x = Andel, fill =Storleksklass  )) +
    geom_col() +scale_fill_manual(values = unname(kommun_colors))+
    labs(
      title = str_wrap(paste("Fördelningen över företagens storleksklasser -",unique(df$År)),width=50),
      x = "Andel (%)",
      y = "",
      caption="Källa: SCB Företagsregistret",
      fill=""
    ) +
    theme(
      legend.position = "bottom",
      plot.title = element_text(),
      plot.caption = element_text(hjust=0)
    )
  
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/andel_storlek_kom_firm.svg"),
    plot = p,
    width = 8,
    height = 5
  )
  
  ggsave(
    paste0("Figurer/andel_storlek_kom_firm.png"),
    plot = p,
    width = 8,
    height = 5,
    dpi = 96
  )
  
  
}

andel_bransch_kom_firm <- function(){
  # Läser in data
  df <- read.csv("Data/df_kulturkategori_firm_per_kom.csv")
  
  df <- df %>% mutate(Säteskommun = factor(Säteskommun, levels= sort(unique(df$Säteskommun),decreasing =T)))
  
  # plot
  p <- ggplot(df, aes(y = Säteskommun, x = Andel, fill =Branschkategori  )) +
    geom_col() +scale_fill_manual(values = unname(kommun_colors))+
    labs(
      title = str_wrap(paste("Fördelningen över företagen uppdelat per bransch -",unique(df$År)),width=50),
      x = "Andel (%)",
      y = "",
      caption="Källa: SCB Företagsregistret",
      fill=""
    ) +
    theme(
      legend.position = "bottom",
      plot.title = element_text(),
      plot.caption = element_text(hjust=0)
    )+
    guides(fill = guide_legend(nrow = 4)) 
  
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/andel_bransch_kom_firm.svg"),
    plot = p,
    width = 8,
    height = 7
  )
  
  ggsave(
    paste0("Figurer/andel_bransch_kom_firm.png"),
    plot = p,
    width = 8,
    height = 7,
    dpi = 96
  )
  
  
}

omsattning_per_storlek_och_bransch <- function(){
  # Hämtar data
  df <- read.csv("Data/df_kulturkategori_firm_per_lan_storlek.csv")
  
  # fixar ordningen på variabeln
  df <- df %>% mutate(Storleksklass..oms = factor(Storleksklass..oms, levels = c(
    "< 1 tkr","1 - 499 tkr","500 - 999 tkr" ,"1 000 - 4 999 tkr" ,
    "5 000 - 9 999 tkr","10 000 - 19 999 tkr","20 000 - 49 999 tkr",
    "50 000 - 99 999 tkr","100 000 - 499 999 tkr","500 000 - 999 999 tkr"
  )))
  
  # antal per klass
  # antal per klass
  antal_df <- df %>%
    group_by(Storleksklass..oms) %>%
    summarise(Antal = sum(Antal, na.rm = TRUE), .groups='drop') %>% 
    mutate(Andel = round(Antal/sum(Antal)*100,0))
  
  
  # Skapar plot
  
  p <- ggplot(df,aes(y=Storleksklass..oms, x=Andel, fill=Branschkategori ))+
    geom_col()+ scale_fill_manual(values=unname(kommun_colors))+
    labs(fill="",
         title=str_wrap(paste("Fördelningen över omsättningsstorlekens branscher"),width=50),
         subtitle = paste0("Omsättningsår ",unique(df$Omsättning..år),", hämtat ",unique(df$År)),
         x="Andel (%)",
         y="",
         caption = "Källa: SCB Företagsregistret")+
    # Lägg till antal till höger
    geom_text(data = antal_df,
              aes(y = Storleksklass..oms,
                  x = 102,  # placerar texten lite utanför 100%
                  label = paste0( Antal," st, ",Andel," %")),
              inherit.aes = F,
              hjust = 0,
              size = 4) +
    coord_cartesian(clip = "off") +   
    
    theme(legend.position="bottom",
          plot.title = element_text( hjust = 1 ),
          plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
          plot.margin =grid::unit(c(15, 60, 15, 15), "pt"),
          plot.caption = element_text(hjust=0))+
    guides(fill = guide_legend(nrow = 4) ) 
  
  p
  
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/andel_bransch_omsatt.svg"),
    plot = p,
    width = 8,
    height = 7
  )
  
  ggsave(
    paste0("Figurer/andel_bransch_omsatt.png"),
    plot = p,
    width = 8,
    height = 7,
    dpi = 96
  )
  
  
}
