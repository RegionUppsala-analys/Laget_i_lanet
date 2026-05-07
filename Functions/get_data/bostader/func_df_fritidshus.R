######## Fritidshus #########

func_df_fritidshus <- function()
{
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104H/BO0104T08/
  # data för Antal fritidshus efter region och år
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0104/BO0104H/BO0104T08'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB825')
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list)
  
  # Convert to data.frame 
  df_fritidshus <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  write.csv(df_fritidshus, "Data/df_fritidshus.csv", row.names = F)
  
  print('Nedladdning av "df_fritidshus.csv" har gått igenom')
}