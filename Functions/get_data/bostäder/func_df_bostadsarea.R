#######laddar in data om Antal lägenheter efter region, hustyp, bostadsarea och år #######
func_df_bostadsarea <- function(){
  
  # laddar in data om Antal lägenheter efter region, hustyp, bostadsarea och år
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104D/BO0104T5/
  url <-'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0104/BO0104D/BO0104T5'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB826')
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Hustyp' = '*',
         'Bostadsarea' = '*',
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list)
  
  # Convert to data.frame 
  df_bostadsarea <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  write.csv(df_bostadsarea, "Data/df_bostadsarea.csv", row.names = F) 
  print('Nedladdning av "df_bostadsarea.csv" har gått igenom')
}
