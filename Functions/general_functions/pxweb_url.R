  #---- Funktion för att förenkla url-angivelsen vid pxweb_get -----#
  #---- Anpassat för pxweb v2 -----#

pxweb_url <- function(table_id, lang = "sv") {

  paste0(
    "https://statistikdatabasen.scb.se/api/v2/tables/",
    table_id,
    "/metadata?lang=",
    lang
  )

}


### Exempelkod för att använda funktionen för att hämta SCB-data ###

#url <- pxweb_url("TAB4879")  # Ange "TAB-numret" för tabellen

#px_get_list <- list( # Detta är samma koncept som tidigare tabeller
  Region = c(riket_narliggande),
  UtbildningsNiva = "*",
  Kon = c("020","030"),
  Alder = "*",
  ContentsCode = "*",
  Tid = "*"
)

#px_get <- pxweb_get(url, px_get_list)

# laddar data och gör till rätt format
  #df_livslangd <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  #df_livslangd <- na.omit(df_livslangd) # tar bort NA då det endast finns uppgift saknas för Riket

#df_livslangd <- df_livslangd |>  # OBS: tabellinnehållet kommer i annat format vid pxweb2-export, så...
#tidyr::pivot_wider(              # man behöver pivota innehållet för att få tabellen i samma format som för v1
    #names_from = "tabellinnehåll",
    #values_from = "value",
#)
