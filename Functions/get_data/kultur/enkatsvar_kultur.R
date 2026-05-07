source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/get_data/search_kolada.R")


# Det lokala kultur- och nöjeslivet i kommunen är bra, andel (%)
# Osäkerhetstal - Det lokala kultur- och nöjeslivet i kommunen är bra, andel (%)

func_df_enkat_kultur <- function(){# df_enkat_kultur
  df_enkat_kultur<- search_and_fetch_kolada("Det lokala kultur- och nöjeslivet i kommunen är bra, andel (%)", match=0.01, kommunkod="Alla")
  
  titles <- c( "Medborgarundersökningen - Det lokala kultur- och nöjeslivet i kommunen är bra, andel (%)",
               "Osäkerhetstal - Det lokala kultur- och nöjeslivet i kommunen är bra, andel (%)" )
  
  df_enkat_kultur <- df_enkat_kultur %>% filter(municipality %in% c("Region Uppsala", kommuner)
                                                , title %in% titles,year >= 2010, !is.na(value)) 
  
  # gör till wide och formaterar om gender
  df_enkat_kultur_wide <- df_enkat_kultur %>% pivot_wider(
    id_cols = c(year,gender, municipality),
    names_from = title, values_from = value)%>%
    mutate(
      gender = case_when(
        gender == "K" ~ "Kvinnor",
        gender == "M" ~ "Män",
        TRUE          ~ "Total"
      )
    )
  
  
  write.csv(df_enkat_kultur_wide, "Data/df_enkat_kultur.csv", row.names = F)
  print('Nedladdning av "df_enkat_kultur.csv" har genomförts')
}