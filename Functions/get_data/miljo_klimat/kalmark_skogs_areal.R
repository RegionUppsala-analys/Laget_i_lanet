################ kalmarksareal ##########
func_kalmarksareal <- function(){
  # https://pxweb.skogsstyrelsen.se/pxweb/sv/Skogsstyrelsens%20statistikdatabas/Skogsstyrelsens%20statistikdatabas__Miljohansyn/JO1403_8.a.px/
  url <- 'https://pxweb.skogsstyrelsen.se:443/api/v1/sv/Skogsstyrelsens statistikdatabas/Miljohansyn/JO1403_8.a.px'
  
  pxweb_query_list <- list(
    "Region" = '*', # Uppsala läns kommuner
    'Variabel' = '*',
    'År' = '*'
  )
  
  px_data <- pxweb_get(url,
                       query = pxweb_query_list
  )
  
  # Steg 4: Omvandla data till ett data.frame för enklare hantering i R
  kalmarksareal <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  # Filterar ut län
  kalmarksareal <- kalmarksareal %>% filter(!Region %in% c("Götaland",
                                                           "Svealand",
                                                           "Norra Norrland",
                                                           "Södra Norrland"))
  
  write.csv(kalmarksareal, "Data/df_kalmarksareal.csv", row.names = F)
  
  print('Nedladdning av "df_kalmarksareal.csv" har genomförts')
  
}


########### Produktiv skogsareal ############
func_skogsareal <- function(){
  # https://pxweb.skogsstyrelsen.se/pxweb/sv/Skogsstyrelsens%20statistikdatabas/Skogsstyrelsens%20statistikdatabas__Fastighets-%20och%20agarstruktur/PX12.px/
  url <- 'https://pxweb.skogsstyrelsen.se:443/api/v1/sv/Skogsstyrelsens statistikdatabas/Fastighets- och agarstruktur/PX12.px'
  
  
  meta <- pxweb_get(url)
  
  uppsala_kom <- which(str_to_sentence(gsub("^\\d+\\s+", "", meta[["variables"]][[1]][["valueTexts"]])) %in% kommuner)
  
  pxweb_query_list <- list(
    "Kommun" = as.character(uppsala_kom), # Uppsala läns kommuner
    'Variabel' = '*',
    'År' = '*'
  )
  
  px_data <- pxweb_get(url,
                       query = pxweb_query_list
  )
  
  # Steg 4: Omvandla data till ett data.frame för enklare hantering i R
  prod_skog <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  
  prod_skog <- prod_skog %>% filter(År > 2004)
  
  write.csv(prod_skog, "Data/df_prod_skog.csv", row.names = F)
  
  print('Nedladdning av "df_prod_skog.csv" har genomförts')
  
}
