
# Diabetes typ 2


func_diabetes <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__Halsoutfall__06Kronisk__06.02.01diabetfall/DiabetfallReg.px/table/tableViewLayout1/
  url<- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/Halsoutfall/06Kronisk/06.02.01diabetfall/DiabetfallReg.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Ålder`='*',
                      Kön = c('1','2'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") 
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_diabetes.csv", row.names = F)
  
  print('Nedladdning av "df_diabetes.csv" genomfördes')
  
}


# sjukdomar och besvär

func_sjukdom_besvar <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__B_HLV__bFyshals__bbdFyshalsovrigt/hlv1sjuxreg.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/B_HLV/bFyshals/bbdFyshalsovrigt/hlv1sjuxreg.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      `Sjukdomar och besvär`='*',
                      `Andel och konfidensintervall`='*',
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_still <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text") 
  
  # Gör till wide
  df_still <- df_still %>% pivot_wider(id_cols= c("Region", "Kön", "År","Sjukdomar och besvär"), 
                                       names_from = `Andel och konfidensintervall`, 
                                       values_from = `Fysisk hälsa, diabetes efter region, kön och år`)
  
  # Tar bort siffror från namn
  df_still$Region <- gsub("[0-9]+ *","",df_still$Region)
  
  # sparar data med variabler:
  write.csv(df_still, "Data/df_sjukdomar_besvar.csv", row.names = F)
  
  print('Nedladdning av "df_sjukdomar_besvar.csv" genomfördes')
  
}

