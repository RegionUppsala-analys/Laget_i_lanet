
########################### utbildningsnivåer ###############################
# Befolkning, antal efter region, ålder, utbildningsnivå, kön och år

func_df_utbildning <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__UF__UF0506__UF0506B/Utbildning/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/UF/UF0506/UF0506B/Utbildning'
  
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB3981')
  
  px_get_list <- list(Region = c(lanskod,kommunkod),
                      UtbildningsNiva = '*',
                      Kon = '*',
                      Alder = "tot16-74",
                      ContentsCode = '*',
                      Tid = "*")
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_utbildning <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_utbildning <- df_utbildning %>% select(region, utbildningsnivå, kön, år, Antal) # tar bort NA då det endast finns uppgift saknas för Riket
  
  # sparar data med variabler:
  write.csv(df_utbildning, "Data/df_utbildning.csv", row.names = F)
  
  print('Nedladdning av "df_utbildning.csv" genomfördes')
}
