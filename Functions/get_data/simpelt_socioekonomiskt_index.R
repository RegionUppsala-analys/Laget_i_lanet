####### socioekonimiskt index #########
# Antal arbetslösa DESO och låg ekonomisk standard 
# Låg ekonomisk standard DeSo
# utbildningsnivå per deso
simpelt_soe_index <- function(){
  {
    # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AM__AM0210__AM0210G/ArRegDesoStatusN/ 
    url <- pxweb_url("TAB6680")
    meta  <- pxweb_get(url)
    # Visa tillgängliga regionkoder
    regioner <- meta$variables[[1]]$values
    
    senaste_aret <- max(as.integer(meta$variables[[5]]$values))
    
    # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__HE__HE0110__HE0110I/Tab4InkDesoRegso/
    url2 <- pxweb_url("TAB6685")
    meta2  <- pxweb_get(url2)
    
    senaste_aret2 <- max(as.integer(meta2$variables[[4]]$values))
    
    # Befolkning 25-64 år efter region, utbildningsnivå och år
    # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__UF__UF0506__UF0506D/UtbSUNBefDesoRegsoN/
    url3 <- pxweb_url("TAB6534")
    meta3  <- pxweb_get(url3)
    
    senaste_aret3 <- max(as.integer(meta3$variables[[4]]$values))
    
    senaste_aret <- min(senaste_aret,senaste_aret2,senaste_aret3) # kollar senaste matchande året mellan tabellerna
    
    if (senaste_aret > 2023){
      suppressMessages({
        suppressWarnings({
          st_layers("Data/DeSO_2025.gpkg")
          deso_sf <- st_read("Data/DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE)  # we keep only Uppsala län
        })
      })
    }else{
      suppressMessages({
        suppressWarnings({
          st_layers("Data/DeSO_2018.gpkg")
          deso_sf <- st_read("Data/DeSO_2018.gpkg", layer = "DeSO_2018", quiet = TRUE) # we keep only Uppsala län
        })
      })
    }  
    
    regioner <- paste0(deso_sf$desokod,'_DeSO2025')
    
    
    px_get_list <- list(Region = regioner,
                        Alder = '20-65',
                        Kon = '*',
                        ContentsCode = c("0000089W","0000089Y"),
                        Tid = as.character(senaste_aret))
    
    px_get <- pxweb_get(url,px_get_list)

    # laddar data och gör till rätt format
    df_arbetsloshet <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    df_arbetsloshet <- na.omit(df_arbetsloshet)

    df_arbetsloshet <- df_arbetsloshet |> 
      tidyr::pivot_wider(
        names_from = "tabellinnehåll",
        values_from = "value"
      )

    df_arbetsloshet <- df_arbetsloshet %>% rename(desokod=region)
    
    df_deso_arbetslos <- left_join(deso_sf, df_arbetsloshet, by = "desokod")
    
    st_write(df_deso_arbetslos, "Data/df_deso_arbetslos.gpkg",  delete_dsn = TRUE)  
    
    px_get_list <- list(Region = regioner,
                        Alder = 'tot',
                        ContentsCode = '000008AC',
                        Tid = as.character(senaste_aret))
    
    px_get <- pxweb_get(url2,px_get_list)

    # laddar data och gör till rätt format
    df_lag_standard <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    df_lag_standard <- na.omit(df_lag_standard)

    df_lag_standard <- df_lag_standard |> 
      tidyr::pivot_wider(
        names_from = "tabellinnehåll",
        values_from = "value"
      )

    df_lag_standard <- df_lag_standard %>% rename(desokod=region)
    
    df_deso_lag_standard <- left_join(deso_sf, df_lag_standard, by = "desokod")
    
    st_write(df_deso_lag_standard, "Data/df_deso_lag_standard.gpkg",  delete_dsn = TRUE)  
    
    ## Utbildningsnivåer
    
    
    px_get_list <- list(Region = regioner,
                        UtbildningsNiva = '*',
                        ContentsCode = '*',
                        Tid = as.character(senaste_aret))
    
    px_get <- pxweb_get(url3,px_get_list)

    # laddar data och gör till rätt format
    df_utbildning <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    df_utbildning <- na.omit(df_utbildning)

    df_utbildning <- df_utbildning |> 
      tidyr::pivot_wider(
        names_from = "tabellinnehåll",
        values_from = "value"
      )

    df_utbildning <- df_utbildning %>% rename(desokod=region)
    
    df_deso_utbildning <- left_join(deso_sf, df_utbildning, by = "desokod")
    
    st_write(df_deso_utbildning, "Data/df_deso_utbildning23.gpkg",  delete_dsn = TRUE)
    
    print('Nedladdning av "df_deso_utbildning23.gpkg" genomfördes')
  }
  # skapa index 
  {# Load datasets
    suppressMessages({
      suppressWarnings({
        st_layers("Data/df_deso_utbildning23.gpkg")
        deso_sf_utbild <- st_read("Data/df_deso_utbildning23.gpkg", quiet = TRUE)
        st_layers("Data/df_deso_arbetslos.gpkg")
        deso_sf_arbets <- st_read("Data/df_deso_arbetslos.gpkg", quiet = TRUE)
        st_layers("Data/df_deso_lag_standard.gpkg")
        deso_sf_lag_standard <- st_read("Data/df_deso_lag_standard.gpkg", quiet = TRUE) 
      })
    })
    
    #  Räkna andelar per DeSO 
    andelar_deso_utb <- deso_sf_utbild %>%
      group_by(desokod) %>%
      mutate(
        Total = sum(Befolkning, na.rm = TRUE),
        Andel = round(100 * Befolkning / Total, 1)
      ) %>%
      ungroup()
    
    andelar_deso_utb_for <- andelar_deso_utb %>% filter(utbildningsnivå == 'förgymnasial utbildning') 
    
    
    deso_sf_arbets <- deso_sf_arbets %>% filter(kön == 'totalt') %>% 
      mutate(Andel_arbetslösa = (antal.arbetslösa/antal.totalt)*100)
    
    
    # Utbildning: keep desokod, Andel, geom
    andelar_deso_utb_clean <- andelar_deso_utb_for %>%
      select(desokod, utbildningsnivå, år, Befolkning, Total, Andel, geom)
    
    # Arbetslöshet: drop geometry and keep needed columns
    deso_sf_arbets_clean <- deso_sf_arbets %>%
      select(desokod, Andel_arbetslösa)%>%
      st_drop_geometry()
    
    # Låg standard: drop geometry and keep needed columns
    deso_sf_lag_standard_clean <- deso_sf_lag_standard %>%
      select(desokod, Låg.ekonomisk.standard..procent) %>%
      st_drop_geometry()
    
    # --- Join datasets ---
    deso_joined <- andelar_deso_utb_clean %>%
      left_join(deso_sf_arbets_clean, by = "desokod") %>%
      left_join(deso_sf_lag_standard_clean, by = "desokod")%>%
      filter(!is.na(Låg.ekonomisk.standard..procent))
    
    # creating the index
    deso_joined <- deso_joined %>% mutate(Socioekonomiskt_index = (Andel+ Andel_arbetslösa + Låg.ekonomisk.standard..procent)/3)
    deso_joined <- deso_joined %>%
      mutate(
        Socioekonomiskt_index_std = (
          scale(Andel)[,1] +
            scale(Andel_arbetslösa)[,1] +
            scale(Låg.ekonomisk.standard..procent)[,1]
        ) / 3
      )
    
    
    medel <- mean(as.numeric(deso_joined$Socioekonomiskt_index),na.rm = TRUE) 
    std_av <- sd(as.numeric(deso_joined$Socioekonomiskt_index),na.rm = TRUE) 
    
    #standardizerade värden
    medel_sd <- mean(as.numeric(deso_joined$Socioekonomiskt_index_std),na.rm = TRUE) 
    std_av_sd <- sd(as.numeric(deso_joined$Socioekonomiskt_index_std),na.rm = TRUE) 
    
    # Function to classify area type
    get_area_type <- function(index_value, mean, std) {
      if (is.na(index_value)) {
        return(NA_integer_)
      } else if (index_value >= mean + 2*std) {
        return(1) # Områden med stora socioekonomiska utmaningar
      } else if (index_value >= mean + std) {
        return(2) # Områden med socioekonomiska utmaningar
      } else if (index_value >= mean) {
        return(3) # Socioekonomiskt blandade områden
      } else if (index_value >= mean - std) {
        return(4) # Områden med goda socioekonomiska förutsättningar
      } else {
        return(5) # Områden med mycket goda socioekonomiska förutsättningar
      }
    }
    # plockar ut uppsala
    uppsala_koder <- deso_joined %>%
      filter(startsWith(desokod, !!lanskod)) %>%
      pull(desokod)
    
    deso_joined <- deso_joined %>% filter(desokod %in% uppsala_koder) 
    # Apply classification and add description
    deso_joined <- deso_joined %>%
      mutate(
        area_type = sapply(Socioekonomiskt_index, get_area_type, mean = medel, std = std_av),
        area_type_description = case_when(
          area_type == 1 ~ "Områden med stora socioekonomiska utmaningar",
          area_type == 2 ~ "Områden med socioekonomiska utmaningar",
          area_type == 3 ~ "Socioekonomiskt blandade områden",
          area_type == 4 ~ "Områden med goda socioekonomiska förutsättningar",
          area_type == 5 ~ "Områden med mycket goda socioekonomiska förutsättningar",
          TRUE ~ NA_character_
        )
      )
    
    deso_joined <- deso_joined %>%
      mutate(
        area_type_sd = sapply(Socioekonomiskt_index_std, get_area_type, mean = medel_sd, std = std_av_sd),
        area_type_description_sd = case_when(
          area_type == 1 ~ "Områden med stora socioekonomiska utmaningar",
          area_type == 2 ~ "Områden med socioekonomiska utmaningar",
          area_type == 3 ~ "Socioekonomiskt blandade områden",
          area_type == 4 ~ "Områden med goda socioekonomiska förutsättningar",
          area_type == 5 ~ "Områden med mycket goda socioekonomiska förutsättningar",
          TRUE ~ NA_character_
        )
      )
    st_write(deso_joined, "Data/df_desocioindex.gpkg",  delete_dsn = TRUE)  
    
    print('Beräkning av socioindex gjort och "df_desocioindex.gpkg" genomfördes')
  }
  
  
  # Andel utrikesfödda samma år som index
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101Y/FolkmDesoLandKon/
  url <- pxweb_url("TAB6572")
  
  uppsala_koder <- paste0(uppsala_koder,"_DeSO2025")
  px_get_list <- list(Region = uppsala_koder,
                      Kon = c('1','2'),
                      Fodelseregion = '*',
                      ContentsCode = '*',
                      Tid = as.character(senaste_aret))
  
  
  px_get <- pxweb_get(url,px_get_list)

  # laddar data och gör till rätt format
  df_deso_fodelse <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_deso_fodelse <- na.omit(df_deso_fodelse)

  df_deso_fodelse <- df_deso_fodelse |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  # Finns dubbletter med NA 
  df_deso_fodelse <- df_deso_fodelse[complete.cases(df_deso_fodelse$Antal),] %>% rename(desokod=region)

  df_deso_fodelse <- left_join(deso_sf, df_deso_fodelse, by = "desokod")

  st_write(df_deso_fodelse, "Data/df_deso_fodelse_index.gpkg",  delete_dsn = TRUE)
  
  print('Nedladdning av "df_deso_fodelse_index.gpkg" genomfördes')
  
}