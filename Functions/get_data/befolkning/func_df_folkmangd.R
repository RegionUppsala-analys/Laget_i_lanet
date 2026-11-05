
################# Folkmängd efter region, kön, ålder och år #################

# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101A/BefolkningNy/
# https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101A/BefolkningCKM/
# TAB638 innehåller historik till 2024, TAB5557 innehåller data från 2025.
func_df_folkmangd <- function(){
  queries <- list(
    TAB638 = list(
      Region = kommunkod,
      Kon = c("1", "2"),
      Alder = c(as.character(0:99), "100+"),
      ContentsCode = "BE0101N1",
      Tid = "*"
    ),
    TAB5557 = list(
      Region = kommunkod,
      Civilstand = "SC",
      Kon = c("1", "2"),
      Alder = c(as.character(0:99), "100+1"),
      ContentsCode = "000007ME",
      Tid = "*"
    )
  )

  # TAB638 summerar civilstånd när dimensionen utelämnas. TAB5557 har en
  # uttrycklig total (SC). Välj bara ettårsåldrar och män/kvinnor så att
  # överlappande åldersgrupper och könstotaler inte räknas flera gånger.
  population_data <- lapply(names(queries), function(table_id) {
    px_get <- pxweb_get(pxweb_url(table_id), queries[[table_id]])
    df <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")

    df |>
      tidyr::pivot_wider(names_from = "tabellinnehåll", values_from = "value") |>
      dplyr::select(region, ålder, kön, år, Folkmängd)
  })

  # Båda tabellerna använder etiketten 100+ år, men olika urvalskoder.
  # Behåll tidigare filformat: heltalsålder 100 står för 100 år eller äldre.
  # Från 2025 är värdena röjandeskyddade (CKM). De behålls oförändrade,
  # även när summan av ettårsåldrar avviker från SCB:s publicerade total.
  df_folkmangd <- dplyr::bind_rows(population_data) |>
    dplyr::mutate(
      ålder = as.integer(gsub("\\+| år", "", ålder)),
      år = as.integer(år)
    )

  if (anyNA(df_folkmangd)) {
    stop("Befolkningsdata innehåller saknade värden efter sammanfogningen.", call. = FALSE)
  }
  if (anyDuplicated(df_folkmangd[c("region", "ålder", "kön", "år")])) {
    stop("Befolkningsdata innehåller flera rader för samma region, ålder, kön och år.", call. = FALSE)
  }

  write.csv(df_folkmangd, "Data/df_folkmangd.csv", row.names = FALSE)
  
  print('Nedladdning av "df_folkmangd.csv" genomfördes')
}