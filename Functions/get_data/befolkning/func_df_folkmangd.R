
################# Folkmängd bakåt, antal efter region, kön , ålder, år 
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101A/BefolkningNy/
func_df_folkmangd <- function(){
  url <- pxweb_url("TAB638")
  
  px_get_list <- list(Region = kommunkod,
                      Kon = '*',
                      Alder = '*',
                      ContentsCode = 'BE0101N1',
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_folkmangd <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_folkmangd <- na.omit(df_folkmangd)

  df_folkmangd <- df_folkmangd |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  df_folkmangd <- df_folkmangd[df_folkmangd$ålder != 'totalt ålder',]
  
  df_folkmangd$ålder <- gsub("\\+", "", df_folkmangd$ålder)
  df_folkmangd$ålder <- as.integer(gsub(" år", "", df_folkmangd$ålder))
  df_folkmangd$år = as.integer(df_folkmangd$år)
  
  # sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
  write.csv(df_folkmangd, "Data/df_folkmangd.csv", row.names = F)
  
  print('Nedladdning av "df_folkmangd.csv" genomfördes')
}