
source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")

####### Kolada trångboddhet #########
func_trandboddhet <- function(){
  df <- search_and_fetch_kolada("Trångboddhet",kommunkod=c("0003",kommunkod))
  
  df <- df %>% filter(gender != 'T' ,
                      title %in% c("Trångboddhet i flerbostadshus, enligt norm 2, andel (%)",
                                   "Trångboddhet i flerbostadshus, enligt norm 3, andel (%)"))
  
  write.csv(df, "Data/trandboddhet.csv", row.names = F)
  
  print('Nedladdning av "trandboddhet.csv" har gått igenom')
}
