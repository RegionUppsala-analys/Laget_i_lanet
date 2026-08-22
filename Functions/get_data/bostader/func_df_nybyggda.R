##########Laddar in data om Färdigställda lägenheter i nybyggda hus, antal efter region, hustyp, upplåtelseform och år #####################
func_df_nybyggda <- function(){
  
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0101__BO0101A/LghReHtypUfAr/
  url <- pxweb_url("TAB4193")
  # Skapa en referenstabell med kommunkoder och namn
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Upplatelseform' = '*',
         'Hustyp' = '*',
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  
  # Download data 
  px_data <- pxweb_get(url = url ,pxweb_query_list)
  
  # Convert to data.frame 
  df_nybyggda <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  df_nybyggda <- na.omit(df_nybyggda)

  df_nybyggda <- df_nybyggda |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  write.csv(df_nybyggda, "Data/df_nybyggda.csv", row.names = F) 
  
  print('Nedladdning av "df_nybyggda.csv" har gått igenom')
}
