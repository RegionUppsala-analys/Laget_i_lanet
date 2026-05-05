############## laddar in data för befolkningsförändring#################

# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101G/BefforandrKvRLK/
func_df_befolkf <- function(){
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101G/BefforandrKvRLK'
  # Skapa en referenstabell med kommunkoder och namn
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB5169')
  
  
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
  
  write.csv(df_befolkf, "Data/df_befolkf.csv", row.names = F) 
  
  print('Nedladdning av "df_befolkf.csv" har gått igenom')
}
