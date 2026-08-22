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
