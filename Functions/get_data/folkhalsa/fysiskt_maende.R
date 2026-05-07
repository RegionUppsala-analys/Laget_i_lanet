##### Folkhälsomyndigheten fysisk########

# aktivitet
func_f_fysisk_aktivitet <- function(){# https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__6_Levanor__02Okad__06.18fysak/fysakyreg.px/
  url <-'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/6_Levanor/02Okad/06.18fysak/fysakyreg.px' 
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Fysisk aktivitet`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_tand <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_tand <- df_tand %>% pivot_wider(id_cols= c("Region", "Kön", "År","Fysisk aktivitet"), 
                                     names_from = `Andel och konfidensintervall`, 
                                     values_from = `Andel fysiskt aktiva (30 min/dag)`)
  
  # Tar bort siffror från namn
  df_tand$Region <- gsub("[0-9]+ *","",df_tand$Region)
  
  # sparar data med variabler:
  write.csv(df_tand, "Data/df_fysisk_aktivitet.csv", row.names = F)
  
  print('Nedladdning av "df_fysisk_aktivitet.csv" genomfördes')
  
  
}



# Stillasittande

func_stillasittande <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__Z_ovrigdata__HLVkn__Fysak/stilla.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/Z_ovrigdata/HLVkn/Fysak/stilla.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Stillasittande`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") %>% 
    filter(År >= "2017-2020")
  
  # Gör till wide
  df_still <- df_still %>% pivot_wider(id_cols= c("Region", "Kön", "År","Stillasittande"), 
                                       names_from = `Andel och konfidensintervall`, 
                                       values_from = `Andel med stillastittande fritid`)
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_stillasittande.csv", row.names = F)
  
  print('Nedladdning av "df_stillasittande.csv" genomfördes')
  
}


# Obesitas

func_df_obesitas <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__B_HLV__bFyshals__bbeFyshalsvikt/hlv1bmixreg.px/
  url<- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/B_HLV/bFyshals/bbeFyshalsvikt/hlv1bmixreg.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Viktstatus (BMI)`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") 
  
  # Gör till wide
  df_still <- df_still %>% pivot_wider(id_cols= c("Region", "Kön", "År","Viktstatus (BMI)"), 
                                       names_from = `Andel och konfidensintervall`, 
                                       values_from = `Levnadsvanor, vikt (BMI) efter region, kön och år`)
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_obesitas.csv", row.names = F)
  
  print('Nedladdning av "df_obesitas.csv" genomfördes')
  
}

