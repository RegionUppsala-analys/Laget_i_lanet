agestructure <- function(){
  # Läser in data
  df_fram <- read.csv('Data/df_folkmangdfram.csv')
  
  # prognosår
  prognosar <- min(df_fram$år) +1
  
  # Fixar data för hela länet först
  minar <- min(df_fram$år) # sorterar bort senaste året plus att jag tar total av inrikes utrikes
  df_fram <- df_fram %>%filter(år>minar,år<=minar+20 , inrikes.utrikes.född == 'inrikes och utrikes födda') 
  
  # Grupperar datan
  regionfram <- df_fram  %>%  group_by(år, ålder) %>% 
    summarise(Total = sum(Antal), .groups='drop') # Summerar per år och ålder
  
  df <- read.csv('Data/df_folkmangd.csv')
  df <- df %>% filter(år > 2001)                 # Väljer 2002 som basår
  
  region <- df %>% group_by( år,ålder ) %>% 
    summarise(Total = sum(Folkmängd), .groups='drop') # Summerar per år och ålder
  
  # Prognosstart = max +1 
  regionmax <- max(region$år)
  # Region , total folkmängd per kön 1986 - 2070
  region <- rbind(region, regionfram)
  
  region$region <- "Länet"
  
  # Skapar ålderkategorier
  region <- region %>% mutate(Åldersgrupp = dplyr::case_when(
    ålder <= 19            ~ "0-19",
    ålder > 19 & ålder <= 39 ~ "20-39",
    ålder > 39 & ålder <= 59 ~ "40-59",
    ålder >= 60 & ålder <= 79 ~ "60-79",
    ålder >= 80 ~ "80+"),
    Åldersgrupp = factor(Åldersgrupp, levels= c("0-19","20-39" , "40-59", "60-79", "80+"))
  )
  
  
  #  Samma som ovan fast per kommun 
  df_kommunfram <- df_fram %>% group_by(region, år,ålder) %>% 
    summarise(Total = sum(Antal), .groups='drop')
  
  df_kommun <- df %>% group_by(region, år, ålder) %>% 
    summarise(Total = sum(Folkmängd), .groups='drop')
  
  kommun <- rbind(df_kommunfram,df_kommun)
  
  
  # Skapar ålderkategorier
  kommun <- kommun %>% mutate(Åldersgrupp = dplyr::case_when(
    ålder <= 19            ~ "0-19",
    ålder > 19 & ålder <= 39 ~ "20-39",
    ålder > 39 & ålder <= 59 ~ "40-59",
    ålder >= 60 & ålder <= 79 ~ "60-79",
    ålder >= 80 ~ "80+"),
    Åldersgrupp = factor(Åldersgrupp, levels= c("0-19","20-39" , "40-59", "60-79", "80+"))
  )
  
  #  Skapa plotly 
  
  # Kombinera Region + Kommun 
  df_plot <- rbind(
    region %>% select(år,  Total , region, Åldersgrupp),
    kommun %>% select(år,  Total, region, Åldersgrupp)
  )
  
  df_plot <- df_plot %>%
    group_by(region, år, Åldersgrupp) %>%
    summarise(Total = sum(Total), .groups = "drop")
  
  df_plot$Total <- ceiling(df_plot$Total)
  
  # Färger per åldersgrupp
  age_group_colors <- c(
    "0-19"   = "#D57667",
    "20-39"  = "#F9B000",
    "40-59"  = "#019CD7",
    "60-79"  = "#4AA271",
    "80+"    = "#B81867")
  
  # Färg till bakrund
  hex_to_rgba <- function(hex, alpha = 0.3) {
    rgb_vals <- col2rgb(hex)
    sprintf("rgba(%d,%d,%d,%f)", rgb_vals[1], rgb_vals[2], rgb_vals[3], alpha)
  }
  
  # Fix till plots
  fillcolor <- hex_to_rgba("#E2E4E5", 0.4)
  alfabetiska_kommuner <- sort(kommuner)
  regions <- c("Länet", alfabetiska_kommuner)
  age_groups<- unique(df_plot$Åldersgrupp )
  
  # Skapa tom figur
  fig <- plot_ly()
  
  # Spara annotationer
  annotations <- list()
  
  # Lägg till traces per region och age_group
  for (r in regions) {
    for (g in age_groups) {
      # Filtrerar data
      temp <- df_plot %>% filter(region == r, Åldersgrupp == g)
      
      if (nrow(temp) > 0) {
        # Lägg till själva linjen
        fig <- fig %>% add_trace(
          x = temp$år,
          y = temp$Total,
          type = "scatter",
          mode = "lines+markers",
          name = g,
          visible = ifelse(r == regions[1], TRUE, FALSE),
          legendgroup = g,
          showlegend= FALSE, 
          line = list(color = age_group_colors[g]),
          marker = list(color = age_group_colors[g])
        )
        
        
        # Hämta sista punkten för annotation
        last_x <- tail(temp$år, 1)
        last_y <- tail(temp$Total, 1)
        
        annotations <- append( # Text i slutet på varje linje
          annotations,
          list(list(
            x = last_x,
            y = last_y,
            text = g,
            xanchor = "left",
            showarrow = FALSE,
            font = list(color = age_group_colors[g], size = 16),
            xshift = 5,
            visible = ifelse(r == regions[1], TRUE, FALSE)
          ))
        )
      }
    }
  }
  # Skapa annotationer för den prognostext
  prognos_annotations <- lapply(regions, function(r){
    
    list(
      text = "Prognosstart",
      x = prognosar,
      y = 1.01,
      xref = 'x',
      yref = 'paper',
      showarrow = TRUE,
      arrowhead = 2,
      arrowcolor = "#6F787E",
      arrowwidth = 2,
      ax = 0,
      ay = -30,
      font = list(color = "#6F787E", size = 16),
      bgcolor = "rgba(255,255,255,0.8)")
    
  })
  
  # Källhänvnisningar
  source_annotation <- list(
    text = "Källa: SCB",
    x = 0,
    y = -0.13,
    xref = "paper",
    yref = "paper",
    xanchor = "left",
    yanchor = "bottom",
    showarrow = FALSE,
    font = list(size = 12),
    align = "left"
  )
  
  all_annotations <- c(annotations, prognos_annotations)
  
  # Dropdown
  buttons <- lapply(seq_along(regions), function(i) {
    # Antal kommuner * antal linjer
    vis <- rep(FALSE, length(regions) * length(age_groups))
    
    # Highlight på rätt plats i listan
    start <- (i-1) * length(age_groups) + 1
    stop  <- i * length(age_groups)
    vis[start:stop] <- TRUE
    
    # vertikal linje
    shapes <-list(
      list(
        type = "line",
        x0 = prognosar,
        x1 = prognosar,
        y0 = 0,
        y1 = 1,
        xref = "x",
        yref = "paper",
        line = list(
          color = "#6F787E",
          width = 2,
          dash = "dash"
        )
      )
    )
    
    # annotations synlighet för denna region
    ann_vis <- all_annotations
    for (j in seq_along(ann_vis)) {
      # Keep prognos_annotations always visible
      if (j > length(annotations)) {
        ann_vis[[j]]$visible <- TRUE
      } else {
        ann_vis[[j]]$visible <- (j > start-1 & j <= stop)
      }
    }
    
    ann_vis <- c(ann_vis, list(source_annotation))
    
    list(
      method = "update",
      args = list(list(visible = vis),
                  list(annotations =  ann_vis,
                       shapes = shapes)),
      label = regions[i]
    )
  })
  
  
  # Lägg till layout
  fig <- fig %>%
    layout( 
      margin = list(t = 100,b=20),  # t = top padding i pixlar
      title=  list(text = "<b>Befolkningsutveckling per åldersgrupp<b>",
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = ""),
      yaxis = list(title = "<b>Folkmängd<b>"),
      updatemenus = list(
        list(
          active = 0,
          type = "dropdown",
          buttons = buttons,
          x = 0.1,
          y = 1.15
        )
      ),
      annotations = c(all_annotations,list(source_annotation)),
      
      shapes=list(
        list(
          type = "line",
          x0 = prognosar,
          x1 = prognosar,
          y0 = 0,
          y1 = 1,
          xref = "x",
          yref = "paper",
          line = list(
            color = "#6F787E",
            width = 2,
            dash = "dash"
          )
        )
      ),
      hovermode = 'x unified' # hoverover funktion
    )
  
  
  # Tar bort plotlyknappar
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