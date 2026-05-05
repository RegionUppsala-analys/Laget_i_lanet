## Demografivariabler för samtliga efter län och kön. År 1997 - 2023
# # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AA__AA0003__AA0003E/IntGr3LanKONS/

func_df_utbildningsniva <- function(){
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/AA/AA0003/AA0003E/IntGr3LanKONS'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB4648')
  
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = lanskod,
                      Kon = c('1','2'),
                      Bakgrund = c("Fp"   ,  "3p"   ,  "EUp" ,   "USp" ),
                      ContentsCode = c("0000016Z" ,"0000016Y"),
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  utbildningsniva <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  
  write.csv(utbildningsniva, "Data/df_utbildningsniva.csv", row.names = F)
  
  print('Nedladdning av "df_utbildningsniva.csv" genomfördes')
}
