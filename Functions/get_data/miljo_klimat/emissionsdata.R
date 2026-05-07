############### Emissionsdatabasen 
# Växthusgaser totalt
func_df_emissions_data <- function(){
  # Definiera URL och sökväg för nedladdning
  url <- "https://nationellaemissionsdatabasen.smhi.se/api/getexcelfile/?county=03&municipality=0&sub=GGT"
  destfile <- "Data/emissionsdata.xlsx"
  
  # Ladda ner filen
  download.file(url, destfile, mode = "wb")
  
  # Läs in data med skip = 5 för att få årtalen som kolumnnamn för emissionsdata
  emissions_data <- read_excel(destfile, sheet = 1, skip = 5)
  
  # Justera kolumnnamnen för de första fyra kolumnerna
  colnames(emissions_data)[1:4] <- c("Huvudsektor", "Undersektor", "Län", "Kommun")
  
  # Ta bort den första raden
  emissions_data <- emissions_data[-1, ]
  
  write.csv(emissions_data, "Data/df_emissions_data.csv", row.names = F)
  print('Nedladdning av "df_emissions_data.csv" har genomförts')
}