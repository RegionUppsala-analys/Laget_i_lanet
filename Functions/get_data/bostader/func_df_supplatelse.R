####### laddar in data om Antal lägenheter efter region, hustyp, upplåtelseform och år #######
func_df_supplatelse <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104D/BO0104T04/
  url <- pxweb_url("TAB824")
  
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
  df_supplatelse <- na.omit(df_supplatelse)

  df_supplatelse <- df_supplatelse |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  write.csv(df_supplatelse, "Data/df_supplatelse.csv", row.names = F) 
  
  print('Nedladdning av "df_supplatelse.csv" har gått igenom')
}