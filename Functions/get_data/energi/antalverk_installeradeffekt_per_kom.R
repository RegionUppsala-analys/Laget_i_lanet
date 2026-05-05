# Antal verk och installerad effekt per kommun, 2003
# https://pxexternal.energimyndigheten.se/pxweb/sv/Energimyndighetens_statistikdatabas/Energimyndighetens_statistikdatabas__Officiell_energistatistik__Vindkraftsstatistik/EN0105_4.px/
func_df_effekt_verk <- function(){
  url <- 'http://pxexternal.energimyndigheten.se/api/v1/sv/Energimyndighetens_statistikdatabas/Officiell_energistatistik/Vindkraftsstatistik/EN0105_4.px'
  
  meta <- pxweb_get(url)
  # Plockar ut index för kommunerna, tar -1 för den börjar från 0 och inte 1
  kom <- as.character(which(str_remove(meta[["variables"]][[2]][["valueTexts"]], "^[0-9]+\\s*") %in% kommuner)-1)
  
  px_get_list <- list('År' = '*',
                      'Kommun' = kom,
                      'Kategori' = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_effekt_verk <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  df_effekt_verk <- df_effekt_verk %>% mutate(Kommun = str_remove(Kommun,"^[0-9]+\\s*" ))
  
  write.csv(df_effekt_verk, "Data/df_effekt_verk.csv", row.names = F)
  
  print('Nedladdning av "df_effekt_verk.csv" har genomförts')
}
