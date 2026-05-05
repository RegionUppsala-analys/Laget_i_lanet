# Elproduktion och bränsleanvändning (MWh), efter län och kommun, produktionssätt samt bränsletyp. År 2009 - 2023
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__EN__EN0203__EN0203A/ProdbrEl/
func_elproduktion <- function(){
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/EN/EN0203/EN0203A/ProdbrEl'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB3451')
  
  
  px_get_list <- list(Region = kommunkod,
                      Produktionssatt = '*',
                      Bransle = '*',
                      ContentsCode = '*',
                      Tid = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_Elproduktion <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  
  write.csv(df_Elproduktion, "Data/df_Elproduktion.csv", row.names = F)  
  print('Nedladdning av "df_Elproduktion.csv" har genomförts')
}
