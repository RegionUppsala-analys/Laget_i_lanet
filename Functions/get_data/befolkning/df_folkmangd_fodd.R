################ Folkmängd efter födelseort #####################
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101E/InrUtrFodRegAlKonCKM/

func_df_folkmangd_fodd <- function(){
  url <- pxweb_url("TAB6645")

  px_get_list <- list(Region = kommunkod,
                      Kon = '*',
                      Alder = '*',
                      Fodelseregion = '*',
                      ContentsCode = '*',
                      Tid = '2025')

  px_get <- pxweb_get(url, px_get_list)
  codes <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "code")
  df_folkmangd_fodd <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")

  # Filtrera på koder: 100+1, 100+5 och 100+10 har samma textetikett.
  # Endast ettårsåldrar och separata kön/födelseregioner får ingå i summorna.
  keep <- codes$ålder %in% c(as.character(0:99), "100+1") &
    codes$kön %in% c("1", "2") &
    codes$födelseregion %in% c("09", "11")

  df_folkmangd_fodd <- df_folkmangd_fodd[keep, ] |>
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    ) |>
    dplyr::select(region, ålder, kön, födelseregion, år, Antal) |>
    dplyr::mutate(
      ålder = as.integer(gsub("\\+| år", "", ålder)),
      år = as.integer(år)
    )

  if (nrow(df_folkmangd_fodd) == 0L || anyNA(df_folkmangd_fodd)) {
    stop("Befolkningsdata efter födelseregion saknas eller innehåller saknade värden.", call. = FALSE)
  }
  if (anyDuplicated(df_folkmangd_fodd[c("region", "ålder", "kön", "födelseregion", "år")])) {
    stop("Befolkningsdata innehåller flera rader för samma region, ålder, kön, födelseregion och år.", call. = FALSE)
  }

  # SCB:s röjandeskyddade cellvärden behålls utan anpassning till totalerna.
  write.csv(df_folkmangd_fodd, "Data/df_folkmangd_fodd.csv", row.names = FALSE)
  
  print('Nedladdning av "df_folkmangd_fodd" genomfördes')
}
