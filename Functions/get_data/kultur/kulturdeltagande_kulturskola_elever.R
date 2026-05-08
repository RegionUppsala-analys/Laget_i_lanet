source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")



######## Deltagande i kultur kolada #####

func_df_deltagande <- function(){
  df_deltagande<- search_and_fetch_kolada("Deltagande i kultur, andel (%)", match=0,kommunkod="Alla")
  df_deltagande <- df_deltagande %>% filter(year >= 2010, !is.na(value), municipality_type=="L") 
  write.csv(df_deltagande, "Data/df_deltagande.csv", row.names = F)
  print('Nedladdning av "df_deltagande.csv" har genomförts')
}


######## Elever i kulturskola #######

func_df_elever <- function(){ #  
  df_elever<- search_and_fetch_kolada("Elever i musik- eller kulturskola", match=0)
  df_elever <- df_elever %>% filter(year >= 2010, !is.na(value),
                                    title %in% c("Elever i musik- eller kulturskola, 6-19 år, andel (%)",
                                                 "Elever i musik- eller kulturskola, 6-15 år, andel (%)",
                                                 "Elever i musik- eller kulturskola totalt, antal")) 
  write.csv(df_elever, "Data/df_elever.csv", row.names = F)
  print('Nedladdning av "df_elever.csv" har genomförts')
}



# Förekomst av öppen verksamhet i kulturskolan (Ja=1, Nej=0)
func_df_oppen_skola <- function(){ #  
  df_oppen_skola<- search_and_fetch_kolada("Förekomst av öppen verksamhet i kulturskolan (Ja=1, Nej=0)", match=0)
  df_oppen_skola <- df_oppen_skola %>% filter(year >= 2010, !is.na(value))
  
  write.csv(df_oppen_skola, "Data/df_oppen_skola.csv", row.names = F)
  print('Nedladdning av "df_oppen_skola.csv" har genomförts')
}




# Ämneskurser som erbjuds i musik- eller kulturskolan, antal ämnesområden

func_df_amne<- function(){ #  
  df_amne<- search_and_fetch_kolada("Ämneskurs", match=0)
  
  
  titles <- c( "Ämneskurser som erbjuds i musik- eller kulturskolan, antal ämnesområden" ,                           
               "Musik - ensemble, orkester, kör, musikgrupp/band erbjuds som ämneskurs i kulturskolan (Ja=1, Nej=0)",
               "Dans erbjuds som ämneskurs i kulturskolan (Ja=1, Nej=0)",                                            
               "Teater/drama erbjuds som ämneskurs i kulturskolan (Ja=1, Nej=0)",                                    
               "Bild och form erbjuds som ämneskurs i kulturskolan (Ja=1, Nej=0)" ,                                  
               "Musikal erbjuds som ämneskurs i kulturskolan (Ja=1, Nej=0)",                                         
               "Cirkus erbjuds som ämneskurs i kulturskolan (Ja=1, Nej=0)" ,                                         
               "Film/animation erbjuds som ämneskurs i kulturskolan (Ja=1, Nej=0)",                                  
               "Foto erbjuds som ämneskurs i kulturskolan (Ja=1, Nej=0)",                                            
               "Slöjd/hantverk erbjuds som ämneskurs i kulturskolan (Ja=1, Nej=0)" ,                                 
               "Skrivande/berättande erbjuds som ämneskurs i kulturskolan (Ja=1, Nej=0)" ,                           
               "Övriga områden erbjuds som ämneskurser i kulturskolan (Ja=1, Nej=0)"   )
  
  
  df_amne <- df_amne %>% filter(title %in% titles ,year >= 2010, !is.na(value))
  
  write.csv(df_amne, "Data/df_amne.csv", row.names = F)
  print('Nedladdning av "df_amne.csv" har genomförts')
}



# Könsfördelning kulturskola
func_df_skola_kon <- function(){ #  
  df_skola_kon<- search_and_fetch_kolada("Flickor i kulturskolan, 6-19 år, andel (%)", match=0)
  df_skola_kon <- df_skola_kon %>% filter(year >= 2010, !is.na(value))
  
  write.csv(df_skola_kon, "Data/df_skola_kon.csv", row.names = F)
  print('Nedladdning av "df_skola_kon.csv" har genomförts')
}


# Genomsnittlig elevavgift i musik- eller kulturskola, kr/elever 6-19 år
func_df_genomkost <- function(){ #  
  df_genomkost<- search_and_fetch_kolada("Genomsnittlig elevavgift i musik- eller kulturskola, kr/elever 6-19 år", match=0)
  df_genomkost <- df_genomkost %>% filter(year >= 2010, !is.na(value))
  
  write.csv(df_genomkost, "Data/df_genomkost.csv", row.names = F)
  print('Nedladdning av "df_genomkost.csv" har genomförts')
}
