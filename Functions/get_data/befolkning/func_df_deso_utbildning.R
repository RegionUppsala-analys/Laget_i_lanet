
## Deso utbildning


func_df_deso_utbildning <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__UF__UF0506__UF0506D/UtbSUNBefDesoRegsoN/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/UF/UF0506/UF0506D/UtbSUNBefDesoRegsoN'
  
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6534')
  
  meta  <- pxweb_get(url)
  # Visa tillgängliga regionkoder
  regioner <- meta$variables[[1]]$values
  
  # Välj endast regioner som börjar med "03"
  uppsala_koder <- regioner[startsWith(regioner, lanskod)]
  senaste_aret <- max(as.integer(meta$variables[[4]]$values))
  
  px_get_list <- list(Region = uppsala_koder,
                      UtbildningsNiva = '*',
                      ContentsCode = '*',
                      Tid = as.character(senaste_aret))
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_utbildning <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  # sparar data med variabler:
  
  suppressMessages({
    suppressWarnings({
      st_layers("Data/DeSO_2025.gpkg")
      deso_sf <- st_read("Data/DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE) %>%
        filter(lanskod == !!lanskod) # we keep only Uppsala län
    })
  })
  # Finns dubbletter med NA 
  df_utbildning <- df_utbildning %>% rename(desokod=region)
  
  df_deso_utbildning <- left_join(deso_sf, df_utbildning, by = "desokod")
  
  st_write(df_deso_utbildning, "Data/df_deso_utbildning.gpkg",  delete_dsn = TRUE)
  
  
  print('Nedladdning av "df_deso_utbildning.gpkg" genomfördes')
}
