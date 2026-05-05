NTU_all_regions <- function(ntu_grupp = 'Utsatthet för brott') {
  
  # Lista alla filer (kommuner)
  files <- list.files("Data/", pattern = "^df_ind_.*\\.xlsx$", full.names = TRUE)
  if (length(files) == 0) stop("Ingen NTU-data hittades i 'Data/' mappen.")
  
  # Gruppdefinition
  NTU_groups <- list(
    "Utsatthet för brott" = c(
      "Misshandel-NTU", "Sexualbrott-NTU"
    ),
    "Otrygghet och oro för brott" = c(
      "Otrygghet utomhus-NTU", "Oro för misshandel-NTU",
      "Oro för sexualbrott-NTU", "Oro för rån-NTU",
      "Oro för bostadsinbrott-NTU", "Oro stöld skadegörelse bil-NTU",
      "Valt annan väg-NTU", "Avstått aktivitet-NTU"
    ),
    "Problem i bostadsområdet" = c(
      "Skadegörelse-NTU", "Klotter-NTU", "Fortkörning-NTU",
      "Störande körning-NTU", "Påverkad alkohol droger-NTU",
      "Gäng i området-NTU", "Öppen narkotikahandel-NTU",
      "Rån-NTU",
      "Försäljningsbedrägeri-NTU", "Kort_kreditbedrägeri-NTU",
      "Cykelstöld-NTU"
    )
  )
  
  # Hämta sheets från första filen
  all_sheets <- excel_sheets(files[1])
  ntu_sheets <- intersect(NTU_groups[[ntu_grupp]], all_sheets)
  if (length(ntu_sheets) == 0) stop(paste("Inga NTU-ark hittades för gruppen:", ntu_grupp))
  
  # Läs in data för alla kommunfiler
  df_all <- purrr::map_dfr(files, function(file) {
    kommun_namn <- str_extract(basename(file), "(?<=df_ind_).*(?=\\.xlsx)")
    kommun_sheets <- intersect(ntu_sheets, excel_sheets(file))
    
    purrr::map_dfr(kommun_sheets, function(sheet) {
      df <- read_excel(file, sheet = sheet, skip = 1)
      colnames(df)[1] <- 'Region'
      
      df_long <- df %>%
        pivot_longer(-Region, names_to = "variable", values_to = "value") %>%
        mutate(Year = str_extract(variable, "\\d{4}/\\d{4}")) %>%
        select(Region, Year, value) %>%
        mutate(Kommun = kommun_namn, Sheet = sheet)
      
      df_long
    })
  })
  
  # Rensa och fixa etiketter
  df_all <- df_all %>%
    mutate(
      Year = factor(Year, levels = unique(Year)),
      Region = ifelse(Region == "Hela landet", "Hela Riket", Region),
      value = round(value, 2)
    )
  
  # Unika rader för region/år/fråga
  df_all <- df_all %>%
    group_by(Sheet, Region, Year) %>%
    slice(1) %>%
    ungroup()
  
  
  # Samla alla regioner (kommuner + Hela Riket)
  regioner <- unique(df_all$Region)
  n_region <- length(regioner)
  n_sheets <- length(ntu_sheets)
  
  # Färgpalett (du kan ändra här)
  kommun_colors2 <- c(kommun_colors, setNames("#B81867",lan),   # samma färg som Uppsala 
                      "Hela Riket" = "black") # valfri neutral färg, t.ex. grå 
  
  # Byter "Hela landet" till "Hela Riket"
  df_all$Region <- ifelse(df_all$Region == 'Hela landet', 'Hela Riket', df_all$Region)
  
  # Titlar till varje variabel
  ntu_names <- list(
    'Misshandel-NTU' = "Självrapporterad utsatthet för misshandel 2016–2023, enligt NTU 2017–2024. Andel (%) utsatta i befolkningen (16–84 år).",
    'Sexualbrott-NTU' = "Självrapporterad utsatthet för sexualbrott 2016–2023, enligt NTU 2017–2024. Andel (%) utsatta i befolkningen (16–84 år).",
    'Rån-NTU' = "Självrapporterad utsatthet för rån 2016–2023, enligt NTU 2017–2024. Andel (%) utsatta i befolkningen (16–84 år).",
    'Försäljningsbedrägeri-NTU'= "Självrapporterad utsatthet för försäljningsbedrägeri 2016–2023, enligt NTU 2017–2024. Andel (%) utsatta i befolkningen (16–84 år).",
    'Kort_kreditbedrägeri-NTU' = "Självrapporterad utsatthet för kort-/kreditbedrägeri 2016–2023, enligt NTU 2017–2024. Andel (%) utsatta i befolkningen (16–84 år).",
    'Cykelstöld-NTU' = "Självrapporterad utsatthet för cykelstöld bland cykelägare 2016–2023, enligt NTU 2017–2024. Andel (%) utsatta hushåll.",
    'Otrygghet utomhus-NTU' = "Otrygghet vid utevistelse sent på kvällen i det egna bostadsområdet, enligt NTU 2017-2024. Andel (%) i befolkningen (16–84 år) som känner sig ganska/mycket otrygga samt de som avstår från att gå ut på grund av otrygghet.",
    'Oro för misshandel-NTU' = "Oro för att utsättas för misshandel, enligt NTU 2017–2024. Andel (%) i befolkningen (16–84 år) som oroar sig ganska/mycket ofta.",
    'Oro för sexualbrott-NTU' = "Oro för att utsättas för våldtäkt/sexuella angrepp, enligt NTU 2017–2024. Andel (%) i befolkningen (16–84 år) som oroar sig ganska/mycket ofta.",
    'Oro för rån-NTU' = "Oro för att utsättas för rån, enligt NTU 2017-2024. Andel (%) i befolkningen (16–84 år) som oroar sig ganska/mycket ofta.",
    'Oro för bostadsinbrott-NTU' = "Oro för att utsättas för bostadsinbrott, enligt NTU 2017–2024. Andel (%) i befolkningen (16–84 år) som oroar sig ganska/mycket ofta.",
    'Oro stöld skadegörelse bil-NTU' = "Oro för att utsättas för stöld av/skadegörelse på bil (bland hushåll som ägde bil), enligt NTU 2017–2024. Andel (%) i befolkningen (16–84 år) som oroar sig ganska/mycket ofta.",
    'Valt annan väg-NTU' = "Valt en annan väg eller ett annat färdsätt på grund av oro för att utsättas för brott, enligt NTU 2017–2024. Andel (%) i befolkningen (16–84 år) som ganska/mycket ofta gjort detta.",
    'Avstått aktivitet-NTU' = "Avstått från någon aktivitet på grund av oro för att utsättas för brott, enligt NTU 2017–2024. Andel (%) i befolkningen (16–84 år) som ganska/mycket ofta gjort detta.",       
    'Skadegörelse-NTU' = "Problem med skadegörelse i det egna bostadsområdet, enligt NTU 2017–2024. Andel (%) i befolkningen (16–84 år) som upplever problem i stor utsträckning.",          
    'Klotter-NTU'    = "Problem med klotter i det egna bostadsområdet, enligt NTU 2017–2024. Andel (%) i befolkningen (16–84 år) som upplever problem i stor utsträckning.",              
    'Fortkörning-NTU'   = "Problem med fortkörning i det egna bostadsområdet, enligt NTU 2018–2024. Andel (%) i befolkningen (16–84 år) som upplever problem i stor utsträckning.",            
    'Störande körning-NTU'     = "Problem med fortkörning i det egna bostadsområdet, enligt NTU 2018–2024. Andel (%) i befolkningen (16–84 år) som upplever problem i stor utsträckning.",    
    'Påverkad alkohol droger-NTU'   = "Problem med personer påverkade av alkohol eller droger utomhus i det egna bostadsområdet, enligt NTU 2018–2024. Andel (%) i befolkningen (16–84 år) som upplever problem i stor utsträckning.",
    'Gäng i området-NTU'      = "Problem med gäng som uppehåller sig i det egna bostadsområdet, enligt NTU 2018–2024. Andel (%) i befolkningen (16–84 år) som upplever problem i stor utsträckning.",   
    'Öppen narkotikahandel-NTU'   = "Problem med öppen narkotikahandel i det egna bostadsområdet, enligt NTU 2017–2024. Andel (%) i befolkningen (16–84 år) som upplever problem i stor utsträckning."
    
  )
  
  # Bryter titlar med str_wrap
  ntu_titles <- lapply(ntu_names, function(x) str_wrap(x, width = 50))
  
  df_all$value <- round(df_all$value,2)
  
  # Gör åren till ett år istället för tex. 2017/2018
  df_all["Year"] = sub("/.*", "", df_all$Year)
  
  # Bygg plotly-objekt
  fig <- plot_ly()
  
  regioner <- unique(df_all$Region)
  
  # loop över alla variabler och kommuner
  for (sheet in ntu_sheets) {
    df_sheet <- df_all %>% filter(Sheet == sheet)
    
    for (region in unique(df_sheet$Region)) {
      df_region <- df_sheet %>% filter(Region == region)
      
      df_region <- df_region %>% mutate(Year = factor(Year, levels = unique(Year)))
      
      fig <- fig %>%
        add_trace(
          x = df_region$Year,
          y = df_region$value,
          type = "scatter",
          mode = "lines+markers",
          name = region,
          line = list(color = kommun_colors2[region],width = 5),
          marker = list(color = kommun_colors2[region],size = 8),
          visible = ifelse(sheet == ntu_sheets[1], TRUE, FALSE)
        )
    }
  }
  
  # Skapa dropdown-knappar
  buttons <- lapply(seq_along(ntu_sheets), function(i) {
    visible_vec <- rep(FALSE, length(ntu_sheets)*n_region) # Antal frågor * antal platser
    visible_vec[((i-1)*n_region + 1):(i*n_region)] <- TRUE # Index på rätt plats för att rätt linje ska synas
    
    list(
      method = "update",
      args = list(
        list(visible = visible_vec),
        list(title = ntu_titles[[ntu_sheets[i]]]) # Ny titel 
      ),
      label = ntu_sheets[i]
    )
  })
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 150,b=50),
      title = list(text = ntu_titles[[ntu_sheets[1]]], y = 0.95, x = 0.55,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = " ", tickangle = 0),
      yaxis = list(title = "<b>Andel (%)<b>", 
                   rangemode = "tozero"),
      hovermode = 'x unified',
      updatemenus = list(
        list(
          y = 1,
          x=-0.1,
          buttons = buttons,
          direction = "down"
        )),
      annotations = list(
        text ='Källa: NTU',
        x = 0,            
        y = -0.15,        
        xref = "paper",
        yref = "paper",
        xanchor = "left",
        yanchor = "bottom",
        showarrow = FALSE,
        font = list(size = 12)
      )
    )
  
  
  # tar bort plotly-funktioner
  fig <- plotly::config(
    fig,
    modeBarButtonsToRemove = c(
      'zoom2d',     # zoom button
      'pan2d',      # pan button
      'select2d',   # box select
      'lasso2d',    # lasso select
      'zoomIn2d',   # zoom in
      'zoomOut2d'   # zoom out
    ),
    displaylogo = FALSE)   # remove plotly logo/link
  
  fig
}




