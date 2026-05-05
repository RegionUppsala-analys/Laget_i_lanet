source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")


# Slutanvändning av energi bland .... MWh/inv
func_df_elavbrott <- function(){
  df_elavbrott <- search_and_fetch_kolada("Elavbrott")
  df_elavbrott <- df_elavbrott %>% dplyr::select(-c(count, gender,municipality_type, status)) 
  df_elavbrott <- df_elavbrott %>% filter(title %in% c("Elavbrott,  genomsnittlig avbrottstid per kund (SAIDI), minuter/kund"  ,                                       
                                                       "Elavbrott,  andel kunder som drabbats av 4 eller fler oaviserade långa avbrott under året (CEMI-4), andel (%)"))
  
  write.csv(df_elavbrott, "Data/df_elavbrott.csv", row.names = F)
  print('Nedladdning av "df_elavbrott.csv" har genomförts')
}