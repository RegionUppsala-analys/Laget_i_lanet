source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")

######### Kostnader/intäkter kolada ############

## Nettokostnad
func_df_nettokostnad <- function(){ # Nettokostnad kulturverksamhet, kr/inv
  df_nettokostnad_k<- search_and_fetch_kolada("Nettokostnad kulturverksamhet, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_k <- df_nettokostnad_k %>% filter(year >= 2010, !is.na(value)) 
  
  # Nettokostnad allmän kulturverksamhet, kr/inv
  df_nettokostnad_ak<- search_and_fetch_kolada("Nettokostnad allmän kulturverksamhet, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_ak <- df_nettokostnad_ak %>% filter(year >= 2010, !is.na(value)) 
  
  # Nettokostnad bibliotek, kr/inv
  df_nettokostnad_b<- search_and_fetch_kolada("Nettokostnad bibliotek, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_b <- df_nettokostnad_b %>% filter(year >= 2010, !is.na(value)) 
  
  # Nettokostnad musik- och kulturskola, kr/inv
  df_nettokostnad_mk<- search_and_fetch_kolada("Nettokostnad musik- och kulturskola, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_mk <- df_nettokostnad_mk %>% filter(year >= 2010, !is.na(value)) 
  
  # Nettokostnad stöd till studieorganisationer, kr/inv
  df_nettokostnad_s<- search_and_fetch_kolada("Nettokostnad stöd till studieorganisationer, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_s <- df_nettokostnad_s %>% filter(year >= 2010, !is.na(value)) 
  
  df_nettokostnad <- rbind(df_nettokostnad_k,df_nettokostnad_ak,df_nettokostnad_b,
                           df_nettokostnad_mk,df_nettokostnad_s)
  
  df_nettokostnad <- df_nettokostnad %>% filter(municipality %in% c("Riket",kommuner),
                                                kpi != "N85004")
  
  write.csv(df_nettokostnad, "Data/df_nettokostnad.csv", row.names = F)
  print('Nedladdning av "df_nettokostnad.csv" har genomförts')
}



## Kostnader -> Gjort det lite lätt för mig och inte ändrat variabelnamn etc
func_df_Kostnad_intakt <- function(){ # kostnad kulturverksamhet, kr/inv
  df_nettokostnad_k<- search_and_fetch_kolada("Kostnad kulturverksamhet, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_k <- df_nettokostnad_k %>% filter(year >= 2010, !is.na(value), 
                                                    title=="Kostnad kulturverksamhet, kr/inv")
  
  # kostnad allmän kulturverksamhet, kr/inv
  df_nettokostnad_ak<- search_and_fetch_kolada("Kostnad allmän kulturverksamhet, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_ak <- df_nettokostnad_ak %>% filter(year >= 2010, !is.na(value), 
                                                      title=="Kostnad allmän kulturverksamhet, kr/inv") 
  
  # kostnad bibliotek, kr/inv
  df_nettokostnad_b<- search_and_fetch_kolada("Kostnad bibliotek, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_b <- df_nettokostnad_b %>% filter(year >= 2010, !is.na(value), 
                                                    title=="Kostnad bibliotek, kr/inv")  
  
  # kostnad musik- och kulturskola, kr/inv
  df_nettokostnad_mk<- search_and_fetch_kolada("Kostnad musik- och kulturskola, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_mk <- df_nettokostnad_mk %>% filter(year >= 2010, !is.na(value), 
                                                      title=="Kostnad musik- och kulturskola, kr/inv")  
  
  # kostnad stöd till studieorganisationer, kr/inv
  df_nettokostnad_s<- search_and_fetch_kolada("Kostnad stöd till studieorganisationer, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_s <- df_nettokostnad_s %>% filter(year >= 2010, !is.na(value), 
                                                    title=="Kostnad stöd till studieorganisationer, kr/inv")  
  
  df_nettokostnad <- rbind(df_nettokostnad_k,df_nettokostnad_ak,df_nettokostnad_b,
                           df_nettokostnad_mk,df_nettokostnad_s)
  
  # Intäkter
  
  # Intäkter kulturverksamhet, kr/inv
  df_nettokostnad_k<- search_and_fetch_kolada("Intäkter kulturverksamhet, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_k <- df_nettokostnad_k %>% filter(year >= 2010, !is.na(value))
  
  # Intäkter allmän kulturverksamhet, kr/inv
  df_nettokostnad_ak<- search_and_fetch_kolada("Intäkter allmän kulturverksamhet, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_ak <- df_nettokostnad_ak %>% filter(year >= 2010, !is.na(value))
  
  # Intäkter bibliotek, kr/inv
  df_nettokostnad_b<- search_and_fetch_kolada("Intäkter bibliotek, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_b <- df_nettokostnad_b %>% filter(year >= 2010, !is.na(value))  
  
  # Intäkter musik- och kulturskola, kr/inv
  df_nettokostnad_mk<- search_and_fetch_kolada("Intäkter musik- och kulturskola, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_mk <- df_nettokostnad_mk %>% filter(year >= 2010, !is.na(value)) 
  
  # Intäkter stöd till studieorganisationer, kr/inv
  df_nettokostnad_s<- search_and_fetch_kolada("Intäkter stöd till studieorganisationer, kr/inv", match=0, kommunkod = "Alla")
  df_nettokostnad_s <- df_nettokostnad_s %>% filter(year >= 2010, !is.na(value))
  
  df_nettokostnad <- rbind(df_nettokostnad,df_nettokostnad_k,df_nettokostnad_ak,df_nettokostnad_b,
                           df_nettokostnad_mk,df_nettokostnad_s)
  
  df_nettokostnad <- df_nettokostnad %>% filter(municipality %in% c("Riket",kommuner),
                                                kpi != "N85014")
  
  write.csv(df_nettokostnad, "Data/df_Kostnad_intakt.csv", row.names = F)
  print('Nedladdning av "df_Kostnad_intakt.csv" har genomförts')
}



