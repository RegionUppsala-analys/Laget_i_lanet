# laddar data och gör till rätt format
# in och utflytt, in och utvandring
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101J/Flyttningar97/

func_inut_flytt <- function(){
 
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101J/Flyttningar97'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB1212')
  
  px_get_list <- list(Region = kommunkod,
                      Alder='*',
                      Kon = '*',
                      ContentsCode = c("BE0101AX","BE0101AY","BE0101A2" ,"BE0101A3"),
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  df_bak <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  df_bak <- df_bak %>% filter(år > 2002, grepl("totalt", ålder, ignore.case = TRUE)) %>% group_by(region, kön, år) %>%
    summarise(Invandring = sum(Invandringar), Utvandring  = sum(Utvandringar),
              Inrikes_inflyttning = sum(`Inrikes inflyttningar`),
              Inrikes_utflyttning = sum(`Inrikes utflyttningar`), .groups = 'drop')
  
  flytt_fram <- df_fram %>% group_by(region, kön, år) %>%  select(region, kön, år,
                                                                  `Inrikes inflyttning`, `Inrikes utflyttning`, Invandring ,Utvandring) %>% 
    summarise(Invandring = sum(Invandring), Utvandring  = sum(Utvandring),
              Inrikes_inflyttning = sum(`Inrikes inflyttning`),
              Inrikes_utflyttning = sum(`Inrikes utflyttning`), .groups = 'drop')
  
  
  df_inut_flytt <- rbind(df_bak,flytt_fram)
  
  write.csv(df_inut_flytt, "Data/df_inut_flytt.csv", row.names = F)
  
  print('Nedladdning av "df_inut_flytt.csv" genomfördes')
}
