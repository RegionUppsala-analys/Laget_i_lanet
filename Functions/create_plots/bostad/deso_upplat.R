######### Deso upplåtelseform #######

deso_upplat <- function(){
  # Läser in data
  df_deso <- read.csv('Data/df_deso.csv')
  
  suppressMessages({
    suppressWarnings({
      st_layers("DeSO_2025.gpkg")
      deso_sf <- st_read("DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE) %>%
        filter(lanskod == !!lanskod) # tar endast ut länet
    })
  })
  
  # Byter namn på kolumn så dom matchar och slår ihop
  df_deso <- df_deso %>%
    rename(desokod = region)
  
  deso_sf <- left_join(deso_sf, df_deso, by = "desokod")
  
  
  ## plockar ut vanligaste upplåtelseformen och lägger till andelar när man klickar på regionen.
  
  #  Mest populära upplåtelseform per DeSO 
  mest_popular_upplat <- df_deso %>%
    group_by(desokod) %>%
    slice_max(order_by = Antal, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    mutate(Popularaste_upplåtelseform = upplåtelseform) %>%
    select(desokod, Popularaste_upplåtelseform)
  
  #  Räkna andelar per DeSO 
  andelar_deso <- df_deso %>% filter(upplåtelseform != 'uppgift saknas') %>% 
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
          str_to_title(upplåtelseform), ": ", Andel, "% (", Antal, " st)",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    )
  
  #  Slå ihop geometri, populäraste form & popup 
  deso_sf_pop <- deso_sf %>%
    left_join(mest_popular_upplat, by = "desokod") %>%
    left_join(popup_text, by = "desokod")
  
  # Säkerställ samma faktorordning + titelfall
  deso_sf_pop$Popularaste_upplåtelseform <- factor(
    deso_sf_pop$Popularaste_upplåtelseform,
    levels = names(upplat_colors),
    labels = tools::toTitleCase(names(upplat_colors))
  )
  
  #  Skapa kartan 
  map <- mapview(
    deso_sf_pop,
    zcol = "Popularaste_upplåtelseform",
    legend = TRUE,
    layer.name = paste("Vanligaste upplåtelseformen",unique(df_deso$år)),
    col.regions = upplat_colors,
    popup = deso_sf_pop$popup,
    alpha.regions = 0.2
  )
  
  # Fixar texten i legenden så den inte blir centrerad
  map@map <- map@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  # Sparar data till tabell i index.qmd-filen
  suppressMessages({
    suppressWarnings({
      st_write(deso_sf, "Data/deso_sf.gpkg", delete_dsn = TRUE, quiet = TRUE)
    })
  })
  
  map
  
  
}

