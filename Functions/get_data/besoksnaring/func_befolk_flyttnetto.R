# Folkämngd
func_hallandsbesoksrapport <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101A/FolkmangdNov/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101A/FolkmangdNov'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB1267')
  
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
         'ContentsCode' = 'BE0101A9'
    )
  
  # print_scb_converter_input(url, pxweb_query_list)
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list )
  
  # Convert to data.frame 
  df_inflytt <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text") %>% 
    group_by(region) %>% summarize(Antal =sum(Antal), .groups='drop') 
  
  
  # sparar data
  write.csv(df_inflytt, "Data/df_folkm.csv", row.names = F)
  
  print('Nedladdning av "df_folkm.csv" har gått igenom')
  
  
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101A/BefolkningCKM/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101A/BefolkningCKM'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB5557')
  
  meta <- pxweb_get(url)
  
  # tar ut alla län
  lan <- meta[["variables"]][[1]][["values"]]
  lan <- lan[nchar(lan) == 2]
  lan <- lan[lan != "00"]
  
  pxweb_query_list <-
    list('Region' = lan,
         'Alder' = 'TOT1',
         'Kon' = 'TotSa',
         'Tid' = '*',
         'Civilstand' = 'SC',
         'ContentsCode' = '000007ME'
    )
  
  # print_scb_converter_input(url, pxweb_query_list)
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list )
  
  # Convert to data.frame 
  df_inflytt <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  
  # sparar data 
  write.csv(df_inflytt, "Data/df_folkm_new.csv", row.names = F)
  
  print('Nedladdning av "df_folkm_new.csv" har gått igenom')
  
  ####### Kommunnivå ########  
  
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101A/FolkmangdNov'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB1267')
  
  meta <- pxweb_get(url)
  
  
  pxweb_query_list <-
    list('Region' = c("03", kommunkod),
         'Alder' = 'tot',
         'Kon' = '*',
         'Tid' = '*',
         'ContentsCode' = 'BE0101A9'
    )
  
  #print_scb_converter_input(url, pxweb_query_list)
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list )
  
  # Convert to data.frame 
  df_inflytt <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text") %>% 
    group_by(region, år) %>% summarize(Folkmängd =sum(Antal), .groups='drop') 
  
  
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101A/BefolkningCKM/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101A/BefolkningCKM'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB5557')
  
  meta <- pxweb_get(url)
  
  pxweb_query_list <-
    list('Region' = c("03", kommunkod),
         'Alder' = 'TOT1',
         'Kon' = 'TotSa',
         'Tid' = '*',
         'Civilstand' = 'SC',
         'ContentsCode' = '000007ME'
    )
  
  #print_scb_converter_input(url, pxweb_query_list)
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list )
  
  # Convert to data.frame 
  df_inflytt2 <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text") %>%
    select(region,år,Folkmängd) 
  
  df_inflytt <- rbind(df_inflytt,df_inflytt2)
  
  # sparar data 
  write.csv(df_inflytt, "Data/df_folkm_kom.csv", row.names = F)
  
  print('Nedladdning av "df_folkm_new.csv" har gått igenom')
  
  
}