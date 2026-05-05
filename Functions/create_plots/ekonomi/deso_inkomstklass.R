deso_inkomstklass <- function(){
  
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_inkomstklass.gpkg")
      deso_sf <- st_read("Data/df_inkomstklass.gpkg", quiet = TRUE)
    })
  })
  
  # Letar ordet kvartil för kolumnerna
  kvartil_cols <- grep("^Kvartil\\.", names(deso_sf), value = TRUE)
  
  # ny kolumn
  deso_sf$highest_kvartil <- NA_integer_
  
  # Loop over rows
  for (i in seq_len(nrow(deso_sf))) {
    row_values <- deso_sf[i, kvartil_cols] |> as.numeric()
    deso_sf$highest_kvartil[i] <- which.max(row_values)
  }
  
  # Filtrerar 
  deso_sf_pop_join_tot <- deso_sf %>% filter(inkomstslag=='sammanräknad förvärvsinkomst',
                                             kön == 'totalt')
  
  # Gör till long-format
  deso_sf_pop_join_tot <- deso_sf_pop_join_tot %>% pivot_longer(
    cols = all_of(kvartil_cols),
    names_to = "Kvartil",
    values_to = "Andel")
  
  # Text till popup
  popup_text <- deso_sf_pop_join_tot %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          str_replace(Kvartil, ".*([0-9]+).*", "Kvartil \\1"),  # clean the name
          ": ",
          Andel, "%",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  # Slår ihop data
  deso_sf_pop_join <- deso_sf_pop_join_tot %>%
    left_join(popup_text, by = "desokod")
  
  # Hoverover info
  deso_sf_pop_join$label <- paste(
    "DeSO: ", deso_sf_pop_join$desokod,  " | ",
    'Störst andel i kvartil',
    deso_sf_pop_join$highest_kvartil)
  
  # färgschema
  custom_colors <- c("#D57667", "#EABAB3", "#A4D0B8", "#4AA271")
  
  # nivåer på kvartilerna
  deso_sf_pop_join$highest_kvartil <- factor(deso_sf_pop_join$highest_kvartil, levels = seq(1,4,1))
  
  # skapar kartan
  map <- mapview(
    deso_sf_pop_join,
    zcol = "highest_kvartil",
    legend = TRUE,
    layer.name = paste("Vanligaste inkomstklasserna", unique(deso_sf_pop_join$år)),
    at = seq(1,4,by=1),
    col.regions = custom_colors,
    popup = deso_sf_pop_join$popup,
    label =  deso_sf_pop_join$label
  )
  
  # Fixar texten
  map@map <- map@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  # Skapar ett layer för män
  deso_sf_pop_join_man <- deso_sf %>% filter(inkomstslag=='sammanräknad förvärvsinkomst', kön == 'män') %>% 
    mutate(kön = tools::toTitleCase(kön))
  
  # longformat
  deso_sf_pop_join_man <- deso_sf_pop_join_man %>% pivot_longer(
    cols = all_of(kvartil_cols),
    names_to = "Kvartil",
    values_to = "Andel")
  
  # popuptext
  popup_text <- deso_sf_pop_join_man %>%
    group_by(desokod, kön) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          str_replace(Kvartil, ".*([0-9]+).*", "Kvartil \\1"),  # clean the name
          ": ",
          Andel, "%",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  # slår ihop data
  deso_sf_pop_join <- deso_sf_pop_join_man %>%
    left_join(popup_text, by = "desokod")
  
  # Hoverover info
  deso_sf_pop_join$label <- paste(
    "DeSO: ", deso_sf_pop_join$desokod,  " | ",
    'Störst andel i kvartil',
    deso_sf_pop_join$highest_kvartil)
  
  # Färgschema
  custom_colors <- c("#D57667", "#EABAB3", "#A4D0B8", "#4AA271")
  
  deso_sf_pop_join$highest_kvartil <- factor(deso_sf_pop_join$highest_kvartil, levels = seq(1,4,1))
  
  # layer för män
  map2 <- mapview(
    deso_sf_pop_join,
    zcol = "highest_kvartil",
    legend = TRUE,
    layer.name = paste("Vanligaste inkomstklasserna för män", unique(deso_sf_pop_join$år)),
    at = seq(1,4,by=1),
    col.regions = custom_colors,
    popup = deso_sf_pop_join$popup,
    label =  deso_sf_pop_join$label,
    hide=T
  )
  
  map2@map <- map2@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  
  
  # Skapar ett layer för kvinnor
  desso_sf_pop_join_kvin <- deso_sf %>% filter(inkomstslag=='sammanräknad förvärvsinkomst', kön == 'kvinnor') %>% 
    mutate(kön = tools::toTitleCase(kön))
  
  desso_sf_pop_join_kvin <- desso_sf_pop_join_kvin %>% pivot_longer(
    cols = all_of(kvartil_cols),
    names_to = "Kvartil",
    values_to = "Andel")
  
  popup_text <- desso_sf_pop_join_kvin %>%
    group_by(desokod, kön) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          str_replace(Kvartil, ".*([0-9]+).*", "Kvartil \\1"),  # clean the name
          ": ",
          Andel, "%",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  deso_sf_pop_join <- desso_sf_pop_join_kvin %>%
    left_join(popup_text, by = "desokod")
  
  deso_sf_pop_join$label <- paste(
    "DeSO: ", deso_sf_pop_join$desokod,  " | ",
    'Störst andel i kvartil',
    deso_sf_pop_join$highest_kvartil)
  
  
  custom_colors <- c("#D57667", "#EABAB3", "#A4D0B8", "#4AA271")
  deso_sf_pop_join$highest_kvartil <- factor(deso_sf_pop_join$highest_kvartil, levels = seq(1,4,1))
  
  
  map3 <- mapview(
    deso_sf_pop_join,
    zcol = "highest_kvartil",
    legend = TRUE,
    layer.name = paste("Vanligaste inkomstklasserna för kvinnor", unique(deso_sf_pop_join$år)),
    at = seq(1,4,by=1),
    col.regions = custom_colors,
    popup = deso_sf_pop_join$popup,
    label =  deso_sf_pop_join$label,
    hide=T
  )
  
  map3@map <- map3@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  
  
  # slår ihop all a layers
  combined_map <- map + map2 + map3
  
  # fixar så att legenderna är dolda från början
  combined_map@map <- combined_map@map %>%
    htmlwidgets::onRender("
    function(el, x) {
      var legends = el.querySelectorAll('.info.legend'); // bara inom detta element
      legends.forEach((lg, i) => { if (i > 0) lg.style.display = 'none'; });
    }
  ")
  return(combined_map)
  
}