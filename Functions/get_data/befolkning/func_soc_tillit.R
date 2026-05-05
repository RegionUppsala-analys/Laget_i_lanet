############ Sociala relationer och tillit ###########

source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")


func_soc_tillit <- function(){
  tillit <- search_and_fetch_kolada("Sociala relationer och tillit - Kommunindex", match=0.01)
  tillit <- tillit %>% filter(title %in% c("Sociala relationer och tillit - Kommunindex", 
                                           "Sociala relationer och tillit – Kommunindex Kvinnor",
                                           "Sociala relationer och tillit – Kommunindex Män"))
  
  write.csv(tillit, "Data/df_tillit.csv", row.names = F)
  print('Nedladdning av "tillit.csv" har genomförts')
}
