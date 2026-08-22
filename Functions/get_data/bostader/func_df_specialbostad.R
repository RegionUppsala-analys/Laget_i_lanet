########## laddar in data om Antal lägenheter efter region, typ av specialbostad, bostadsarea och år (äldre/funktionshindrade, student, övrigt) #######
func_df_specialbostad <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104D/BO0104T7/
  url <- pxweb_url("TAB827")
  
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
  df_specialbostad <- na.omit(df_specialbostad)

  df_specialbostad <- df_specialbostad |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  write.csv(df_specialbostad, "Data/df_specialbostad.csv", row.names = F) 
  
  print('Nedladdning av "df_specialbostad" har gått igenom')
}
