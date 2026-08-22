# Markanvändning 
func_markanvandning <- function(){
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__MI__MI0803__MI0803A/MarkanvN/
  url <- pxweb_url("TAB5118")
  
  
  pxweb_query_list <- list(
    "Region" = kommunkod, # Uppsala läns kommuner
    "Markanvandningsklass" = c("16", "213", "3", "421", "811", "911"), 
    'ContentsCode' = '*',
    "Tid" = c("*")    # Årtal att hämta data för
  )
  
  px_data <- pxweb_get(
    url = url,
    query = pxweb_query_list
  )
  
  # Steg 4: Omvandla data till ett data.frame för enklare hantering i R
  px_markanvandning <- as.data.frame(px_data, column.name.type = "text", variable.value.type = "text")
  px_markanvandning <- na.omit(px_markanvandning)
  
  # Omstrukturera data så att markanvändningsklasser blir kolumner
  px_markanvandning <- px_markanvandning %>%
    pivot_wider(names_from = "markanvändningsklass", values_from = "Markanvändningen, hektar")
  
  
  # Skapa nya andelsvariabler för varje markanvändningsklass baserat på 'total jordbruksmark'
  px_markanvandning <- px_markanvandning %>%
    mutate(
      `andel total jordbruksmark` = `total jordbruksmark` / `total landareal`,
      `andel total skogsmark` = `total skogsmark` / `total landareal`,
      `andel bebyggd och anlagd mark` = `bebyggd och anlagd mark ` / `total landareal`,
      `andel öppen myrmark` = `öppen myrmark` / `total landareal`,
      `andel övrig mark` = `övrig mark` / `total landareal`
    )
  
  write.csv(px_markanvandning, "Data/df_markanvandning.csv", row.names = F)
  
  print('Nedladdning av "df_markanvandning.csv" har genomförts')
}