source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")


############# Hållbarhetsindex ###########
# Miljömässig hållbarhet - Kommunindex
func_df_hallbarhet<- function(){
  df_hallbarhet <- search_and_fetch_kolada("Miljömässig hållbarhet - Kommunindex", kommunkod='Alla', match=0)
  write.csv(df_hallbarhet, "Data/df_hallbarhet.csv", row.names = F)
  print('Nedladdning av "df_hallbarhet.csv" har genomförts')
}


############# Miljökvalitetsindex ##############
func_df_miljokval <- function(){
  df_miljokval <- search_and_fetch_kolada("Miljökvalitet - Kommunindex", kommunkod='Alla', match=0)
  df_miljokval <- df_miljokval %>% filter(title == "Miljökvalitet - Kommunindex")
  write.csv(df_miljokval, "Data/df_miljokval.csv", row.names = F)
  print('Nedladdning av "df_miljokval.csv" har genomförts')
}



