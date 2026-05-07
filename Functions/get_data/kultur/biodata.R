############# Kulturanalys biodata ##########
# Biografstatistik efter kommun, år och tabellinnehåll
func_kommun_biodata <- function(){
  # https://statistik.kulturanalys.se/pxweb/sv/Statistikdatabas/Statistikdatabas__Film%20p%c3%a5%20bio__Annan%20statistik/FPB_MUNICIPA.Px/table/tableViewLayout1/
  
  
  # url
  url <- "https://statistik.kulturanalys.se:443/api/v1/sv/Statistikdatabas/Film på bio/Annan statistik/FPB_MUNICIPA.Px"
  
  # kikar på metadata
  meta <- pxweb_get(url)
  
  # query
  query_list <- list('municipality' = kommunkod,
                     'year' = '*',
                     'tablecontent' = '*')
  
  # Tar hem data och gör till df
  px_data <- pxweb_get(url, query_list)
  kommun_bio <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  
  # Values blev till NA ovan, tar in dem manuellt
  kommun_bio$biografer <- vapply(
    px_data$data,
    function(x) x$values[[1]],
    character(1)
  )
  
  kommun_bio$biografer <- as.numeric(kommun_bio$biografer)
  
  
  write.csv(kommun_bio, "Data/df_kommun_bio.csv", row.names = F)
  print('Nedladdning av "df_kommun_bio.csv" har genomförts')
  
}


#Biografstatistik efter år, område och tabellinnehåll
func_df_region_bio <- function(){# https://statistik.kulturanalys.se/pxweb/sv/Statistikdatabas/Statistikdatabas__Film%20p%c3%a5%20bio__Annan%20statistik/FPB_REGION.Px/table/tableViewLayout1/
  
  # url
  url <- 'https://statistik.kulturanalys.se:443/api/v1/sv/Statistikdatabas/Film på bio/Annan statistik/FPB_REGION.Px'
  
  # kikar på metadata
  meta <- pxweb_get(url)
  value_names <- meta$variables[[3]]$values
  kol_namn <- meta$variables[[3]]$valueTexts
  
  # query
  pxweb_query_list <- list('region' = '*', # ar ut alla regioner
                           'year' = '*',
                           'tablecontent' =value_names)
  
  # Tar hem data och gör till df
  px_data <- pxweb_get(url=url, pxweb_query_list)
  
  # Bygg dataframe
  region_bio <- do.call(rbind, lapply(px_data$data, function(x) {
    # x$values är lista med alla mått
    vals <- sapply(x$values, function(v) v)  # platta ut listan
    data.frame(
      year = x$text[[1]],
      region = x$text[[2]],
      t(vals),           # transponera så det blir kolumner
      stringsAsFactors = FALSE
    )
  }))
  
  # Sätt korrekta kolumnnamn
  colnames(region_bio)[3:(2+length(kol_namn))] <- kol_namn
  
  # Konvertera alla mått till numeriskt
  region_bio[kol_namn] <- lapply(region_bio[kol_namn], as.numeric)
  
  
  write.csv(region_bio, "Data/df_region_bio.csv", row.names = F)
  print('Nedladdning av "df_region_bio.csv" har genomförts')
  
  
  
}
