################ Folkmängd efter födelseort #####################
func_df_folkmangd_fodd <- function(){# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101E/InrUtrFoddaRegAlKon/
  url <- pxweb_url("TAB4823")
  meta <- pxweb_get(url)
  
  max_ar  <- max(meta[["variables"]][[6]]$values)
  px_get_list <- list(Region = kommunkod,
                      Kon = '*',
                      Alder = '*',
                      Fodelseregion = '*',
                      ContentsCode = '*',
                      Tid = max_ar)
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_folkmangd_fodd <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_folkmangd_fodd <- na.omit(df_folkmangd_fodd)

  df_folkmangd_fodd <- df_folkmangd_fodd |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  df_folkmangd_fodd <- df_folkmangd_fodd[df_folkmangd_fodd$ålder != 'totalt ålder',]
  
  df_folkmangd_fodd$ålder <- gsub("\\+", "", df_folkmangd_fodd$ålder)
  df_folkmangd_fodd$ålder <- as.integer(gsub(" år", "", df_folkmangd_fodd$ålder))
  df_folkmangd_fodd$år = as.integer(df_folkmangd_fodd$år)
  
  # sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
  write.csv(df_folkmangd_fodd, "Data/df_folkmangd_fodd.csv", row.names = F)
  
  print('Nedladdning av "df_folkmangd_fodd" genomfördes')
}
