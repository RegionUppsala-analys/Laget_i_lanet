
func_boverket <- function(ar="2025"){# <- Här
  
  url <- paste0('https://www.boverket.se/contentassets/fe1716843d2147edb3c38cd4ea7df7b9/laget-pa-bostadsmarknaden-och-bostadsbyggande---bme-',
                ar, # <- Här
                '.xlsx') 
  
  # Download the file
  download.file(url, destfile = 'Data/boverket.xlsx', mode = "wb")
  
  print('Nedladdning av "boverket.xlsx" har gått igenom')
}
