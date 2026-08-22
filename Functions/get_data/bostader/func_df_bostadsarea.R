#######laddar in data om Antal lägenheter efter region, hustyp, bostadsarea och år #######
func_df_bostadsarea <- function(){
  
  # laddar in data om Antal lägenheter efter region, hustyp, bostadsarea och år
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104D/BO0104T5/
  url <- pxweb_url("TAB826")
  
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
  df_bostadsarea <- na.omit(df_bostadsarea)

  df_bostadsarea <- df_bostadsarea |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  write.csv(df_bostadsarea, "Data/df_bostadsarea.csv", row.names = F) 
  print('Nedladdning av "df_bostadsarea.csv" har gått igenom')
}
