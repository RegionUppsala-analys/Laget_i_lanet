# Femårig livslängdstabell efter län, utbildningsnivå, kön och ålder. Årsintervall 2012-2016 - 2020-2024

func_df_livslangd <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0701/LivslUtbLan/
  url <- pxweb_url("TAB4879")

  px_get_list <- list(
    Region = c(riket_narliggande),
    UtbildningsNiva = "*",
    Kon = c("020","030"),
    Alder = "*",
    ContentsCode = "*",
    Tid = "*"
  )

  px_get <- pxweb_get(url, px_get_list)

  df_livslangd <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_livslangd <- na.omit(df_livslangd)


  df_livslangd <- df_livslangd |>
  tidyr::pivot_wider(             
      names_from = "tabellinnehåll",
      values_from = "value",
  )
  
  # sparar data med variabler:
  write.csv(df_livslangd, "Data/df_livslangd.csv", row.names = F)
  
  print('Nedladdning av "df_livslangd.csv" genomfördes')
}




func_livslangd_kom <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__Halsoutfall__01Overgrip__01.03medlivs/MedlivsYreg.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/Halsoutfall/01Overgrip/01.03medlivs/MedlivsYreg.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = kommunkod,
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_livslangd <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Tar bort siffror från namn
  df_livslangd$Region <- gsub("[0-9]+ *","",df_livslangd$Region)
  
  # sparar data med variabler:
  write.csv(df_livslangd, "Data/df_livslangd_kom.csv", row.names = F)
  
  print('Nedladdning av "df_livslangd_kom.csv" genomfördes')
}



func_livslangd_region <- function(){ # https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/pxweb/sv/A_Folkhalsodata/A_Folkhalsodata__A_Mo8__Halsoutfall__01Overgrip__01.03medlivs/MedlivsYreg.px/table/tableViewLayout1/
  url <- 'https://fohm-app.folkhalsomyndigheten.se/Folkhalsodata/api/v1/sv/A_Folkhalsodata/A_Mo8/Halsoutfall/01Overgrip/01.03medlivs/MedlivsYreg.px'
  
  # Get metadata for the table
  meta <- pxweb_get(url = url)
  
  
  px_get_list <- list(Region = riket_narliggande,
                      Kön = c('01','02'),
                      År = '*')
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_livslangd <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # Tar bort siffror från namn
  df_livslangd$Region <- gsub("[0-9]+ *","",df_livslangd$Region)
  
  # sparar data med variabler:
  write.csv(df_livslangd, "Data/df_livslangd_region.csv", row.names = F)
  
  print('Nedladdning av "df_livslangd_region.csv" genomfördes')
}
