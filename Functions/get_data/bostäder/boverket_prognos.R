######### Boverket prognos ########

############ Byt ut året i länken för ny data
# https://www.boverket.se/sv/om-boverket/oppna-data/byggbehovsberakning/
boverket_prognos <- function(ar=2025){
  year <- ar
  url <- paste0('https://www.boverket.se/contentassets/8cac305f717845d39c4e471d761f176f/beraknat-bostadsbyggnadsbehov-',year,'-05-27.xlsx')
  
  download.file(url, destfile = 'Data/boverket_prognos.xlsx', mode = "wb")
  
  print('Nedladdning av "boverket_prognos.xlsx" har gått igenom')
}