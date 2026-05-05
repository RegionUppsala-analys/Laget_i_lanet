source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")

############## Bredband tillgång ##################
# Tillgång till fast berdband om minst 100 Mbit/s, Andel%
func_df_internet <- function(){
  df_internet <- search_and_fetch_kolada("Tillgång till fast bredband om minst 100 Mbit/s, andel (%)", match=0)
  df_internet <- df_internet %>% filter(year >= 2010)
  write.csv(df_internet, "Data/df_internet.csv", row.names = F)
  print('Nedladdning av "df_internet.csv" har genomförts')
}


# Hushåll med tillgång till eller möjlighet att ansluta till bredband om minst 1 Gbit/s, andel (%)
func_df_internet_gb <- function(){
  df_internet_gb <- search_and_fetch_kolada("Hushåll med tillgång till eller möjlighet att ansluta till bredband om minst 1 Gbit/s")
  unique(df_internet_gb$title)
  df_internet_gb <- df_internet_gb %>% filter(title %in% c("Hushåll med tillgång till eller möjlighet att ansluta till bredband om minst 1 Gbit/s, andel (%)"     ,                 
                                                           "Hushåll i tätbebyggt område med tillgång till eller möjlighet i att ansluta till bredband om minst 1 Gbit/s, andel (%)",
                                                           "Hushåll i glesbebyggt område med tillgång till eller möjlighet att ansluta till bredband om minst 1 Gbit/s, andel (%)" ))
  
  write.csv(df_internet_gb, "Data/df_internet_gb.csv", row.names = F)
  print('Nedladdning av "df_internet_gb.csv" har genomförts')
}


# Internetstiftelsens och Bredbandskollens mätningar
func_bredbandskollen <- function(){
  df_bredbandskollen <- search_and_fetch_kolada("Bredbandskollen, genomsnittligt")
  unique(df_bredbandskollen$title)
  df_bredbandskollen <-df_bredbandskollen %>% filter(title %in% c(
    "Bredbandskollen, genomsnittligt mätresultat, nedströms, webb, Mbit/s",  "Bredbandskollen, genomsnittligt mätresultat, uppströms, webb, Mbit/s" ,
    "Bredbandskollen, genomsnittligt mätresultat, nedströms, mobil, Mbit/s", "Bredbandskollen, genomsnittligt mätresultat, uppströms, mobil, Mbit/s"
  ))
  
  write.csv(df_bredbandskollen, "Data/df_bredbandskollen.csv", row.names = F)
  print('Nedladdning av "df_bredbandskollen.csv" har genomförts')
}

# PTS Mobiltäcknings- och bredbandskartläggning.
# https://statistik.pts.se/telekom-och-bredband/mobiltackning-och-bredband/dokument/


func_tackningsdata <- function(){
  # Direktlänkar till Excel-filerna för mobiltäckning
  url_mobiltackning <- "https://statistik.pts.se/media/aecfgy4i/tabelbilaga-mobiltäckning-1-3.xlsx"
  
  # Sökvägar där filerna ska sparas
  dest_mobiltackning <- file.path("Data", "mobiltackning.xlsx")
  
  # Ladda ned filerna
  download.file(url_mobiltackning, dest_mobiltackning, mode = "wb")
  
  print('Nedladdning av "mobiltackning.xlsx" har genomförts')
  # Teknik 
  url_teknik <- 'https://statistik.pts.se/media/b2rhdc1g/tabellbilaga-teknik-1-1.xlsx'
  
  # Sökvägar där filerna ska sparas
  teknik <- file.path("Data", "teknik.xlsx")
  
  # Ladda ned filerna
  download.file(url_teknik, teknik, mode = "wb")
  
  print('Nedladdning av "teknik.xlsx" har genomförts')
  
}