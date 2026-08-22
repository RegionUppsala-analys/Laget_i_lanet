########################### Ohälsotal ###############################

func_df_ohalso <- function(){
  # # Ohälsotalet efter län och kön. År 1997 - 2023
  #https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AA__AA0003__AA0003I/IntGr10LanKon/
  
  url <- pxweb_url("TAB1768")
  meta <- pxweb_get(url)
  
  px_get_list <- list(Region = '*',
                      Kon = c('1', '2'),
                      Bakgrund = c("SE" ,"NEXS" ,"EUEESXN","VXEUEES"),
                      ContentsCode = '*',
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_ohalso <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_ohalso <- na.omit(df_ohalso)

  df_ohalso <- df_ohalso |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  write.csv(df_ohalso, "Data/df_ohalso.csv", row.names = F)
  
  print('Nedladdning av "df_ohalso.csv" genomfördes')
}
