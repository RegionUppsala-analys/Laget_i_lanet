################ SFI Kolada ################
source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")


func_SFI_antal <- function(){
  SFI <- search_and_fetch_kolada("Elever i SFI-utbildning")
  SFI <- SFI %>% filter(title %in% c("Elever i SFI-utbildning, antal" ,
                                     "Elever i SFI-utbildning. kommunal regi, antal"))
  
  write.csv(SFI, "Data/df_SFI_antal.csv", row.names = F)
  print('Nedladdning av "SFI_antal.csv" har genomförts')
}

func_SFI_antal()

func_SFI <- function(){
  SFI <- search_and_fetch_kolada("Elever på SFI som klfort") # fult sökord men funkar
  SFI <- SFI %>% filter(title %in% c("Elever på SFI som klarat minst två kurser, av nybörjare två år tidigare, andel (%)" ,                               
                                     "Elever på SFI som fortsätter utbildningen men klarat mindre än två kurser, av nybörjare två år tidigare, andel (%)"))
  write.csv(SFI, "Data/df_SFI.csv", row.names = F)
  print('Nedladdning av "SFI.csv" har genomförts')
}

func_SFI()
