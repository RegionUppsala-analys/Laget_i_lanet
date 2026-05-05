#inrikesflytt
func_inrikesflytt <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101J/Flyttningar97/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101J/Flyttningar97'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB1212')
  
  meta <- pxweb_get(url)
  
  # tar ut alla län
  lan <- meta[["variables"]][[1]][["values"]]
  lan <- lan[nchar(lan) == 2]
  lan <- lan[lan != "00"]
  
  pxweb_query_list <-
    list('Region' = lan,
         'Alder' = 'tot',
         'Kon' = '*',
         'Tid' = '2022',
         'ContentsCode' = 'BE0101A4'
    )
  
  # print_scb_converter_input(url, pxweb_query_list)
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list )
  
  # Convert to data.frame 
  df_inflytt <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text") %>% 
    group_by(region) %>% summarize(Antal =sum(`Inrikes flyttningsöverskott`), .groups='drop') 
  
  
  # sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
  write.csv(df_inflytt, "Data/df_inflytt.csv", row.names = F)
  
  print('Nedladdning av "df_inflytt" har gått igenom')
  
  
  
  
}