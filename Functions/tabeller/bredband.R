
mobilt_agg_tbl <- function(){
  # läser in exceldata
  df <- read_excel("Data/mobiltackning.xlsx", skip = 2,sheet =3,
                   col_names = FALSE)
  
  # Fixar till columnnamn
  header_main <- df[1, ]
  header_year <- df[2, ]
  
  # Konvertera till character
  header_main <- as.character(unlist(header_main))
  header_year <- as.character(unlist(header_year))
  
  # Fyll NA med föregående värde
  for(i in 2:length(header_main)) {
    if(is.na(header_main[i])) header_main[i] <- header_main[i-1]
  }
  
  # Kombinera rubrik + år
  col_names <- paste(
    as.character(unlist(header_main)),
    header_year,
    sep = "_"
  )
  
  # Städning av namn
  col_names <- paste(header_main, header_year, sep = "_") |>
    str_replace_all("[\r\n]", " ") |>
    str_replace_all(",", "") |>
    str_replace_all("/", "_") |>
    str_replace_all(" ", "_") |>
    str_replace_all("__+", "_") |>
    str_to_lower()
  
  # Lägg in på dataframe
  df <- df[-c(1,2), ]
  
  colnames(df) <- col_names
  
  colnames(df)[1:2] <- c("kommun_lan_riket", "kod")
  
  # Tar ut kommuner och länet
  df <- df %>% filter(kod %in% c(lanskod, kommunkod))                       
  
  
  #  dataframe i long format
  df_long <- df %>%
    pivot_longer(
      cols = -c(kommun_lan_riket, kod),
      names_to = c("coverage", "year"),
      names_pattern = "(.*)_(\\d{4})",
      values_to = "value"
    ) %>%
    mutate(year = as.integer(year),
           # rensar value
           value = value %>%
             str_replace_all("-", "") %>% 
             str_replace_all(">", "") %>%        # remove >
             str_replace_all(",", ".") %>%       # comma to dot
             str_replace_all("%", "") %>%        # remove % sign
             as.numeric()) %>% 
    # Fixar till värden till 2 decimaler, mellan 0-100 
    mutate(
      value = as.numeric(value),                    
      value = ifelse(value <=1,value * 100, value),                         
      value = round(value, 2)                  
    ) %>%
    mutate(
      coverage = coverage %>%
        str_replace_all("_", " ") %>%
        str_to_sentence()) %>% filter(!is.na(value)) %>% 
    mutate(                  
      value = paste0(value, "%") ) # lägger till %
  
  # wide för att få åren i separata kolumner
  mobilt_wide <- df_long %>%
    pivot_wider(names_from = year, values_from = value)
  
  # fixar till datat
  mobilt_wide <- mobilt_wide %>%
    arrange(coverage != "Totalt alla områden där man normalt befinner sig")
  
  # sparar för att skicka till quarto och skapa tabellen där
  
  saveRDS(mobilt_wide, "Data/mobilt_wide.rds")
  
  
}


mobilt_tbl <- function(){
  # Namn på öperatörer i ordning efter sheets i exl
  operators <- c("Telenor", "Tele2","Telia", "Tre")
  
  # Spara resultat
  result_list <- list()
  
  # läser in exceldata
  for(j in 4:7){
    # Tar ut rätt namn och sheet
    operatornamn <- operators[j-3]
    df <- read_excel("Data/mobiltackning.xlsx", skip = 2,sheet =j,
                     col_names = FALSE)
    
    
    
    # Fixar till columnnamn
    header_main <- df[1, ]
    header_year <- df[2, ]
    
    # Konvertera till character
    header_main <- as.character(unlist(header_main))
    header_year <- as.character(unlist(header_year))
    
    # Fyll NA med föregående värde
    for(i in 2:length(header_main)) {
      if(is.na(header_main[i])) header_main[i] <- header_main[i-1]
    }
    
    # Kombinera rubrik + år
    col_names <- paste(
      as.character(unlist(header_main)),
      header_year,
      sep = "_"
    )
    
    # Städning av namn
    col_names <- paste(header_main, header_year, sep = "_") |>
      str_replace_all("[\r\n]", " ") |>
      str_replace_all(",", "") |>
      str_replace_all("/", "_") |>
      str_replace_all(" ", "_") |>
      str_replace_all("__+", "_") |>
      str_to_lower()
    
    # Lägg in på dataframe
    df <- df[-c(1,2), ]
    
    colnames(df) <- col_names
    
    colnames(df)[1:2] <- c("kommun_lan_riket", "kod")
    
    # Tar ut kommuner och länet
    df <- df %>% filter(kod %in% c(lanskod, kommunkod))    
    
    # allt till samma format
    df <- df %>%
      mutate(across(-c(kommun_lan_riket, kod), as.character))
    
    #  dataframe i long format
    df_long <- df %>%
      pivot_longer(
        cols = -c(kommun_lan_riket, kod),
        names_to = c("coverage", "year"),
        names_pattern = "(.*)_(\\d{4})",
        values_to = "value"
      ) %>%
      mutate(year = as.integer(year),
             # rensar value
             value = value %>%
               str_replace_all("-", "") %>% 
               str_replace_all(">", "") %>%        # remove >
               str_replace_all(",", ".") %>%       # comma to dot
               str_replace_all("%", "") %>%        # remove % sign
               as.numeric()) %>% 
      # Fixar till värden till 2 decimaler, mellan 0-100 
      mutate(
        value = as.numeric(value),                    
        value = ifelse(value <=1,value * 100, value),                         
        value = round(value, 2)                  
      ) %>%
      mutate(
        coverage = coverage %>%
          str_replace_all("_", " ") %>%
          str_to_sentence()) %>% filter(!is.na(value)) %>% 
      mutate(                  
        value = paste0(value, "%") ) # lägger till %
    
    # wide för att få åren i separata kolumner
    mobilt_wide <- df_long %>%
      pivot_wider(names_from = year, values_from = value)
    
    # fixar till datat
    mobilt_wide <- mobilt_wide %>%
      arrange(coverage != "Totalt alla områden där man normalt befinner sig")
    
    year_cols <- grep("^20\\d{2}$", names(mobilt_wide), value = TRUE)
    latest_year <- max(as.integer(year_cols))                     # senaste årtalet
    latest_year_col <- as.character(latest_year)                  # tillbaka till text
    
    df_clean <- mobilt_wide %>%
      select(kommun_lan_riket, kod, coverage, all_of(latest_year_col)) %>%
      rename(!!operatornamn := all_of(latest_year_col))
    
    # Sparar i lista
    result_list[[operatornamn]] <- df_clean
  }
  
  slutdata <- reduce(result_list, full_join,
                     by = c("kommun_lan_riket", "kod", "coverage"))
  
  slutdata$År <- rep(latest_year, nrow(slutdata))
  
  # sparar för att skicka till quarto och skapa tabellen där
  saveRDS(slutdata, "Data/mobilt_wide_op.rds")
  
  
}
