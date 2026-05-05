########### Fordonstatistik ##############
func_fordonsstatistik <- function(){{
  df_bil <- search_and_fetch_kolada("Bilar, antal/1000 inv", match=0.01) # Alla bilsorter
  # unique(df_bil$title)
  df_bil <- df_bil %>% dplyr::select(-c(count, gender,municipality_type, status)) 
  write.csv(df_bil, "Data/df_bil.csv", row.names = F)
  print('Nedladdning av "df_bil.csv" har genomförts')
}
  
  {
    df_stracka <- search_and_fetch_kolada("Genomsnittlig körsträcka med personbil", match=0.01) # Alla bilsorter
    # unique(df_stracka$title)
    df_stracka <- df_stracka %>% dplyr::select(-c(count, gender,municipality_type, status)) %>% filter(year > 2010)
    write.csv(df_stracka, "Data/df_stracka.csv", row.names = F)
    print('Nedladdning av "df_stracka.csv" har genomförts')
  }
  
  {
    df_andel <- search_and_fetch_kolada("Fossiloberoende personbilar, andel av totalt antal bilar i det geografiska området (%)", match=0) 
    # unique(df_andel$title)
    df_andel <- df_andel %>% dplyr::select(-c(count, gender,municipality_type, status)) %>% filter(year > 2010)
    write.csv(df_andel, "Data/df_andel_bil.csv", row.names = F)
    print('Nedladdning av "df_andel_bil.csv" har genomförts')
  }
}
