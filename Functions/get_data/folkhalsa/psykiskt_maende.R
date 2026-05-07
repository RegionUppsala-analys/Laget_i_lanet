# Psykiskt välbefinnande 
func_psykiskt <- function(){
  # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__Halsoutfall__02Pyskhals__02.01warwick/warwickyreg.px/table/tableViewLayout1/
  url <- "https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/Halsoutfall/02Pyskhals/02.01warwick/warwickyreg.px"
  
  # Metadata
  meta <- pxweb_get(url)
  
  px_get_list <- list(Region = riket_narliggande,
                      'Psykiskt välbefinnande' = '*',
                      Kön = c('01','02'),
                      'Andel och konfidensintervall' = '*',
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_psykist <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_psykist <- df_psykist %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                           names_from = `Andel och konfidensintervall`, 
                                           values_from = `Andel med gott psykiskt välbefinnande`)
  
  # Tar bort siffror från namn
  df_psykist$Region <- gsub("[0-9]+ *","",df_psykist$Region)
  
  
  # sparar data med variabler:
  write.csv(df_psykist, "Data/df_psykiskt.csv", row.names = F)
  
  print('Nedladdning av "df_psykist.csv" genomfördes')
  
}




# Psykisk påfrestning
func_df_psykisk_halsa <- function(){
  # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__Halsoutfall__02Pyskhals__02.03psykessler6/psykessler6yreg.px/table/tableViewLayout1/
  url <- "https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/Halsoutfall/02Pyskhals/02.03psykessler6/psykessler6yreg.px"
  # Metadata
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      'Psykisk hälsa' = '*',
                      Kön = c('01','02'),
                      'Andel och konfidensintervall' = '*',
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_psykist <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_psykist <- df_psykist %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                           names_from = `Andel och konfidensintervall`, 
                                           values_from = `Andel med psykisk påfrestning`)
  
  # Tar bort siffror från namn
  df_psykist$Region <- gsub("[0-9]+ *","",df_psykist$Region)
  
  
  # sparar data med variabler:
  write.csv(df_psykist, "Data/df_psykisk_halsa.csv", row.names = F)
  
  print('Nedladdning av "df_psykisk_halsa.csv" genomfördes')
  
}


# Psykiska variabler
func_df_psykiska_variabler <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__B_HLV__dPsykhals/hlv1psyxreg.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/B_HLV/dPsykhals/hlv1psyxreg.px'
  
  # Metadata
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      "Psykisk hälsa"= '*',
                      Kön = c('01','02'),
                      "Andel och konfidensintervall" = '*',
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_psykist <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")%>%
    filter(!is.na(`Psysisk hälsa, nedsatt psykiskt välbefinnande och svår ångest efter region, kön och år` )) 
  
  # Gör till wide
  df_psykist <- df_psykist %>%
    pivot_wider(id_cols= c("Region", "Kön", "År",`Andel och konfidensintervall`), 
                names_from =  `Psykisk hälsa`, 
                values_from = `Psysisk hälsa, nedsatt psykiskt välbefinnande och svår ångest efter region, kön och år`)
  
  # Tar bort siffror från namn
  df_psykist$Region <- gsub("[0-9]+ *","",df_psykist$Region)
  
  
  # sparar data med variabler:
  write.csv(df_psykist, "Data/df_psykiska_variabler.csv", row.names = F)
  
  print('Nedladdning av "df_psykiska_variabler.csv" genomfördes')
}


# Tillit 
func_df_tillit_till_andra <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__7_Kontroll__02Civil__07.05lita/litaYreg.px/
  
  url <- "https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/7_Kontroll/02Civil/07.05lita/litaYreg.px"
  
  # Metadata
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      'Tillit' = '*',
                      Kön = c('01','02'),
                      "Andel och konfidensintervall" = '*',
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_psykist <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_psykist <- df_psykist %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                           names_from = `Andel och konfidensintervall`, 
                                           values_from = `Andel som saknar tillit till andra`)
  
  # Tar bort siffror från namn
  df_psykist$Region <- gsub("[0-9]+ *","",df_psykist$Region)
  
  
  # sparar data med variabler:
  write.csv(df_psykist, "Data/df_tillit_till_andra.csv", row.names = F)
  
  print('Nedladdning av "df_tillit_till_andra.csv" genomfördes')
  
}



# emotionellt stöd 

func_emotionellt_stod <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__Z_ovrigdata__HLVkn__Socrel/emstod.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/Z_ovrigdata/HLVkn/Socrel/emstod.px'
  
  # Metadata
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      'Emotionellt stöd' = '*',
                      Kön = c('01','02'),
                      "Andel och konfidensintervall" = '*',
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_psykist <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_psykist <- df_psykist %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                           names_from = `Andel och konfidensintervall`, 
                                           values_from = `Andel som saknar emotionellt stöd efter region, år och kön`)
  
  # Tar bort siffror från namn
  df_psykist$Region <- gsub("[0-9]+ *","",df_psykist$Region)
  
  
  # sparar data med variabler:
  write.csv(df_psykist, "Data/emotionellt_stod.csv", row.names = F)
  
  print('Nedladdning av "emotionellt_stod.csv" genomfördes')
  
  
}



# Praktiskt stöd 

func_praktiskt_stod <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__Z_ovrigdata__HLVkn__Socrel/praksto.px/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/Z_ovrigdata/HLVkn/Socrel/praksto.px'
  
  # Metadata
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      'Praktiskt stöd' = '*',
                      Kön = c('01','02'),
                      "Andel och konfidensintervall" = '*',
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_psykist <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_psykist <- df_psykist %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                           names_from = `Andel och konfidensintervall`, 
                                           values_from = `Andel som saknar praktiskt stöd`)
  
  # Tar bort siffror från namn
  df_psykist$Region <- gsub("[0-9]+ *","",df_psykist$Region)
  
  
  # sparar data med variabler:
  write.csv(df_psykist, "Data/praktiskt_stod.csv", row.names = F)
  
  print('Nedladdning av "praktiskt_stod.csv" genomfördes')
  
  
}