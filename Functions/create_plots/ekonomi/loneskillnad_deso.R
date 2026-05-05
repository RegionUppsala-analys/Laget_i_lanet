loneskillnad_deso <- function(){
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_inkomststruktur.gpkg")
      df_inkomststruktur <- st_read("Data/df_inkomststruktur.gpkg", quiet = TRUE)
    })
  })
  
  # tar ut året
  ar <- unique(df_inkomststruktur$år)
  # Filter out "totalt"
  df_gender <- df_inkomststruktur %>% filter(kön != "totalt")
  
  # en geom per desokod
  geom_df <- df_gender %>%
    group_by(desokod) %>%
    summarise(geom = first(geom), .groups = "drop") %>%
    st_as_sf()
  
  # löneinkomst
  df_wage <- df_gender %>%
    filter(inkomstkomponent == "löneinkomst ")
  
  # pivot wide och ändrar namn
  df_gap <- df_wage %>%
    st_drop_geometry() %>%
    pivot_wider(names_from = kön, values_from = c(Medelvärde.för.samtliga..tkr,Antal.personer.totalt), id_cols =desokod) %>%
    rename(
      inkomst_män = Medelvärde.för.samtliga..tkr_män,
      inkomst_kvinnor = Medelvärde.för.samtliga..tkr_kvinnor,
      personer_män = Antal.personer.totalt_män,
      personer_kvinnor = Antal.personer.totalt_kvinnor
    ) %>%
    mutate(
      gap =  round(inkomst_kvinnor/inkomst_män,2)*100,
      personer_totalt = personer_män + personer_kvinnor
    )
  
  # tar tillbaka geometry
  df_gap_sf <- df_wage %>%
    select(desokod, geom) %>%
    distinct() %>%
    left_join(df_gap, by = "desokod")
  
  
  # Skapar karta med manuell hoverover info och popup
  map <- mapview(
    df_gap_sf,
    zcol = "gap",        # <- use the new factor variable
    col.regions = viridis::cividis,
    popup = paste0( 
      "Deso: ", df_gap_sf$desokod, "<br>",
      "Män: ", df_gap_sf$inkomst_män, " tkr<br>",
      "Kvinnor: ", df_gap_sf$inkomst_kvinnor, " tkr<br>", # popup
      "Kvinnors i % av männens: ", df_gap_sf$gap, " %<br>",
      "Antal Män: ", df_gap_sf$personer_män, "<br>",
      "Antal Kvinnor: ", df_gap_sf$personer_kvinnor, "<br>"
    ),
    layer.name = paste("Kvinnors lön i procent av männens - år",ar),
    label = paste('Kvinnor har',df_gap_sf$gap,'% av männens inkomst ')) # hoverover
  
  # Layer med sjuk- och aktivitetersättning
  df_sjuk <- df_gender %>%
    st_drop_geometry() %>% 
    filter(inkomstkomponent == "sjuk- och aktivitetsersättning") %>%
    pivot_wider(names_from = kön, values_from = c(Medelvärde.för.samtliga..tkr, Antal.personer.totalt), id_cols = desokod) %>%
    rename(
      ersättning_män = Medelvärde.för.samtliga..tkr_män,
      ersättning_kvinnor = Medelvärde.för.samtliga..tkr_kvinnor,
      
      personer_män = Antal.personer.totalt_män,
      personer_kvinnor = Antal.personer.totalt_kvinnor
    ) %>%
    mutate(                    # Viktat medelvärde
      ersättning_medel = round((ersättning_män*personer_män + ersättning_kvinnor*personer_kvinnor)/(personer_män+personer_kvinnor),1),
      gap_ersättning =ersättning_kvinnor - ersättning_män
    ) %>%
    left_join(geom_df %>% select(desokod, geom), by = "desokod") %>%
    st_as_sf()
  
  
  map2 <- mapview(
    df_sjuk,
    zcol = "gap_ersättning",
    col.regions = viridis::cividis,
    layer.name = "Sjukhusersättning (kvinnors ersättning - männens ersättning)",
    popup = paste0(
      "Deso: ", df_sjuk$desokod, "<br>",
      "Män: ", df_sjuk$ersättning_män, " tkr<br>",
      "Kvinnor: ", df_sjuk$ersättning_kvinnor, " tkr<br>",
      "Skillnad: ", df_sjuk$gap_ersättning, " tkr<br>",
      "Medel: ", df_sjuk$ersättning_medel, " tkr<br>",
      "Antal Män: ", df_sjuk$personer_män, "<br>",
      "Antal Kvinnor: ", df_sjuk$personer_kvinnor
    ),
    label = paste('Sjukhusersättningen:', df_sjuk$gap_ersättning, 'tkr'),
    hide=T
  )
  
  # Layer med ekonomiskt bistånd
  df_bistand <- df_gender %>%
    st_drop_geometry() %>% 
    filter(inkomstkomponent == "ekonomiskt bistånd") %>%
    pivot_wider(names_from = kön, values_from = c(Medelvärde.för.samtliga..tkr, Antal.personer.totalt), id_cols = desokod) %>%
    rename(
      ersättning_män = Medelvärde.för.samtliga..tkr_män,
      ersättning_kvinnor = Medelvärde.för.samtliga..tkr_kvinnor,
      
      personer_män = Antal.personer.totalt_män,
      personer_kvinnor = Antal.personer.totalt_kvinnor
    ) %>%
    mutate(                     # Viktat medelvärde
      ersättning_medel = round((ersättning_män*personer_män + ersättning_kvinnor*personer_kvinnor)/(personer_män+personer_kvinnor),1),
      gap_ersättning = ersättning_kvinnor - ersättning_män
    ) %>%
    left_join(geom_df %>% select(desokod, geom), by = "desokod") %>%
    st_as_sf()
  
  
  map3 <- mapview(
    df_bistand,
    zcol = "gap_ersättning",
    col.regions = viridis::cividis,
    layer.name = "Ekonomiskt bistånd (kvinnor - män)",
    popup = paste0(
      "Deso: ", df_bistand$desokod, "<br>",
      "Män: ", df_bistand$ersättning_män, " tkr<br>",
      "Kvinnor: ", df_bistand$ersättning_kvinnor, " tkr<br>",
      "Skillnad: ", df_bistand$gap_ersättning, " tkr<br>",
      "Medel: ", df_bistand$ersättning_medel, " tkr<br>",
      "Antal Män: ", df_bistand$personer_män, "<br>",
      "Antal Kvinnor: ", df_bistand$personer_kvinnor
    ),
    label = paste('Ekonomiskt bistånd:', df_bistand$gap_ersättning, 'tkr'),hide=T
  )
  
  # Layer med pensioner
  df_pen <- df_gender %>%
    st_drop_geometry() %>% 
    filter(inkomstkomponent == "pensioner") %>%
    pivot_wider(names_from = kön, values_from = c(Medelvärde.för.samtliga..tkr, Antal.personer.totalt), id_cols = desokod) %>%
    rename(
      ersättning_män = Medelvärde.för.samtliga..tkr_män,
      ersättning_kvinnor = Medelvärde.för.samtliga..tkr_kvinnor,
      
      personer_män = Antal.personer.totalt_män,
      personer_kvinnor = Antal.personer.totalt_kvinnor
    ) %>%
    mutate(                     # Viktat medelvärde 
      ersättning_medel = round((ersättning_män*personer_män + ersättning_kvinnor*personer_kvinnor)/(personer_män+personer_kvinnor),1),
      gap_ersättning = round(ersättning_kvinnor - ersättning_män,2)
    ) %>%
    left_join(geom_df %>% select(desokod, geom), by = "desokod") %>%
    st_as_sf()
  
  
  map4 <- mapview(
    df_pen,
    zcol = "gap_ersättning",
    col.regions = viridis::cividis,
    layer.name = "Pensioner (kvinnor - män)",
    popup = paste0(
      "Deso: ", df_pen$desokod, "<br>",
      "Män: ", df_pen$ersättning_män, " tkr<br>",
      "Kvinnor: ", df_pen$ersättning_kvinnor, " tkr<br>",
      "Skillnad: ", df_pen$gap_ersättning, " tkr<br>",
      "Medel: ", df_pen$ersättning_medel, " tkr<br>",
      "Antal Män: ", df_pen$personer_män, "<br>",
      "Antal Kvinnor: ", df_pen$personer_kvinnor
    ),
    label = paste('Pensioner:', df_pen$gap_ersättning, 'tkr'),hide=T
  )
  
  # Layer med arbetsmarknadsstöd
  df_arb <- df_gender %>%
    st_drop_geometry() %>% 
    filter(inkomstkomponent == "arbetsmarknadsstöd") %>%
    pivot_wider(names_from = kön, values_from = c(Medelvärde.för.samtliga..tkr, Antal.personer.totalt), id_cols = desokod) %>%
    rename(
      ersättning_män = Medelvärde.för.samtliga..tkr_män,
      ersättning_kvinnor = Medelvärde.för.samtliga..tkr_kvinnor,
      
      personer_män = Antal.personer.totalt_män,
      personer_kvinnor = Antal.personer.totalt_kvinnor
    ) %>%
    mutate(               # Viktat medelvärde
      ersättning_medel = round((ersättning_män*personer_män + ersättning_kvinnor*personer_kvinnor)/(personer_män+personer_kvinnor),1),
      gap_ersättning = ersättning_kvinnor - ersättning_män
    ) %>%
    left_join(geom_df %>% select(desokod, geom), by = "desokod") %>%
    st_as_sf()
  
  
  map5 <- mapview(
    df_arb,
    zcol = "gap_ersättning",
    col.regions = viridis::cividis,
    layer.name = "Arbetsmarknadsstöd (kvinnor - män)",
    popup = paste0(
      "Deso: ", df_arb$desokod, "<br>",
      "Män: ", df_arb$ersättning_män, " tkr<br>",
      "Kvinnor: ", df_arb$ersättning_kvinnor, " tkr<br>",
      "Skillnad: ", df_arb$gap_ersättning, " tkr<br>",
      "Medel: ", df_arb$ersättning_medel, " tkr<br>",
      "Antal Män: ", df_arb$personer_män, "<br>",
      "Antal Kvinnor: ", df_arb$personer_kvinnor
    ),
    label = paste('Arbetsmarknadsstöd:', df_arb$gap_ersättning, 'tkr'),hide=T
  )
  
  # Slår ihop ala kartor
  combined_map <- map+ map2 + map3 + map4+map5
  
  
  # Fixar text och legender
  combined_map@map <- combined_map@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  combined_map@map <- combined_map@map %>%
    htmlwidgets::onRender("
    function(el, x) {
      var legends = el.querySelectorAll('.info.legend'); // bara inom detta element
      legends.forEach((lg, i) => { if (i > 0) lg.style.display = 'none'; });
    }
  
  ")
  combined_map
}