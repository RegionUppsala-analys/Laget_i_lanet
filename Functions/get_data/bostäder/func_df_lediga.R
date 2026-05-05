######## # Läser in data om Andel lediga lägenheter i flerbostadshus, allmännyttiga efter region, lägenhetstyp och år #######
func_df_lediga <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0303__BO0303A/OuthAllmLghTypKom0/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0303/BO0303A/OuthAllmLghTypKom0'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB5605')
  
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Lagenhetstyp'="*",
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list)
  
  # Convert to data.frame 
  df_lediga <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  
  write.csv(df_lediga, "Data/df_lediga.csv", row.names = F) 
  
  print('Nedladdning av "df_lediga.csv" har gått igenom')
}
