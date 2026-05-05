
########## Befolkningsprognoser ###########

func_df_folkmangdfram <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0401__BE0401A/BefProgRegFakN/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0401/BE0401A/BefProgRegFakN'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6008')
  
  px_get_list <- list(Region = kommunkod,
                      InrikesUtrikes = '*',
                      Kon = '*',
                      Alder = '*',
                      ContentsCode = '*',
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_folkmangdfram <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_folkmangdfram$ålder <- gsub("\\+", "", df_folkmangdfram$ålder)
  df_folkmangdfram$ålder <- as.integer(gsub(" år", "", df_folkmangdfram$ålder))
  df_folkmangdfram$år = as.integer(df_folkmangdfram$år)
  df_folkmangdfram <- df_folkmangdfram %>% filter(`inrikes/utrikes född` == "inrikes och utrikes födda")
  
  # sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
  write.csv(df_folkmangdfram, "Data/df_folkmangdfram.csv", row.names = F)
  
  print('Nedladdning av "df_folkmangdfram.csv" har gått igenom')
}
