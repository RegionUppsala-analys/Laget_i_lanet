######## Fritidshus #########

func_df_fritidshus <- function()
{
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104H/BO0104T08/
  # data för Antal fritidshus efter region och år
  url <- pxweb_url("TAB825")
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list)
  
  # Convert to data.frame 
  df_fritidshus <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  df_fritidshus <- na.omit(df_fritidshus)

  df_fritidshus <- df_fritidshus |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  write.csv(df_fritidshus, "Data/df_fritidshus.csv", row.names = F)
  
  print('Nedladdning av "df_fritidshus.csv" har gått igenom')
}