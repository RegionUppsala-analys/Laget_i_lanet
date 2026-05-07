source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")



############## AVFALL ##################
# Kommunalt avfall som samlats in för materialåtervinning, inkl. biologisk behandling, andel (%)
func_df_avfall <- function(){
  df_avfall <- search_and_fetch_kolada("Kommunalt avfall")
  
  df_avfall <- df_avfall %>% 
    mutate(title_clean = stringr::str_squish(title)) %>%
    filter(
      year >= 2010,
      title_clean %in% c(
        "Kommunalt avfall som samlats in för materialåtervinning, inkl. biologisk behandling, andel (%)",
        "Mängd kommunalt avfall till deponi, kg/invånare (justerat)",
        "Insamlat kommunalt avfall totalt, kg/invånare (justerat)"
      )
    )
  
  write.csv(df_avfall, "Data/df_avfall.csv", row.names = F)
  print('Nedladdning av "df_avfall.csv" har genomförts')
}


# Insamlat mat- och restavfall, kg/invånare (justerat)
func_df_matavf <- function(){
  df_matavf <- search_and_fetch_kolada("Insamlat mat- och restavfall, kg/invånare (justerat)", match=0)
  
  write.csv(df_matavf, "Data/df_matavf.csv", row.names = F)
  print('Nedladdning av "df_matavf.csv" har genomförts')
}


# Insamlat förpackningar och returpapper, kg/invånare (justerat)
func_df_returpapp <- function(){
  df_returpapp <- search_and_fetch_kolada("Insamlat förpackningar och returpapper, kg/invånare (justerat)", match=0)
  #unique(df_returpapp$title)
  write.csv(df_returpapp, "Data/df_returpapp.csv", row.names = F)
  print('Nedladdning av "df_returpapp.csv" har genomförts')
}


# Insamlat grovavfall, kg/invånare (justerat)
func_df_grovt <- function(){
  df_grovt <- search_and_fetch_kolada("Insamlat grovavfall, kg/invånare (justerat)", match=0)
  #unique(df_grovt$title)
  write.csv(df_grovt, "Data/df_grovt.csv", row.names = F)
  print('Nedladdning av "df_grovt.csv" har genomförts')
}



# Insamlat farligt avfall (inkl. elavfall och batterier), kg/invånare (justerat)
func_df_farligt <-function(){
  df_farligt <- search_and_fetch_kolada("Insamlat farligt avfall (inkl. elavfall och batterier), kg/invånare (justerat)", match=0)
  #unique(df_farligt$title)
  write.csv(df_farligt, "Data/df_farligt.csv", row.names = F)
  print('Nedladdning av "df_farligt.csv" har genomförts')
}


# Avgift för avfallshämtning 
func_df_avfall_avgift <- function(){
  df_avfall_avgift <- search_and_fetch_kolada("Avgift för avfallshämtning (ny definition) inkl. moms för typfastighet enligt Nils Holgersson-modellen, kr/kvm", match=0)
  unique(df_avfall_avgift$title)
  write.csv(df_avfall_avgift, "Data/df_avfall_avgift.csv", row.names = F)
  print('Nedladdning av "df_avfall_avgift.csv" har genomförts')
}

# kostnad för avfallshämtning 
func_df_avfall_kost <- function(){
  df_avfall_kost <- search_and_fetch_kolada("Kostnad avfallshantering")
  df_avfall_kost <- df_avfall_kost %>% filter(title %in%  c("Kostnad avfallshantering, kr/inv",
                                                            "Nettokostnad avfallshantering, kr/inv"))
  write.csv(df_avfall_kost, "Data/df_avfall_kost.csv", row.names = F)
  print('Nedladdning av "df_avfall_kost.csv" har genomförts')
}





