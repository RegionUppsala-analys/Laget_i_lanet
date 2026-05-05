
######## SCB trångboddhet för födelseort #######

fun_df_trang <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__LE__LE0105__LE0105B/LE0105Boende02/table/tableViewLayout1/
  
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/LE/LE0105/LE0105B/LE0105Boende02'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB5089')
  meta <- pxweb_get(url)
  
  senaste_aret <- max(as.integer(meta$variables[[7]]$values))
  
  
  px_get_list <- list(Region = lanskod,
                      Trangboddhet =  c("TOT","TRÅNGB N2") ,
                      Kon = "TOT2" ,
                      Fodelseregion = c( "020", "030" ,"040", "050", "010", "100"),
                      Alder = "totalt" ,
                      ContentsCode = c( "000004SS", "000004ST"),
                      Tid = as.character(2012:senaste_aret))
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_trang <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  write.csv(df_trang, "Data/df_trang.csv", row.names = F)
  
  print('Nedladdning av "df_trang.csv" genomfördes')
  
}