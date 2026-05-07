############## DESO nivå upplåtelseform############
func_deso_upplatelse <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104X/BO0104T01N2/
  
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0104/BO0104X/BO0104T01N2'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6638')
  
  # Hämta metadata för Region
  meta <- pxweb_get(url)
  
  # Visa tillgängliga regionkoder
  regioner <- meta$variables[[1]]$values
  
  # Välj endast regioner som börjar med lanskod
  uppsala_koder <- regioner[startsWith(regioner, lanskod)]
  
  pxweb_query_list <-
    list('Region' = uppsala_koder,
         'Upplatelseform'="*",
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url, pxweb_query_list)
  
  # Convert to data.frame 
  df_deso <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  write.csv(df_deso, "Data/df_deso.csv", row.names = F)
  
  print('Nedladdning av "df_deso.csv" har gått igenom')
}
