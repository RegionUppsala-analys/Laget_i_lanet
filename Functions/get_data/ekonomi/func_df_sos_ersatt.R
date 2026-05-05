## som försörjs med sociala ersättningar och bidrag efter region och kön. Månad 2014M01 - 2024M12

# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__HE__HE0112/HE0000T02N2/
func_df_sos_ersatt <- function(){
  url <- 'https://api.scb.se/OV0104/v1/doris/sv/ssd/START/HE/HE0112/HE0000T02N2'
  
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB1386')
  
  meta <- pxweb_get(url)
  
  latest_year <- tail(meta[['variables']][[5]][['values']],12) 
  px_get_list <- list(Region = kommunkod,
                      Kon = c('1' ,'2'),
                      Aldersgrupp = '20-65',
                      ContentsCode = '*',
                      Tid = latest_year)
  
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  sos_ersatt <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  
  sos_ersatt <- sos_ersatt  %>% # medelvärde över senaste året, avrundar uppåt
    group_by(region, kön) %>%
    summarise(
      across(
        where(is.numeric) & !all_of("Andel av befolkningen"),
        ~ ceiling(mean(.x, na.rm = TRUE))
      ),
      `Andel av befolkningen` = round(mean(`Andel av befolkningen`, na.rm = TRUE), 1),
      .groups = 'drop'
    )
  
  write.csv(sos_ersatt, "Data/df_sos_ersatt.csv", row.names = F)
  
  print('Nedladdning av "df_sos_ersatt.csv" genomfördes')
}