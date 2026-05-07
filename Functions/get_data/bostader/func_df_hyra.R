######## Hyresutveckling ###########
func_df_hyra <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BO__BO0406__BO0406E/BO0406Tab01/
  # Läser in data
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0406/BO0406E/BO0406Tab01'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB4590')
  
  pxweb_query_list <-
    list('Region' = c("03",kommunkod),
         'Hyresuppg'='Mh_kvm',
         'Tid' = '*',
         'ContentsCode' = '000000J4'
    )
  
  
  # Download data 
  px_data <- pxweb_get(url = url,pxweb_query_list)
  
  # Convert to data.frame 
  df_hyra <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  # imputerar ett saknande värde till samma som året innan och efter
  df_hyra$`Medianhyra i hyreslägenhet`[df_hyra$region=='Tierp' & df_hyra$år=='2017'] <- 86
  
  write.csv(df_hyra, "Data/df_hyra.csv", row.names = F)
  
  print('Nedladdning av "df_hyra.csv" har gått igenom')
}
