##########################  Antal födda och döda:   Inrikes och utrikes flytt: Invandring och utvandring #####################
func_foddadoda_inut_flytt <- function(){
  ########## Antal födda
  # framskrivning födda , döda inrikes utrikes flytt, in- och utvandring
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0401__BE0401A/BefProgOsiktRegN/
  url <- pxweb_url("TAB698")
  
  px_get_list <- list(Region = kommunkod,
                      Kon = '*',
                      Alder = '*',
                      ContentsCode = '*',
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_fram <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_fram <- na.omit(df_fram)

  df_fram <- df_fram |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

  df_fram <- df_fram %>% filter(år > min(år)) # tar bort senaste året så det ej överlappar med annan data
  
  
  # Födda och döda bakåt i tiden
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101G/BefforandrKvRLK/
  url <- pxweb_url("TAB5169")
  
  px_get_list <- list(Region = kommunkod,
                      Forandringar='*',
                      Period = 'hel', 
                      Kon = c('1', '2'),
                      ContentsCode = '*',
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  df_bak <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_bak <- na.omit(df_bak)

  df_bak <- df_bak |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )
  
  df_bak <- df_bak %>% filter(år > 2002 ) %>% pivot_wider(names_from =förändringar,values_from = `Antal personer` ) %>% 
    select(region, kön, år, födda, döda) %>% rename('Tot_födda'=födda, 'Tot_döda'=döda)
  
  foddod_fram <- df_fram %>% group_by(region, kön, år) %>%  select(region, kön, år, Födda, Döda) %>% 
    summarise(Tot_födda = sum(Födda), Tot_döda = sum(Döda), .groups = 'drop')
  
  df_foddadoda <- rbind(foddod_fram ,df_bak)
  
  write.csv(df_foddadoda, "Data/df_foddadoda.csv", row.names = F)
  
  print('Nedladdning av "df_foddadoda" genomfördes')
  
  # laddar data och gör till rätt format
  # in och utflytt, in och utvandring
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101J/Flyttningar97/
  url <- pxweb_url("TAB1212")
  
  px_get_list <- list(Region = kommunkod,
                      Alder='*',
                      Kon = '*',
                      ContentsCode = c("BE0101AX","BE0101AY","BE0101A2" ,"BE0101A3"),
                      Tid = '*')
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  df_bak <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_bak <- na.omit(df_bak)

  df_bak <- df_bak |> 
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )

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


func_foddadoda_inut_flytt()
