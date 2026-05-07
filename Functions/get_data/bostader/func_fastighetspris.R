source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")

### Fastighetspriser per kommun och år

func_fastighetspris <- function(){
  df <- search_and_fetch_kolada("Fastighetspris",kommunkod=kommunkod)
  
  df <- df %>% filter(year > 2004, title !="Fastighetspris småhus, tkr",
                      title %in% c("Fastighetspris bostadsrätt, kr/kvm",
                                   "Fastighetspris fritidshus, kr/kvm" ))
  
  write.csv(df, "Data/fastighetspris.csv", row.names = F)
  
  print('Nedladdning av "fastighetspris.csv" har gått igenom')
}