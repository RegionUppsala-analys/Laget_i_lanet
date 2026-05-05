source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")

# Slutanvändning av energi bland .... MWh/inv
kolada_f_energianvandning <- function(){
  df_energianvandning <- search_and_fetch_kolada("MWH/inv")
  df_energianvandning <- df_energianvandning %>% filter(status != 'Privacy') %>% dplyr::select(-c(count, gender,municipality_type, status)) 
  df_energianvandning <- df_energianvandning %>% filter(title %in% c( "Slutanvändning av fjärrvärme inom det geografiska området, MWh/inv"  ,                            
                                                                      "Slutanvändning av el inom det geografiska området, MWh/inv"))
  
  write.csv(df_energianvandning, "Data/df_energianvandning.csv", row.names = F)
  print('Nedladdning av "df_energianvandning.csv" har genomförts')
}


# Slutanvändning av energi bland .... MWh/inv
kolada_df_slutanvandning_tjanst <- function(){
  df_energianvandning <- search_and_fetch_kolada("MWH/inv")
  df_energianvandning <- df_energianvandning %>% filter(status != 'Privacy') %>% dplyr::select(-c(count, gender,municipality_type, status)) 
  df_energianvandning <- df_energianvandning %>% filter(title %in% c("Slutanvändning av energi inom jordbruk, skogsbruk och fiske inom det geografiska området, MWh/inv",
                                                                     "Slutanvändning av energi inom industri och byggverksamhet inom det geografiska området, MWh/inv"  ,
                                                                     "Slutanvändning av energi inom offentlig verksamhet inom det geografiska området, MWh/inv" ,        
                                                                     "Slutanvändning av energi inom transporter inom det geografiska området, MWh/inv",                  
                                                                     "Slutanvändning av energi inom övriga tjänster inom det geografiska området, MWh/inv"))
  
  write.csv(df_energianvandning, "Data/df_slutanvandning_tjanst.csv", row.names = F)
  print('Nedladdning av "df_slutanvandning_tjanst.csv" har genomförts')
}

# Slutanvändning av energi bland .... MWh/inv
kolada_slutanvandning_hushall <- function(){
  df_energianvandning <- search_and_fetch_kolada("MWH/inv")
  df_energianvandning <- df_energianvandning %>% filter(status != 'Privacy') %>% dplyr::select(-c(count, gender,municipality_type, status)) 
  df_energianvandning <- df_energianvandning %>% filter(title %in% c( "Slutanvändning av energi bland småhus inom det geografiska området, MWh/inv" ,                     
                                                                      "Slutanvändning av energi bland flerbostadshus inom det geografiska området, MWh/inv" ,             
                                                                      "Slutanvändning av energi bland fritidshus inom det geografiska området, MWh/inv",                  
                                                                      "Slutanvändning energi inom hushåll inom det geografiska området, MWh/inv"   ))
  
  write.csv(df_energianvandning, "Data/df_slutanvandning_hushall.csv", row.names = F)
  print('Nedladdning av "df_slutanvandning_hushall.csv" har genomförts')
}