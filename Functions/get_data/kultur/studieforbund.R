####### Studieförbundens statistik scb ########

# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__KU__KU0402/StudieforbHelarLanKo/table/tableViewLayout1/
func_df_studieforbund <- function(){
  # Deltagare, män efter region, arrangemangstyp, verksamhetsform, studieförbund, distans/ej distans och år
  url <- pxweb_url("TAB1652")
  meta <- pxweb_get(url)
  
  # Skapa en referenstabell med kommunkoder och namn
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Arrangemangstyp' = 'TOT',
         'Verksamhetsform' = '*',
         'Studieforbund' = "TOTFORB",
         'Distansellerej'='TOT',
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list )
  
  # Convert to data.frame 
  df_studieforbund <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text") 
  df_studieforbund <- na.omit(df_studieforbund)

  df_studieforbund <- df_studieforbund |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )
  
  # sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
  write.csv(df_studieforbund, "Data/df_studieforbund.csv", row.names = F)
  
  print('Nedladdning av "df_studieforbund" har gått igenom')
}