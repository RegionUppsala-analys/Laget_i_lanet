########## laddar in data om Antal lägenheter efter region, typ av specialbostad, bostadsarea och år (äldre/funktionshindrade, student, övrigt) #######
func_df_specialbostad <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104D/BO0104T7/
  url <-'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0104/BO0104D/BO0104T7'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB827')
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'TypAvSpecialbostad' = '*',
         'Bostadsarea' = '*',
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list)
  
  # Convert to data.frame 
  df_specialbostad <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  write.csv(df_specialbostad, "Data/df_specialbostad.csv", row.names = F) 
  
  print('Nedladdning av "df_specialbostad" har gått igenom')
}
