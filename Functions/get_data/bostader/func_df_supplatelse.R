####### laddar in data om Antal lägenheter efter region, hustyp, upplåtelseform och år #######
func_df_supplatelse <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104D/BO0104T04/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0104/BO0104D/BO0104T04'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB824')
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Upplatelseform' = '*',
         'Hustyp' = '*',
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list)
  
  # Convert to data.frame 
  df_supplatelse <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  write.csv(df_supplatelse, "Data/df_supplatelse.csv", row.names = F) 
  
  print('Nedladdning av "df_supplatelse.csv" har gått igenom')
}