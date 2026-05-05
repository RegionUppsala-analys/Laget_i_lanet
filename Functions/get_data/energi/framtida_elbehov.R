########### Elbehov Energimyndigheten ############
# https://www.energimyndigheten.se/energisystem-och-analys/samhallsbyggnad-och-energiplanering/framtida-elbehov-i-ditt-lan/

func_framtida_elbehov <- function(){
  url <- 'https://www.energimyndigheten.se/4a4f58/globalassets/energisystem-och-analys/langsiktiga-scenarier/framtida-elbehov-pa-lansniva.xlsx'
  
  output_file <- "Data/framtida_elbehov.xlsx"
  
  response <- GET(url, write_disk(output_file, overwrite = TRUE))
  
  
  print('Nedladdning av "framtida_elbehov.xlsx" har genomförts')
  
}

