#######laddar in data om Antal lägenheter efter region, hustyp, ägarkategori och år #######
func_df_agarkategori <- function(){
  # laddar in data om Antal lägenheter efter region, hustyp, ägarkategori och år
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104D/BO0104T03/
  url <- pxweb_url("TAB823")
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Hustyp' = '*',
         'Agarkategori' = '*',
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list)
  
  # Convert to data.frame 
  df_agarkategori <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  df_agarkategori <- na.omit(df_agarkategori)

  df_agarkategori <- df_agarkategori |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  write.csv(df_agarkategori, "Data/df_agarkategori.csv", row.names = F)
  
  print('Nedladdning av "df_agarkategori" har gått igenom')
}