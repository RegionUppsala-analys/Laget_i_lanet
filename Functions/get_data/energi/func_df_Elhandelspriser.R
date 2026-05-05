# Elhandelspriser på elenergi (exkl. elskatt, moms och nätavgift) efter avtalstyp, elområde och kundkategori. Månad 2013M04 - 2025M08
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__EN__EN0301__EN0301A/SSDManadElhandelpris/table/tableViewLayout1/
func_df_Elhandelspriser <- function(){
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/EN/EN0301/EN0301A/SSDManadElhandelpris'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB3819')
  
  meta <- pxweb_get(url)
  years <- meta[["variables"]][[5]][["values"]] # för att plocka ut år från 2020 och framåt
  years_after <- years[as.numeric(substr(years, 1, 4)) > 2021]
  
  px_get_list <- list(Avtalstyp = '*',
                      Elomrade = '*',
                      Kundkategori = '*',
                      ContentsCode = '*',
                      Tid = years_after)
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_Elhandelspriser <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Tar bort NA (2021M01 för alla kategorier)
  df_Elhandelspriser <- df_Elhandelspriser %>%
    drop_na()
  
  write.csv(df_Elhandelspriser, "Data/df_Elhandelspriser.csv", row.names = F)
  print('Nedladdning av "df_Elhandelspriser.csv" har genomförts')
}




