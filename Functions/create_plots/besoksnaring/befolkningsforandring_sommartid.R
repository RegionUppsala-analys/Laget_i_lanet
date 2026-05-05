######## SCB #######
# Befolkningsförändringar
karta_befolkning <- function() {
  # läser in data
  df_raw <- read.csv("Data/scb_kommunbesok_raw.csv") %>% mutate(
    kommunkod = str_extract(Kommun, "^[0-9]{4}"))
  
  # läser in shape
  kommun_shape <- suppressMessages(
    suppressWarnings(
      st_read(
        "Data/Kommun_Sweref99TM/Kommun_Sweref99TM.shp",
        quiet = TRUE
      )
    )
  ) %>%
    st_transform(crs = 4326)
  
  # klassificerar
  breaks <- c(-Inf, -20, 0, 20, 40, 60, Inf)
  
  labels <- c(
    "Minskning > 20 %",
    "Minskning 0–20 %",
    "Ökning 0–20 %",
    "Ökning 20–40 %",
    "Ökning 40–60 %",
    "Ökning > 60 %"
  )
  
  df_analysis <- df_raw %>%
    mutate(
      kategori_juli = cut(
        skillnad_juli ,
        breaks = breaks,
        labels = labels,
        include.lowest = TRUE
      ),
      kategori_midsommar = cut(
        skillnad_midsommar ,
        breaks = breaks,
        labels = labels,
        include.lowest = TRUE
      )
    )
  
  # färgkod
  colors <- c(
    "#D57667",
    "#E8A89C",
    "#EAF5EF",
    "#A4D0B8",
    "#4AA271",
    "#1A6B40"
  )
  
  # matchar mot shape
  map_data <- kommun_shape %>%
    left_join(
      df_analysis,
      by = c("KnKod" = "kommunkod")
    )
  
  # After building map_data, filter Uppsala län and compute centroids
  uppsala_labels <- map_data %>%
    filter(str_starts(KnKod, "03")) %>%
    mutate(
      centroid = st_centroid(geometry),
      lon = st_coordinates(centroid)[, 1],
      lat = st_coordinates(centroid)[, 2]
    )
  
  # Popup-mall
  make_popup <- function(namn, bef_bas, bef_period, skillnad, period_label) {
    paste0('
    <div style="font-family:sans-serif;min-width:180px;font-size:13px">
      <b style="font-size:14px">', namn, '</b>
      <hr style="margin:6px 0">
      <table style="width:100%;border-collapse:collapse">
        <tr><td style="color:#666">Befolkningsförändring okt–nov (bas)</td>
            <td style="text-align:right">', format(bef_bas*10, big.mark = "\u00a0"), '</td></tr>
        <tr><td style="color:#666">Befolkningsförändring ', str_to_lower(period_label), '</td>
            <td style="text-align:right">', format(bef_period*10, big.mark = "\u00a0"), '</td></tr>
        <tr><td style="color:#666">Skillnad</td>
            <td style="text-align:right">', ifelse(skillnad > 0, "+", ""), round(skillnad, 1), " %</td></tr>
      </table>
    </div>" )
  }
  
  # Bygg popup-vektorer
  popups_juli <- mapply(make_popup,
                        map_data$KnNamn,
                        map_data$bef_okt_nov,
                        map_data$bef_juli,
                        map_data$skillnad_juli,
                        MoreArgs = list(period_label = "Juli"),
                        USE.NAMES = FALSE)
  
  popups_midsommar <- mapply(make_popup,
                             map_data$KnNamn,
                             map_data$bef_okt_nov,
                             map_data$bef_midsommar,
                             map_data$skillnad_midsommar,
                             MoreArgs = list(period_label = "Midsommar"),
                             USE.NAMES = FALSE)
  
  # Karta
  m1 <- mapview(
    map_data,
    zcol        = "kategori_juli",
    col.regions = colors,
    layer.name  = "Juli 2022 vs okt\u2013nov 2022",
    popup       = popups_juli
  )
  
  m2 <- mapview(
    map_data,
    zcol        = "kategori_midsommar",
    col.regions = colors,
    hide        = TRUE,
    layer.name  = "Midsommar 2022 vs okt\u2013nov 2022",
    popup       = popups_midsommar
  )
  
  # Add labels using leaflet directly on the combined map
  m <- m1 + m2
  
  m@map <- m@map %>%
    leaflet::addLabelOnlyMarkers(
      data    = uppsala_labels,
      lng     = ~lon,
      lat     = ~lat,
      label   = ~KnNamn,
      labelOptions = leaflet::labelOptions(
        noHide    = TRUE,
        direction = "center",
        textOnly  = TRUE,
        className = "uppsala-label",
        style     = list(
          "font-size"   = "11px",
          "font-weight" = "600",
          "color"       = "#222222",
          "text-shadow" = "0px 0px 3px #ffffff, 0px 0px 3px #ffffff",
          "display"     = "none"
        )
      )
    ) %>%
    htmlwidgets::onRender("
    function(el, x) {
      var legends = el.querySelectorAll('.info.legend');
      legends.forEach((lg, i) => { if (i > 0) lg.style.display = 'none'; });

      var map = this;
      function toggleLabels() {
        var show = map.getZoom() >= 7;
        el.querySelectorAll('.uppsala-label').forEach(function(lbl) {
          lbl.style.display = show ? 'block' : 'none';
        });
      }
      toggleLabels();
      map.on('zoomend', toggleLabels);
    }
  ")
  
  m@map <- m@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  m  
}

# Länsnivå

lans_befolkning <- function() {
  # läser in data
  df_raw <- read.csv("Data/scb_kommunbesok_raw.csv") %>% mutate(
    kommunkod = str_extract(Kommun, "^[0-9]{4}"),
    lan = str_extract(Kommun, "^[0-9]{2}"))
  
  # länsnamn lookup
  lansnamn_lookup <- c(
    "01" = "Stockholms län",
    "03" = "Uppsala län",
    "04" = "Södermanlands län",
    "05" = "Östergötlands län",
    "06" = "Jönköpings län",
    "07" = "Kronobergs län",
    "08" = "Kalmar län",
    "09" = "Gotlands län",
    "10" = "Blekinge län",
    "12" = "Skåne län",
    "13" = "Hallands län",
    "14" = "Västra Götalands län",
    "17" = "Värmlands län",
    "18" = "Örebro län",
    "19" = "Västmanlands län",
    "20" = "Dalarnas län",
    "21" = "Gävleborgs län",
    "22" = "Västernorrlands län",
    "23" = "Jämtlands län",
    "24" = "Västerbottens län",
    "25" = "Norrbottens län"
  )
  
  df <- df_raw %>%
    group_by(lan) %>%
    summarise(
      Antal_juli = sum(bef_juli - bef_okt_nov) / 1000,
      Antal_mid  = sum(bef_midsommar - bef_okt_nov) / 1000,
      .groups = "drop"
    ) %>%
    mutate(
      lansnamn = lansnamn_lookup[lan],
      highlight = factor(ifelse(lan == "03", 1, 0))
    )
  
  p_juli <- ggplot(df, aes(x = Antal_juli, y = reorder(lansnamn, Antal_juli), fill = highlight)) +
    geom_bar(stat = "identity") +
    scale_fill_manual(values = c("0" = "grey70", "1" = "#B81867"), guide = "none") +
    scale_x_continuous(
      breaks = scales::pretty_breaks(n = 8),
      labels = scales::number_format(accuracy = 1))+
    labs(
      x = "Befolkningsförändring (tusental personer)",
      y = "",
      title = "Juli jämfört med okt–nov år 2022",
      caption="Källa: SCB"
    ) +
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'),
          axis.text.x = element_text(angle = 45, hjust=1))
  
  p_mid <- ggplot(df, aes(x = Antal_mid, y = reorder(lansnamn, Antal_mid), fill = highlight)) +
    geom_bar(stat = "identity") +
    scale_fill_manual(values = c("0" = "grey70", "1" = "#B81867"), guide = "none") +
    scale_x_continuous(
      breaks = scales::pretty_breaks(n = 8),
      labels = scales::number_format(accuracy = 1)
    )+
    labs(
      x = "Befolkningsförändring (tusental personer)",
      y = "",
      title = "Midsommar jämfört med okt–nov år 2022",
      caption="Källa: SCB"
    )+
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'),
          axis.text.x = element_text(angle = 45, hjust=1),
    )
  
  ggsave("Figurer/befolkning_juli.svg", plot = p_juli, width = 8, height = 5)
  ggsave("Figurer/befolkning_juli.png", plot = p_juli, width = 8, height = 5, dpi = 96)
  
  ggsave("Figurer/befolkning_midsommar.svg", plot = p_mid, width = 8, height = 5)
  ggsave("Figurer/befolkning_midsommar.png", plot = p_mid, width = 8, height = 5, dpi = 96)
  
}


befolkning_flyttnetto <- function(){
  # hämtar data
  df1 <- read.csv("Data/df_inflytt.csv")
  
  df2 <- read.csv("Data/df_folkm.csv")
  
  df <- df1 %>% left_join(df2, by="region")
  
  # beräknar netto per 1000 inv
  df$netto.per.1000 <- (df$Antal.x / df$Antal.y)*1000
  
  # läser in data
  df_raw <- read.csv("Data/scb_kommunbesok_raw.csv") %>% mutate(
    kommunkod = str_extract(Kommun, "^[0-9]{4}"),
    lan = str_extract(Kommun, "^[0-9]{2}"))
  
  # länsnamn lookup
  lansnamn_lookup <- c(
    "01" = "Stockholms län",
    "03" = "Uppsala län",
    "04" = "Södermanlands län",
    "05" = "Östergötlands län",
    "06" = "Jönköpings län",
    "07" = "Kronobergs län",
    "08" = "Kalmar län",
    "09" = "Gotlands län",
    "10" = "Blekinge län",
    "12" = "Skåne län",
    "13" = "Hallands län",
    "14" = "Västra Götalands län",
    "17" = "Värmlands län",
    "18" = "Örebro län",
    "19" = "Västmanlands län",
    "20" = "Dalarnas län",
    "21" = "Gävleborgs län",
    "22" = "Västernorrlands län",
    "23" = "Jämtlands län",
    "24" = "Västerbottens län",
    "25" = "Norrbottens län"
  )
  
  df3 <- df_raw %>%
    group_by(lan) %>%
    summarise(
      Antal_juli = sum(bef_juli - bef_okt_nov) / sum(bef_okt_nov),
      Antal_mid  = sum(bef_midsommar - bef_okt_nov) / sum(bef_okt_nov),
      .groups = "drop"
    ) %>%
    mutate(
      lansnamn = lansnamn_lookup[lan],
      highlight = factor(ifelse(lan == "03", 1, 0))
    )
  
  df <- df %>% left_join(df3, by = c("region" = "lansnamn"))
  
  df$region <- str_remove(df$region, ' län')
  
  p_juli <- ggplot(df, aes(x = Antal_juli,y=netto.per.1000 , color = highlight)) +
    geom_point(size=3) +
    geom_vline(xintercept = 0, color = "grey40", linewidth = 0.4) +
    geom_hline(yintercept = 0, color = "grey40", linewidth = 0.4) +
    scale_color_manual(values = c("0" = "grey70", "1" = "#B81867"), guide = "none") +
    geom_text(aes(label = region), size = 5, vjust = -0.5, show.legend = FALSE) +
    scale_x_continuous(
      breaks = scales::pretty_breaks(n = 8),
      labels = scales::number_format(accuracy = 0.1),
      expand = expansion(mult = 0.1))+
    scale_y_continuous(
      expand = expansion(mult = 0.1))+
    labs(
      x = "Befolkningsförändring (tusental personer)",
      y = "Inrikes flyttnetto per tusen invånare",
      title = "Julibefolkning och flytnetto år 2022",
      caption = "Källa: SCB"
    ) +
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'),
          axis.text.x = element_text(angle = 45, hjust=1),
          plot.margin = grid::unit(c(20, 30, 30, 20), "pt"))
  
  
  
  p_mid <- ggplot(df, aes(x = Antal_mid, y=netto.per.1000, color = highlight)) +
    geom_point(size=3) +
    geom_vline(xintercept = 0, color = "grey40", linewidth = 0.4) +
    geom_hline(yintercept = 0, color = "grey40", linewidth = 0.4) +
    geom_text(aes(label = region), size = 5, vjust = -0.5, show.legend = FALSE) +
    scale_color_manual(values = c("0" = "grey70", "1" = "#B81867"), guide = "none") +
    scale_x_continuous(
      breaks = scales::pretty_breaks(n = 8),
      labels = scales::number_format(accuracy = 0.1),
      expand = expansion(mult = 0.1)
    )+
    scale_y_continuous(
      expand = expansion(mult = 0.1))+
    labs(
      x = "Befolkningsförändring (tusental personer)",
      y = "Inrikes flyttnetto per tusen invånare",
      title = "Midsommarbefolkning och flytnetto år 2022",
      caption = "Källa: SCB"
    )+
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'),
          axis.text.x = element_text(angle = 45, hjust=1),
          plot.margin = grid::unit(c(20, 30, 60, 20), "pt"))
  
  ggsave("Figurer/befolkning_flyttnetto_juli.svg", plot = p_juli, width = 8, height = 5)
  ggsave("Figurer/befolkning_flyttnetto_juli.png", plot = p_juli, width = 8, height = 5, dpi = 96)
  
  ggsave("Figurer/befolkning_flyttnetto_midsommar.svg", plot = p_mid, width = 8, height = 5)
  ggsave("Figurer/befolkning_flyttnetto_midsommar.png", plot = p_mid, width = 8, height = 5, dpi = 96)
}
