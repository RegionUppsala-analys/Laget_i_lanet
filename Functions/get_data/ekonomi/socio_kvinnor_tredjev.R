fetch_socio_kvinnor_tredjev_table <- function(table_id, query) {
  pxweb_get(pxweb_url(table_id), query) |>
    as.data.frame(column.name.type = "text", variable.value.type = "text") |>
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )
}

socio_kvinnor_tredjev <- function(year = "2023", country_year = "2022") {
  list(
    sjalvforsorjning = fetch_socio_kvinnor_tredjev_table(
      "TAB6396",
      list(
        Region = "03",
        Kon = "2",
        Alder = "20-65",
        Fodelseregion = "utee",
        UtbildningsNiva = c("21", "3+4", "8", "US"),
        ContentsCode = "*",
        Tid = year
      )
    ),
    utbildningsniva = fetch_socio_kvinnor_tredjev_table(
      "TAB4648",
      list(
        Region = "03",
        Kon = "2",
        Bakgrund = c("000p", "Fp", "3p", "EUp", "USp"),
        ContentsCode = "00000172",
        Tid = year
      )
    ),
    ohalsotal = fetch_socio_kvinnor_tredjev_table(
      "TAB1768",
      list(
        Region = "03",
        Kon = "2",
        Bakgrund = c("SE", "NEXS", "EUEESXN", "VXEUEES"),
        ContentsCode = "*",
        Tid = year
      )
    ),
    inkomst = fetch_socio_kvinnor_tredjev_table(
      "TAB1793",
      list(
        Region = "03",
        Kon = "2",
        Bakgrund = c("SE", "NEXS", "EUEESXN", "VXEUEES"),
        ContentsCode = "*",
        Tid = year
      )
    ),
    aktivitetsersattning = fetch_socio_kvinnor_tredjev_table(
      "TAB5550",
      list(
        SjukOchAktiviteters = "*",
        Vistelsetid = "*",
        Kon = "2",
        Alder = "*",
        Fodelseregion = "*",
        ContentsCode = "*",
        Tid = country_year
      )
    ),
    sjuk_och_rehabiliteringspenning = fetch_socio_kvinnor_tredjev_table(
      "TAB5549",
      list(
        Sjukochrehabpenning = "*",
        Vistelsetid = "*",
        Kon = "2",
        Alder = "*",
        Fodelseregion = "*",
        ContentsCode = "*",
        Tid = country_year
      )
    ),
    utbildning_vistelsetid = fetch_socio_kvinnor_tredjev_table(
      "TAB6076",
      list(
        UtbildningsNiva = "*",
        UtbildningsinriktUF = "TOT",
        Vistelsetid = "TOT",
        Kon = "100",
        Alder = "totalt",
        Fodelseregion = "*",
        ContentsCode = "*",
        Tid = country_year
      )
    )
  )
}
