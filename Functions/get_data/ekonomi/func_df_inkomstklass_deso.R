func_df_inkomstklass <- function(){
  ## Deso Andel av befolkningen i inkomstklass efter region, inkomstslag, kön, tabellinnehåll och år
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__HE__HE0110__HE0110I/Tab1InkDesoRegso/
  {
    url <- pxweb_url("TAB6679")
    meta  <- pxweb_get(url)
    
    regioner <- meta$variables[[1]]$values
    
    # Välj endast regioner som börjar med "03"
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
                        InkomstTyp = '*',
                        Kon = '*',
                        ContentsCode = c("0000089P" ,"0000089Q" ,"0000089R", "0000089S"),
                        Tid = as.character(senaste_aret))
    
    px_get <- pxweb_get(url,px_get_list)
    
    # laddar data och gör till rätt format
    df_inkomstklass <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    df_inkomstklass <- na.omit(df_inkomstklass)

    df_inkomstklass <- df_inkomstklass |> 
      tidyr::pivot_wider(
        names_from = "tabellinnehåll",
        values_from = "value"
      )

    df_inkomstklass <- df_inkomstklass %>%
      mutate(across(where(is.numeric), ~replace_na(.x, 0)))
    df_inkomstklass <- df_inkomstklass %>% rename(desokod=region)
    
    df_inkomstklass <- left_join(deso_sf, df_inkomstklass, by = "desokod")
    
    st_write(df_inkomstklass, "Data/df_inkomstklass.gpkg",  delete_dsn = TRUE)  
    
    
    print('Nedladdning av "df_inkomstklass.gpkg" genomfördes')  
    
  }
}
