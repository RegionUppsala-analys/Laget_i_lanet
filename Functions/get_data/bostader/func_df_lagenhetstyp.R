######### laddar in data om Antal lägenheter efter region, hustyp, lägenhetstyp och år #######
func_df_lagenhetstyp <- function(){
  
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104D/BO0104T09/
  # laddar in data om Antal lägenheter efter region, hustyp, lägenhetstyp och år
  
  url <-'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0104/BO0104D/BO0104T09'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB4807')
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Hustyp' = '*',
         'Lagenhetstyp' = '*',
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list)
  
  # Convert to data.frame 
  df_lagenhetstyp <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  write.csv(df_lagenhetstyp, "Data/df_lagenhetstyp.csv", row.names = F) 
  
  print('Nedladdning av "df_lagenhetstyp.csv" har gått igenom')
}
