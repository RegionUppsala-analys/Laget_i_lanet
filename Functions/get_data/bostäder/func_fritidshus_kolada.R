
source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")


func_fritidshus_kolada <- function(){
  df_fritidshus <- search_and_fetch_kolada("Fritidshus, antal/1000 inv", match=0)
  df_fritidshus <- df_fritidshus %>% filter(year >= 2010)
  write.csv(df_fritidshus, "Data/df_fritidshus.csv", row.names = F)
  print('Nedladdning av "df_fritidshus.csv" har genomförts')
}
