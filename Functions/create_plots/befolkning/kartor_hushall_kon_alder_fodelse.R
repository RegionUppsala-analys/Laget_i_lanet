
Deso_husall <- function(){
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_hushall.gpkg")
      deso_sf <- st_read("Data/df_deso_hushall.gpkg", quiet = TRUE) 
    })
  })
  
  # Tar ej med totalt 
  deso_sf <- deso_sf %>% filter(!grepl("totalt antal hushåll", hushållstyp, ignore.case = TRUE))
  
  # Färgschema
  hus_col <- c(
    "sammanboende med barn" = "#D57667",
    "sammanboende utan barn"   = "#F9B000",
    "ensamstående med barn"    = "#019CD7",
    "ensamstående utan barn" = "#4AA271", 
    "övriga hushåll" = "#6F787E"
  )
  
  #  Mest populär upplåtelseform per DeSO 
  mest_popular <- deso_sf %>% 
    group_by(desokod) %>%
    slice_max(order_by = Antal.hushåll, n = 1, with_ties = F) %>%
    ungroup() %>%
    mutate(Popularaste = hushållstyp   ) %>%
    select(desokod, Popularaste) 
  
  
  #  Räkna andelar per DeSO 
  andelar_deso <- deso_sf %>%
    group_by(desokod) %>%
    mutate(
      Total = sum(Antal.hushåll, na.rm = TRUE),
      Andel = round(100 * Antal.hushåll / Total, 1)
    ) %>%
    ungroup()
  
  # äldre data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_hushall_2018.gpkg")
      deso_sf <- st_read("Data/df_deso_hushall_2018.gpkg", quiet = TRUE) 
    })
  })
  
  #  Bygg popup-texten med andelar
  popup_text <- andelar_deso %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod)," ",max(as.integer(deso_sf$år))+5, "<br>",
        paste0(
          str_to_title(hushållstyp), ": ", Andel, "% (", Antal.hushåll, " st)",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  
  #  Slå ihop geometri, populäraste form & popup 
  deso_sf_pop <- mest_popular %>%
    left_join(popup_text, by = "desokod")
  
  # Säkerställ samma faktorordning + titelfall
  deso_sf_pop$Popularaste <- factor(
    deso_sf_pop$Popularaste,
    levels = names(hus_col),
    labels = tools::toTitleCase(names(hus_col))
  )
  
  # lägger in label
  deso_sf_pop$label <- paste(
    "DeSO: ", deso_sf_pop$desokod, " | ",
    deso_sf_pop$Popularaste)
  
  
  #  Skapar kartan 
  map <- mapview(
    deso_sf_pop,
    zcol = "Popularaste",
    legend = TRUE,
    layer.name = paste("Vanligaste hushållstypen", max(as.integer(deso_sf$år))+5 ),
    col.regions = hus_col,
    popup = deso_sf_pop$popup,
    label= deso_sf_pop$label
  )
  
  # Layer med andra år
  deso_sf <- deso_sf %>% filter(!grepl("totalt antal hushåll", hushållstyp, ignore.case = TRUE))
  
  #  Mest populär upplåtelseform per DeSO 
  mest_popular <- deso_sf %>% 
    group_by(desokod, år) %>%
    slice_max(order_by = Antal.hushåll, n = 1, with_ties = F) %>%
    ungroup() %>%
    mutate(Popularaste = hushållstyp   ) %>%
    select(desokod, Popularaste, år)
  
  
  #  Räkna andelar per DeSO 
  andelar_deso <- deso_sf %>%
    group_by(desokod, år) %>%
    mutate(
      Total = sum(Antal.hushåll, na.rm = TRUE),
      Andel = round(100 * Antal.hushåll / Total, 1)
    ) %>%
    ungroup()
  
  #  Bygg popup-texten med andelar
  popup_text <- andelar_deso %>%
    group_by(desokod, år) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod)," ",unique(år), "<br>",
        paste0(
          str_to_title(hushållstyp), ": ", Andel, "% (", Antal.hushåll, " st)",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  
  
  
  #  Slå ihop geometri, populäraste form & popup 
  deso_sf_pop <- mest_popular %>%
    left_join(popup_text, by = c("desokod", "år"))
  
  # Säkerställ samma faktorordning + titelfall
  deso_sf_pop$Popularaste <- factor(
    deso_sf_pop$Popularaste,
    levels = names(hus_col),
    labels = tools::toTitleCase(names(hus_col))
  )
  
  
  deso_sf_pop_5 <- deso_sf_pop %>% filter(år == max(as.integer(år)))
  deso_sf_pop_5$label <- paste(
    "DeSO: ", deso_sf_pop_5$desokod, " | ",
    deso_sf_pop_5$Popularaste)
  
  #  Skapa kartan 
  map2 <- mapview(
    deso_sf_pop_5,
    zcol = "Popularaste",
    legend = TRUE,
    layer.name = paste("Vanligaste hushållstypen", max(as.integer(deso_sf$år))),
    col.regions = hus_col,
    popup = deso_sf_pop_5$popup,
    hide = TRUE,
    label = deso_sf_pop_5$label
  )
  
  # Layer med ett till år
  deso_sf_pop_10 <- deso_sf_pop %>% filter(år == min(as.integer(år)))
  
  deso_sf_pop_10$label <- paste(
    "DeSO: ", deso_sf_pop_10$desokod, " | ",
    deso_sf_pop_10$Popularaste)
  
  #  Skapa kartan 
  map3 <- mapview(
    deso_sf_pop_10,
    zcol = "Popularaste",
    legend = TRUE,
    layer.name = paste("Vanligaste hushållstypen", min(as.integer(deso_sf$år))),
    col.regions = hus_col,
    popup = deso_sf_pop_10$popup,
    hide = TRUE,
    label= deso_sf_pop_10$label
  )
  # After creating all three maps, you can try this approach:
  map_combined <- map + map2 + map3
  
  # Add custom JavaScript to control legend visibility
  map_combined@map <- map_combined@map %>%
    htmlwidgets::onRender("
    function(el, x) {
      var legends = el.querySelectorAll('.info.legend'); // bara inom detta element
      legends.forEach((lg, i) => { if (i > 0) lg.style.display = 'none'; });
    }
  
  ")
  return(map_combined)
}


Deso_kon <- function(){
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_alder.gpkg")
      deso_sf <- st_read("Data/df_deso_alder.gpkg", quiet = TRUE) 
    })
  })
  
  
  # Andelsberäkningar
  andelar_deso_kon <- deso_sf %>% 
    filter(ålder == 'totalt', Antal>0) %>% 
    group_by(desokod) %>%
    mutate(
      Total = sum(Antal, na.rm = TRUE),
      Andel = round(100 * Antal / Total, 1)
    ) %>%
    ungroup()
  
  
  
  # Build popup text 
  popup_text_kon <- andelar_deso_kon %>% st_drop_geometry() %>% 
    group_by(desokod) %>%
    summarise(
      popup_kon = paste0(
        "DeSO: ", unique(desokod), "<br>",
        "<b>Könsfördelning:</b><br>",
        paste0(
          str_to_title(kön), ": ", Andel, "% (", format(Antal, big.mark = " "), " st)",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    )
  
  # Gör till wide för att få en andel per kolumn för färg
  andelar_deso_kon_wide <- andelar_deso_kon %>% 
    select(desokod, kön, Andel) %>% 
    pivot_wider(
      names_from = kön,
      values_from = Andel
    )
  
  
  # slå ihop med popupdata
  deso_sf_kon <- andelar_deso_kon_wide %>% left_join(popup_text_kon, by='desokod')
  
  # Hoverover info
  deso_sf_kon$label <- paste(
    "DeSO: ", deso_sf_kon$desokod, " | Andel kvinnor:",
    str_to_title(deso_sf_kon$kvinnor),"%")
  
  # färgschema
  
  pal_kvinnor <- colorRampPalette(c("white","#F6E1DC", "#D57667","#5A1F18"))
  
  # skapar kartan
  map <- mapview(
    deso_sf_kon,
    zcol = "kvinnor",
    legend = TRUE,
    layer.name = "Andel kvinnor (%)", # procenttecknet ger en warning, men påverkar inte
    col.regions = pal_kvinnor,
    popup = deso_sf_kon$popup_kon,
    alpha.regions = 0.5,
    label = deso_sf_kon$label
  )
  
  # Fixar texten i legenden
  map@map <- map@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  map
  
}

# Den går går att göra snabbare genom att manipulera data i en annan funktion och spara, så kartan genereras snabbt utan skapandet av åldersgrupperna
Deso_alder <- function(){
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_alder.gpkg")
      deso_sf <- st_read("Data/df_deso_alder.gpkg", quiet = TRUE) 
    })
  })
  
  
  # Färgschema
  alder_col <- c(
    "0-19 år" = "#D57667",      # Children/Youth
    "20-39 år" = "#F9B000",     # Young Adults  
    "40-59 år" = "#019CD7",     # Middle Age
    "60-79 år" = "#4AA271",     # Seniors
    "80+ år" = "#B81867"        # Elderly
  )
  
  
  
  # Åldersgrupper och summering
  alder_data <- deso_sf %>% 
    filter(ålder != 'totalt') %>% 
    mutate(
      alder_grupp = case_when(
        ålder %in% c("0-4 år", "5-9 år", "10-14 år", "15-19 år") ~ "0-19 år",
        ålder %in% c("20-24 år", "25-29 år", "30-34 år", "35-39 år") ~ "20-39 år",
        ålder %in% c("40-44 år", "45-49 år", "50-54 år", "55-59 år") ~ "40-59 år",
        ålder %in% c("60-64 år", "65-69 år", "70-74 år", "75-79 år") ~ "60-79 år",
        ålder == "80- år" ~ "80+ år",
        TRUE ~ ålder
      )
    ) %>%
    group_by(desokod, kön, alder_grupp) %>%
    summarise(Antal_grupp = sum(Antal, na.rm = TRUE), .groups = 'drop')
  
  # Vanligaste åldersgruppen
  mest_popular_alder <- alder_data %>%
    group_by(desokod, alder_grupp) %>%
    summarise(Total_alder = sum(Antal_grupp, na.rm = TRUE), .groups = 'drop') %>%
    group_by(desokod) %>%
    slice_max(order_by = Total_alder, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    mutate(Popularaste_alder = alder_grupp) %>%
    select(desokod, Popularaste_alder)
  
  # Andelar per deso
  andelar_deso_alder <- alder_data %>% 
    st_drop_geometry() %>%
    group_by(desokod, alder_grupp) %>%
    summarise(Antal_alder = sum(Antal_grupp, na.rm = TRUE), .groups = 'drop') %>%
    group_by(desokod) %>%
    mutate(
      Total = sum(Antal_alder, na.rm = TRUE),
      Andel = round(100 * Antal_alder / Total, 1)
    ) %>%
    ungroup()
  
  # Läser in äldre deso
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_alder_2018.gpkg")
      deso_sf <- st_read("Data/df_deso_alder_2018.gpkg", quiet = TRUE) 
    })
  })
  
  # popup text
  popup_text_alder <- andelar_deso_alder %>%
    group_by(desokod) %>%
    summarise(
      popup_alder = paste0(
        "DeSO: ", unique(desokod)," ",max(as.integer(deso_sf$år))+5, "<br>",
        "<b>Åldersfördelning:</b><br>",
        paste0(
          alder_grupp, ": ", Andel, "% (", format(Antal_alder, big.mark = " "), " st)",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    )
  
  # Skapar lager för ålder
  deso_sf_alder <- mest_popular_alder %>%
    left_join(as.data.frame(popup_text_alder), by = "desokod")
  
  # Färgschema
  deso_sf_alder$Popularaste_alder <- factor(
    deso_sf_alder$Popularaste_alder,
    levels = names(alder_col)
  )
  
  # Hoverover text
  deso_sf_alder$label <- paste(
    "DeSO: ", deso_sf_alder$desokod, " | ",
    deso_sf_alder$Popularaste_alder)
  
  # Skapar kartan
  map_alder <- mapview(
    deso_sf_alder,
    zcol = "Popularaste_alder", 
    legend = TRUE,
    layer.name = paste("Vanligaste åldersgruppen", max(as.integer(deso_sf$år))+5),
    col.regions = alder_col,
    popup = deso_sf_alder$popup_alder,
    alpha.regions = 0.5,
    label=deso_sf_alder$label
  )
  map_alder@map <- map_alder@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  
  # Skapar lager för ålder
  alder_data <- deso_sf %>% 
    filter(ålder != 'totalt') %>% 
    mutate(
      alder_grupp = case_when(
        ålder %in% c("0-4 år", "5-9 år", "10-14 år", "15-19 år") ~ "0-19 år",
        ålder %in% c("20-24 år", "25-29 år", "30-34 år", "35-39 år") ~ "20-39 år",
        ålder %in% c("40-44 år", "45-49 år", "50-54 år", "55-59 år") ~ "40-59 år",
        ålder %in% c("60-64 år", "65-69 år", "70-74 år", "75-79 år") ~ "60-79 år",
        ålder == "80- år" ~ "80+ år",
        TRUE ~ ålder
      )
    ) %>%
    group_by(desokod, kön, alder_grupp ,år) %>%
    summarise(Antal_grupp = sum(Antal, na.rm = TRUE), .groups = 'drop')
  
  
  mest_popular_alder <- alder_data %>%
    group_by(desokod, alder_grupp, år) %>%
    summarise(Total_alder = sum(Antal_grupp, na.rm = TRUE), .groups = 'drop') %>%
    group_by(desokod, år) %>%
    slice_max(order_by = Total_alder, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    mutate(Popularaste_alder = alder_grupp) %>%
    select(desokod, Popularaste_alder, år)
  
  
  andelar_deso_alder <- alder_data %>% 
    st_drop_geometry() %>%
    group_by(desokod, alder_grupp ,år) %>%
    summarise(Antal_alder = sum(Antal_grupp, na.rm = TRUE), .groups = 'drop') %>%
    group_by(desokod, år) %>%
    mutate(
      Total = sum(Antal_alder, na.rm = TRUE),
      Andel = round(100 * Antal_alder / Total, 1)
    ) %>%
    ungroup()
  
  
  popup_text_alder <- andelar_deso_alder %>%
    group_by(desokod, år) %>%
    summarise(
      popup_alder = paste0(
        "DeSO: ", unique(desokod)," ",unique(år), "<br>",
        "<b>Åldersfördelning",":</b><br>",
        paste0(
          alder_grupp, ": ", Andel, "% (", format(Antal_alder, big.mark = " "), " st)",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    )
  
  deso_sf_alder <- mest_popular_alder %>%
    left_join(popup_text_alder, by = c("desokod", "år"))
  
  deso_sf_alder$Popularaste_alder <- factor(
    deso_sf_alder$Popularaste_alder,
    levels = names(alder_col)
  )
  # För 5 år sedan
  deso_sf_alder5 <-deso_sf_alder %>% filter(år == max(as.integer(år)))
  
  deso_sf_alder5$label <- paste(
    "DeSO: ", deso_sf_alder5$desokod, " | ",
    deso_sf_alder5$Popularaste_alder)
  
  # För 10 år sedan
  deso_sf_alder10 <- deso_sf_alder %>% filter(år == min(as.integer(år)))
  
  deso_sf_alder10$label <- paste(
    "DeSO: ", deso_sf_alder10$desokod, " | ",
    deso_sf_alder10$Popularaste_alder)
  
  # Skapar kartan
  map_alder2 <- mapview(
    deso_sf_alder5,
    zcol = "Popularaste_alder", 
    legend = TRUE,
    layer.name = paste("Vanligaste åldersgruppen", max(as.integer(deso_sf_alder5$år))),
    col.regions = alder_col,
    popup = deso_sf_alder5$popup_alder,
    alpha.regions = 0.5, 
    hide=TRUE,
    label = deso_sf_alder5$label
  )
  
  # Skapar kartan
  map_alder3 <- mapview(
    deso_sf_alder10,
    zcol = "Popularaste_alder", 
    legend = TRUE,
    layer.name = paste("Vanligaste åldersgruppen", min(as.integer(deso_sf_alder10$år))),
    col.regions = alder_col,
    popup = deso_sf_alder10$popup_alder,
    alpha.regions = 0.5, 
    hide=TRUE, 
    label=deso_sf_alder10$label)
  
  # Slår ihop kartorna
  combined_map <-  map_alder+ map_alder2+ map_alder3
  
  # Dölj alla utom 1 legend vid start
  combined_map@map <- combined_map@map %>%
    htmlwidgets::onRender("
    function(el, x) {
      var legends = el.querySelectorAll('.info.legend'); // bara inom detta element
      legends.forEach((lg, i) => { if (i > 0) lg.style.display = 'none'; });
    }
  
  ")
  return(combined_map)
}

Deso_fodd <- function(){
  # Läs in datan
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_fodelse.gpkg")
      deso_sf <- st_read("Data/df_deso_fodelse.gpkg", quiet = TRUE) 
    })
  })
  
  # tar ut året
  ar <- unique(deso_sf$år)
  
  # Filtrerar ut och summerar
  deso_sf <- deso_sf %>% filter(!grepl("totalt", födelseregion, ignore.case = TRUE)) %>%
    group_by(desokod,födelseregion ) %>% summarise(Antal = sum(Antal), .groups = "drop")
  
  
  #  Räkna andelar per DeSO 
  andelar_deso <- deso_sf %>%
    group_by(desokod) %>%
    mutate(
      Total = sum(Antal, na.rm = TRUE),
      Andel = round(100 * Antal / Total, 1)
    ) %>%
    ungroup()
  
  #  Bygg popup-texten med andelar
  popup_text <- andelar_deso %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          str_to_title(födelseregion), ": ", Andel, "% (", Antal, " st)",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  
  # Andelar födda utanför sverige
  andel_utanf <- andelar_deso %>%
    filter(födelseregion != "Sverige") %>%
    group_by(desokod) %>%
    summarise(Andel_utanför = sum(Andel), .groups = "drop")
  
  # Slår ihop
  deso_sf_pop <- andel_utanf %>%
    left_join(popup_text, by = "desokod")
  
  # Hoverover infor
  deso_sf_pop$label <- paste(
    "DeSO: ", deso_sf_pop$desokod,  " | ",
    deso_sf_pop$Andel_utanför , '%')
  
  # Tar ut maxandel för färgen
  maxandel <- round(max(andel_utanf$Andel_utanför)+5, -1)
  
  # Skapar kartan
  map <- mapview(
    deso_sf_pop,
    zcol = "Andel_utanför",
    legend = TRUE,
    layer.name = paste("Andel födda utanför Sverige -",ar),
    at = seq(0,maxandel,10),
    col.regions = viridis::cividis(11),
    popup = deso_sf_pop$popup,
    label =  deso_sf_pop$label
  )
  # fixar texten i legenden
  map@map <- map@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  # Layer för födda i övriga världen
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_fodelse.gpkg")
      deso_sf <- st_read("Data/df_deso_fodelse.gpkg", quiet = TRUE) 
    })
  })
  
  # Filtrerar och summerar
  deso_sf1 <- deso_sf %>% filter(!grepl("totalt", födelseregion, ignore.case = TRUE)) %>%
    group_by(desokod,födelseregion ) %>% summarise(Antal = sum(Antal), .groups = "drop")
  
  #  Räkna andelar per DeSO 
  andelar_deso <- deso_sf1 %>%
    group_by(desokod) %>%
    mutate(
      Total = sum(Antal, na.rm = TRUE),
      Andel = round(100 * Antal / Total, 1)
    ) %>%
    ungroup()
  
  #  Bygg popup-texten med andelar
  popup_text <- andelar_deso %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          str_to_title(födelseregion), ": ", Andel, "% (", Antal, " st)",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  
  # Andel födda övriga världen
  andel_utanf <- andelar_deso %>%
    filter(grepl("övriga världen inkl. uppgift saknas", födelseregion, ignore.case = TRUE)) %>%
    group_by(desokod) %>%
    summarise(Andel_utanför = sum(Andel), .groups = "drop")
  
  # Slår ihop
  deso_sf_pop <- andel_utanf %>%
    left_join(popup_text, by = "desokod")
  
  # Hoverover info
  deso_sf_pop$label <- paste(
    "DeSO: ", deso_sf_pop$desokod,  " | ",
    deso_sf_pop$Andel_utanför , '%')
  
  # Andel för färg
  maxandel <- round(max(andel_utanf$Andel_utanför)+5, -1)
  
  # Skapar kartan
  map2 <- mapview(
    deso_sf_pop,
    zcol = "Andel_utanför",
    legend = TRUE,
    layer.name = paste("Andel födda utanför Europa"),
    at = seq(0,maxandel,10),
    col.regions = viridis::cividis(11),
    popup = deso_sf_pop$popup,
    label =  deso_sf_pop$label,
    hide=T
  )
  
  # Layer för skönsskillnad
  deso_sf <- deso_sf %>% filter(!grepl("totalt", födelseregion, ignore.case = TRUE)) %>%
    group_by(desokod,födelseregion , kön) %>% summarise(Antal = sum(Antal), .groups = "drop")
  
  #  Räkna andelar per DeSO 
  andelar_deso <- deso_sf %>%
    group_by(desokod) %>%
    mutate(
      Total = sum(Antal, na.rm = TRUE))%>%
    group_by(desokod, kön) %>% 
    mutate(Andel = round(100 * Antal / Total, 1)
    ) %>%
    ungroup()
  
  
  andel_utanf <- andelar_deso %>%
    filter(grepl("övriga världen inkl. uppgift saknas", födelseregion, ignore.case = TRUE)) %>%
    group_by(desokod, kön) %>%
    summarise(Andel_utanför = sum(Andel), .groups = "drop")
  
  gender_diff <- andel_utanf %>%
    select(desokod, kön, Andel_utanför) %>%
    pivot_wider(names_from = kön, values_from = Andel_utanför, values_fill = 0) %>%
    mutate(
      # Calculate difference (positive = more men, negative = more women)
      Könsskillnad = män - kvinnor,
      # Create categories for better visualization
      Skillnad_kategori = case_when(
        abs(Könsskillnad) < 2 ~ "Ingen större skillnad (±2%)",
        Könsskillnad >= 2 ~ "Fler män",
        Könsskillnad <= -2 ~ "Fler kvinnor"
      ),
      # For popup - show both values
      Män_andel = män,
      Kvinnor_andel = kvinnor
    )
  
  #  Bygg popup-texten med andelar
  popup_text <- andel_utanf %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod)," ", "<br>",
        paste0(
          str_to_title(kön), ": ", Andel_utanför , "%",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  
  
  
  deso_sf_pop2 <- gender_diff %>%
    left_join(popup_text, by = "desokod")
  
  
  deso_sf_pop2$label <- paste(
    "DeSO: ", deso_sf_pop2$desokod,  " | ",
    "Skillnad: ", abs(round(deso_sf_pop2$Könsskillnad, 1)), "%")
  
  
  deso_sf_pop2$Skillnad_kategori <- factor(
    deso_sf_pop2$Skillnad_kategori,
    levels = c("Fler kvinnor", "Ingen större skillnad (±2%)", "Fler män")
  )
  
  map3 <- mapview(
    deso_sf_pop2,
    zcol = "Skillnad_kategori",
    legend = TRUE,
    layer.name = paste("Könsskillnad - födda utanför Europa"),
    col.regions = c("#D57667","#6F787E","#4AA271"),
    popup = deso_sf_pop2$popup,
    label =  deso_sf_pop2$label,
    hide=T
  )
  
  # Slår ihop lagren
  combined_map <- map + map2 + map3
  
  # Döljer alla legender utom första
  combined_map@map <- combined_map@map %>%
    htmlwidgets::onRender("
    function(el, x) {
      var legends = el.querySelectorAll('.info.legend'); // bara inom detta element
      legends.forEach((lg, i) => { if (i > 0) lg.style.display = 'none'; });
    }
  
  ")
  return(combined_map)
}
