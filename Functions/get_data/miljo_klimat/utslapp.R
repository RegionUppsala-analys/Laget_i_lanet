source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")


# Utsläpp till luft av växthusgaser totalt per kommun
func_vaxthusgas <- function(){
  df_vaxthusgas <- search_and_fetch_kolada("växthusgaser")
  titles <- "Utsläpp till luft av växthusgaser totalt, ton CO2-ekv/inv"
  
  df_vaxthusgas <- df_vaxthusgas %>% filter(title %in% titles, year > 2004)
  
  write.csv(df_vaxthusgas, "Data/df_vaxthusgas.csv", row.names = F)
  print('Nedladdning av "df_vaxthusgas.csv" har genomförts')
}

# Utsläpp luft kväveoxider
func_df_utslapp_kv <- function(){
  df_utslapp <- search_and_fetch_kolada('Utsläpp till luft av kväveoxider (NOx), totalt, kg/inv', match=0)
  
  df_utslapp_kv <- df_utslapp %>% filter(year > 2004)
  
  write.csv(df_utslapp_kv, "Data/df_utslapp_kv.csv", row.names = F)
  print('Nedladdning av "df_utslapp_kv.csv" har genomförts')
}

# Utsläpp pm2.5
func_df_utslapp_pm <- function(){
  df_utslapp <- search_and_fetch_kolada("Utsläpp till luft av PM2.5 (partiklar <2.5 mikrom). kg/inv",match=0)
  df_utslapp_pm <- df_utslapp %>% filter( year > 2004)
  write.csv(df_utslapp_pm, "Data/df_utslapp_pm.csv", row.names = F)
  print('Nedladdning av "df_utslapp_pm.csv" har genomförts')
}


# Utsläpp ammoniak

func_df_utslapp_am <- function(){
  df_utslapp <- search_and_fetch_kolada("Utsläpp till luft av ammoniak (NH3), totalt, kg/inv", match=0)
  df_utslapp_am <- df_utslapp %>% filter( year > 2004)
  write.csv(df_utslapp_am, "Data/df_utslapp_am.csv", row.names = F)
  print('Nedladdning av "df_utslapp_am.csv" har genomförts')
}

# Utsläpp flytande organiska ämnen
func_df_utslapp_org <- function(){
  df_utslapp <- search_and_fetch_kolada("Utsläpp till luft av flyktiga organiska ämnen totalt, ton NMVOC/inv", match=0)
  df_utslapp_org <- df_utslapp %>% filter( year > 2004)
  
  write.csv(df_utslapp_org, "Data/df_utslapp_org.csv", row.names = F)
}
