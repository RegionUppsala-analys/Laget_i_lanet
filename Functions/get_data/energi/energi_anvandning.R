# Lokaler: Total energianvändning för värme och varmvatten, fördelat på energislag/typ, typ av lokal, ägare och län
# https://pxexternal.energimyndigheten.se/pxweb/sv/Energimyndighetens_statistikdatabas/Energimyndighetens_statistikdatabas__Officiell_energistatistik__Bostader_och_lokaler__Lokaler/EN0103_14.px/table/tableViewLayout2/
func_energianvandning <- function(){
  url <- 'http://pxexternal.energimyndigheten.se/api/v1/sv/Energimyndighetens_statistikdatabas/Officiell_energistatistik/Bostader_och_lokaler/Lokaler/EN0103_14.px'
  
  
  
  meta <- pxweb_get(url)
  
  nar_liggande <- as.character(which(meta[["variables"]][[2]][["valueTexts"]] %in% mellan_sverige))
  
  px_get_list <- list('Faktisk/temperaturkorrigerad' = '*',
                      'Ägare/län/lokaltyp' = nar_liggande,
                      'Energislag/energibärare' = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_energianvändning <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  write.csv(df_energianvändning, "Data/df_energianvändning.csv", row.names = F)
  
  print('Nedladdning av "df_energianvändning.csv" har genomförts')
}
