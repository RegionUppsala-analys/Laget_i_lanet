
#### Gästnätter tillvv######


gastnatter_karta <- function(){
  
  # ── Gästnätter 
  df <- read.csv("Data/df_gastlan.csv") %>% filter(AR == max(AR)-1) %>% 
    group_by(LAN_NAMN, ANLAGGNINGSTYP_NAMN, AR) %>%
    summarize(Antal = sum(ANTAL_GASTNATTER), .groups = "drop") %>% 
    group_by(LAN_NAMN, AR) %>% 
    mutate(Totalt = sum(Antal)) %>%
    ungroup()
  
  ar <- unique(df$AR)
  
  # ── Folkmängd 
  folkm <- read.csv("Data/df_folkm_new.csv") %>%
    mutate(LAN_NAMN = str_remove(region, "s? län$"))
  
  # ── Shapefil 
  lan_shape <- suppressMessages(suppressWarnings(
    st_read("Data/LanSweref99TM/Lan_Sweref99TM_region.shp", quiet = TRUE)
  )) %>%
    st_transform(crs = 4326) %>%
    mutate(LnNamn = str_remove(LnNamn, "s$"))
  
  df <- df %>% left_join(lan_shape, by = c("LAN_NAMN" = "LnNamn"))
  
  df_totalt <- df %>%
    distinct(LAN_NAMN, Totalt, geometry) %>%
    left_join(folkm, by = "LAN_NAMN") %>%
    mutate(Per_invånare = round(Totalt / Folkmängd, 2)) %>%
    st_as_sf()
  
  df <- df %>%
    left_join(folkm, by = "LAN_NAMN") %>%
    mutate(Per_invånare = round(Antal / Folkmängd, 2))
  
  typer  <- sort(unique(df$ANLAGGNINGSTYP_NAMN))
  groups <- c("Totalt gästnätter", "Gästnätter per invånare", paste(typer, "per invånare"))
  
  # CSS-safe key for each group: used as legend class suffix
  safe_key <- function(x) gsub("[^a-zA-Z0-9]", "_", x)
  
  fmt <- function(x) format(x, big.mark = "\u00a0", scientific = FALSE)
  
  pal_totalt <- colorNumeric("PuRd", domain = df_totalt$Totalt)
  pal_percap <- colorNumeric("PuRd",   domain = df_totalt$Per_invånare)
  
  m <- leaflet() %>%
    addProviderTiles("CartoDB.Positron") %>%
    
    # --- Layer 1: Totalt ---
    addPolygons(
      data        = df_totalt,
      fillColor   = ~pal_totalt(Totalt),
      fillOpacity = 0.7, color = "white", weight = 1,
      highlight   = highlightOptions(weight = 2, color = "#444", fillOpacity = 0.9),
      label       = ~lapply(paste0(
        "<b>", LAN_NAMN, "</b><br>",
        "Totalt: <b>", fmt(Totalt), "</b> gästnätter"
      ), HTML),
      group = "Totalt gästnätter"
    ) %>%
    addLegend(
      pal       = pal_totalt, values = df_totalt$Totalt,
      title     = paste("Totala gästnätter", ar), position = "bottomright",
      labFormat = labelFormat(big.mark = "\u00a0"),
      className = paste0("info legend legend-", safe_key("Totalt gästnätter"))
    ) %>%
    
    # --- Layer 2: Per invånare ---
    addPolygons(
      data        = df_totalt,
      fillColor   = ~pal_percap(Per_invånare),
      fillOpacity = 0.7, color = "white", weight = 1,
      highlight   = highlightOptions(weight = 2, color = "#444", fillOpacity = 0.9),
      label       = ~lapply(paste0(
        "<b>", LAN_NAMN, "</b><br>",
        "Per invånare: <b>", fmt(Per_invånare), "</b> gästnätter<br>",
        "Folkmängd: <b>", fmt(Folkmängd), "</b>"
      ), HTML),
      group = "Gästnätter per invånare"
    ) %>%
    addLegend(
      pal       = pal_percap, values = df_totalt$Per_invånare,
      title     = paste("Gästnätter / invånare", ar), position = "bottomright",
      className = paste0("info legend legend-", safe_key("Gästnätter per invånare")))
  
  
  # --- Layers 3+: Per anläggningstyp ---
  for (typ in typer) {
    df_typ <- df %>% filter(ANLAGGNINGSTYP_NAMN == typ) %>% st_as_sf()
    pal    <- colorNumeric("PuRd", domain = df_typ$Per_invånare)
    
    m <- m %>%
      addPolygons(
        data        = df_typ,
        fillColor   = ~pal(Per_invånare),
        fillOpacity = 0.7, color = "white", weight = 1,
        highlight   = highlightOptions(weight = 2, color = "#444", fillOpacity = 0.9),
        label       = ~lapply(paste0(
          "<b>", LAN_NAMN, "</b><br>",
          "Per invånare: <b>", fmt(Per_invånare), "</b> gästnätter<br>",
          "Totalt: <b>", fmt(Antal), "</b> gästnätter"
        ), HTML),
        group = paste(typ,"per invånare"), 
      ) %>%
      addLegend(
        pal       = pal, values = df_typ$Per_invånare,
        title     = paste(typ,ar), position = "bottomright",
        labFormat = labelFormat(big.mark = "\u00a0"),
        className = paste0("info legend legend-", safe_key(paste(typ,"per invånare")))
      )
  }
  
  # ── Build JS lookup: { "Group name": "legend-SafeKey", ... } ─────────────────
  js_map_entries <- paste0(
    '"', groups, '": "legend-', sapply(groups, safe_key), '"',
    collapse = ",\n"
  )
  js_legend_map <- paste0("{\n", js_map_entries, "\n}")
  
  m <- m %>%
    addLayersControl(
      baseGroups = groups,
      options    = layersControlOptions(collapsed = FALSE)
    ) %>%
    hideGroup(c("Gästnätter per invånare", typer)) %>%
    onRender(sprintf("
      function(el, x) {
        var map       = this;
        var legendMap = %s;

        function showLegend(groupName) {
          // Hide all managed legends
          Object.values(legendMap).forEach(function(cls) {
            var el = document.querySelector('.' + cls);
            if (el) el.style.display = 'none';
          });
          // Show the one matching this group
          var target = legendMap[groupName];
          if (target) {
            var el = document.querySelector('.' + target);
            if (el) el.style.display = 'block';
          }
        }

        // Set initial state: show only Totalt
        showLegend('Totalt gästnätter');

        map.on('baselayerchange', function(e) {
          showLegend(e.name);
        });
      }
    ", js_legend_map))
  
  m
}

gastnatter_tid_tot <- function(){
  # Hämtar data
  df <- read.csv("Data/df_gastkom.csv")
  # grupperar per kommun och månad
  df <- df %>% filter(AR <= (max(AR))-1) %>% 
    group_by(AR,KOMMUN_NAMN) %>% summarize(Antal = sum(ANTAL_GASTNATTER), .groups='drop')
  
  # Länsdata
  df_lan <- read.csv("Data/df_gastlan.csv") %>% filter(LAN_NAMN == 'Uppsala',
                                                       AR <= (max(AR))-1)
  df_lan <- df_lan %>% group_by(AR) %>% summarize(Antal = sum(ANTAL_GASTNATTER), .groups='drop')
  df_lan$KOMMUN_NAMN <- "Uppsala län"
  
  # Slår ihop datasets
  df <- rbind(df, df_lan)
  
  # Loopar över varje kommun
  for (r in unique(df$KOMMUN_NAMN)) {
    
    # filtrerar och beräknar förändring
    temp <- df %>% filter(KOMMUN_NAMN == r) %>%
      arrange(AR) %>%
      mutate(
        Forandring_pct = (Antal - lag(Antal)) / lag(Antal) * 100,
        Forandring_label = case_when(
          is.na(Forandring_pct) ~ "",
          Forandring_pct > 0    ~ paste0("+", round(Forandring_pct, 1), "%"),
          TRUE                  ~ paste0(round(Forandring_pct, 1), "%")
        )
      )
    
    # om det är under 2 år av data
    if (n_distinct(temp$AR) < 2) next
    
    p <- ggplot(temp, aes(x=AR, y=Antal))+
      geom_line(linewidth=2, color="#B81867") +
      geom_point(size = 3, color = "#B81867") +
      geom_text(aes(label = Forandring_label),
                vjust = -1.5, size = 3.5, color = "black") +
      scale_y_continuous(
        labels = label_number(big.mark = " "),
        expand = expansion(mult = c(0.1, 0.15))  # extra utrymme för labels
      )+
      labs(title=paste("Totalt antal gästnätter i",r),
           x="",
           y="Antal",
           caption= "Källa: Tillväxtverket")+ 
      theme(legend.position = "bottom",
            axis.text.x = element_text(angle = 45),
            plot.caption = element_text(hjust=0))
    
    ggsave(paste0("Figurer/gastnatter_tid_tot_", r, ".svg"), plot = p, width = 8, height = 5)
    ggsave(paste0("Figurer/gastnatter_tid_tot_", r, ".png"), plot = p, width = 8, height = 5, dpi = 96)
  }
}

gastnatter_tid <- function(){
  # Hämtar data
  df <- read.csv("Data/df_gastkom.csv")
  # grupperar per kommun och månad
  df <- df %>% group_by(AR,MANAD_NAMN_LANG,KOMMUN_NAMN, ANLAGGNINGSTYP_NAMN) %>% summarize(Antal = sum(ANTAL_GASTNATTER), .groups='drop')
  
  # Länsdata
  df_lan <- read.csv("Data/df_gastlan.csv") %>% filter(LAN_NAMN == 'Uppsala')
  df_lan <- df_lan %>% group_by(AR,MANAD_NAMN_LANG, ANLAGGNINGSTYP_NAMN) %>% summarize(Antal = sum(ANTAL_GASTNATTER), .groups='drop')
  df_lan$KOMMUN_NAMN <- "Uppsala län"
  
  # Slår ihop datasets
  df <- rbind(df, df_lan)
  
  # Gör månad/år till date: 
  month_map <- c(
    "Januari" = "01",
    "Februari" = "02",
    "Mars" = "03",
    "April" = "04",
    "Maj" = "05",
    "Juni" = "06",
    "Juli" = "07",
    "Augusti" = "08",
    "September" = "09",
    "Oktober" = "10",
    "November" = "11",
    "December" = "12"
  )
  
  df <- df %>%
    mutate(
      month_num = unname(month_map[MANAD_NAMN_LANG]),
      date = as.Date(paste0(AR, "-", month_num, "-01"))
    )
  
  colmap <- c("Sekretesskyddad" ="#B81867" ,
              "Hotell" = "#D57667",
              "Camping" = "#4AA271"  , 
              "Vandrarhem" = "#019CD7" )
  
  # Loopar över varje kommun
  for (r  in unique(df$KOMMUN_NAMN)) {
    
    temp <- df %>% filter(KOMMUN_NAMN == r)
    
    # om det finns lite data
    x_tik <- ifelse(nrow(temp) < 5,"1 month","5 month" )
    
    p <- ggplot(temp, aes(x=date, y=Antal, color=ANLAGGNINGSTYP_NAMN))+
      geom_line(linewidth=2)+
      scale_color_manual(values=colmap)+
      scale_x_date(
        date_breaks = paste(x_tik),
        date_labels = "%b %Y"
      ) +
      labs(title=paste("Antal gästnätter per månad i",r),
           x="",
           y="Antal",
           color="",
           caption= "Källa: Tillväxtverket")+ 
      theme(legend.position = "bottom",
            axis.text.x = element_text(angle = 90, hjust=1),
            plot.caption = element_text(hjust=0))
    
    p  
    
    
    ggsave(paste0("Figurer/gastnatter_tid_",r,".svg"), plot = p, width = 8, height = 5)
    ggsave(paste0("Figurer/gastnatter_tid_",r,".png"), plot = p, width = 8, height = 5, dpi = 96)
    
  }
}



gastnatter_typ <- function(){
  # Länsdata
  df <- read.csv("Data/df_gastlan.csv") %>% filter(LAN_NAMN == 'Uppsala', AR == max(AR)-1)
  
  df <- df %>% group_by(AR, ANLAGGNINGSTYP_NAMN) %>% summarize(Antal = sum(ANTAL_GASTNATTER), .groups='drop')
  df$KOMMUN_NAMN <- "Uppsala län"
  
  colmap <- c("Sekretesskyddad" ="#B81867" ,
              "Hotell" = "#D57667",
              "Camping" = "#4AA271"  , 
              "Vandrarhem" = "#019CD7" )
  
  # Force consistent factor order
  df$ANLAGGNINGSTYP_NAMN <- factor(
    df$ANLAGGNINGSTYP_NAMN,
    levels = names(colmap)
  )
  
  # beräknar andelar
  df <- df %>% mutate( andel = Antal / sum(Antal), label = percent(andel, accuracy = 1) )
  
  # skapar plot
  p <- ggplot(df, aes(x = "", y = Antal, fill = ANLAGGNINGSTYP_NAMN)) + 
    geom_col(width = 1, color = "white") + coord_polar(theta = "y") + 
    geom_text( aes(label = label),
               position = position_stack(vjust = 0.5), size = 4 )+
    scale_fill_manual(values = colmap, drop = FALSE) +
    labs(
      title = str_wrap(paste("Fördelning av gästnätter per boendetyp i Uppsala län –", unique(df$AR)), width=50),
      fill = NULL,
      caption = "Källa: Tillväxtverket"
    ) +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      panel.grid = element_blank(),
      
      plot.title = element_text(
        hjust = 0.5,
        face = "bold",
        size = 18
      ),
      
      legend.position = "bottom",
      legend.text = element_text(size = 10),
      
      plot.caption = element_text(
        hjust = 0,
        size = 9
      )
    )
  
  p
  
  
  ggsave(paste0("Figurer/gastnatter_typ.svg"),
         plot = p, width = 8, height = 5)
  
  ggsave(paste0("Figurer/gastnatter_typ.png"),
         plot = p, width = 8, height = 5, dpi = 300)
  
}

gastnatter_land <- function(){
  
  # Läser in data
  df_raw <- read.csv("Data/df_gastlan.csv") %>% 
    filter(LAN_NAMN == "Uppsala")
  
  # räkna antal månader per år
  year_check <- df_raw %>%
    group_by(AR) %>%
    summarise(
      n_months = n_distinct(MANAD_NAMN_LANG),   # eller datum -> month()
      .groups = "drop"
    )
  
  # behåll bara kompletta år
  valid_years <- year_check %>%
    filter(n_months == 12) %>%
    pull(AR)
  
  # filtrera + aggregera
  df <- df_raw %>%
    filter(AR %in% valid_years) %>%
    group_by(LAND_NAMN, AR, LANDGRP_20_NAMN) %>%
    summarise(Antal = sum(ANTAL_GASTNATTER), .groups = "drop")
  
  # tittar på antal observationer
  valid_c <- df %>%
    group_by(LAND_NAMN) %>%
    summarise(
      n = n_distinct(AR),   # eller datum -> month()
      .groups = "drop"
    ) %>% filter(n > 1) %>%
    pull(LAND_NAMN)
  
  df <- df %>% filter(LAND_NAMN %in% valid_c)
  
  # År
  df$AR <- as.integer(df$AR)
  
  # unika landsgrupper
  groups <- sort(unique(df$LANDGRP_20_NAMN))
  
  fig <- plot_ly()
  
  # indexering för rätt trace
  trace_map <- list()
  trace_index <- 0
  
  # Loop över varje grupp
  for (g in groups) {
    
    df_g <- df %>% filter(LANDGRP_20_NAMN == g)
    countries <- unique(df_g$LAND_NAMN)
    
    trace_ids <- c()
    
    # En linje per land
    for (c in countries) {
      
      trace_index <- trace_index + 1
      
      df_c <- df_g %>% filter(LAND_NAMN == c)
      
      fig <- fig %>%
        add_trace(
          x = df_c$AR,
          y = df_c$Antal,
          type = "scatter",
          mode = "lines+markers",
          name = c,
          line = list(width = 3),
          marker = list(size = 6),
          visible = (g == groups[1])
        )
      
      trace_ids <- c(trace_ids, trace_index)
    }
    
    trace_map[[g]] <- trace_ids
  }
  
  # Skapa dropdown-knappar
  buttons <- lapply(seq_along(groups), function(i) {
    
    vis <- rep(FALSE, trace_index)
    
    vis[ unlist(trace_map[groups[i]]) ] <- TRUE
    
    list(
      method = "update",
      args = list(
        list(visible = vis),
        list(title =  paste("<b>Antal gästnätter i Uppsala län</b>"))
      ),
      label = groups[i]
    )
  })
  
  # Layout
  fig <- fig %>% layout(font = list(family = "sourcesanspro"),
                        hovermode = 'x unified',
                        barmode = "group",
                        margin = list(t = 100),
                        title = list(
                          font = list(size = 24, color = "#B81867"),
                          text = paste("<b>Antal gästnätter i Uppsala län</b>"),
                          x = 0.5,
                          y = 1.3
                        ),
                        xaxis = list(title = ""),
                        updatemenus = list(
                          list(
                            type = "dropdown",
                            buttons = buttons,
                            x = 0,
                            y = 1.12
                          )
                        ),
                        yaxis = list(title = "<b>Antal</b>",
                                     font = list(size=18)),
                        annotations = list(
                          text ='Källa: Tillväxtverket',
                          x = 0,            
                          y = -0.12,        
                          xref = "paper",
                          yref = "paper",
                          xanchor = "left",
                          yanchor = "bottom",
                          showarrow = FALSE,
                          font = list(size = 12)
                        )
  )
  
  # Tar bort vissa knappar i plotly    
  fig <- plotly::config(fig,
                        modeBarButtonsToRemove = c(
                          "zoom2d",
                          "pan2d",
                          "select2d",
                          "lasso2d",
                          "zoomIn2d",
                          "zoomOut2d"
                        ),
                        displaylogo = FALSE)
  
  fig
  
  
}