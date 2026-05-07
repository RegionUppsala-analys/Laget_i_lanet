
# Tandhälsa
func_tandhalsa <- function(){# https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__Z_ovrigdata__HLVkn__Tandhals/tanhal.px/
  url <-'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/Z_ovrigdata/HLVkn/Tandhals/tanhal.px' 
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      Tandhälsa='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_tand <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_tand <- df_tand %>% pivot_wider(id_cols= c("Region", "Kön", "År","Tandhälsa"), 
                                     names_from = `Andel och konfidensintervall`, 
                                     values_from = `Andel med dålig respektive bra tandhälsa`)
  
  # Tar bort siffror från namn
  df_tand$Region <- gsub("[0-9]+ *","",df_tand$Region)
  
  # sparar data med variabler:
  write.csv(df_tand, "Data/df_tandhalsa.csv", row.names = F)
  
  print('Nedladdning av "df_tandhalsa.csv" genomfördes')
  
  
}


# Avstått tandläkarbesök
func_df_tandhalsa_avsta <- function(){# https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__Z_ovrigdata__HLVkn__Tandhals/tlejsok.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/Z_ovrigdata/HLVkn/Tandhals/tlejsok.px'
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Avstått tandläkarvård`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_tand <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Gör till wide
  df_tand <- df_tand %>% pivot_wider(id_cols= c("Region", "Kön", "År","Avstått tandläkarvård"), 
                                     names_from = `Andel och konfidensintervall`, 
                                     values_from = `Tandläkarvård, avstått trots behov`)
  
  # Tar bort siffror från namn
  df_tand$Region <- gsub("[0-9]+ *","",df_tand$Region)
  
  # sparar data med variabler:
  write.csv(df_tand, "Data/df_tandhalsa_avsta.csv", row.names = F)
  
  print('Nedladdning av "df_tandhalsa_avsta.csv" genomfördes')
  
  
  
}
