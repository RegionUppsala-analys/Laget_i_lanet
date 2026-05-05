## Inkomststruktur nettoinkomst efter region och kön. År 2011 - 2024
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__HE__HE0110__HE0110I/Tab2InkDesoRegso/

func_df_inkomststruktur - function{
  
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/HE/HE0110/HE0110I/Tab2InkDesoRegso'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6683')
  
  meta <- pxweb_get(url)
  regioner <- meta$variables[[1]]$values
  
  # Välj endast regioner som börjar med "03"
  uppsala_koder <- regioner[startsWith(regioner, lanskod)]  
  senaste_aret <- max(as.integer(meta$variables[[5]]$values))
  
  if (senaste_aret > 2023){
    suppressMessages({
      suppressWarnings({
        st_layers("Data/DeSO_2025.gpkg")
        deso_sf <- st_read("Data/DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE) %>%
          filter(lanskod == !!lanskod) # we keep only Uppsala län
      })
    })
  }else{
    suppressMessages({
      suppressWarnings({
        st_layers("Data/DeSO_2018.gpkg")
        deso_sf <- st_read("Data/DeSO_2018.gpkg", layer = "DeSO_2018", quiet = TRUE) %>%
          filter(lanskod == !!lanskod) # we keep only Uppsala län
      })
    })
  }  
  
  uppsala_koder <- paste0(deso_sf$desokod,'_DeSO2025') # deso 2025
  
  px_get_list <- list(Region = uppsala_koder,
                      Inkomstkomponenter = '*',
                      Kon = '*',
                      ContentsCode = '*',
                      Tid = as.character(senaste_aret))
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_inkomststruktur <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  # sparar data med variabler:
  
  df_inkomststruktur <- df_inkomststruktur %>%
    mutate(across(where(is.numeric), ~replace_na(.x, 0)))
  df_inkomststruktur <- df_inkomststruktur %>% rename(desokod=region)
  
  df_inkomststruktur <- deso_sf %>% left_join(df_inkomststruktur, by = "desokod")
  
  st_write(df_inkomststruktur, "Data/df_inkomststruktur.gpkg",  delete_dsn = TRUE)  
  
  
  
  print('Nedladdning av "df_inkomststruktur.gpkg" genomfördes')  
  
}
