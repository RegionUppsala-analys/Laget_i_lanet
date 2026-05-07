##########Laddar in data om Färdigställda lägenheter i nybyggda hus, antal efter region, hustyp, upplåtelseform och år #####################
func_df_nybyggda <- function(){
  
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0101__BO0101A/LghReHtypUfAr/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0101/BO0101A/LghReHtypUfAr'
  # Skapa en referenstabell med kommunkoder och namn
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB4193')
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Upplatelseform' = '*',
         'Hustyp' = '*',
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  
  # Download data 
  px_data <- pxweb_get(url = url ,pxweb_query_list)
  
  # Convert to data.frame 
  df_nybyggda <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  write.csv(df_nybyggda, "Data/df_nybyggda.csv", row.names = F) 
  
  print('Nedladdning av "df_nybyggda.csv" har gått igenom')
}
