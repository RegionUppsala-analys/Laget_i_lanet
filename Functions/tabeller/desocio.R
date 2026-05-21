## skapa tabeller

# Ställer in settings paket mm
{
  source("Script/install_load_packages.R")
  source("Script/settings.R")
  install_and_load()
  settings <- get_settings()
  
  kommunkod <- settings$kommunkod
  kommuner <- settings$kommuner
  kommun_colors <- settings$kommun_colors
  
  
}


##### befolkning åldersklasser senaste året

tab_alder_class <- function(){
  # Läser in data
  df <- read.csv('Data/df_folkmangd.csv')
  df <- df %>% filter(år ==max(år)) 
  
  # Region 
  # Grupperar datan
  region <- df  %>%  group_by(år, ålder) %>% 
    summarise(Total = sum(Folkmängd), .groups='drop')
  
  region$region <- "Länet"
  
  # Skapar ålderkategorier
  region <- region %>% mutate(Åldersgrupp = dplyr::case_when(
    ålder <= 19            ~ "0-19",
    ålder > 19 & ålder <= 39 ~ "20-39",
    ålder > 39 & ålder <= 59 ~ "40-59",
    ålder >= 60 & ålder <= 79 ~ "60-79",
    ålder >= 80 ~ "80+")
  )
  
  
  #  Kommun summering
  kommun <- df %>% group_by(region, år, ålder) %>% 
    summarise(Total = sum(Folkmängd), .groups='drop')
  
  # Skapar ålderkategorier
  kommun <- kommun %>% mutate(Åldersgrupp = dplyr::case_when(
    ålder <= 19            ~ "0-19",
    ålder > 19 & ålder <= 39 ~ "20-39",
    ålder > 39 & ålder <= 59 ~ "40-59",
    ålder >= 60 & ålder <= 79 ~ "60-79",
    ålder >= 80 ~ "80+"))
  
  # Slår ihop data
  df_plot <- rbind(
    region %>% select(år,  Total , region, Åldersgrupp),
    kommun %>% select(år,  Total, region, Åldersgrupp)
  )
  
  # Beräknar total och andel
  df_plot <- df_plot %>% group_by(region, år, Åldersgrupp) %>% 
    summarise(Total = sum(Total), .groups='drop') %>% 
    group_by(region, år) %>%
    mutate(Totalt = sum(Total),
           Andel = round(100 * Total / Totalt, 1)
    ) %>% ungroup() %>% select(region, Åldersgrupp, Total, Andel) %>% 
    rename(Antal = Total)
  
  regioner <- c('Länet', sort(kommuner))
  
  #  filter buttons, loopar över kommuner och län
  region_buttons <- div(
    style = "margin-bottom: 20px;",
    h4("Välj region:"),
    div(
      style = "display: flex; flex-wrap: wrap; gap: 5px;",
      lapply(regioner, function(r) {
        tags$button(
          r,
          onclick = sprintf("Reactable.setFilter('table', 'region', '%s')", r),
          class = "btn btn-outline-primary btn-sm"
        )
      })
    )
  )
  
  
  # Skapar tabell
  table <- reactable(
    df_plot,
    elementId = "table",
    filterable = TRUE,
    searchable = FALSE,
    columns = list(
      region = colDef(name = "Region", filterable = TRUE),
      Åldersgrupp = colDef(name = "Åldersgrupp"),
      Antal = colDef(
        name = "Antal",
        format = colFormat(separators = TRUE)
      ),
      Andel = colDef(
        name = "Andel (%)",
        format = colFormat(suffix = "%", digits = 1),
        style = function(value) {
          normalized <- (value - min(df_plot$Andel)) / (max(df_plot$Andel) - min(df_plot$Andel))
          # Convert hex colors to RGB
          end_color <- c(184, 24, 103)  # #B81867
          start_color <- c(244, 220, 232)  # #F4DCE8
          
          # Interpolate between colors
          r <- round(start_color[1] + (end_color[1] - start_color[1]) * normalized)
          g <- round(start_color[2] + (end_color[2] - start_color[2]) * normalized)
          b <- round(start_color[3] + (end_color[3] - start_color[3]) * normalized)
          
          color <- rgb(r, g, b, maxColorValue = 255)
          list(background = color)
        }
      )
    ),
    striped = TRUE,
    highlight = TRUE,
    bordered = TRUE,
    theme = reactableTheme(
      headerStyle = list(
        background = "#F4DCE8",
        color = "black",
        fontSize = "14px",
        fontWeight = "600"
      )
    ),
    language = reactableLang(
      searchPlaceholder = "Sök...",
      noData = "Ingen data tillgänglig",
      pageInfo = "{rowStart} till {rowEnd} av {rows} rader",
      pagePrevious = "Föregående",
      pageNext = "Nästa"
    )
  )
  
  
  # kombinera buttons och tabell
  div(region_buttons, table)
  
  
}


##### Tabell för de 10 Deso områden med högst andel hushåll som är ensamstående med barn
tab_hushall <- function(){
  # Läser in data
  regso <- read_excel('Data/koppling-deso2025-regso2025.xlsx',col_names = T, skip=3)
  
  regso <- regso %>%  rename(desokod = 'DeSO_2025',
                             'Område' = RegSO_2025)
  
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_hushall.gpkg")
      deso_sf <- st_read("Data/df_deso_hushall.gpkg", quiet = TRUE) 
    })
  })
  
  # Filtrerar ut total
  deso_sf <- deso_sf %>% filter(!grepl("totalt antal hushåll", hushållstyp, ignore.case = TRUE))
  
  # Tar bort dubbletter, fel från SCB?
  deso_sf <- deso_sf %>%
    group_by(desokod, hushållstyp) %>%
    slice_max(Antal.hushåll, n = 1, with_ties = FALSE) %>%
    ungroup()
  
  # Lägger in kommunnamn
  komnamn <- data.frame(kommunnamn=c("Knivsta", "Heby", "Tierp", "Uppsala", "Enköping", "Östhammar", "Håbo", "Älvkarleby"), 
                        kommunkod=c("0330", "0331", "0360", "0380", "0381", "0382", "0305", "0319"))
  deso_sf <- deso_sf %>% left_join(komnamn, by="kommunkod" )
  
  
  #  Räkna andelar per DeSO 
  andelar_deso <- deso_sf %>%
    group_by(desokod) %>%
    mutate(
      Total = sum(Antal.hushåll, na.rm = TRUE),
      Andel = round(100 * Antal.hushåll / Total, 1)
    ) %>%
    ungroup() %>%
    st_drop_geometry()%>% select(desokod, hushållstyp, kommunnamn, kommunkod,Antal.hushåll, Andel)
  
  # Left join
  andelar_deso <- andelar_deso %>% left_join(regso %>% select(desokod, Område), by='desokod')
  
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_hushall_2018.gpkg")
      deso_sf2 <- st_read("Data/df_deso_hushall_2018.gpkg", quiet = TRUE) 
    })
  })
  
  regso <- read_excel('Data/koppling-deso2018-regso2020.xlsx',col_names = T, skip=3)
  
  # Byter namn
  regso <- regso %>%  rename(desokod = 'DeSO_2018',
                             'Område' = RegSO_2020)
  
  # Tar ut senaste året
  new_y <- max(as.integer(deso_sf$år))
  andelar_deso$år <- as.character(new_y)
  
  
  deso_sf2 <- deso_sf2 %>% filter(!grepl("totalt antal hushåll", hushållstyp, ignore.case = TRUE))
  
  deso_sf2 <- deso_sf2 %>% left_join(regso %>% select(desokod, Område), by='desokod')
  
  # Lägger in kommunnamn
  komnamn <- data.frame(kommunnamn=c("Knivsta", "Heby", "Tierp", "Uppsala", "Enköping", "Östhammar", "Håbo", "Älvkarleby"), 
                        kommunkod=c("0330", "0331", "0360", "0380", "0381", "0382", "0305", "0319"))
  deso_sf2 <- deso_sf2 %>% left_join(komnamn, by="kommunkod" )
  
  deso_sf2 <- deso_sf2 %>%
    group_by(desokod, hushållstyp, år) %>%
    slice_max(Antal.hushåll, n = 1, with_ties = FALSE) %>%
    ungroup()
  
  #  Räkna andelar per DeSO 
  andelar_deso2 <- deso_sf2 %>%
    group_by(desokod, år) %>%
    mutate(
      Total = sum(Antal.hushåll, na.rm = TRUE),
      Andel = round(100 * Antal.hushåll / Total, 1)
    ) %>%
    ungroup()%>%
    st_drop_geometry() %>% select(desokod, hushållstyp, kommunnamn, kommunkod,Antal.hushåll, Andel,Område,år)
  
  
  
  #  Slå ihop geometri, populäraste form & popup 
  table_hus <- bind_rows(andelar_deso, andelar_deso2)
  
  
  
  table_ensam_medbarn_top <- table_hus %>% filter(hushållstyp == 'ensamstående med barn') %>% 
    group_by(år) %>% slice_max(order_by = Andel, n = 10, with_ties = F) %>% ungroup() 
  
  
  
  # Dela upp data per år
  df10 <- table_ensam_medbarn_top %>% filter(år == as.character(new_y-10)) %>% 
    select(Område,desokod, Antal.hushåll, Andel)
  
  df5 <- table_ensam_medbarn_top %>% filter(år == as.character(new_y-5)) %>% 
    select(Område,desokod, Antal.hushåll, Andel)
  
  dfnew <- table_ensam_medbarn_top %>% filter(år == max(år)) %>% 
    select(Område,desokod, Antal.hushåll, Andel)
  
  # Hitta max antal rader
  max_rows <- max(nrow(df10), nrow(df5), nrow(dfnew))
  
  # Funktion för att fylla med NA
  fill_na_rows <- function(df, max_rows){
    if(nrow(df) < max_rows){
      df[(nrow(df)+1):max_rows, ] <- NA
    }
    df
  }
  
  df10 <- fill_na_rows(df10, max_rows)
  df5 <- fill_na_rows(df5, max_rows)
  dfnew <- fill_na_rows(dfnew, max_rows)
  
  # Sätt ihop horisontellt
  table_side_by_side <- bind_cols(
    df10, df5, dfnew
  )
  
  # Byt kolumnnamn för tydlighet
  colnames(table_side_by_side) <- c(
    paste0(paste0(as.character(new_y-10),"_"), colnames(df10)),
    paste0(paste0(as.character(new_y-5),"_"), colnames(df5)),
    paste0(new_y,'_', colnames(dfnew))
  )
  
  colormap <- c( "#EABAB3","#D57667")
  domain_vals <- range(
    unlist(table_side_by_side %>% select(ends_with("Andel"))),
    na.rm = TRUE
  )
  
  
  years <- c(new_y - 10, new_y - 5, new_y)
  
  labels <- unlist(
    lapply(years, function(y) {
      c(
        setNames("DeSO-kod", paste0(y, "_desokod")),
        setNames("Område", paste0(y, "_Område")),
        setNames("Antal hushåll", paste0(y, "_Antal.hushåll")),
        setNames("Andel (%)", paste0(y, "_Andel"))
      )
    })
  )
  
  # Skapa gt-tabellen
  gt(table_side_by_side) %>%
    tab_spanner(label = as.character(new_y-10), columns = starts_with(as.character(new_y-10))) %>%
    tab_spanner(label = as.character(new_y-5), columns = starts_with(as.character(new_y-5))) %>%
    tab_spanner(label = new_y, columns = starts_with(paste0(new_y,'_'))) %>%
    cols_label(.list = labels) %>%
    fmt_number(
      columns = ends_with("Antal.hushåll"),
      decimals = 0
    ) %>%
    fmt_number(
      columns = ends_with("Andel"),
      decimals = 1,
      suffixing = "%"
    )%>%
    data_color(
      columns = contains("Andel"),
      colors = scales::col_numeric(
        palette = colormap,
        domain = domain_vals
      )) %>%
    tab_source_note(
      source_note = "Källa: SCB"
    ) %>%
    tab_options(
      table.font.names = "sourcesanspro",
      table.width = pct(100),
      heading.title.font.size = 14,
      table.font.size = 12
    )
  
}



tab_kon <- function(){
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_alder.gpkg")
      deso_sf <- st_read("Data/df_deso_alder.gpkg", quiet = TRUE) 
    })
  })
  
  # Lägger in kommunnamn
  komnamn <- data.frame(kommunnamn=c("Knivsta", "Heby", "Tierp", "Uppsala", "Enköping", "Östhammar", "Håbo", "Älvkarleby"), 
                        kommunkod=c("0330", "0331", "0360", "0380", "0381", "0382", "0305", "0319"))
  
  deso_sf <- deso_sf %>% left_join(komnamn, by="kommunkod" )
  
  regso <- read_excel('Data/koppling-deso2025-regso2025.xlsx',col_names = T, skip=3)
  
  regso <- regso %>%  rename(desokod = 'DeSO_2025',
                             'Område' = RegSO_2025)
  
  # KÖN LAYER 
  # Most popular gender per DeSO (using totalt data)
  mest_popular_kon <- deso_sf %>% 
    filter(ålder == 'totalt') %>% 
    group_by(desokod) %>%
    slice_max(order_by = Antal, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    mutate(Popularaste_kon = tools::toTitleCase(kön)) %>%
    select(desokod, Popularaste_kon)
  
  # Andelar per deso
  andelar_deso_kon <- deso_sf %>% 
    filter(ålder == 'totalt') %>% 
    st_drop_geometry() %>%
    group_by(desokod) %>%
    mutate(
      Total = sum(Antal, na.rm = TRUE),
      Andel = round(100 * Antal / Total, 1)
    ) %>%
    ungroup()%>%
    st_drop_geometry()%>% select(desokod, kön, kommunnamn,Antal, Andel)
  
  # Tar ut dom 10 med skevast fördelning
  mest_konet <- andelar_deso_kon %>% slice_max(order_by = Andel, n = 10, with_ties = F)
  
  colnames(mest_konet)[5] <- 'Andel (%)'
  
  # Färgschema och fixar till versaler
  colormap <- c( "#EABAB3","#D57667")
  mest_konet$kön <- tools::toTitleCase(mest_konet$kön)
  
  # Slår ihop data
  mest_konet <- mest_konet %>% left_join(regso %>% select(desokod, Område), by='desokod')
  
  mest_konet <- mest_konet %>% select(Område, colnames(mest_konet)[-ncol(mest_konet)])
  
  # Stor bokstav på variabelnamn
  colnames(mest_konet) <- tools::toTitleCase(colnames(mest_konet))
  
  # Skapar tabell
  mest_konet %>% gt() %>%
    tab_header(
      title = "DeSo med högst andel av ett kön",
      subtitle = "(i hela länet)"
    )%>%
    data_color(
      columns = contains("Andel"),
      colors = scales::col_numeric(
        palette = colormap,
        domain = NULL # will scale across actual values
      )
    ) %>%
    tab_source_note(
      source_note = "Källa: SCB"
    )  %>% tab_options(table.font.names = "sourcesanspro")
  
  
  
}


inkomst_summary <- function(){
  # Läser data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_inkomststruktur.gpkg")
      df_inkomststruktur <- st_read("Data/df_inkomststruktur.gpkg", quiet = TRUE)
    })
  })
  
  # Filter out "totalt"
  df_gender <- df_inkomststruktur %>% filter(kön != "totalt")
  
  # Variabler
  top_components <- c(
    "löneinkomst ",
    "näringsinkomst med mera",
    "inkomst av kapital",
    "pensioner",
    "sjuk- och aktivitetsersättning",
    "sjukpenning med mera",
    "föräldrapenning",
    "arbetsmarknadsstöd",
    "ekonomiskt bistånd",
    "barnbidrag"
  )
  
  
  # Pivotera så att varje inkomstkomponent blir en kolumn, separerat på kön
  df_wide_plot <- df_gender %>%
    st_drop_geometry() %>%
    filter(inkomstkomponent %in% top_components) %>%
    select(inkomstkomponent, kön, år, desokod, Medelvärde.för.samtliga..tkr) %>%
    pivot_wider(
      names_from = inkomstkomponent,
      values_from = Medelvärde.för.samtliga..tkr
    )
  
  
  # Pivotera data wide men behåll kön som kolumn
  df_wide_plot <- df_gender %>%
    st_drop_geometry() %>%
    filter(inkomstkomponent %in% top_components) %>%
    select(inkomstkomponent, kön, år, desokod, Medelvärde.för.samtliga..tkr) %>%
    pivot_wider(
      names_from = inkomstkomponent,
      values_from = Medelvärde.för.samtliga..tkr
    )
  
  # Tar ut statistik per kön
  summary_tab <- df_wide_plot %>% group_by(kön) %>% 
    summarise(across(
      .cols = where(is.numeric),  # select all numeric columns
      .fns = list(
        SD = ~ sd(.x, na.rm = TRUE),
        Median = ~median(.x, na.rm = TRUE),
        Mean = ~mean(.x, na.rm = TRUE)
      ),
      .names = "{col}_{fn}"  # create new column names like 'löneinkomst_Min'
    ))
  
  
  #  Pivot longer 
  tidy_summary <- summary_tab %>%
    pivot_longer(
      cols = -kön,
      names_to = "Variable_Stat",
      values_to = "Value"
    ) %>%
    # Step 2: separate Variable and Stat
    mutate(
      Stat = sub(".*_(SD|Median|Mean)$", "\\1", Variable_Stat),
      Variable = sub("_(SD|Median|Mean)$", "", Variable_Stat)
    ) %>%
    select(Variable, Stat, kön, Value)  # keep only important columns
  
  # Wider för män och kvinnor som kolumn
  final_table <- tidy_summary %>%
    pivot_wider(
      names_from = c(kön, Stat),         # combine gender and stat
      values_from = Value,
      names_glue = "{kön}_{Stat}"        # columns like Män_Mean, Kvinnor_Median
    )%>%
    mutate(
      Variable = str_to_sentence(Variable),           # första bokstaven stor
      Variable = str_replace_all(Variable, '"', '')   # ta bort citationstecken
    )
  
  # Fixar namnen
  colnames(final_table) <- c(
    "Variable","Kvinnor_SD",
    "Kvinnor_Median" ,"Kvinnor_Medel", 
    "Män_SD", "Män_Median", "Män_Medel"
  )
  
  # Alphabetic order
  final_table_ordered <- final_table %>%
    arrange(Variable) %>% rename(" " = Variable)
  
  
  # Skapar tabell
  gt_table <- final_table_ordered %>%
    gt() %>%
    # Add spanner labels for top-level headers
    tab_spanner(
      label = "Män",
      columns = c(Män_Median,Män_Medel, Män_SD)
    ) %>%
    tab_spanner(
      label = "Kvinnor",
      columns = c(Kvinnor_Median,Kvinnor_Medel, Kvinnor_SD)
    ) %>%
    # Rename sub-columns nicely
    cols_label(
      Män_Median = "Median",
      Män_Medel = "Medel",
      Män_SD = "Sd",
      Kvinnor_Median = "Median",
      Kvinnor_Medel = "Medel",
      Kvinnor_SD = "Sd"
    ) %>%
    fmt_number(
      columns = everything(), 
      decimals = 1
    ) %>%
    tab_source_note(
      source_note = "Källa: SCB"
    )  %>% tab_options(table.font.names = "sourcesanspro")
  
  gt_table
  
}




