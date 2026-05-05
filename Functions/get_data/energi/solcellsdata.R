# Nätanslutna solcellsanläggningar, installerad effekt per capita och landareal, fr.o.m. år 2016 -
# https://pxexternal.energimyndigheten.se/pxweb/sv/Energimyndighetens_statistikdatabas/Energimyndighetens_statistikdatabas__Officiell_energistatistik__Natanslutna_solcellsanlaggningar/EN0123_2.px/
func_solceller <- function(){
  url <- 'http://pxexternal.energimyndigheten.se/api/v1/sv/Energimyndighetens_statistikdatabas/Officiell_energistatistik/Natanslutna_solcellsanlaggningar/EN0123_2.px'  
  meta <- pxweb_get(url)
  # Plockar ut index för kommunerna, tar -1 för den börjar från 0 och inte 1
  kom <- as.character(which(str_remove(meta[["variables"]][[2]][["valueTexts"]], "^[0-9]+\\s*") %in% kommuner)-1)
  
  px_get_list <- list('År' = '*',
                      'Område' = kom,
                      Effektklass = '*',
                      'Kategori' = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_solcell <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  df_solcell <- df_solcell %>% mutate(Område = str_remove(Område,"^[0-9]+\\s*" ))
  
  write.csv(df_solcell, "Data/df_solcell.csv", row.names = F)
  
  print('Nedladdning av "df_solcell.csv" har genomförts')
}
