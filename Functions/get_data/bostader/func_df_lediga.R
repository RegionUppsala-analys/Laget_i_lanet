######## # Läser in data om Andel lediga lägenheter i flerbostadshus, allmännyttiga efter region, lägenhetstyp och år #######
func_df_lediga <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0303__BO0303A/OuthAllmLghTypKom0/
  url <- pxweb_url("TAB5605")
  
  
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
  df_lediga <- na.omit(df_lediga)

  df_lediga <- df_lediga |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  write.csv(df_lediga, "Data/df_lediga.csv", row.names = F) 
  
  print('Nedladdning av "df_lediga.csv" har gått igenom')
}
