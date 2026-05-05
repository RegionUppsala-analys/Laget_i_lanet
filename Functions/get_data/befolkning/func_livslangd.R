# Femårig livslängdstabell efter län, utbildningsnivå, kön och ålder. Årsintervall 2012-2016 - 2020-2024

func_df_livslangd <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0701/LivslUtbLan/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0701/LivslUtbLan'
  
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB4879')
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  latest_year <- tail(meta$variables[[6]]$values, 1)  # last value
  
  px_get_list <- list(Region = riket_narliggande,
                      UtbildningsNiva = '*',
                      Kon = c('020','030'),
                      Alder = '*',
                      ContentsCode = '*',
                      Tid = latest_year)
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_livslangd <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_livslangd <- na.omit(df_livslangd) # tar bort NA då det endast finns uppgift saknas för Riket
  
  # sparar data med variabler:
  write.csv(df_livslangd, "Data/df_livslangd.csv", row.names = F)
  
  print('Nedladdning av "df_livslangd.csv" genomfördes')
}