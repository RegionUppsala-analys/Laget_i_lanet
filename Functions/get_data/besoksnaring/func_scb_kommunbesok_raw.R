func_scb_kommunbesok_raw <- function()
{
  # https://www.scb.se/hitta-statistik/artiklar/2023/snart-vantas-sommarens-stora-folkforflyttning/
  # https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fwww.scb.se%2Fcontentassets%2F0a2bcdf10d5d4d44a597d3656257ffa8%2Fkort_analys_kommuntabell.xlsx&wdOrigin=BROWSELINK
  
  url <- "https://www.scb.se/contentassets/0a2bcdf10d5d4d44a597d3656257ffa8/kort_analys_kommuntabell.xlsx"
  
  data_dir <- "Data"
  dir.create(data_dir, showWarnings = FALSE)
  
  xlsx_file <- file.path(data_dir, "scb_kommunbesok.xlsx")
  
  download.file(
    url,
    xlsx_file,
    mode = "wb"
  )
  
  ############################################################
  #  Läs in Excel
  
  df_raw <- read_excel(xlsx_file, skip=1) %>%
    clean_names()
  
  colnames(df_raw) <- c("Kommun","bef_okt_nov", "bef_juli", "bef_midsommar", "skillnad_juli", "skillnad_midsommar" )
  
  ############################################################
  #  Spara rådata som CSV
  
  csv_raw_file <- file.path(data_dir, "scb_kommunbesok_raw.csv")
  
  write.csv(
    df_raw,
    csv_raw_file
  )
  
}