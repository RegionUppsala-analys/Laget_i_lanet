func_foddadoda <- function(){
  ########## Antal födda
  # framskrivning födda , döda inrikes utrikes flytt, in- och utvandring
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0401__BE0401A/BefProgOsiktRegN/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0401/BE0401A/BefProgOsiktRegN'
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB698')
  
  px_get_list <- list(Region = kommunkod,
                      Kon = '*',
                      Alder = '*',
                      ContentsCode = '*',
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_fram <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  df_fram <- df_fram %>% filter(år > min(år)) # tar bort senaste året så det ej överlappar med annan data
  
  
  # Födda och döda bakåt i tiden
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101G/BefforandrKvRLK/
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101G/BefforandrKvRLK'
  
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB5169')
  
  px_get_list <- list(Region = kommunkod,
                      Forandringar='*',
                      Period = 'hel', 
                      Kon = c('1', '2'),
                      ContentsCode = '*',
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  df_bak <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  df_bak <- df_bak %>% filter(år > 2002 ) %>% pivot_wider(names_from =förändringar,values_from = `Antal personer` ) %>% 
    select(region, kön, år, födda, döda) %>% rename('Tot_födda'=födda, 'Tot_döda'=döda)
  
  foddod_fram <- df_fram %>% group_by(region, kön, år) %>%  select(region, kön, år, Födda, Döda) %>% 
    summarise(Tot_födda = sum(Födda), Tot_döda = sum(Döda), .groups = 'drop')
  
  df_foddadoda <- rbind(foddod_fram ,df_bak)
  
  write.csv(df_foddadoda, "Data/df_foddadoda.csv", row.names = F)
  
  print('Nedladdning av "df_foddadoda" genomfördes')
}