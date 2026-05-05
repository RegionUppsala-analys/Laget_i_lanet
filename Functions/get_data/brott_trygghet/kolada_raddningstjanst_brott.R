source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")



######### Kolada #########

# Avvikelse anmältbrott
func_avvikelse_brott <- function(){
  df_avvikelse_brott <- search_and_fetch_kolada("Avvikelse från modellberäknat värde för anmälda", match=0)
  titles <- c("Avvikelse från modellberäknat värde för anmälda våldsbrott, (Färre än=2, lika många=1, fler än=0)" ,               
              "Avvikelse från modellberäknat värde för anmälda stöld- och tillgreppsbrott, (Färre än=2, lika många=1, fler än=0)")
  
  df_avvikelse_brott <- df_avvikelse_brott %>% filter(title %in% titles, year > 2008)
  write.csv(df_avvikelse_brott, "Data/df_avvikelse_brott.csv", row.names = F)
  print('Nedladdning av "df_avvikelse_brott.csv" har genomförts')
}



# Tider  
## Larmbehandlingstid för räddningstjänst, mediantid i minuter.
func_larmbehandlingstid <- function(){
  df_larmbehandlingstid <- search_and_fetch_kolada("Larmbehandlingstid för räddningstjänst, mediantid i minuter", match=0)
  df_larmbehandlingstid <- df_larmbehandlingstid %>% filter( year > 2008)
  write.csv(df_larmbehandlingstid, "Data/df_larmbehandlingstid.csv", row.names = F)
  print('Nedladdning av "df_larmbehandlingstid.csv" har genomförts')
  
  # Ambulans
  df_larmbehandlingstid <- search_and_fetch_kolada("Larmbehandlingstid för ambulans, mediantid i minuter", match=0)
  df_larmbehandlingstid <- df_larmbehandlingstid %>% filter( year > 2008)
  write.csv(df_larmbehandlingstid, "Data/df_larmbehandlingstid_ambulans.csv", row.names = F)
  print('Nedladdning av "df_larmbehandlingstid_ambulans.csv" har genomförts')
  
  
}



## Responstid (tid från 112-samtal till första resurs är på plats) för räddningstjänst, mediantid i minuter
func_responstid_raddning <- function(){
  df_responstid <- search_and_fetch_kolada("Responstid (tid från 112-samtal till första resurs är på plats) för räddningstjänst, mediantid i minuter", match=0)
  df_responstid <- df_responstid %>% filter(year > 2008)
  write.csv(df_responstid, "Data/df_responstid.csv", row.names = F)
  print('Nedladdning av "df_responstid.csv" har genomförts')
}


## Responstid (tid från 112-samtal till första resurs är på plats) för ambulans, mediantid i minuter
func_responstid_ambulans <- function(){
  df_responstid <- search_and_fetch_kolada("Responstid (tid från 112-samtal till första resurs är på plats) för ambulans, mediantid i minuter", match=0)
  df_responstid <- df_responstid %>% filter( year > 2008)
  write.csv(df_responstid, "Data/df_responstid_ambulans.csv", row.names = F)
  print('Nedladdning av "df_responstid_ambulans.csv" har genomförts')
}



# Brandförsvar och samverkan
## Utvecklade bränder i byggnad
func_brander <- function(){
  df_brander <- search_and_fetch_kolada("Utvecklade bränder i byggnad, antal/1000 inv (-2023)")
  
  
  ### Ny variabel har släppts här
  titles <- "Utvecklade bränder i byggnad, antal/1000 inv (-2023)"   
  ### Men det finns då färre år samt en ny definition på datan.
  
  
  df_brander <- df_brander %>% filter(title %in% titles, year > 2008)
  write.csv(df_brander, "Data/df_brander.csv", row.names = F)
  print('Nedladdning av "df_brander.csv" har genomförts')
}




## IVPA-insatser (i väntan på ambulans), antal/1000 inv/ Samverkan - utför kommunen IVPA (i väntan på ambulans)? (1=Ja, 0=Nej)
func_ivpa <- function(){
  df_ivpa <- search_and_fetch_kolada("IVPA-insatser (i väntan på ambulans), antal/1000 inv", match=0)
  titles <- unique(df_ivpa$title)
  df_ivpa <- df_ivpa %>% filter(year > 2008)
  write.csv(df_ivpa, "Data/df_ivpa.csv", row.names = F)
  print('Nedladdning av "df_ivpa.csv" har genomförts')
}


# Kostnader

func_kostnad_olycka <- function(){
  df_kost_olycka <- search_and_fetch_kolada("Kostnad för olyckor totalt, kr/inv", match=0)
  titles <- unique(df_kost_olycka$title)
  df_kost_olycka <- df_kost_olycka %>% filter( year > 2008)
  write.csv(df_kost_olycka, "Data/df_kost_olycka.csv", row.names = F)
  print('Nedladdning av "df_kost_olycka.csv" har genomförts')
}



# Modellberäknat värde 
### Ny variabel har släppts här för bränder
func_avvikelse_olycka <- function(){
  df_avvikelse_olycka <- search_and_fetch_kolada("Avvikelse från modellberäknat värde ", match=0)
  titles <- c("Avvikelse från modellberäknat värde för sjukhusvårdade till följd av oavsiktliga skador (olyckor), (Färre än=2, lika många=1,  fler än=0)",
              "Avvikelse från modellberäknat värde för utvecklade bränder i byggnad, (Färre än=2, lika många=1, fler än=0) (-2023)"  )
  df_avvikelse_olycka <- df_avvikelse_olycka %>% filter(title %in% titles, year > 2008)
  write.csv(df_avvikelse_olycka, "Data/df_avvikelse_olycka.csv", row.names = F)
  print('Nedladdning av "df_avvikelse_olycka.csv" har genomförts')
}


# Olyckor 

func_sjukhusvar_olycka <- function(){
  df_sjukhusvar_olycka <- search_and_fetch_kolada("Sjukhusvårdade till följd", match=0)
  titles <- c("Avvikelse från modellberäknat värde för sjukhusvårdade till följd av oavsiktliga skador (olyckor), (Färre än=2, lika många=1,  fler än=0)",
              "Sjukhusvårdade till följd av oavsiktliga skador (olyckor), antal/1000 inv" )
  
  df_sjukhusvar_olycka <- df_sjukhusvar_olycka %>% filter(title %in% titles, year > 2008)
  write.csv(df_sjukhusvar_olycka, "Data/df_sjukhusvar_olycka.csv", row.names = F)
  print('Nedladdning av "df_sjukhusvar_olycka.csv" har genomförts')
}

