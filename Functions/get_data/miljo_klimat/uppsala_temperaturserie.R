######## Här måste manuellt ändra 2022 i url för att ladda ned ny data #############
func_uppsala_tm_1722_2022 <- function(ar="2022"){
  
  
  # URL till ZIP-filen
  url <- paste0("https://www.smhi.se/download/18.53cdce23194f389da053a4e/1740398333056/uppsala_tm_1722-",ar,".zip")
  
  # Ange sökvägen där filen ska sparas
  destfile <- "Data/Uppsalas_temperaturserie.zip"
  
  # Ladda ner ZIP-filen
  GET(url, write_disk(destfile, overwrite = TRUE))
  
  # Extrahera ZIP-filen
  unzip(destfile, exdir = "Data")
  
  # Visa innehållet i den extraherade mappen
  #list.files("Uppsalas_temperaturserie")
  
  print('Nedladdning av "uppsala_tm_1722-2022" har genomförts')
}