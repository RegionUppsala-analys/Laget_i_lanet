

## Arbetsmarknadsvariabler efter kommun, kön, utbildningsnivå och bakgrundsvariabel. År 2022 - 2023
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AA__AA0003__AA0003B/IntGr1KomUtbBAS/


func_df_syssel_utb <- function(){
  
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/AA/AA0003/AA0003B/IntGr1KomUtbBAS'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6383')
  
  meta <- pxweb_get(url)
  regioner <- meta$variables[[1]]$values
  
  # Välj endast regioner som börjar med "03"
  uppsala_koder <- regioner[startsWith(regioner, lanskod)]  
  senaste_aret <- max(as.integer(meta$variables[[6]]$values))
  
  
  px_get_list <- list(Region = uppsala_koder,
                      UtbNiv = '*',
                      BakgrVar = c("SE"    ,  "NEXS"   , "EUEESXN", "VXEUEES" ,"SAMUTF"),
                      Kon = c('1','2'),
                      ContentsCode = '*',
                      Tid = as.character(senaste_aret))
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_syssel_utb <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  # fixar NA till 0
  df_syssel_utb <- df_syssel_utb %>%
    mutate(across(where(is.numeric), ~ replace_na(.x, 0)))
  
  write.csv(df_syssel_utb, "Data/df_syssel_utb.csv", row.names = F)
  print('Nedladdning av "df_syssel_utb.csv" genomfördes')  
}