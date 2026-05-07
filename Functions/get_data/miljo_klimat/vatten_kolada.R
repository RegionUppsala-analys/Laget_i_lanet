source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")


########### Vatten kolada ###########

func_vatten_kolada <- functin(){
  { # Avgift för vatten och avlopp inkl. moms för typfastighet enligt Nils Holgersson-modellen, kr/kvm
    df_avgift <- search_and_fetch_kolada("Avgift för vatten och avlopp inkl. moms för typfastighet enligt Nils Holgersson-modellen, kr/kvm", match=0)
    df_avgift <- df_avgift %>% filter(year >= 2010)
    write.csv(df_avgift, "Data/avgift_vatten_NHM.csv", row.names = F)
    print('Nedladdning av "avgift_vatten_NHM.csv" har genomförts')
  }
  
  { #   Investeringsutgifter vattenförsörjning och avloppshantering, kr/inv
    df_avgift <- search_and_fetch_kolada("Investeringsutgifter vattenförsörjning och avloppshantering, kr/inv", match=0)
    df_avgift <- df_avgift %>% filter(year >= 2010)
    write.csv(df_avgift, "Data/investering_vatten.csv", row.names = F)
    print('Nedladdning av "investering_vatten.csv" har genomförts')
  }
  
  { #   Vattenanvändning totalt, senaste mätning, kbm/inv
    df_anvandning <- search_and_fetch_kolada("Vattenanvändning", kommunkod='Alla')
    #unique(df_anvandning$title)
    titles <- c("Vattenanvändning totalt, senaste mätning, kbm/inv"  ,"Vattenanvändning, hushåll, senaste mätning, kbm/inv" ,       
                "Vattenanvändning jordbruk, senaste mätning, kbm/inv" ,"Vattenanvändning industri, senaste mätning, kbm/inv"    ,    
                "Vattenanvändning övrig användning, senaste mätning, kbm/inv")
    
    df_anvandning <- df_anvandning %>% filter(year >= 2010, title %in% titles)
    write.csv(df_anvandning, "Data/vattenanvandning.csv", row.names = F)
    print('Nedladdning av "vattenanvandning.csv" har genomförts')
  }
  
  { #    Nettokostnad vattenförsörjning och avloppshantering, kr/inv
    df_anvandning <- search_and_fetch_kolada("Nettokostnad vattenförsörjning och avloppshantering, kr/inv", match = 0)
    #unique(df_anvandning$title)
    df_anvandning <- df_anvandning %>% filter(year >= 2010)
    write.csv(df_anvandning, "Data/nettokostnad_vatten.csv", row.names = F)
    print('Nedladdning av "nettokostnad_vatten.csv" har genomförts')
  }
  
  { # Grundvattenförekomster med god kemisk och kvantitativ status, andel (%)
    df_grund <- search_and_fetch_kolada("Grundvattenförekomster med god kemisk och kvantitativ status, andel (%)", match = 0)
    #unique(df_anvandning$title)
    df_grund <- df_grund %>% filter(year >= 2004)
    write.csv(df_grund, "Data/df_grund.csv", row.names = F)
    print('Nedladdning av "df_grund.csv" har genomförts')
  }
}