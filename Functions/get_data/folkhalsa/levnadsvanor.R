###### Levnadsvanor #######

# Alkohol


func_df_alkohol <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__6_Levanor__01Begrans__06.04alkrisk/alkriskyreg.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/6_Levanor/01Begrans/06.04alkrisk/alkriskyreg.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Alkoholkonsumtion`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") 
  
  # Gör till wide
  df_still <- df_still %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                       names_from = `Andel och konfidensintervall`, 
                                       values_from = `Alkoholkonsumtion, andel efter region, kön och år`)
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_alkohol.csv", row.names = F)
  
  print('Nedladdning av "df_alkohol.csv" genomfördes')
  
}


# frukt och grönt


func_frukt_gront <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__Z_ovrigdata__HLVkn__Mat/fruktgront.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/Z_ovrigdata/HLVkn/Mat/fruktgront.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Frukt och grönt`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") 
  
  # Gör till wide
  df_still <- df_still %>% pivot_wider(id_cols= c("Region", "Kön", "År","Frukt och grönt"), 
                                       names_from = `Andel och konfidensintervall`, 
                                       values_from = `Intag av frukt och grönt efter kön, region och år`)
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_frukt_gront.csv", row.names = F)
  
  print('Nedladdning av "df_frukt_gront.csv" genomfördes')
  
}


# tobak

func_tobak <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__Z_ovrigdata__HLVkn__Tobak/tobak.px/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/Z_ovrigdata/HLVkn/Tobak/tobak.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Tobakskonsumtion`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") 
  
  # Gör till wide
  df_still <- df_still %>% pivot_wider(id_cols= c("Region", "Kön", "År","Tobakskonsumtion"), 
                                       names_from = `Andel och konfidensintervall`, 
                                       values_from = `Användning av tobak`)
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_rokning.csv", row.names = F)
  
  print('Nedladdning av "df_rokning.csv" genomfördes')
  
}



# Sötad dryck

func_socker_dryck <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__6_Levanor__01Begrans__06.13lask/laskyreg.px/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/6_Levanor/01Begrans/06.13lask/laskyreg.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Intag av sötad dryck`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") 
  names(df_still) <- make.names(names(df_still), unique = TRUE)
  # Gör till wide
  df_still <- df_still %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                       names_from = `Andel.och.konfidensintervall`, 
                                       values_from = `Intag.av.sötad.dryck.1`)
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_dryck.csv", row.names = F)
  
  print('Nedladdning av "df_dryck.csv" genomfördes')
  
}



# spelande
func_spelande <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__6_Levanor__01Begrans__06.10riskspel/riskspelyreg.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/6_Levanor/01Begrans/06.10riskspel/riskspelyreg.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Riskabelt spelande`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") 
  
  # Gör till wide
  df_still <- df_still %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                                       names_from = `Andel och konfidensintervall`, 
                                       values_from = `Andel som spelat de senaste 12 månaderna efter region, kön och år`)
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_spel.csv",row.names = F)
  
  print('Nedladdning av "df_spel.csv" genomfördes')
  
}



# Narkotika
func_narkotika <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__Z_ovrigdata__HLVkn__Narkotika/narkotika4.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/Z_ovrigdata/HLVkn/Narkotika/narkotika4.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Frekvens`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") 
  
  # Gör till wide
  df_still <- df_still %>% pivot_wider(id_cols= c("Region", "Kön", "År","Frekvens"), 
                                       names_from = `Andel och konfidensintervall`, 
                                       values_from = `Användning av annan narkotika`)
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_narkotika.csv",row.names = F)
  
  print('Nedladdning av "df_narkotika.csv" genomfördes')
  
}

# Cannabis
func_cannabis <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__Z_ovrigdata__HLVkn__Narkotika/cannabis4.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/Z_ovrigdata/HLVkn/Narkotika/cannabis4.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Använt cannabis`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") 
  
  # Gör till wide
  df_still <- df_still %>% pivot_wider(id_cols= c("Region", "Kön", "År","Använt cannabis"), 
                                       names_from = `Andel och konfidensintervall`, 
                                       values_from = `Användning av cannabis (hasch, hasch12, hasch30)`)
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_cannabis.csv",row.names = F)
  
  print('Nedladdning av "df_cannabis.csv" genomfördes')
  
}
