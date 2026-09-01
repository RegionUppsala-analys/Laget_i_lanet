#### Befolkningspyramider med slider och prognos från scb

library(plotly)
library(pxweb)
library(dplyr)
library(stringr)
library(htmlwidgets)

kommunkod <- c("0330", "0331", "0360", "0380", "0381", "0382", "0305", "0319")
kommuner <- c("Knivsta", "Heby", "Tierp", "Uppsala", "Enköping", "Östhammar", "Håbo", "Älvkarleby")


### Laddar ned data och sparar

####### Framskrivningar från SCB ############
url <- pxweb_url("TAB6008")

px_get_list <- list(Region = kommunkod,
                    InrikesUtrikes = '*',
                    Kon = '*',
                    Alder = '*',
                    ContentsCode = '*',
                    Tid = '*')


px_get <- pxweb_get(url,px_get_list)

# laddar data och gör till rätt format
df_folkmangdfram <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
df_folkmangdfram <- df_folkmangdfram |>
  tidyr::pivot_wider(
    names_from = "tabellinnehåll",
    values_from = "value"
  )
df_folkmangdfram$ålder <- gsub("\\+", "", df_folkmangdfram$ålder)
df_folkmangdfram$ålder <- as.integer(gsub(" år", "", df_folkmangdfram$ålder))
df_folkmangdfram$år = as.integer(df_folkmangdfram$år)
write.csv(df_folkmangdfram, "Data/df_folkmangdfram.csv", row.names = F)

########## Folkmängd ############

url <- pxweb_url("TAB638")

px_get_list <- list(Region = kommunkod,
                    Kon = '*',
                    Alder = '*',
                    ContentsCode = 'BE0101N1',
                    Tid = '*')


px_get <- pxweb_get(url,px_get_list)

# laddar data och gör till rätt format
df_folkmangd <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
df_folkmangd <- df_folkmangd |>
  tidyr::pivot_wider(
    names_from = "tabellinnehåll",
    values_from = "value"
  )
df_folkmangd <- df_folkmangd[df_folkmangd$ålder != 'totalt ålder',]

df_folkmangd$ålder <- gsub("\\+", "", df_folkmangd$ålder)
df_folkmangd$ålder <- as.integer(gsub(" år", "", df_folkmangd$ålder))
df_folkmangd$år = as.integer(df_folkmangd$år)

# sparar data med variabler: region, unrikes/utrikes född, kön, ålder, tid , antal
write.csv(df_folkmangd, "Data/df_folkmangd.csv", row.names = F)



############ Skapar plots och retunerar en lista med alla kommuner + län ##############
befolknigstree_years <- function(){
  
  df_fram <- read.csv('Data/df_folkmangdfram.csv')
  
  # Region 
  minar <- min(df_fram$år) # sorterar bort senaste året plus att jag tar total av inrikes utrikes
  df_fram <- df_fram %>%filter(år>minar,år<=minar+20 , inrikes.utrikes.född == 'inrikes och utrikes födda') %>% 
    select(region, kön, ålder, år, Antal)
  
  df <- read.csv('Data/df_folkmangd.csv')
  df <- df %>% filter(år > 2001)  %>% rename('Antal' = Folkmängd )              # Väljer 2002 som basår
  
  regionmax <- max(df$år)
  # Region , total folkmängd per kön 1986 - 2070
  region <- rbind(df, df_fram)
  region <- region %>% group_by(år, kön, ålder) %>% summarise(Total = ceiling(sum(Antal)), .groups = 'drop')
  region$region <- "Länet"
  
  # Kommun 
  df_kommunfram <- df_fram %>% group_by(region, år, kön, ålder) %>% 
    summarise(Total = ceiling(sum(Antal)), .groups='drop') # Summerar per region år kön ålder
  
  df_kommun <- df %>% group_by(region, år, kön , ålder) %>% 
    summarise(Total = sum(Antal), .groups='drop')
  
  kommun <- rbind(df_kommunfram,df_kommun)
  
  
  # Skapa plotly 
  
  # Kombinera Region + Kommun 
  df_plot <- rbind(
    region %>% select(år,  Total, ålder, region, kön),
    kommun %>% select(år,  Total, ålder, region, kön)
  )
  
  # Gör om mäns värden till negativa för pyramid
  df_plot <- df_plot %>%
    mutate(Total_plot = ifelse(kön == "män", -Total, Total))
  
  # Sortera kommuner alfabetiskt, Region först
  alfabetiska_kommuner <- sort(kommuner)
  unika_regioner <- c("Länet", alfabetiska_kommuner)
  
  
  genders <- c("kvinnor", "män")
  colors <- c("kvinnor" = "#D57667", "män" = "#4AA271")
  # Alla år
  ar_sorterade <- sort(unique(df_plot$år))
  
  # Konvertera år till faktor med rätt levels
  df_plot$år <- factor(df_plot$år, levels = ar_sorterade)
  # Lista som håller grafer
  plots <- list()
  
  # loopar över alla regioner
  for (r in unika_regioner) {
    temp <- df_plot %>% filter(region == r)
    
    p <- plot_ly()
    # Loopar över kön
    for (k in genders) {
      temp_k <- temp %>% filter(kön == k)
      if(nrow(temp_k) == 0) next
      
      # Skapar bars 
      p <- p %>%
        add_bars(
          data = temp_k,
          x = ~Total_plot,
          y = ~ålder,
          frame = ~år, # Slider ska gå över år
          name = tools::toTitleCase(k),
          orientation = "h",
          marker = list(color = colors[k],line = list(width = 0)),
          legendgroup = k,
          showlegend = TRUE,
          text = ~paste0( # Hover-information
            "<b>Kön:</b> ", tools::toTitleCase(k), "<br>",
            "<b>Ålder:</b> ", ålder, "<br>",
            "<b>Befolkning:</b> ", formatC(abs(Total_plot), format = "d", big.mark = " "), " personer<br>",
            "<b>År:</b> ", år
          ),
          hoverinfo = "text",
          textposition = "none"
        )
    }
    max_total <- ceiling(max(abs(temp$Total_plot)))
    # Symmetrisk x-axel med 0 i mitten och endast heltal
    tick_vals <- c(-max_total,-round(max_total/2),-round(max_total/4), 0 ,round(max_total/4),round(max_total/2),max_total )
    
    p <- p %>%
      layout(font = list(family = "sourcesanspro"),
             margin = list(t = 40),
             barmode = 'overlay',
             bargap = 0, # Ändra till 0.01 om barsen inte ska sitta ihop
             title = list(
               text = paste('<b>Befolkningsutveckling i',r,'</b>'),
               font = list(size = 24, color = "#B81867"),
               x = 0.5,       
               y = 1.3
             ),
             yaxis = list(title = "<b>Ålder</b>", font=list(size=18)),
             xaxis = list(title = "Antal", tickformat = ",", font=list(size=18),
                          zeroline = TRUE,
                          tickvals = tick_vals,
                          ticktext = abs(tick_vals))) %>%
      animation_opts(frame = 400, transition = 150, redraw = FALSE) %>% ## Här ändras hastigheten på slidern :)
      animation_slider(
        currentvalue = list(prefix = "År: ")
      )
    
    p <- config(
      p,
      modeBarButtonsToRemove = c(
        'zoom2d',     # zoom button
        'pan2d',      # pan button
        'select2d',   # box select
        'lasso2d',    # lasso select
        'zoomIn2d',   # zoom in
        'zoomOut2d'   # zoom out
      ),
      displaylogo = FALSE)   # remove plotly logo/link
    
    plots[[r]] <- p
    
    
  }
  
  return(plots)
}

# Kör funktionen
plot_list <- befolknigstree_years()

# Loopar över alla kommuner
for (r in names(plot_list)) {
  htmlwidgets::saveWidget(plot_list[[r]], paste0("Figurer/pyramide_slider_", r, ".html"), selfcontained = TRUE)
  print(plot_list[[r]]) # Printar grafen
  
}

