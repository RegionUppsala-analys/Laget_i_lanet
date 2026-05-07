source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")


######## Kommunens köp av kultur #########

func_df_kost_andel <- function(){ #  
  df_kost_andel<- search_and_fetch_kolada("Gemensamma kostnader fördelade till kulturverksamhet, andel (%)", match=0, kommunkod="Alla")
  df_kost_andel <- df_kost_andel %>% filter(year >= 2010, !is.na(value),
                                            municipality %in% c("Riket", kommuner)) 
  
  
  write.csv(df_kost_andel, "Data/df_kost_andel.csv", row.names = F)
  print('Nedladdning av "df_kost_andel.csv" har genomförts')
}

######### Kommunens köp av kultur och fritid totalt, andel (%) #####
func_df_kop_kf <- function(){
  # Kommunens köp av kultur och fritid totalt, andel (%)
  # Kommunens köp av kultur och fritid från offentliga utförare, andel (%)
  # Kommunens köp av kultur och fritid från privata utförare, andel (%)
  # Kommunens köp av kultur och fritid från privatägda företag, andel (%)
  df_andel<- search_and_fetch_kolada("Kommunens köp av kultur och fritid ", match=0)
  
  titles <- c("Kommunens köp av kultur och fritid från offentliga utförare, andel (%) (-2024)" ,
              "Kommunens köp av kultur och fritid från privata utförare, andel (%) (-2024)"  , 
              "Kommunens köp av kultur och fritid totalt, andel (%)"  ,   
              "Kommunens köp av kultur och fritid från privatägda företag, andel (%)" )
  
  df_andel <- df_andel %>% filter(title %in% titles,year >= 2015, !is.na(value)) 
  write.csv(df_andel, "Data/df_kop_kf.csv", row.names = F)
  print('Nedladdning av "df_kop_kf.csv" har genomförts')
}



########## sysselsättning kolada   ##########
func_df_sysselkolada <- function(){ #  
  df_sysselkolada<- search_and_fetch_kolada("Sysselsatta inom kulturella och personliga tjänster m.m.,", match=0)
  df_sysselkolada <- df_sysselkolada %>% filter(year >= 2010, !is.na(value))
  
  write.csv(df_sysselkolada, "Data/df_sysselkolada.csv", row.names = F)
  print('Nedladdning av "df_sysselkolada.csv" har genomförts')
}


