# Suicid 

func_suicid <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__Halsoutfall__02Pyskhals__02.07.02SuicidVux/SuicidVuxReg.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/Halsoutfall/02Pyskhals/02.07.02SuicidVux/SuicidVuxReg.px'
  
  # Metadata
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = kommunkod,
                      Kön = c('1','2'),
                      Ålder = '*',
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_psykist <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_psykist <- df_psykist %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                           names_from =  Ålder, 
                                           values_from = `Säkra självmord, region`)
  
  # Tar bort siffror från namn
  df_psykist$Region <- gsub("[0-9]+ *","",df_psykist$Region)
  
  
  # sparar data med variabler:
  write.csv(df_psykist, "Data/df_suicid.csv", row.names = F)
  
  print('Nedladdning av "df_suicid.csv" genomfördes')
}

func_suicid_region <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__Halsoutfall__02Pyskhals__02.07.02SuicidVux/SuicidVuxReg.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/Halsoutfall/02Pyskhals/02.07.02SuicidVux/SuicidVuxReg.px'
  
  # Metadata
  meta <- pxweb_get(url)
  
  px_get_list <- list(Region = riket_narliggande,
                      Kön = c('1','2'),
                      Ålder = '*',
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_psykiskt <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_psykiskt <- df_psykiskt %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                           names_from =  Ålder, 
                                           values_from = `Säkra självmord, region`)
  
  # Tar bort siffror från namn
  df_psykiskt$Region <- gsub("[0-9]+ *","",df_psykiskt$Region)
  
  # sparar data med variabler:
  write.csv(df_psykiskt, "Data/df_suicid_region.csv", row.names = F)
  
  print('Nedladdning av "df_suicid_region.csv" genomfördes')
}