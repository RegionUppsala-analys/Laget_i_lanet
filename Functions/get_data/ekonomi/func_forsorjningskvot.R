###### Försörjningskvot #########
# Demografisk försörjningskvot (R2). Antalet yngre och äldre i relation till antalet i åldern 20–64 år, efter region. År 2006 - 2024
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AM__AM9906__AM9906D/RegionInd19R2/

func_forsorjningskvot <- function(){
  url <- pxweb_url("TAB5457")

  px_get_list <- list(Region = c(lanskod,kommunkod),
                      ContentsCode = '*',
                      Tid = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_fkvot<- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_fkvot <- na.omit(df_fkvot) # tar bort NA då det endast finns uppgift saknas för Riket

  df_fkvot <- df_fkvot |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )
  
  # sparar data med variabler:
  write.csv(df_fkvot, "Data/df_fkvot.csv", row.names = F)
  
  print('Nedladdning av "df_fkvot.csv" genomfördes')
}