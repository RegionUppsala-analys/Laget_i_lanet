SFI_antal <- function(){
  
  df <- read.csv('Data/df_SFI_antal.csv') %>% filter(year > 2005,
                                                     title=='Elever i SFI-utbildning, antal')
  
  # Gör region till faktor för snygg färgordning
  df <- df %>% mutate(municipality =factor(municipality, levels=c(sort(kommuner))))
  df <- df %>% mutate(year = factor(year, levels=c(sort(unique(df$year)))))
  
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
  
  # Lägg till en trace per region
  for (r in levels(df$municipality)) {
    df_sub <- df %>% filter(municipality == r)
    
    df_m <- df_sub %>% filter(gender == 'M')
    fig <- fig %>%
      add_trace(
        data = df_m,
        x = ~year,
        y = ~value ,
        type = 'scatter',
        mode = 'lines+markers',
        name = r,
        line = list(
          color = kommun_colors[r],
          width = 4
        ),
        marker = list(
          size = 6,
          color = kommun_colors[r]
        ),
        legendgroup = r,
        yaxis = "y"
      )
    
    df_k <- df_sub %>% filter(gender == 'K')
    fig <- fig %>%
      add_trace(
        data = df_k,
        x = ~year,
        y = ~value ,
        type = 'scatter',
        mode = 'lines+markers',
        name = r,
        line = list(
          color = kommun_colors[r],
          width = 4
        ),
        marker = list(
          size = 6,
          color = kommun_colors[r]
        ),
        legendgroup = r,
        yaxis = "y2",
        showlegend = FALSE
      )
  }
  
  fig <- fig %>% # Lägger till layout
    layout( 
      hovermode = 'x unified',
      barmode = "group",
      title = list(text=paste("<b>Antal elever i SFI-utbildning<b>"),
                   font = list(size = 20, color = "#B81867")),
      # Top subplot (Män)
      xaxis = list(
        title = "",
        domain = c(0, 1),
        anchor = "y" # namn som las in på trace tidigare
      ),
      yaxis = list(
        title = "<b>Antal<b>", 
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
        title = "<b>Antal<b>", 
        domain = c(0, 0.45),
        anchor = "x2"
      ) ,
      # Titlar för subplots
      annotations = list(
        list(
          x = 0.5, y = 1.02, 
          text = "<b>Män</b>", 
          showarrow = FALSE, 
          xref = "paper", yref = "paper",
          font = list(size = 14)
        ),
        list(
          x = 0.5, y = 0.47, 
          text = "<b>Kvinnor</b>", 
          showarrow = FALSE, 
          xref = "paper", yref = "paper",
          font = list(size = 14)
        ),
        list(
          text = "Källa: SCB",
          x = -0.1,          
          y = -0.05,      
          xref = "paper",
          yref = "paper",
          xanchor = "left",
          yanchor = "bottom",
          showarrow = FALSE,
          font = list(size = 12)
        )
      ),
      margin = list(b = 50, t=50) # extra bottom space
    )
  
  # Tar bort plotly-funktioner
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


SFI <- function(){
  # Läser in data och fixar titlarns
  df <- read.csv('Data/df_SFI.csv') %>% filter(year > 2005, !is.na(value))
  
  df$title <- str_remove_all(df$title, ", andel \\(%\\)")
  df$title <-str_wrap(df$title, width=50)
  titles <- unique(df$title)
  
  # Gör region till faktor för snygg färgordning
  df <- df %>% mutate(municipality =factor(municipality, levels=c(sort(kommuner))))
  df <- df %>% mutate(year = factor(year, levels=c(sort(unique(df$year)))))
  
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
  
  # Lägg till en trace per region och fråga
  for(t in titles){
    temp <- df %>% filter(title == t)
    
    trace_ids <- c()
    for (r in levels(df$municipality)) {
      df_sub <- temp %>% filter(municipality == r)
      
      df_m <- df_sub %>% filter(gender == 'M')
      if(nrow(df_m)>0){
        trace_index <- trace_index + 1
        fig <- fig %>%
          add_trace(
            data = df_m,
            x = ~year,
            y = ~value ,
            type = 'scatter',
            mode = 'lines+markers',
            name = r,
            line = list(
              color = kommun_colors[r],
              width = 4
            ),
            marker = list(
              size = 6,
              color = kommun_colors[r]
            ),
            visible = ifelse(t == titles[1], TRUE, FALSE),
            legendgroup = r,
            yaxis = "y"
          )
        trace_ids <- c(trace_ids, trace_index)
      }
      
      
      df_k <- df_sub %>% filter(gender == 'K')
      if(nrow(df_k)>0){
        trace_index <- trace_index + 1
        fig <- fig %>%
          add_trace(
            data = df_k,
            x = ~year,
            y = ~value ,
            type = 'scatter',
            mode = 'lines+markers',
            name = r,
            line = list(
              color = kommun_colors[r],
              width = 4
            ),
            marker = list(
              size = 6,
              color = kommun_colors[r]
            ),
            visible = ifelse(t == titles[1], TRUE, FALSE),
            legendgroup = r,
            yaxis = "y2",
            showlegend = FALSE
          )
        
        trace_ids <- c(trace_ids, trace_index)
      }
    }
    trace_map[[t]] <- trace_ids 
  }
  
  #  Dropdown  
  buttons <- lapply(seq_along(titles), function(i){
    vis <- rep(FALSE, trace_index) # Vector med false för alla traces
    vis[ trace_map[[ titles[i] ]] ] <- TRUE # fyller med true på rätt plats
    
    list(
      method = "update",
      args = list(
        list(visible = vis),
        list(title = paste("<b>",titles[i],'<b>')) # ny titel per kommun
      ),
      label = titles[i]
    )
  })
  
  
  
  fig <- fig %>% # Lägger till layout
    layout( 
      hovermode = 'x unified',
      barmode = "group",
      title = list(text=paste("<b>",titles[1],'<b>'),
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
        range = c(0,100)
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
        range = c(0,100)
      ) ,
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
          x = 0.5, y = 1.02, 
          text = "<b>Män</b>", 
          showarrow = FALSE, 
          xref = "paper", yref = "paper",
          font = list(size = 14)
        ),
        list(
          x = 0.5, y = 0.47, 
          text = "<b>Kvinnor</b>", 
          showarrow = FALSE, 
          xref = "paper", yref = "paper",
          font = list(size = 14)
        ),
        list(
          text = "Källa: SCB",
          x = -0.1,          
          y = -0.05,      
          xref = "paper",
          yref = "paper",
          xanchor = "left",
          yanchor = "bottom",
          showarrow = FALSE,
          font = list(size = 12)
        )
      ),
      margin = list(b = 30, t=50) # extra bottom space
    )
  
  # Tar bort plotly-funktioner
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
