########### Deso land/vatten areal ##############
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__MI__MI0802/Areal2025/
func_df_deso_land_vatten <- function(){
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/MI/MI0802/Areal2025'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6420')
  
  meta <- pxweb_get(url)
  
  # Visa tillgängliga regionkoder
  regioner <- meta$variables[[1]]$values
  
  # Välj endast regioner som börjar med "03"
  uppsala_koder <- regioner[startsWith(regioner, lanskod)]
  
  pxweb_query_list <- list(
    "Region" =uppsala_koder , # Uppsala läns kommuner
    "ArealTyp" = '*', 
    'ContentsCode' = '*',
    "Tid" = c("*")    # Årtal att hämta data för
  )
  
  px_data <- pxweb_get(url,pxweb_query_list)
  px_deso <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  write.csv(px_deso, "Data/df_deso_land_vatten.csv", row.names = F)
  
  print('Nedladdning av "df_deso_land_vatten.csv" har genomförts')
}

source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")


############## Natur ############
# Skyddad natur, andel (%)
func_df_avstand_natur <- function(){
  df_skyddad_natur <- search_and_fetch_kolada("Skyddad natur ")
  
  df_skyddad_natur<- df_skyddad_natur %>%  filter(title %in% c("Skyddad natur land, andel (%)" ,
                                                               "Skyddad natur hav, andel (%)",
                                                               "Skyddad natur inlandsvatten, andel (%)"))
  
  write.csv(df_skyddad_natur, "Data/df_skyddad_natur.csv", row.names = F)
  print('Nedladdning av "df_skyddad_natur.csv" har genomförts')
}


# Medelavstånd skyddad natur
func_df_avstand_natur <- function(){
  df_avstand_natur <- search_and_fetch_kolada("Medelavstånd till skyddad natur, km", match=0)
  #unique(df_avstand_natur$title)
  write.csv(df_avstand_natur, "Data/df_avstand_natur.csv", row.names = F)
  print('Nedladdning av "df_avstand_natur.csv" har genomförts')
}


# Ekomark
func_ekomark <- function(){
  df_eko <- search_and_fetch_kolada("Ekologiskt brukad åkermark, andel (%)", match=0)
  
  #unique(df_eko$title)
  write.csv(df_eko, "Data/df_eko.csv", row.names = F)
  print('Nedladdning av "df_eko.csv" har genomförts')
}


############ Slåtteräng #############
func_slatterang <- function(){
  df_slatt <- search_and_fetch_kolada("Slåtteräng")
  unique(df_slatt$title)
  
  df_slatt <- df_slatt %>% filter(title %in% c("Slåtteräng, hektar" , "Slåtteräng, andel (%)"  ))
  write.csv(df_slatt, "Data/df_slatt.csv", row.names = F)
  print('Nedladdning av "df_slatt.csv" har genomförts')
}


############ Betesmark #############
func_df_betesmark <- function(){
  df_betesmark <- search_and_fetch_kolada("Betesmark", match = 0)
  unique(df_betesmark$title)
  
  df_betesmark <- df_betesmark %>% filter(title %in% c("Total betesmark, hektar"                   
                                                       ,"Betesmark, andel (%)"))
  write.csv(df_betesmark, "Data/df_betesmark.csv", row.names = F)
  print('Nedladdning av "df_betesmark.csv" har genomförts')
}



############ Ekologisk sjö #############
func_eko_sjo <- function(){
  df_ekovatten <- search_and_fetch_kolada(" god ekologisk", match = 0)
  unique(df_ekovatten$title)
  
  df_ekovatten <- df_ekovatten %>% filter(title %in% c("Sjöar med god ekologisk status, andel (%)", 
                                                       "Vattendrag med god ekologisk status, andel (%)",
                                                       "Kustvatten med god ekologisk status, andel (%)"))
  write.csv(df_ekovatten, "Data/df_ekovatten.csv", row.names = F)
  print('Nedladdning av "df_ekovatten.csv" har genomförts')
}
