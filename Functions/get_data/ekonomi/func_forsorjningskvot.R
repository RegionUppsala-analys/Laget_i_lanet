###### Försörjningskvot #########
# Demografisk försörjningskvot (R2). Antalet yngre och äldre i relation till antalet i åldern 20–64 år, efter region. År 2006 - 2024
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AM__AM9906__AM9906D/RegionInd19R2/

func_forsorjningskvot <- function(){
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/AM/AM9906/AM9906D/RegionInd19R2'
  
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB5457')
  
  px_get_list <- list(Region = c(lanskod,kommunkod),
                      ContentsCode = '*',
                      Tid = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_fkvot<- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_fkvot <- na.omit(df_fkvot) # tar bort NA då det endast finns uppgift saknas för Riket
  
  # sparar data med variabler:
  write.csv(df_fkvot, "Data/df_fkvot.csv", row.names = F)
  
  print('Nedladdning av "df_fkvot.csv" genomfördes')
}