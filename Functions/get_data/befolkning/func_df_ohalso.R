########################### Ohälsotal ###############################

func_df_ohalso <- function(){
  # # Ohälsotalet efter län och kön. År 1997 - 2023
  #https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AA__AA0003__AA0003I/IntGr10LanKon/
  
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/AA/AA0003/AA0003I/IntGr10LanKon'
  meta <- pxweb_get(url)
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB1768')
  
  
  px_get_list <- list(Region = '*',
                      Kon = c('1', '2'),
                      Bakgrund = c("SE" ,"NEXS" ,"EUEESXN","VXEUEES"),
                      ContentsCode = '*',
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_ohalso <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  write.csv(df_ohalso, "Data/df_ohalso.csv", row.names = F)
  
  print('Nedladdning av "df_ohalso.csv" genomfördes')
}
