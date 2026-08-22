## Anställda med arbetsplats i regionen (dagbef) efter region, yrke (3-siffrig SSYK 2012), näringsgren SNI2007 (grov nivå) och kön. Baserat på BAS. År 2020 - 2023
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AM__AM0208__AM0208D/YREG56BAS/

func_df_arbetsplats <- function(){
  url <- pxweb_url("TAB4436")
  meta <- pxweb_get(url)
  regioner <- meta$variables[[1]]$values
  
  # Välj endast regioner som börjar med "03"
  uppsala_koder <- regioner[startsWith(regioner, lanskod)]  
  senaste_aret <- max(as.integer(meta$variables[[6]]$values))
  
  
  px_get_list <- list(Region = uppsala_koder,
                      SNI2007 = '*',
                      Yrke2012 = '*',
                      Kon = '*',
                      ContentsCode = '*',
                      Tid = as.character(senaste_aret))
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_arbetsplats <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_arbetsplats <- na.omit(df_arbetsplats)

  df_arbetsplats <- df_arbetsplats |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  df_arbetsplats <- df_arbetsplats %>% group_by(region,kön, `näringsgren SNI 2007`) %>% 
    summarize(Antal = sum(Antal), .groups = 'drop')
  
  write.csv(df_arbetsplats, "Data/df_arbetsplats.csv", row.names = F)
  
  print('Nedladdning av "df_arbetsplats.csv" genomfördes')  
}