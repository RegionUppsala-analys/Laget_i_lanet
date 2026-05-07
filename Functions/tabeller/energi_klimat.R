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
  lanskod <- settings$lanskod
  lan <- settings$lan
  
}
########### Klimat###########
###### Fotavtryck per konsumtionskategori likt den från konsumtionskompassens hemsida
Fotavtryck_per_konsumtionskategori <- function(){
  ############################Lägger in året manuellt då det ej följer med datan
  ar <- 2022 
  ############################
  
  # Läser in data
  df <- read.csv('Data/fotavtryck-per-konsumtionskategori.csv')
  
  # Fixar kolumner och namn
  df <- df[,2:ncol(df)]
  colnames(df) <- gsub("\\.", " ", colnames(df)) 
  colnames(df)[1:2] <- c('Konsumtionskategori', 'Utsläpp / 100 sek')
  
  # Ändrar till stor bokstav på kategorier
  df <- df %>% mutate(Konsumtionskategori = str_to_sentence(Konsumtionskategori))
  
  # Ändrar ordningen på kolumnerna 
  df <- df %>%
    dplyr::select(Konsumtionskategori, `Utsläpp / 100 sek`, `Uppsala län`, all_of(sort(kommuner)))
  
  # kolumner för att göra färgskala
  numeric_cols <- c("Uppsala län", sort(kommuner))
  
  # Färgskala baseras på detta
  val_range <- range(df %>%  dplyr::select(all_of(numeric_cols)) %>% unlist(), na.rm = TRUE)
  
  # Skapa tabell
  gt_table<-df %>%
    gt() %>%
    # Color numeric columns
    data_color(
      columns = all_of(numeric_cols),
      colors = scales::col_numeric(
        palette = c("#DBECE3", "#D57667"), 
        domain = val_range
      )
    ) %>%
    # Formatering
    fmt_number(
      columns = c(`Utsläpp / 100 sek`,all_of(numeric_cols)),
      decimals = 1
    ) %>%
    tab_header(
      title = paste("Fotavtryck per konsumtionskategori år", ar)
    ) %>%
    # Smalare tabell
    cols_width(
      everything() ~ px(65),          # Storlek på numeriska kolumner
      vars(Konsumtionskategori) ~ px(100) # Storlek på kategori
    ) %>%
    tab_source_note(
      source_note = "Källa: Konsumtionskompassen"
    )%>%
    tab_options(
      table.font.names = "sourcesanspro",
      table.font.size = px(14),
      table.width = px(700),          # Sidan är inställd på 700 px som standardmått
      heading.title.font.size = px(16)
    )
  
  gt_table
  
}




Fotavtryck_per_konsumtionskategori2 <- function(){
  ############################Lägger in året manuellt då det ej följer med datan
  ar <- 2022 
  ############################
  
  # Läser in data
  df <- read.csv('Data/fotavtryck-per-konsumtionskategori.csv')
  
  # Fixar kolumner och namn
  df <- df[,2:ncol(df)]
  colnames(df) <- gsub("\\.", " ", colnames(df)) 
  colnames(df)[1:2] <- c('Konsumtionskategori', 'Utsläpp / 100 sek')
  
  # Ändrar till stor bokstav på kategorier
  df <- df %>% mutate(Konsumtionskategori = str_to_sentence(Konsumtionskategori))
  
  # Ändrar ordningen på kolumnerna 
  df <- df %>%
    dplyr::select(Konsumtionskategori, `Utsläpp / 100 sek`, `Uppsala län`, all_of(sort(kommuner)))
  
  # kolumner för att göra färgskala
  numeric_cols <- c("Uppsala län", sort(kommuner))
  
  # Färgskala baseras på detta
  val_range <- range(df %>% select(all_of(numeric_cols)) %>% unlist(), na.rm = TRUE)
  
  # Lista över kolumner som ska rundas & göras smala
  num_cols <- c(
    "Utsläpp / 100 sek", "Uppsala län", "Enköping", "Heby", "Håbo",
    "Knivsta", "Tierp", "Uppsala", "Älvkarleby", "Östhammar"
  )
  
  # Färgområde (samma som i GT)
  val_range <- range(dplyr::select(df, all_of(numeric_cols)), na.rm = TRUE)
  
  # Skapa colDef-lista
  col_defs <- list(
    Konsumtionskategori = colDef(
      width = 120,
      filterable = FALSE,
      searchable = FALSE,
      style = cell_style(font_size = 12),
      headerStyle = list(
        fontSize = "12px",
        fontWeight = "bold",
        color = "black"
      )
    ),
    
    # Denna kolumn avrundas men har ingen färg
    `Utsläpp / 100 sek` = colDef(
      width = 65,
      filterable = FALSE,
      searchable = FALSE,
      format = colFormat(digits = 1),
      style = cell_style(font_size = 12),
      headerStyle = list(
        fontSize = "12px",
        fontWeight = "bold",
        color = "black"
      )
    )
  )
  
  # Kolumner som ska färgas
  for (col in numeric_cols) {
    col_defs[[col]] <- colDef(
      width = 65,
      format = colFormat(digits = 1),
      style = function(value) {
        color <- scales::col_numeric(
          palette = c("#DBECE3", "#D57667"),
          domain = val_range
        )(value)
        
        list(
          background = color,
          fontSize = "12px"
        )
      },
      headerStyle = list(
        fontSize = "12px",
        fontWeight = "bold",
        color = "black"
      )
    )
  }
  
  # Skapa tabellen
  table <- reactable(
    df,
    columns = col_defs,
    defaultPageSize = nrow(df),
    bordered = FALSE,
    highlight = FALSE,
    wrap = TRUE,
    theme = reactablefmtr::nytimes(),
    width = 700
  ) %>%
    add_source("Källa: Konsumtionskompassen") %>% 
    add_title(
      paste("Fotavtryck per konsumtionskategori år", ar),
      font_size = 16,
      align = "center"
    )
  
  table
}

########### Energi ############

Elavtals_tabell <- function(){
  # Läser in data
  df <- read.csv('Data/df_Elhandelspriser.csv')
  
  # Gör kolumnnamn och kategorier till storbokstav
  colnames(df) <- str_to_sentence(colnames(df))
  
  df <- df %>% mutate(Avtalstyp = str_to_sentence(Avtalstyp),
                      Kundkategori = str_to_sentence(Kundkategori)) 
  # fixar år för att ta ut variabler
  df <- df %>%
    mutate(
      Månad = as.Date(paste0(substr(Månad, 1, 4), "-", substr(Månad, 6, 7), "-01")),
      År = as.numeric(substr(Månad, 1, 4))
    )
  
  # Variabler till titel-intervall
  ar_start <- min(df$År)
  ar_end <- max(df$År)
  
  # Medel per avtalstyp och kundkategori
  df1 <- df %>% filter(Elområde == 'SE3') %>% group_by(Avtalstyp, Kundkategori) %>% 
    summarise(Medel = mean(Elhandelspriser), .groups='drop')
  
  # Tar ut medel
  df <- df %>% filter(År > 2022) %>% group_by(Avtalstyp, Kundkategori) %>% 
    summarise(Medel_efter_22 = mean(Elhandelspriser), .groups='drop')
  
  # Sorterar i växande ordning
  df <- df1 %>% left_join(df, by=c('Avtalstyp','Kundkategori'))
  df <- df %>% arrange(Medel)
  
  # Skapar tabell
  df %>% gt() %>%
    tab_header(
      title = paste("Genomsnittligt elpris per avtalstyp och kundkategori mellan",ar_start,'-',ar_end ),
      subtitle = "Elområde SE3"
    ) %>%
    fmt_number(
      columns = c(Medel, Medel_efter_22),
      decimals = 2
    ) %>%
    cols_label(
      Avtalstyp = "Avtalstyp",
      Kundkategori = "Kundkategori",
      Medel = "Medelpris (öre/kWh)",
      Medel_efter_22 = "Medelpris efter 2022"
    ) %>%
    data_color(
      columns = c(Medel,Medel_efter_22),
      colors = scales::col_numeric(
        palette = c("#DBECE3", "#D57667"),
        domain = NULL
      )
    ) %>%
    tab_source_note(
      source_note = "Källa: SCB"
    ) %>%
    tab_options(
      table.font.names = "sourcesanspro",
      table.font.size = px(14),
      table.align = "center",
      heading.align = "center"
    )
  
}
