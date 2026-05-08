


kostnad_intakt <- function(){
  # Hämtar data
  df <- read.csv("Data/df_Kostnad_intakt.csv") %>% filter(year==max(year))
  
  # Rensar titlar
  df$title <- gsub(", kr/inv","",df$title)
  
  # variabel som definierar intäkt/kostnad
  df$index <- grepl("Intäkt",df$title )
  df$index  <- ifelse(df$index==TRUE, "Intäkt", "Kostnad")
  
  # Kortar ned titlar
  df$title <- gsub("Kostnad ", "",df$title)
  df$title <- gsub("Intäkter ", "",df$title)
  
  # Stor bokstav
  df$title <- str_to_sentence(df$title)
  
  # Gör till wide
  df_wide <- df %>% pivot_wider(id_cols = c(title,municipality),
                                names_from = index,
                                values_from = value)
  
  
  # Skapar kolumner för andelar
  df_wide <- df_wide %>%
    group_by(municipality) %>%
    mutate(
      total_kostnad = Kostnad[title == "Kulturverksamhet"], # totala kostnaden
      total_intakt  = Intäkt[title == "Kulturverksamhet"], # totala intäkten
      
      andel_kostnad = case_when(
        title == "Kulturverksamhet" ~ 100, # Andel av kostnaden
        TRUE ~ (Kostnad / total_kostnad) * 100
      ),
      
      andel_intakt = case_when(
        title == "Kulturverksamhet" ~ 100, # Andel av intäkten
        TRUE ~ (Intäkt / total_intakt) * 100
      )
    ) %>%
    ungroup() %>%
    select(-total_kostnad, -total_intakt)   # ta bort hjälpkolumner
  
  df_wide <- df_wide %>%mutate(municipality=factor(municipality, levels=c("Riket",sort(kommuner)))) %>%  arrange(municipality) %>% 
    select(title, municipality ,Kostnad, andel_kostnad,Intäkt, andel_intakt)
  
  #  KNAPPAR 
  kommun_buttons <- div(
    style = "margin-bottom: 20px;",
    h4("Välj kommun:"),
    div(
      style = "display: flex; flex-wrap: wrap; gap: 6px;",
      lapply(c("Riket",sort(kommuner)), function(k) {
        tags$button(
          k,
          onclick = sprintf(
            "Reactable.setFilter('kostnad_intakt_table', 'municipality', '%s')",
            k
          ),
          class = "btn btn-outline-primary btn-sm"
        )
      })
    )
  )
  
  
  #  TABELL
  table <- reactable(
    df_wide,
    elementId = "kostnad_intakt_table",
    
    striped = TRUE,
    highlight = TRUE,
    bordered = TRUE,
    compact = TRUE,
    
    searchable = F,
    defaultPageSize = 5,
    
    # Färg och storlek i celler
    theme = reactableTheme(
      headerStyle = list(
        background = "#F4DCE8",
        color = "black",
        fontSize = "14px",
        fontWeight = "600"
      )
    ),
    
    # Kolumnerna och dess titlar -> storlek etc
    columns = list(
      title = colDef(name = "Verksamhet",
                     minWidth = 140,
                     header = function(value) {
                       tagList(
                         tags$div("Verksamhet", style = "font-size: 18px; font-weight: 600;"),
                         tags$div(
                           "Kulturverksamhet per område",
                           style = "font-size: 12px; "
                         )
                       )
                     }
      ),
      
      municipality = colDef(
        minWidth = 80,
        name = "Kommun",header = function(value) {
          tags$div(
            "Kommun",
            style = "font-size: 18px; font-weight: 600;"
          )
        },
        filterable = F
      ),
      
      Kostnad = colDef(
        minWidth = 80,
        name = "Kostnad",
        header = function(value) {
          tagList(
            tags$div("Kostnad", style = "font-size: 18px; font-weight: 600;"),
            tags$div("kr per invånare", style = "font-size: 12px;")
          )
        },
        format = colFormat(digits = 1, separators = TRUE),
        align = "right"
      ),
      
      andel_kostnad = colDef(
        minWidth = 80,
        name = "Andel kostnad",
        header = function(value) {
          tagList(
            tags$div("Andel (%)", style = "font-size: 18px; font-weight: 600;"),
            tags$div("av kostnaden", style = "font-size: 12px; ")
          )
        },
        format = colFormat(digits = 1, separators = TRUE),
        align = "right"
      ),
      
      Intäkt = colDef(
        minWidth = 80,
        name = "Intäkt",
        header = function(value) {
          tagList(
            tags$div("Intäkt", style = "font-size: 18px; font-weight: 600;"),
            tags$div("kr per invånare", style = "font-size: 12px; ")
          )
        },
        format = colFormat(digits = 1, separators = TRUE),
        align = "right"
      ),
      
      andel_intakt = colDef(
        minWidth = 80,
        name = "Andel Intäkt",
        header = function(value) {
          tagList(
            tags$div("Andel (%)", style = "font-size: 18px; font-weight: 600;"),
            tags$div("av intäkten", style = "font-size: 12px; ")
          )
        },
        format = colFormat(digits = 1, separators = TRUE),
        align = "right"
      )
    ))
  
  
  # Källa
  table <- table%>%
    add_source("Källa: SCB:s Räkenskapssammandrag")
  
  # RETURNERA KNAPPAR + TABELL
  div(
    kommun_buttons,
    table
  )
}



# Tabell med andel kulturställen enligt företagsregistret
antal_arbets <- function(){
  # Läser in data
  df <- read.csv("Data/df_antal_arbets_kultur.csv")
  
  ar <- unique(df$år)
  
  df <- df %>% select(-år)
  
  # skapar gt-tabell
  df %>% gt() %>%
    fmt_number(
      columns = Andel,
      decimals = 1
    ) %>%
    fmt_number(
      columns = c(Antal, Totalt),
      use_seps = TRUE,
      decimals = 0,  # visa endast heltal
    ) %>%
    cols_label(
      kommun = "Kommun",
      Andel = "Andel (%)",
      Antal = "Antal kulturarbetställen",
      Totalt = "Totalt antal arbetsställen"
    ) %>%
    tab_header(
      title = paste("Andel och antal kulturarbetsställen per kommun"),
      subtitle = paste("Hämtat:",ar)
    ) %>%
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_title(groups = c("title", "subtitle"))
    ) %>%
    tab_source_note(
      source_note = "Källa: Företagsregistret"
    ) %>%
    tab_options(
      table.border.top.color = "black",
      table.border.bottom.color = "black",
      table.font.size = 16
    )%>%
    data_color(
      columns = c(Andel, Antal, Totalt),
      fn = col_numeric(
        palette = c( "#F4DCE8","#B81867"),  
        domain = NULL                 
      )
    ) %>% tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    )
  
}

antal_foretag <- function(){
  # Läser in data
  df <- read.csv("Data/df_antal_firm_kultur.csv")
  
  ar <- unique(df$år)
  
  df <- df %>% select(-år)
  
  # skapar gt-tabell
  df %>% gt() %>%
    fmt_number(
      columns = Andel,
      decimals = 1
    ) %>%
    fmt_number(
      columns = c(Antal, Totalt),
      use_seps = TRUE,
      decimals = 0,  # visa endast heltal
    ) %>%
    cols_label(
      Säteskommun = "Säteskommun",
      Andel = "Andel (%)",
      Antal = "Antal kulturföretag",
      Totalt = "Totalt antal företag"
    ) %>%
    tab_header(
      title = paste("Andel och antal kulturföretag per kommun"),
      subtitle = paste("Hämtat:",ar)
    ) %>%
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_title(groups = c("title", "subtitle"))
    ) %>%
    tab_source_note(
      source_note = "Källa: Företagsregistret"
    ) %>%
    tab_options(
      table.border.top.color = "black",
      table.border.bottom.color = "black",
      table.font.size = 16
    )%>%
    data_color(
      columns = c(Andel, Antal, Totalt),
      fn = col_numeric(
        palette = c( "#F4DCE8","#B81867"),  
        domain = NULL                 
      )
    ) %>% tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    )
  
}

# Företagsregistret

antal_storlek_kom_t <- function(){
  # Läser in data
  df <- read.csv("Data/df_antal_arbets_kultur_storlek.csv")
  
  
  #  Unika storleksklasser för filter
  df <- df %>% mutate(Storleksklass=factor(Storleksklass ,levels=c("0 anställda" , "1-4 anställda" ,"5-9 anställda","10-19 anställda" , "20-49 anställda"  ,  "50-99 anställda", 
                                                                   "100-199 anställda" ,"200-499 anställda")))
  # Tar ut variabler till tabellen
  ar <- unique(df$År)
  
  df <- df %>% select(Kommun, Storleksklass, Antal)%>% arrange(Storleksklass)
  
  # Gör till wide och sorterar kolumnerna
  df <- df %>% pivot_wider(id_cols = Kommun, values_from = Antal,
                           names_from = Storleksklass) %>% arrange(Kommun)
  
  df%>%
    gt() %>%
    
    # Centrering (motsvarar align = "c")
    cols_align(
      align = "center",
      everything()
    ) %>%
    
    # Bold kolumnrubriker
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Tabellutseende (samma som tidigare)
    tab_options(table.width = pct(100),
                table.border.top.color = "black",
                table.border.bottom.color = "black",
                table.font.size = 16,
                table.align = "center",
                data_row.padding = px(6)
    ) %>%
    
    # Färgskala med FAST domain baserad på alla värden
    data_color(
      columns = where(is.numeric),
      rows = everything(),  # Alla rader
      palette = c("#F4DCE8", "#B81867"),
      apply_to = "fill"  # Bakgrundsfärg
    )%>%
    tab_header(
      title = paste("Antal anställningsplatser inom kultur per storleksklass och kommun"),
      subtitle = paste("Hämtat:",ar)
    )%>%
    
    # Källa (motsvarar footnote)
    tab_source_note(
      source_note = "Källa: SCB Företagsregistret"
    )
  
  
}

antal_storlek_kom_t_firm <- function(){
  # Läser in data
  df <- read.csv("Data/df_antal_firm_kultur_storlek.csv")
  
  
  #  Unika storleksklasser för filter
  df <- df %>% mutate(Storleksklass=factor(Storleksklass ,levels=c("0 anställda" , "1-4 anställda" ,"5-9 anställda","10-19 anställda" , "20-49 anställda"  ,  "50-99 anställda", 
                                                                   "100-199 anställda" ,"200-499 anställda")))
  # Tar ut variabler till tabellen
  ar <- unique(df$År)
  
  df <- df %>% select(Säteskommun, Storleksklass, Antal) %>% arrange(Storleksklass)
  
  # Gör till wide och sorterar kolumnerna
  df <- df %>% pivot_wider(id_cols = Säteskommun, values_from = Antal,
                           names_from = Storleksklass) %>% arrange(Säteskommun)
  
  df%>%
    gt() %>%
    
    # Centrering (motsvarar align = "c")
    cols_align(
      align = "center",
      everything()
    ) %>%
    
    # Bold kolumnrubriker
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Tabellutseende (samma som tidigare)
    tab_options(table.width = pct(100),
                table.border.top.color = "black",
                table.border.bottom.color = "black",
                table.font.size = 16,
                table.align = "center",
                data_row.padding = px(6)
    )%>%
    tab_header(
      title = paste("Antal företag inom kultur per storleksklass och kommun"),
      subtitle = paste("Hämtat:",ar)
    ) %>%
    
    # Färgskala med FAST domain baserad på alla värden
    data_color(
      columns = where(is.numeric),
      rows = everything(),  # Alla rader
      palette = c("#F4DCE8", "#B81867"),
      apply_to = "fill"  # Bakgrundsfärg
    )%>%
    
    # Källa (motsvarar footnote)
    tab_source_note(
      source_note = "Källa: SCB Företagsregistret"
    )
  
  
}


antal_bransch_kom_t <- function(){
  # Läser in data
  df <- read.csv("Data/df_kulturkategori_per_kom.csv")
  
  # Tar ut variabler till tabellen
  ar <- unique(df$År)
  
  df <- df %>% select(Kommun, Branschkategori, Antal)
  
  # Gör till wide och sorterar kolumnerna
  df <- df %>% pivot_wider(id_cols = Kommun, values_from = Antal,
                           names_from = Branschkategori) %>% arrange(Kommun)
  
  df%>%
    gt() %>%
    
    # Centrering (motsvarar align = "c")
    cols_align(
      align = "center",
      everything()
    ) %>%
    
    # Bold kolumnrubriker
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Tabellutseende (samma som tidigare)
    tab_options(table.width = pct(100),
                table.border.top.color = "black",
                table.border.bottom.color = "black",
                table.font.size = 14,
                column_labels.font.size = 14,
                table.align = "center",
                data_row.padding = px(6)
    )%>%
    tab_header(
      title = paste("Antal anställningsplatser per kulturbransch och kommun"),
      subtitle = paste("Hämtat:",ar)
    ) %>%
    
    # Färgskala med FAST domain baserad på alla värden
    data_color(
      columns = where(is.numeric),
      rows = everything(),  # Alla rader
      palette = c("#F4DCE8", "#B81867"),
      apply_to = "fill"  # Bakgrundsfärg
    )%>%
    
    # Källa (motsvarar footnote)
    tab_source_note(
      source_note = "Källa: SCB Företagsregistret"
    )
  
  
  
}

antal_bransch_kom_t_firm <- function(){
  # Läser in data
  df <- read.csv("Data/df_kulturkategori_firm_per_kom.csv")
  
  # Tar ut variabler till tabellen
  ar <- unique(df$År)
  
  df <- df %>% select(Säteskommun, Branschkategori, Antal)
  
  # Gör till wide och sorterar kolumnerna
  df <- df %>% pivot_wider(id_cols = Säteskommun, values_from = Antal,
                           names_from = Branschkategori) %>% arrange(Säteskommun)
  
  df%>%
    gt() %>%
    
    # Centrering (motsvarar align = "c")
    cols_align(
      align = "center",
      everything()
    ) %>%
    
    # Bold kolumnrubriker
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Tabellutseende (samma som tidigare)
    tab_options(table.width = pct(100),
                table.border.top.color = "black",
                table.border.bottom.color = "black",
                table.font.size = 14,
                column_labels.font.size = 14,
                table.align = "center",
                data_row.padding = px(6)
    )%>%
    tab_header(
      title = paste("Antal företag per kulturbransch och kommun"),
      subtitle = paste("Hämtat:",ar)
    ) %>%
    
    # Färgskala med FAST domain baserad på alla värden
    data_color(
      columns = where(is.numeric),
      rows = everything(),  # Alla rader
      palette = c("#F4DCE8", "#B81867"),
      apply_to = "fill"  # Bakgrundsfärg
    )%>%
    
    # Källa (motsvarar footnote)
    tab_source_note(
      source_note = "Källa: SCB Företagsregistret"
    )
  
  
  
}


# Kolada
konsfordelning_skola <- function(){
  # Hämtar data
  df <- read.csv("Data/df_skola_kon.csv") %>% mutate(value = round(value,2))
  
  # Rensar titlar
  df$title <- gsub(", andel \\(%\\)", "", df$title )
  
  # Årsintervall
  
  year_m <- max(df$year)
  
  intervall <- (year_m -8):year_m 
  
  # Filtrera data
  df_filtered <- df %>% filter(year %in% intervall)
  
  
  # Beräkna min och max värden INNAN pivot (för hela datasetet)
  value_range <- range(df_filtered$value, na.rm = TRUE)
  
  # Gör til wide
  df_wide <- df_filtered %>%  pivot_wider(id_cols = c(municipality),
                                          names_from=year,
                                          values_from = value)
  # fixar namn
  colnames(df_wide)[1] <- "Kommun"
  
  df_wide <- df_wide %>% arrange(Kommun)
  
  
  # printar tabell
  df_wide %>%
    gt() %>%
    
    # Centrering (motsvarar align = "c")
    cols_align(
      align = "center",
      everything()
    ) %>%
    
    # Bold kolumnrubriker
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Tabellutseende (samma som tidigare)
    tab_options(table.width = pct(100),
                table.border.top.color = "black",
                table.border.bottom.color = "black",
                table.font.size = 16,
                table.align = "center",
                data_row.padding = px(6)
    ) %>%
    
    # Färgskala med FAST domain baserad på alla värden
    data_color(
      columns = where(is.numeric),
      fn = col_numeric(
        palette = c("#F4DCE8", "#B81867"),
        domain = value_range  # Använd det fasta intervallet!
      )
    )  %>%
    
    # Källa (motsvarar footnote)
    tab_source_note(
      source_note = "Källa: Kulturrådet"
    )
  
}



######### kulturanalys biodata ############


biografer <- function(){
  # hämtar data 
  df <- read.csv("Data/df_kommun_bio.csv")
  
  value_range <- df$biografer
  
  # Gör till wide och sorterar kolumnerna
  df <- df %>% pivot_wider(id_cols = kommun, values_from = biografer,
                           names_from = år) %>% arrange(kommun)
  
  colnames(df)[1] <- "Kommun"
  
  df%>%
    gt() %>%
    
    # Centrering (motsvarar align = "c")
    cols_align(
      align = "center",
      everything()
    ) %>%
    
    # Bold kolumnrubriker
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Tabellutseende (samma som tidigare)
    tab_options(table.width = pct(100),
                table.border.top.color = "black",
                table.border.bottom.color = "black",
                table.font.size = 16,
                table.align = "center",
                data_row.padding = px(6)
    ) %>%
    
    # Färgskala med FAST domain baserad på alla värden
    data_color(
      columns = where(is.numeric),
      fn = col_numeric(
        palette = c("#F4DCE8", "#B81867"),
        domain = value_range  # Använd det fasta intervallet!
      )
    ) %>%
    
    # Källa (motsvarar footnote)
    tab_source_note(
      source_note = "Källa: Kulturanalys"
    )
  
  
}


biosalong_trend_region <- function(){
  # hämtar data 
  df <- read.csv("Data/df_region_bio.csv") %>% filter(region %in% c('Riket',
                                                                    "Uppsala län")) %>% 
    arrange(year)
  
  value_range <- df$besök.per.invånare
  
  # Gör till wide och sorterar kolumnerna
  df2 <- df %>% pivot_wider(id_cols = region, values_from = besök.per.invånare,
                            names_from = year) %>% arrange(region)
  
  colnames(df2)[1] <- "Region"
  
  t1 <- df2 %>%
    gt() %>%
    
    # Centrering (motsvarar align = "c")
    cols_align(
      align = "center",
      everything()
    ) %>%
    
    # Bold kolumnrubriker
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Tabellutseende (samma som tidigare)
    tab_options(table.width = pct(100),
                table.border.top.color = "black",
                table.border.bottom.color = "black",
                table.font.size = 16,
                table.align = "center",
                data_row.padding = px(6)
    ) %>%
    
    # Färgskala med FAST domain baserad på alla värden
    data_color(
      columns = where(is.numeric),
      fn = col_numeric(
        palette = c("#F4DCE8", "#B81867"),
        domain = value_range  # Använd det fasta intervallet!
      )
    )  %>%
    
    # Källa (motsvarar footnote)
    tab_source_note(
      source_note = "Källa: Kulturanalys"
    )
  
  value_range <- df$visningar.per.tusen.invånare
  
  # Gör till wide och sorterar kolumnerna
  df1 <- df %>% pivot_wider(id_cols = region, values_from = visningar.per.tusen.invånare,
                            names_from = year) %>% arrange(region)
  
  colnames(df1)[1] <- "Region"
  
  t2 <- df1 %>%
    gt() %>%
    
    # Centrering (motsvarar align = "c")
    cols_align(
      align = "center",
      everything()
    ) %>%
    
    # Bold kolumnrubriker
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Tabellutseende (samma som tidigare)
    tab_options(table.width = pct(100),
                table.border.top.color = "black",
                table.border.bottom.color = "black",
                table.font.size = 16,
                table.align = "center",
                data_row.padding = px(6)
    ) %>%
    
    # Färgskala med FAST domain baserad på alla värden
    data_color(
      columns = where(is.numeric),
      fn = col_numeric(
        palette = c("#F4DCE8", "#B81867"),
        domain = value_range  # Använd det fasta intervallet!
      )
    )  %>%
    
    # Källa (motsvarar footnote)
    tab_source_note(
      source_note = "Källa: Kulturanalys"
    )
  
  
  return(list(t1,t2))
  
}


# scenföreställningar
forestallning_konsert_tbl <- function(){
  # Hämtar kolnamn 
  df <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "3 - Tidsserier", skip = 5)
  namn <-colnames(df)
  
  # tar ut museer och konsthallar
  index <- which(df$...1=='4.3 Tidsserier scenkonst – föreställningar/konserter och publik')
  
  # Hämtar data
  KDB_Uppsala <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "3 - Tidsserier", skip = index+5)
  colnames(KDB_Uppsala)[-1] <- namn[-1]
  
  KDB_Uppsala[KDB_Uppsala == "#"] <- NA
  
  # Fixar till strukturen på data
  df_clean <- KDB_Uppsala %>%
    rename(kategori = 1) %>%
    mutate(år = if_else(str_detect(kategori, "^\\d{4}$"), kategori, NA_character_)) %>%
    fill(år, .direction = "down") %>%
    filter(!str_detect(kategori, "^\\d{4}$")) %>%
    remove_empty("cols") %>%  # Tar bort tomma kolumner
    relocate(år, .before = kategori) %>% mutate(år = as.integer(år),
                                                `Totalt i länet` = as.numeric(Uppsala),
                                                `Region UppsalaKulturutvecklingTotalt interna övriga`=as.numeric(`Region UppsalaKulturutvecklingTotalt interna övriga`)) %>% 
    select(-Uppsala)%>% rename("Övriga interna"=`Region UppsalaKulturutvecklingTotalt interna övriga`)
  
  
  
  # gör till long
  df_clean <- df_clean %>% pivot_longer(names_to = "Plats",
                                        cols = c(where(is.numeric),-år))
  # Sorterar grupperna
  df2 <- df_clean %>%
    mutate(
      typ = case_when(
        str_detect(kategori, "Publik") ~ "Publik",
        str_detect(kategori, "Föreställningar") ~ "Föreställningar"
      ),
      grupp = case_when(
        str_detect(kategori, "Egen") ~ "Egen och samproduktion",
        str_detect(kategori, "Mottagna") ~ "Gästspel"
      )
    )
  
  # tar bort na och snyggar till tabellen
  df2 <- df2  %>% filter(!is.na(value), !is.na(typ), år == max(år))
  df2 <- df2 %>%
    pivot_wider(
      id_cols = c(år, grupp, Plats),
      names_from = typ,
      values_from = value
    )
  
  # fixar kolumnnamn
  colnames(df2) <- str_to_sentence(colnames(df2))
  
  
  
  # Identifiera numeriska kolumner
  num_cols <- df2 %>%
    select(where(is.numeric)) %>%
    names()
  
  # Global min/max (FAST domain som i gt)
  global_range <- range(unlist(df2[, num_cols]), na.rm = TRUE)
  
  # Skapa färgfunktion
  col_pal <- col_numeric(
    palette = c("#F4DCE8", "#B81867"),
    domain = global_range
  )
  
  
  df2  %>% gt() %>%
    
    # Centrering (motsvarar align = "c")
    cols_align(
      align = "center",
      everything()
    ) %>%
    
    # Bold kolumnrubriker
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Tabellutseende (samma som tidigare)
    tab_options(table.width = pct(100),
                table.border.top.color = "black",
                table.border.bottom.color = "black",
                table.font.size = 16,
                table.align = "center",
                data_row.padding = px(6)
    ) %>%
    
    # Färgskala med FAST domain baserad på alla värden
    data_color(
      columns = where(is.numeric),
      fn = col_pal
    )  %>%
    
    # Källa (motsvarar footnote)
    tab_source_note(
      source_note = "Källa: Kulturrådet"
    )
  
  
  
}
