

##  Högskoleövergångar (R4). Avgångna från gymnasieskolan som påbörjat högskolestudier inom tre år efter region och kön. År 2003/04 - 2020/21
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AM__AM9906__AM9906D/RegionInd19R4/

func_df_hogskole_overgang <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AM__AM9906__AM9906D/RegionInd19R4/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/AM/AM9906/AM9906D/RegionInd19R4'
  # pxweb v2
  #  url <- print_pxwebv2('TAB5461')
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = c(lanskod,kommunkod),
                      Kon = c('1','2'),
                      ContentsCode = '*',
                      Tid = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  hogskole_overgang <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # sparar data med variabler:
  write.csv(hogskole_overgang, "Data/df_hogskole_overgang.csv", row.names = F)
  print('Nedladdning av "df_hogskole_overgang.csv" genomfördes')
}

