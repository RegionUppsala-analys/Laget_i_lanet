
##### HÄR KAN DET BEHÖVA ÄNDRAS LITE I QUERY_LIST till V2
# Antal hushåll efter region, hushållstyp och år

func_alder_hushall_fodelse25 <- function(){ # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101Y/HushallDesoTyp/
  
  # läser in DeSo 2025  
  suppressMessages({
    suppressWarnings({
      st_layers("Data/DeSO_2025.gpkg")
      deso_sf <- st_read("Data/DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE) %>%
        filter(lanskod == !!lanskod) # we keep only Uppsala län
    })
  })
  
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101Y/HushallDesoTyp'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6568')
  
  # Hämta metadata för Region
  meta <- pxweb_get(url)
  
  # Visa tillgängliga regionkoder
  regioner <- meta$variables[[1]]$values
  
  # Välj endast regioner som börjar med "03"
  uppsala_koder <- regioner[startsWith(regioner, lanskod)]
  senaste_aret <-  max(as.integer(meta$variables[[4]]$values))
  
  px_get_list <- list(Region = uppsala_koder,
                      Hushallstyp = '*',
                      ContentsCode = '*',
                      Tid = as.character(senaste_aret))
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_deso_hushallstyp <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Finns dubbletter med NA 
  df_deso_hushallstyp <- df_deso_hushallstyp[complete.cases(df_deso_hushallstyp$`Antal hushåll`),] %>% rename(desokod=region)
  
  df_deso_hushall <- left_join(deso_sf, df_deso_hushallstyp, by = "desokod")
  
  
  st_write(df_deso_hushall, "Data/df_deso_hushall.gpkg",  delete_dsn = TRUE)
  
  print('Nedladdning av "df_deso_hushall.gpkg" genomfördes')
  
  
  # Folkmängden per region efter ålder och kön. År 2010 - 2025
  {# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101Y/FolkmDesoAldKon/
    url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101Y/FolkmDesoAldKon'
    
    # pxweb v2
    #  url <- print_pxwebv2('TAB6574')
    
    px_get_list <- list(Region = uppsala_koder,
                        Kon = c('1','2'),
                        Alder = '*',
                        ContentsCode = '*',
                        Tid = as.character(senaste_aret))
    
    
    px_get <- pxweb_get(url,px_get_list)
    
    # laddar data och gör till rätt format
    df_deso_alder <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    # Finns dubbletter med NA 
    df_deso_alder <- df_deso_alder[complete.cases(df_deso_alder$Antal),] %>% rename(desokod=region)
    
    df_deso_alder <- left_join(deso_sf, df_deso_alder, by = "desokod")
    
    st_write(df_deso_alder, "Data/df_deso_alder.gpkg",  delete_dsn = TRUE)
    
  }
  
  # Folkmängden per region efter födelseregion och kön. År 2010 - 2025
  {
    # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101Y/FolkmDesoLandKon/
    url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101Y/FolkmDesoLandKon'
    
    # pxweb v2
    #  url <- print_pxwebv2('TAB6572')
    
    px_get_list <- list(Region = uppsala_koder,
                        Kon = c('1','2'),
                        Fodelseregion = '*',
                        ContentsCode = '*',
                        Tid = as.character(senaste_aret))
    
    
    px_get <- pxweb_get(url,px_get_list)
    
    # laddar data och gör till rätt format
    df_deso_fodelse <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    # Finns dubbletter med NA 
    df_deso_fodelse <- df_deso_fodelse[complete.cases(df_deso_fodelse$Antal),] %>% rename(desokod=region)
    
    df_deso_fodelse <- left_join(deso_sf, df_deso_fodelse, by = "desokod")
    
    st_write(df_deso_fodelse, "Data/df_deso_fodelse.gpkg",  delete_dsn = TRUE)
    
    print('Nedladdning av "df_deso_fodelse.gpkg" genomfördes')
  }}




#####  HÄR KAN DET BEHÖVA ÄNDRAS LITE I QUERY_LIST till V2
######## 2018

func_alder_hushall_fodelse18 <- function(){
  # läser in DeSo 2018  
  suppressMessages({
    suppressWarnings({
      st_layers("Data/DeSO_2018.gpkg")
      deso_sf <- st_read("Data/DeSO_2018.gpkg", layer = "DeSO_2018", quiet = TRUE) %>%
        filter(lanskod == !!lanskod) # we keep only Uppsala län
    })
  })
  
  
  
  # Antal hushåll efter region, hushållstyp och år
  
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101Y/HushallDesoTyp'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6568')
  
  # Hämta metadata för Region
  meta <- pxweb_get(url)
  
  # Visa tillgängliga regionkoder
  regioner <- meta$variables[[1]]$values
  
  # Välj endast regioner som börjar med "03"
  uppsala_koder <- regioner[startsWith(regioner, lanskod)]
  senaste_aret <- regioner <- max(as.integer(meta$variables[[4]]$values))
  
  px_get_list <- list(Region = uppsala_koder,
                      Hushallstyp = '*',
                      ContentsCode = '*',
                      Tid = as.character(c(senaste_aret-5,senaste_aret-10 )))
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_deso_hushallstyp <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Finns dubbletter med NA 
  df_deso_hushallstyp <- df_deso_hushallstyp[complete.cases(df_deso_hushallstyp$`Antal hushåll`),] %>% rename(desokod=region)
  
  df_deso_hushall <- left_join(deso_sf, df_deso_hushallstyp, by = "desokod")
  
  
  st_write(df_deso_hushall, "Data/df_deso_hushall_2018.gpkg",  delete_dsn = TRUE)
  
  print('Nedladdning av "df_deso_hushall_2018.gpkg" genomfördes')
  
  # Folkmängden per region efter ålder och kön. År 2010 - 2024
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101Y/FolkmDesoAldKon'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6574')
  
  px_get_list <- list(Region = uppsala_koder,
                      Kon = c('1','2'),
                      Alder = '*',
                      ContentsCode = '*',
                      Tid = as.character(c(senaste_aret-5,senaste_aret-10 )))
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_deso_alder <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  # Finns dubbletter med NA 
  df_deso_alder <- df_deso_alder[complete.cases(df_deso_alder$Antal),] %>% rename(desokod=region)
  
  df_deso_alder <- left_join(deso_sf, df_deso_alder, by = "desokod")
  
  st_write(df_deso_alder, "Data/df_deso_alder_2018.gpkg",  delete_dsn = TRUE)
  
  print('Nedladdning av "df_deso_alder_2018.gpkg" genomfördes')
  
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101Y/FolkmDesoLandKon'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6572')
  
  px_get_list <- list(Region = uppsala_koder,
                      Kon = c('1','2'),
                      Fodelseregion = '*',
                      ContentsCode = '*',
                      Tid = as.character(c(senaste_aret-5,senaste_aret-10 )))
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_deso_fodelse <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  # Finns dubbletter med NA 
  df_deso_fodelse <- df_deso_fodelse[complete.cases(df_deso_fodelse$Antal),] %>% rename(desokod=region)
  
  df_deso_fodelse <- left_join(deso_sf, df_deso_fodelse, by = "desokod")
  
  st_write(df_deso_fodelse, "Data/df_deso_fodelse_2018.gpkg",  delete_dsn = TRUE)
  
  print('Nedladdning av "df_deso_fodelse_2018.gpkg" genomfördes')
}