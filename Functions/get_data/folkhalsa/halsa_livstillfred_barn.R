# Självrapporterad hälsa, barn

func_df_sjalvrapporterad <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__Halsoutfall__02Pyskhals__02.06psykbesvZelev/halbBaReg.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/Halsoutfall/02Pyskhals/02.06psykbesvZelev/halbBaReg.px'
  
  # Metadata
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      'Hälsobesvär' = '*',
                      Kön = c('1','2'),
                      "Andel och konfidensintervall" = '*',
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_psykist <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_psykist <- df_psykist %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                           names_from = `Andel och konfidensintervall`, 
                                           values_from = `Psykosomatiska besvär, barn efter kön, region och år`)
  
  # Tar bort siffror från namn
  df_psykist$Region <- gsub("[0-9]+ *","",df_psykist$Region)
  
  
  # sparar data med variabler:
  write.csv(df_psykist, "Data/df_sjalvrapporterad.csv", row.names = F)
  
  print('Nedladdning av "df_sjalvrapporterad.csv" genomfördes')
}



func_df_livstillfresstallelse <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__Halsoutfall__02Pyskhals__02.02tillfredsZelev/tillfrBaReg.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/Halsoutfall/02Pyskhals/02.02tillfredsZelev/tillfrBaReg.px'
  
  # Metadata
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      'Livstillfredsställelse' = '*',
                      Kön = c('1','2'),
                      "Andel och konfidensintervall" = '*',
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_psykist <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_psykist <- df_psykist %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                           names_from = `Andel och konfidensintervall`, 
                                           values_from = `Livstillfredsställelse, barn efter kön, region och år`)
  
  # Tar bort siffror från namn
  df_psykist$Region <- gsub("[0-9]+ *","",df_psykist$Region)
  
  
  # sparar data med variabler:
  write.csv(df_psykist, "Data/df_livstillfresstallelse.csv", row.names = F)
  
  print('Nedladdning av "df_livstillfresstallelse.csv" genomfördes')
}