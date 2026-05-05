
## Genomsnittlig grund- och månadslön samt kvinnors lön i procent av mäns lön efter region, sektor, yrkesgrupp (SSYK 2012) och kön. År 2023 - 2024
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AM__AM0110__AM0110B/LonYrkeRegionAN/

func_df_genom_lon <- function(){
  url <-  'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/AM/AM0110/AM0110B/LonYrkeRegionAN'
  
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB5881')
  
  meta <- pxweb_get(url)
  
  latest_year <- tail(meta[['variables']][[6]][['values']],1)
  
  px_get_list <- list(Region = '*',
                      Sektor = '0',
                      Yrkesgrupp12 = '*',
                      Kon = c('1' ,'2'),
                      ContentsCode = '*',
                      Tid = latest_year)
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  genom_lon <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # setting NAs to 0
  genom_lon <- genom_lon %>% replace(is.na(.), 0)
  
  write.csv(genom_lon, "Data/df_genom_lon.csv", row.names = F)
  
  print('Nedladdning av "df_genom_lon.csv" genomfördes')
}

