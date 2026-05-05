####### Utbildningsnivåer #######

utbildnings_niv <- function(){
  # Läser in data
  df <- read.csv('Data/df_utbildning.csv')
  
  # Fixar till data
  df_plot <- df %>% filter(as.integer(år) > 2002) %>% 
    mutate(
      utbildningsnivå = str_to_title(utbildningsnivå),
      kön = str_to_title(kön)
    ) # sorterar bort år 
  
  # Fixar indelning på grupper samt deras namn
  df_plot <- df_plot %>% 
    mutate(
      utbildningsnivå = case_when(
        utbildningsnivå %in% c("Gymnasial Utbildning, Högst 2 År", 
                               "Gymnasial Utbildning, 3 År") ~ "Gymnasial Utbildning",
        utbildningsnivå %in% c("Eftergymnasial Utbildning, Mindre Än 3 År", 
                               "Eftergymnasial Utbildning, 3 År Eller Mer") ~ "Eftergymnasial Utbildning",
        TRUE ~ utbildningsnivå
      )
    ) %>%
    group_by(region, utbildningsnivå, kön, år) %>%
    summarise(Antal = sum(Antal, na.rm = TRUE), .groups = 'drop') # summerar antal
  
  # Byter namn till länet
  df_plot$region[df_plot$region==lan] <- "Länet"
  
  # Beräknar andel
  df_plot <-  df_plot %>% group_by(år, region, kön) %>% mutate(Total = sum(Antal),
                                                               Andel = (Antal/Total)*100) %>% ungroup()
  
  # Gör om till factorvariabel
  df_plot <- df_plot %>% 
    mutate(
      utbildningsnivå = factor(utbildningsnivå, levels = c(
        "Förgymnasial Utbildning Kortare Än 9 År",
        "Förgymnasial Utbildning, 9 (10) År",
        "Gymnasial Utbildning",
        "Eftergymnasial Utbildning",
        "Forskarutbildning",
        "Uppgift Om Utbildningsnivå Saknas"
      ))
    )
  
  # Skapar variabler till plot
  kommun_lan <-c("Länet", sort(kommuner))
  df_plot <- df_plot %>% arrange(factor(region, levels=kommun_lan)) # ordnar data
  regions <- unique(df_plot$region)
  
  # Färgschema
  col_map <- c(
    "Förgymnasial Utbildning Kortare Än 9 År" = "#D57667",
    "Förgymnasial Utbildning, 9 (10) År"      = "#F9B000",
    "Gymnasial Utbildning"                    = "#019CD7",
    "Eftergymnasial Utbildning"               = "#4AA271",
    "Forskarutbildning"                       = "#B81867",
    "Uppgift Om Utbildningsnivå Saknas"       = "#6F787E"
  )
  
  
  #  Skapar traces, en för män och en för kvinnor
  fig <- plot_ly() %>%
    add_trace(
      x = c(), y = c(), 
      type = "scatter", mode = "lines",
      xaxis = "x", yaxis = "y"
    ) %>%
    add_trace(
      x = c(), y = c(),
      type = "scatter", mode = "lines", 
      xaxis = "x", yaxis = "y2"
    )
  
  # Tar bort datat för de skapade
  fig$x$data <- list()
  
  # Hålla koll på traces och index
  trace_index <- 2 # Börjar på index 2 iom att fig skapats ovan
  trace_map <- list()
  
  all_utbildningsnivåer <- levels(df_plot$utbildningsnivå)
  
  for (r in regions){
    # Filtrarar kommun
    temp <- df_plot %>% filter(region == r)
    
    trace_ids <- c()
    
    for (u in all_utbildningsnivåer){
      
      # Trace för män
      temp_man <- temp %>% filter(utbildningsnivå == u, kön == "Män")
      
      if(nrow(temp_man) > 0) {
        trace_index <- trace_index + 1
        fig <- fig %>% add_trace(
          data = temp_man,
          x = ~år,
          y = ~Andel,
          name = u,
          type = "scatter",
          mode = "lines+markers",
          marker = list(color = col_map[u]),
          line = list(color = col_map[u]),
          legendgroup = u,
          visible = ifelse(r == regions[1], TRUE, FALSE),
          yaxis = "y" # Y-axeln män utgår ifrån
        )
        trace_ids <- c(trace_ids, trace_index)
      }
      
      # Trace för kvinnor
      temp_kvinna <- temp %>% filter(utbildningsnivå == u, kön == "Kvinnor")
      
      if(nrow(temp_kvinna) > 0) {
        trace_index <- trace_index + 1
        fig <- fig %>% add_trace(
          data = temp_kvinna,
          x = ~år,
          y = ~Andel,
          name = u,
          type = "scatter",
          mode = "lines+markers",
          marker = list(color = col_map[u]),
          line = list(color = col_map[u]),
          legendgroup = u,
          showlegend = FALSE,
          visible = ifelse(r == regions[1], TRUE, FALSE),
          yaxis = "y2" # Y-axeln kvinnor utgår ifrån
        )
        trace_ids <- c(trace_ids, trace_index)
        
      }
    }
    
    trace_map[[r]] <- trace_ids # Fyller i traces för kommunen
    
  }
  
  #  Dropdown  
  buttons <- lapply(seq_along(regions), function(i){
    vis <- rep(FALSE, trace_index) # Vector med false för alla traces
    vis[ trace_map[[ regions[i] ]] ] <- TRUE # fyller med true på rätt plats
    
    list(
      method = "update",
      args = list(
        list(visible = vis),
        list(title = paste("<b>Utbildningsnivå över tid –", regions[i],"<b>")) # ny titel per kommun
      ),
      label = regions[i]
    )
  })
  
  # Layout med manual subplot configuration 
  fig <- fig %>% layout(
    hovermode = 'x unified', # hoverfunktion
    
    title = list(text=paste("<b>Utbildningsnivå över tid –", regions[1],'<b>'),
                 font = list(size = 20, color = "#B81867")),
    # Top subplot (Män)
    xaxis = list(
      title = "",
      domain = c(0, 1),
      anchor = "y" # namn som las in på trace tidigare
    ),
    yaxis = list(
      title = "<b>Andel (%)<b>", 
      domain = c(0.55, 1),
      anchor = "x"
    ),
    # Bottom subplot (Kvinnor)
    xaxis2 = list(
      title = "År",
      domain = c(0, 1),
      anchor = "y2" # namn som las in på trace tidigare
    ),
    yaxis2 = list(
      title = "<b>Andel (%)<b>", 
      domain = c(0, 0.45),
      anchor = "x2"
    ),
    updatemenus = list(
      list(
        x = -0.1,
        xanchor = "left",
        y = 1.05,
        yanchor = "bottom",
        buttons = buttons
      )
    ),
    # Titlar för subplots
    annotations = list(
      list(
        x = 0.5, y = 1.04, 
        text = "<b>Män</b>", 
        showarrow = FALSE, 
        xref = "paper", yref = "paper",
        font = list(size = 14)
      ),
      list(
        x = 0.5, y = 0.48, 
        text = "<b>Kvinnor</b>", 
        showarrow = FALSE, 
        xref = "paper", yref = "paper",
        font = list(size = 14)
      ),
      list(
        text = "Källa: SCB",
        x = -0.1,          
        y = -0.2,      
        xref = "paper",
        yref = "paper",
        xanchor = "left",
        yanchor = "bottom",
        showarrow = FALSE,
        font = list(size = 12)
      )
    ),
    # Placering/layout av legenden 
    legend = list(
      orientation = "h",   
      x = 0.5,             
      y = -0.1,           
      xanchor = "center",
      yanchor = "top"
    ),
    margin = list(b = 100) # extra bottom space
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


utbildnings_karta <- function(){
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_deso_utbildning.gpkg")
      deso_sf <- st_read("Data/df_deso_utbildning.gpkg", quiet = TRUE) 
    })
  })
  
  #  Räkna andelar per DeSO 
  andelar_deso <- deso_sf %>%
    group_by(desokod) %>%
    mutate(
      Total = sum(Befolkning, na.rm = TRUE),
      Andel = round(100 * Befolkning / Total, 1)
    ) %>%
    ungroup()
  
  #  Bygg popup-texten med andelar
  popup_text <- andelar_deso %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          str_to_title(utbildningsnivå), ": ", Andel, "% (", Befolkning, " st)",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  # filtrerar dom med andast förgymnasial utbildning
  andel_utanf <- andelar_deso %>%
    filter(utbildningsnivå == "förgymnasial utbildning") 
  
  # slår ihop med popuptext
  deso_sf_pop <- andel_utanf %>%
    left_join(popup_text, by = "desokod")
  
  # Labels som visas vid hoverover
  deso_sf_pop$label <- paste(
    "DeSO: ", deso_sf_pop$desokod,  " | ",
    'Andel förgymnasial utbildning:',
    deso_sf_pop$Andel,'%' )
  
  # Största andelen används för färg med "at" i mapview
  maxandel <- max(deso_sf_pop$Andel)
  
  # Skapar karta
  map <- mapview(
    deso_sf_pop,
    zcol = "Andel",
    legend = TRUE,
    layer.name = paste("Andel med endast förgymnasial utbildning", unique(deso_sf$år)),
    at =  seq(0,maxandel+round(maxandel/5),round(maxandel/5)), # färgbrytningar
    col.regions = viridis::cividis(11), # färgschema
    popup = deso_sf_pop$popup, # popuptext när man trycker
    label =  deso_sf_pop$label
  )
  
  # fixar legendtextens alignment
  map@map <- map@map %>%
    htmlwidgets::prependContent(
      htmltools::tags$style(
        ".info.legend { text-align: left !important; }"
      )
    )
  
  
  map
  
}


andel_behoerig <- function(){
  # Läser in data
  df <- read.csv('Data/df_behorig.csv')
  
  # Färger för könen
  colors <- c("kvinnor" = "#D57667", "män" = "#4AA271")
  
  df <- df %>% arrange(factor(region, levels=order(kommuner))) # ordnar data
  
  regioner <- sort(kommuner)
  
  fig <- plot_ly()
  
  # Loopar över regionerna
  for(i in 1:length(regioner)){
    r <- regioner[i]
    
    # Filtrerar data
    temp_man <- df %>% filter(region == r, bakgrundsvariabel == 'män')
    temp_kvinna <- df %>% filter(region == r, bakgrundsvariabel == 'kvinnor')
    
    # Första grafen ska vara synlig
    is_visible <- if(i == 1) TRUE else FALSE
    
    fig <- fig %>%
      # Män trace
      add_trace(
        data = temp_man,
        x = ~år, 
        y = ~Andel.behöriga.till.gymnasium..procent,
        type = 'scatter',
        mode = 'lines+markers',
        name = paste('Män'),
        line = list(color = colors[["män"]], width = 5),
        marker = list(color = colors[["män"]], size = 10),
        visible = is_visible,
        showlegend = TRUE,
        legendgroup = r
      ) %>%
      # Kvinnor trace
      add_trace(
        data = temp_kvinna,
        x = ~år, 
        y = ~Andel.behöriga.till.gymnasium..procent,
        type = 'scatter',
        mode = 'lines+markers',
        name = paste('Kvinnor'),
        line = list(color = colors[["kvinnor"]], width = 5),
        marker = list(color = colors[["kvinnor"]], size = 10),
        visible = is_visible,
        showlegend = TRUE,
        legendgroup = r
      )
  }
  
  # Create dropdown buttons
  dropdown_buttons <- list()
  
  for(i in 1:length(regioner)){
    r <- regioner[i]
    
    # False för antal kommuner * 2(könen)
    visibility <- rep(FALSE, length(regioner) * 2)  
    visibility[((i-1)*2 + 1):(i*2)] <- TRUE  # TRue på rätt plats
    
    dropdown_buttons[[i]] <- list(
      method = "update",
      args = list(list(visible = visibility),
                  list(title = paste("<b>Andel behöriga till gymnasium -", r,"<b>"))),
      label = r
    )
  }
  
  # Min max för samma y-på graferna
  y_min <- 0
  y_max <- 100
  
  #  layout 
  fig <- fig %>%
    layout( 
      hovermode = 'x unified',
      title = list(text=paste("<b>Andel behöriga till gymnasium -", regioner[1],'<b>'),
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = ""),
      yaxis = list(title = "<b>Andel (%)<b>",
                   range = c(y_min, y_max)  ),
      annotations = list( list(
        text = "Källa: SCB",
        x = 0,          
        y = -0.1,      
        xref = "paper",
        yref = "paper",
        xanchor = "left",
        yanchor = "bottom",
        showarrow = FALSE,
        font = list(size = 12)
      )),
      updatemenus = list(
        list(
          type = "dropdown",
          direction = "down",
          showactive = TRUE,
          x = 0.1,
          y = 1.06,
          buttons = dropdown_buttons
        )
      )
    )
  
  # Tar bort plotly funktioner  
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


hogskole_overgang <- function(){
  # läser in data och hanterar årsintervallen
  df <- read.csv('Data/df_hogskole_overgang.csv')
  year <-  as.integer(sub("^(\\d{2})(\\d{2})/(\\d{2})$", "\\1\\3", df$läsår))
  
  # Fixar till data
  df$läsår <- year
  df <- df %>% 
    mutate(kön = tools::toTitleCase(kön))
  
  # Färgschema för kön
  color_map <- c(
    "Män" = "#4AA271",
    "Kvinnor" = "#D57667"
  )
  
  df$region[df$region==lan] <- 'Länet'
  
  # sorterar data
  ordr <- c('Länet', sort(kommuner))
  
  
  
  fig <- plot_ly()
  
  # globalt max för y-axeln
  ymax <- max(df$Övergångsfrekvens..procent, na.rm = TRUE)  
  
  # Loopar över alla åren
  for (r in ordr) {
    df_year <- df %>% filter(region == r)
    
    for (sex in sort(unique(df$kön))) { # loopar över könen
      df_sex <- df_year %>% filter(kön == sex)
      
      # Skapar hoverover text layout
      
      df_sex <- df_sex %>% 
        mutate(hovertext = paste0(
          läsår,"\n",
          'Avgång från gymnasie: ', Avgångna.från.gymnasieskolan..antal,'\n',
          'Påbörjat högskola inom 3 år: ', Påbörjat.högskolestudier.inom.tre.år..antal,'\n',
          'Andel: ', Övergångsfrekvens..procent ))
      
      fig <- fig %>% add_trace(
        data = df_sex,
        x = ~läsår,
        y = ~Övergångsfrekvens..procent,
        type = "scatter",
        mode = 'lines+markers',
        hoverinfo = 'text',
        hovertext = ~hovertext,
        marker = list(color = color_map[sex], size=10),
        line = list(color= color_map[sex], width = 5),
        name = sex,
        visible = ifelse(r == ordr[1], TRUE, FALSE) # endast första regionen synlig först
      )
    }
  }
  
  # antal traces = antal år * antal kön
  n_traces <- length(ordr) * length(unique(df$kön))
  
  # Dropdown-steg
  steps <- lapply(seq_along(ordr), function(i) {
    vis <- rep(FALSE, n_traces)
    idx <- ((i - 1) * length(unique(df$kön)) + 1):(i * length(unique(df$kön)))
    vis[idx] <- TRUE
    
    list(
      method = "restyle",
      args = list("visible", vis),
      label = ordr[i]
    )
  })
  
  # layout
  fig <- fig %>% layout( 
    margin = list(t = 40),
    barmode = "group",
    title = list(text="<b>Högskoleövergångar<b>",
                 font = list(size = 20, color = "#B81867")),
    xaxis = list(title = ""),
    yaxis = list(title = "<b>Andel (%)<b>", range = c(0, ymax)),
    hovermode = "x unified",
    annotations = list(list(
      text = "Källa: SCB",
      x = 0,          
      y = -0.1,      
      xref = "paper",
      yref = "paper",
      xanchor = "left",
      yanchor = "bottom",
      showarrow = FALSE,
      font = list(size = 12)
    )),
    updatemenus = list(
      list(
        active = 0,
        type = "dropdown",
        buttons = steps,
        x = 0,
        xanchor = "left",
        y = 1.1,
        yanchor = "top",
        direction = "down",
        showactive = TRUE
      )
    )
  )
  
  # Tar bort plotly funktioner
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


utbildningsniva_fodelse <- function(){
  # Läser in data
  utbildningsniva <- read.csv('Data/df_utbildningsniva.csv')
  
  # År efter 2004
  
  utbildningsniva <- utbildningsniva %>% filter(år >2004)
  
  # Gör till longdata
  utbildningsniva <- utbildningsniva %>%
    pivot_longer(cols = c(Födda.i.Sverige, Utrikes.födda),
                 names_to = "födelseregion",
                 values_to = "Andel")
  
  # Namnger variablerna och gör till factor
  utbildningsniva <- utbildningsniva %>%
    mutate(
      Utbildningsniva = case_when(
        str_detect(bakgrundsvariabel, "förgymnasial") ~ "Förgymnasial",
        str_detect(bakgrundsvariabel, "eftergymnasial") ~ "Eftergymnasial",  # must come before gymnasial
        str_detect(bakgrundsvariabel, "gymnasial") ~ "Gymnasial",
        str_detect(bakgrundsvariabel, "saknas") ~ "Uppgift saknas"
      ),
      Födelseregion = case_when(
        str_detect(födelseregion, 'Sverige') ~ 'Födda i Sverige',
        str_detect(födelseregion, 'Utrikes') ~ 'Utrikesfödda'),
      # Ordning på utbildningsnivån
      Utbildningsniva = factor(Utbildningsniva, 
                               levels = c("Förgymnasial", 
                                          "Gymnasial", 
                                          "Eftergymnasial", 
                                          "Uppgift saknas"))
    )
  
  # Färgschema
  col_map <- c("Födda i Sverige" = "#F9B000",
               "Utrikesfödda"  = "#4AA271")
  
  utbildningsniva <- utbildningsniva %>%  mutate(kön = str_to_title(kön))
  # tar ut utbildningsnivåer
  
  x_vars <- levels(utbildningsniva$Utbildningsniva)
  regions <- unique(utbildningsniva$Födelseregion)
  
  #  Skapar traces, en för män och en för kvinnor
  fig <- plot_ly() %>%
    add_trace(
      x = c(), y = c(), 
      type = "scatter", mode = "lines",
      xaxis = "x", yaxis = "y"
    ) %>%
    add_trace(
      x = c(), y = c(),
      type = "scatter", mode = "lines", 
      xaxis = "x", yaxis = "y2"
    )
  
  # Tar bort datat för de skapade
  fig$x$data <- list()
  
  # Hålla koll på traces och index
  trace_index <- 2 # Börjar på index 2 iom att fig skapats ovan
  trace_map <- list()
  
  
  for (r in x_vars){
    # Filtrarar kommun
    temp <- utbildningsniva %>% filter(Utbildningsniva == r)
    
    trace_ids <- c()
    
    for (u in regions){
      
      # Trace för män
      temp_man <- temp %>% filter(Födelseregion == u, kön == "Män")
      
      if(nrow(temp_man) > 0) {
        trace_index <- trace_index + 1
        fig <- fig %>% add_trace(
          data = temp_man,
          x = ~år,
          y = ~Andel,
          name = u,
          type = "scatter",
          mode = "lines+markers",
          marker = list(color = col_map[u], size =8),
          line = list(color = col_map[u], width =5),
          legendgroup = u,
          visible = ifelse(r == x_vars[1], TRUE, FALSE),
          yaxis = "y" # Y-axeln män utgår ifrån
        )
        trace_ids <- c(trace_ids, trace_index)
      }
      
      # Trace för kvinnor
      temp_kvinna <- temp %>% filter(Födelseregion == u, kön == "Kvinnor")
      
      if(nrow(temp_kvinna) > 0) {
        trace_index <- trace_index + 1
        fig <- fig %>% add_trace(
          data = temp_kvinna,
          x = ~år,
          y = ~Andel,
          name = u,
          type = "scatter",
          mode = "lines+markers",
          marker = list(color = col_map[u], size =8),
          line = list(color = col_map[u], width =5),
          legendgroup = u,
          showlegend = FALSE,
          visible = ifelse(r == x_vars[1], TRUE, FALSE),
          yaxis = "y2" # Y-axeln kvinnor utgår ifrån
        )
        trace_ids <- c(trace_ids, trace_index)
        
      }
    }
    
    trace_map[[r]] <- trace_ids # Fyller i traces för kommunen
    
  }
  
  #  Dropdown  
  buttons <- lapply(seq_along(x_vars), function(i){
    vis <- rep(FALSE, trace_index) # Vector med false för alla traces
    vis[ trace_map[[ x_vars[i] ]] ] <- TRUE # fyller med true på rätt plats
    
    list(
      method = "update",
      args = list(
        list(visible = vis),
        list(title = paste("<b>Utbildningsnivå -", x_vars[i],'<b>')) # ny titel per kommun
      ),
      label = x_vars[i]
    )
  })
  
  # Layout med manual subplot configuration 
  fig <- fig %>% layout( 
    hovermode = 'x unified', # hoverfunktion
    
    title = list(text=paste("<b>Utbildningsnivå -", x_vars[1],'<b>'),
                 font = list(size = 20, color = "#B81867")),
    # Top subplot (Män)
    xaxis = list(
      title = "",
      domain = c(0, 1),
      anchor = "y" # namn som las in på trace tidigare
    ),
    yaxis = list(
      title = "<b>Andel (%)<b>", 
      domain = c(0.55, 1),
      anchor = "x",
      range = c(0, 65) 
    ),
    # Bottom subplot (Kvinnor)
    xaxis2 = list(
      title = "År",
      domain = c(0, 1),
      anchor = "y2" # namn som las in på trace tidigare
    ),
    yaxis2 = list(
      title = "<b>Andel (%)<b>", 
      domain = c(0, 0.45),
      anchor = "x2",
      range = c(0, 65)
    ),
    updatemenus = list(
      list(
        x = -0.1,
        xanchor = "left",
        y = 1.05,
        yanchor = "bottom",
        buttons = buttons
      )
    ),
    # Titlar för subplots
    annotations = list(
      list(
        x = 0.5, y = 1.04, 
        text = "<b>Män</b>", 
        showarrow = FALSE, 
        xref = "paper", yref = "paper",
        font = list(size = 14)
      ),
      list(
        x = 0.5, y = 0.48, 
        text = "<b>Kvinnor</b>", 
        showarrow = FALSE, 
        xref = "paper", yref = "paper",
        font = list(size = 14)
      ),
      list(
        text = "Källa: SCB",
        x = -0.1,          
        y = -0.2,      
        xref = "paper",
        yref = "paper",
        xanchor = "left",
        yanchor = "bottom",
        showarrow = FALSE,
        font = list(size = 12)
      )
    ),
    # Placering/layout av legenden 
    legend = list(
      orientation = "h",   
      x = 0.5,             
      y = -0.15,           
      xanchor = "center",
      yanchor = "top"
    ),
    margin = list(b = 50) # extra bottom space
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
