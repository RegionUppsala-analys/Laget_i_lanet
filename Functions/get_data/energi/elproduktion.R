# Elproduktion och bränsleanvändning (MWh), efter län och kommun, produktionssätt samt bränsletyp. År 2009 - 2023
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__EN__EN0203__EN0203A/ProdbrEl/
func_elproduktion <- function(){
  url <- pxweb_url("TAB3451")
  
  
  px_get_list <- list(Region = kommunkod,
                      Produktionssatt = '*',
                      Bransle = '*',
                      ContentsCode = '*',
                      Tid = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_Elproduktion <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_Elproduktion <- na.omit(df_Elproduktion)

  df_Elproduktion <- df_Elproduktion |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  write.csv(df_Elproduktion, "Data/df_Elproduktion.csv", row.names = F)  
  print('Nedladdning av "df_Elproduktion.csv" har genomförts')
}
