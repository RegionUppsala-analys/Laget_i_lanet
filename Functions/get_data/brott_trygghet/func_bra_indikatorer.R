################## Indikatorer BRÅ ############### 
# https://bra.se/statistik/indikatorer-for-kommuners-lagesbild


# Definiera URL och sökväg för nedladdning, tyvärr är det olika länkar per kommun, både sifferkod i bokstavsordning och namn
func_bra_indikatorer <- function(){
  # Enköping
  
  url <- "https://bra.se/download/18.9040d26195b246441f3b47d/1743687281705/Enköping.xlsx"
  
  # Filen sparas som
  destfile <- paste0("Data/df_ind_Enköping.xlsx")
  
  # Ladda ner filen
  download.file(url, destfile, mode = "wb")
  
  # Tierp 
  url <- "https://bra.se/download/18.9040d26195b246441f3b550/1743687340305/Tierp.xlsx"
  
  # Filen sparas som
  destfile <- paste0("Data/df_ind_Tierp.xlsx")
  
  # Ladda ner filen
  download.file(url, destfile, mode = "wb")
  
  # Heby
  url <- "https://bra.se/download/18.9040d26195b246441f3b49e/1743687283699/Heby.xlsx"
  
  # Filen sparas som
  destfile <- paste0("Data/df_ind_Heby.xlsx")
  
  # Ladda ner filen
  download.file(url, destfile, mode = "wb")
  
  # Håbo
  url <- "https://bra.se/download/18.9040d26195b246441f3b4a8/1743687284351/Håbo.xlsx"
  
  # Filen sparas som
  destfile <- paste0("Data/df_ind_Håbo.xlsx")
  
  # Ladda ner filen
  download.file(url, destfile, mode = "wb")
  
  # Knivsta
  url <- "https://bra.se/download/18.9040d26195b246441f3b4c2/1743687304355/Knivsta.xlsx"
  
  # Filen sparas som
  destfile <- paste0("Data/df_ind_Knivsta.xlsx")
  
  # Ladda ner filen
  download.file(url, destfile, mode = "wb")
  
  # Uppsala
  url <- "https://bra.se/download/18.9040d26195b246441f3b564/1743687341208/Uppsala.xlsx"
  
  # Filen sparas som
  destfile <- paste0("Data/df_ind_Uppsala.xlsx")
  
  # Ladda ner filen
  download.file(url, destfile, mode = "wb")
  
  # Älvkarleby
  url <- "https://bra.se/download/18.9040d26195b246441f3b587/1743687364420/Älvkarleby.xlsx"
  
  # Filen sparas som
  destfile <- paste0("Data/df_ind_Älvkarleby.xlsx")
  
  # Ladda ner filen
  download.file(url, destfile, mode = "wb")
  
  # Östhammar
  url <- "https://bra.se/download/18.9040d26195b246441f3b591/1743687364971/Östhammar.xlsx"
  
  # Filen sparas som
  destfile <- paste0("Data/df_ind_Östhammar.xlsx")
  
  # Ladda ner filen
  download.file(url, destfile, mode = "wb")
  
  print('Nedladdning av Kommunernas indikatorer har genomförts')
}



