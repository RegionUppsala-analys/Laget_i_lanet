# Bostadsfunktion


##############Laddar in data om Antal lägenheter efter region, hustyp och byggnadsperiod. År 2013 - 2024 #######
func_df_byggnadsperiod <- function(){
  # Laddar in data om Antal lägenheter efter region, hustyp och byggnadsperiod. År 2013 - 2024
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0104__BO0104D/BO0104T02/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0104/BO0104D/BO0104T02'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB822')
  
  # Skapa en referenstabell med kommunkoder och namn
  
  kommunkod <- c("0330", "0331", "0360", "0380", "0381", "0382", "0305", "0319")
  kommuner <- c("Knivsta", "Heby", "Tierp", "Uppsala", "Enköping", "Östhammar", "Håbo", "Älvkarleby")
  
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Hustyp' = '*',
         'Byggnadsperiod' = '*',
         'Tid' = '*',
         'ContentsCode' = '*'
    )
  
  print_scb_converter_input(url, pxweb_query_list)
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list )
  
  # Convert to data.frame 
  df_byggnadsperiod <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  
  # sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
  write.csv(df_byggnadsperiod, "Data/df_byggnadsperiod.csv", row.names = F)
  
  print('Nedladdning av "df_byggnadsperiod" har gått igenom')
}
