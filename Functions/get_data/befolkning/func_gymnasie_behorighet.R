
## Andel behörig till gymnasier per kommun 
func_gymnasie_behorighet <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AA__AA0003__AA0003H/IntGr8Kom2/table/tableViewLayout1/
  url <- pxweb_url("TAB1804")
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = kommunkod,
                      Bakgrund = c('1','2'),
                      ContentsCode = '*',
                      Tid = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_behorig <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_behorig <- na.omit(df_behorig) # tar bort NA då det endast finns uppgift saknas för Riket

  df_behorig <- df_behorig |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )
  df_behorig <- df_behorig %>%  filter(as.integer(år) > 2002)
  
  # sparar data med variabler:
  write.csv(df_behorig, "Data/df_behorig.csv", row.names = F)
  
  print('Nedladdning av "df_behorig.csv" genomfördes')
}
