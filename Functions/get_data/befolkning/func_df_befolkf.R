############## laddar in data för befolkningsförändring#################

# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101G/BefforandrKvRLK/
func_df_befolkf <- function(){
  # Skapa en referenstabell med kommunkoder och namn
  
  url <- pxweb_url("TAB5169")
  
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Forandringar' = '110',
         'Period' = 'hel',
         'Tid' = '*',
         'Kon' = '1+2',
         'ContentsCode' = '*'
    )
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list )
  
  # Convert to data.frame 
  df_befolkf <-  as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  df_befolkf <- na.omit(df_befolkf)

  df_befolkf <- df_befolkf |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  write.csv(df_befolkf, "Data/df_befolkf.csv", row.names = F) 
  
  print('Nedladdning av "df_befolkf.csv" har gått igenom')
}
