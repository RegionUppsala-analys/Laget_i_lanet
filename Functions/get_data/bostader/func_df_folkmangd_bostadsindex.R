######## Laddar in data Folkmängden efter region,  ålder  År 2006 ##########
func_df_folkmangd_bostadsindex <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101A/BefolkningNy/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101A/BefolkningNy'
  # Skapa en referenstabell med kommunkoder och namn
  
  meta <- pxweb_get(url)
  
  senaste <- max(meta[["variables"]][[6]][["valueTexts"]])
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB638')
  
  pxweb_query_list <-
    list('Region' = kommunkod,
         'Alder' = c(as.character(20:99), "100+"), # 20 år och uppåt
         'Tid' = c("2006",senaste) , # basåret
         'ContentsCode' = 'BE0101N1' # folkmängd
    )
  
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list)
  
  # Convert to data.frame 
  folkmangd <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  write.csv(folkmangd, "Data/df_folkmangd.csv", row.names = F)
  
  print('Nedladdning av "df_folkmangd.csv" har gått igenom')
}
