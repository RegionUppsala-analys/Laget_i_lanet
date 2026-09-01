func_kommun_shape <- function() {
  url <- "https://www.scb.se/contentassets/3443fea3fa6640f7a57ea15d9a372d33/shape_svenska_250121.zip"
  output_file <- "Data/shape.zip"

  if (!file.exists(output_file)) {
    httr::GET(url, httr::write_disk(output_file, overwrite = TRUE))
  }

  unzip(output_file, files = "Kommun_Sweref99TM.zip", exdir = "Data")
  unzip(output_file, files = "LanSweref99TM.zip", exdir = "Data")
  unzip("Data/Kommun_Sweref99TM.zip", exdir = "Data/Kommun_Sweref99TM")
  unzip("Data/LanSweref99TM.zip", exdir = "Data/Lan_Sweref99TM")

  print('Nedladdning av "Kommun_Sweref99TM" och "LanSweref99TM" har genomförts')
}
