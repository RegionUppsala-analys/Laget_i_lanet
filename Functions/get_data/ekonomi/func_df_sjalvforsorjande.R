
###### Självförsörjning, sos ersättning och genomsnittlig lön ###########
## Självförsörjning efter region, kön, ålder, födelseregion och utbildningsnivå. År 2013 - 2023

func_df_sjalvforsorjande <- function(){
  #https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__HE__HE0000/HE0000Tab01/
  
  url <-  'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/HE/HE0000/HE0000Tab01'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6396')
  
  meta <- pxweb_get(url)
  
  latest_year <- tail(meta[['variables']][[7]][['values']],1)
  
  px_get_list <- list(Region = c(lanskod, kommunkod),
                      Kon = c('1' ,'2'),
                      Alder = '20-65',
                      Fodelseregion =c("in" ,  "ut" ,  "ute" , "utee"),
                      UtbildningsNiva = c("21"  ,"3+4", "8"  , "US" ),
                      ContentsCode = c( "00000791" ,"000007M2" ,"00000792"),
                      Tid = latest_year)
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  sjalvforsorjande <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # setting NAs to 0
  sjalvforsorjande <- sjalvforsorjande %>% replace(is.na(.), 0)
  
  write.csv(sjalvforsorjande, "Data/df_sjalvforsorjande.csv", row.names = F)
  
  print('Nedladdning av "df_sjalvforsorjande.csv" genomfördes')
  
}
