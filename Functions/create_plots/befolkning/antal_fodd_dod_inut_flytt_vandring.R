### Alla grafer med prognosstart som en linje går att förenkla och behöver inte vara i en loop ->> Jobb för framtiden!
### Från början var tanken att fylla prognosperioden med en skugga, vilket kräver loop!
# Dessa tre är extra krångligt gjorda och skulle kunna kortas ner rejält

########################## Antal födda och döda #####################
antal_fodda_doda_plot <- function(){
  # Läser in data
  df <- read.csv('Data/df_foddadoda.csv')
  
  # prognosår
  df_fram <- read.csv('Data/df_folkmangdfram.csv')
  prognosar <- min(df_fram$år) +1
  
  # 20 år framåt(utgår från att datat är ett år gammalt därav + 19): 
  cur_year <- as.integer(format(Sys.Date(), "%Y"))
  df <- df %>% filter(år<=cur_year+19)%>% group_by(region,år) %>%
    summarise(Födda = sum(Tot_födda ),Döda = sum(Tot_döda), .groups = 'drop')
  
  # skapa regionsvariabel
  region <- df %>% group_by(år) %>% summarise(Födda = sum(Födda ),
                                              Döda = sum(Döda), .groups = 'drop')
  
  region$region <- 'Länet'
  
  # Slår ihop dataseten
  df <- rbind(
    region %>% select(år,  Födda,Döda , region),
    df %>% select(år,  Födda, Döda, region)
  )
  # Gör variablerna till heltal och skapar nettofödsel
  df<-df %>%
    mutate(Födda =  as.integer(Födda) , Döda = as.integer(Döda))
  
  # Beräknar födelsenetto
  df<-df %>%
    mutate(Födelsenetto = Födda - Döda)
  
  
  colors <- c("Döda" = "#F9B000",
              "Födda" = "#019CD7",
              "Födelsenetto" = "#4AA271")
  
  regions  <- c("Länet", sort(kommuner))
  
  # Start på länet
  initial_region <- regions[1]
  initial_data <- df %>% filter(region == initial_region)
  
  # max-år för text efter linje
  last_year <- max(initial_data$år)
  
  # trace per metric
  p <- plot_ly() %>%
    # Döda 
    add_trace(
      data = initial_data,
      x = ~år, 
      y = ~Döda,
      type = 'scatter',
      mode = 'lines+markers',
      name = 'Döda',
      line = list(color = colors[["Döda"]], width = 2),
      marker = list(color = colors[["Döda"]], size = 6),
      visible = TRUE,
      showlegend = FALSE
    ) %>%
    # Födda 
    add_trace(
      data = initial_data,
      x = ~år, 
      y = ~Födda,
      type = 'scatter',
      mode = 'lines+markers',
      name = 'Födda',
      line = list(color = colors[["Födda"]], width = 2),
      marker = list(color = colors[["Födda"]], size = 6),
      visible = TRUE,
      showlegend = FALSE
    ) %>%
    # Netto
    add_trace(
      data = initial_data,
      x = ~år, 
      y = ~Födelsenetto,
      type = 'scatter',
      mode = 'lines+markers',
      name = 'Födelsenetto',
      line = list(color = colors[["Födelsenetto"]], width = 2),
      marker = list(color = colors[["Födelsenetto"]], size = 6),
      visible = TRUE,
      showlegend = FALSE
    )
  
  # Loop över resten
  for(i in 2:length(regions)) {
    region_data <- df %>% filter(region == regions[i])
    
    p <- p %>%
      add_trace(
        data = region_data,
        x = ~år, 
        y = ~Döda,
        type = 'scatter',
        mode = 'lines+markers',
        name = 'Döda',
        line = list(color = colors[["Döda"]], width = 2),
        marker = list(color = colors[["Döda"]], size = 6),
        visible = FALSE,
        showlegend = FALSE
      ) %>%
      add_trace(
        data = region_data,
        x = ~år, 
        y = ~Födda,
        type = 'scatter',
        mode = 'lines+markers',
        name = 'Födda',
        line = list(color = colors[["Födda"]], width = 2),
        marker = list(color = colors[["Födda"]], size = 6),
        visible = FALSE,
        showlegend = FALSE
      ) %>%
      add_trace(
        data = region_data,
        x = ~år, 
        y = ~Födelsenetto,
        type = 'scatter',
        mode = 'lines+markers',
        name = 'Födelsenetto',
        line = list(color = colors[["Födelsenetto"]], width = 2),
        marker = list(color = colors[["Födelsenetto"]], size = 6),
        visible = FALSE,
        showlegend = FALSE
      )
  }
  
  # Lista för annotations
  all_annotations <- list()
  
  source_annotation <- list(
    text = "Källa: SCB",
    x = 0,            
    y = -0.13,        
    xref = "paper",
    yref = "paper",
    xanchor = "left",
    yanchor = "bottom",
    showarrow = FALSE,
    font = list(size = 12)
  )
  
  
  # Text för prognoslinjen
  all_annotations[[1]] <- list(
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
    bgcolor = "rgba(255,255,255,0.8)"
  )
  
  # label per linje
  annotation_index <- 2
  for(i in 1:length(regions)) {
    region_data <- df %>% filter(region == regions[i])
    region_last_year <- max(region_data$år)
    region_last_values <- region_data[region_data$år == region_last_year, ]
    
    if(nrow(region_last_values) > 0) {
      # Döda annotation
      all_annotations[[annotation_index]] <- list(
        x = region_last_year,
        y = region_last_values$Döda,
        text = "Döda",
        xref = "x",
        yref = "y",
        showarrow = FALSE,
        xanchor = "left",
        xshift = 5,
        font = list(color = colors[["Döda"]], size = 16),
        visible = if(i == 1) TRUE else FALSE
      )
      annotation_index <- annotation_index + 1
      
      # Födda annotation
      all_annotations[[annotation_index]] <- list(
        x = region_last_year,
        y = region_last_values$Födda,
        text = "Födda",
        xref = "x",
        yref = "y",
        showarrow = FALSE,
        xanchor = "left",
        xshift = 5,
        font = list(color = colors[["Födda"]], size = 16),
        visible = if(i == 1) TRUE else FALSE
      )
      annotation_index <- annotation_index + 1
      
      # Födelsenetto annotation
      all_annotations[[annotation_index]] <- list(
        x = region_last_year,
        y = region_last_values$Födelsenetto,
        text = "Födelsenetto",
        xref = "x",
        yref = "y",
        showarrow = FALSE,
        xanchor = "left",
        xshift = 5,
        font = list(color = colors[["Födelsenetto"]], size = 16),
        visible = if(i == 1) TRUE else FALSE
      )
      annotation_index <- annotation_index + 1
    }
  }
  
  all_annotations <- c(all_annotations, list(source_annotation))
  
  # Dropdown
  dropdown_buttons <- list()
  for(i in 1:length(regions)) {
    # Create visibility vector: show traces for selected region, hide others
    trace_visibility <- rep(FALSE, length(regions) * 3)
    trace_visibility[((i-1)*3 + 1):(i*3)] <- TRUE
    
    # Create visibility vector for annotations
    # First two annotations (title and prognosis) are always visible, then 3 annotations per region
    updated_annotations <- all_annotations
    # Keep first two annotations always visible
    updated_annotations[[1]]$visible <- TRUE
    # Update region-specific annotations
    for(j in 2:length(updated_annotations)) {
      region_index <- ceiling((j-1)/3)
      updated_annotations[[j]]$visible <- (region_index == i)
    }
    # Visa källa
    updated_annotations[[length(updated_annotations)]]$visible <- TRUE
    
    dropdown_buttons[[i]] <- list(
      method = "update",
      args = list(
        list(visible = trace_visibility),
        list(annotations = updated_annotations)
      ),
      label = regions[i]
    )
  }
  
  # Layout
  p <- p %>%
    layout(
      margin = list(t = 100,b=50),  # t = top padding i pixlar
      title =  list(text=paste("<b>Födda, Döda och Netto per region (2003-",max(initial_data$år),')<b>', sep=""),
                    font = list(size = 20, color = "#B81867")),
      xaxis = list(
        title = "",
        showgrid = TRUE
      ),
      yaxis = list(
        title = "<b>Antal<b>",
        showgrid = TRUE
      ),
      updatemenus = list( # dropdown
        list(
          type = "dropdown",
          direction = "down",
          showactive = TRUE,
          x = 0.1,
          y = 1.5,
          buttons = dropdown_buttons
        )
      ),
      annotations = all_annotations,
      hovermode = 'x unified',
      showlegend = FALSE,
      shapes = list( # linje för prognosstart
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
    )
  
  # tar bort plotly-funktioner
  p <- plotly::config(
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
  # Display the plot
  p
}
########################## inrikes utrikes flytt#####################

antal_in_ut_flytt_plot <- function(){
  # Läser in datat
  df <- read.csv('Data/df_inut_flytt.csv')
  
  # prognosår
  df_fram <- read.csv('Data/df_folkmangdfram.csv')
  prognosar <- min(df_fram$år) +1
  
  # 20 år framåt(utgår från att datat är ett år gammalt därav + 19): 
  cur_year <- as.integer(format(Sys.Date(), "%Y"))
  df <- df %>% filter(år<=cur_year+19)%>% group_by(region,år) %>%
    summarise(Inrikes_inflyttning  = sum(Inrikes_inflyttning  ),Inrikes_utflyttning = sum(Inrikes_utflyttning), .groups = 'drop')
  
  # skapa regionsvariabel
  region <- df %>% group_by(år) %>%summarise(Inrikes_inflyttning  = sum(Inrikes_inflyttning  ),
                                             Inrikes_utflyttning = sum(Inrikes_utflyttning), .groups = 'drop')
  
  region$region <- 'Länet'
  
  # Slår ihop datat
  df <- rbind(
    region %>% select(år,  Inrikes_inflyttning,Inrikes_utflyttning , region),
    df %>% select(år,  Inrikes_inflyttning, Inrikes_utflyttning, region)
  )
  
  # Fixar till variabler och beräknar netto
  df<-df %>%
    mutate(Inrikes_inflyttning = as.integer(Inrikes_inflyttning),
           Inrikes_utflyttning = as.integer(Inrikes_utflyttning))
  df<-df %>%
    mutate(Inrikes_flyttnetto = Inrikes_inflyttning - Inrikes_utflyttning)
  
  # Färgschema
  colors <- c("Inrikes_utflyttning" = "#F9B000",
              "Inrikes_inflyttning" = "#019CD7",
              "Inrikes_flyttnetto" = "#4AA271")
  
  regions  <- c("Länet", sort(kommuner))
  
  # Skapar första plotten
  initial_region <- regions[1]
  initial_data <- df %>% filter(region == initial_region)
  
  
  last_year <- max(initial_data$år)
  
  # traces för första plotten
  p <- plot_ly() %>%
    # Utflyttning
    add_trace(
      data = initial_data,
      x = ~år, 
      y = ~Inrikes_utflyttning,
      type = 'scatter',
      mode = 'lines+markers',
      name = 'Utflyttade',
      line = list(color = colors[["Inrikes_utflyttning"]], width = 2),
      marker = list(color = colors[["Inrikes_utflyttning"]], size = 6),
      visible = TRUE,
      showlegend = FALSE
    ) %>%
    # Inflyttning
    add_trace(
      data = initial_data,
      x = ~år, 
      y = ~Inrikes_inflyttning,
      type = 'scatter',
      mode = 'lines+markers',
      name = 'Inflyttade',
      line = list(color = colors[["Inrikes_inflyttning"]], width = 2),
      marker = list(color = colors[["Inrikes_inflyttning"]], size = 6),
      visible = TRUE,
      showlegend = FALSE
    ) %>%
    # Flyttnetto
    add_trace(
      data = initial_data,
      x = ~år, 
      y = ~Inrikes_flyttnetto,
      type = 'scatter',
      mode = 'lines+markers',
      name = 'Flyttnetto',
      line = list(color = colors[["Inrikes_flyttnetto"]], width = 2),
      marker = list(color = colors[["Inrikes_flyttnetto"]], size = 6),
      visible = TRUE,
      showlegend = FALSE
    )
  
  # lägger till resterande regioner
  for(i in 2:length(regions)) {
    region_data <- df %>% filter(region == regions[i])
    
    p <- p %>%
      add_trace(
        data = region_data,
        x = ~år, 
        y = ~Inrikes_utflyttning,
        type = 'scatter',
        mode = 'lines+markers',
        name = 'Utflyttade',
        line = list(color = colors[["Inrikes_utflyttning"]], width = 2),
        marker = list(color = colors[["Inrikes_utflyttning"]], size = 6),
        visible = FALSE,
        showlegend = FALSE
      ) %>%
      add_trace(
        data = region_data,
        x = ~år, 
        y = ~Inrikes_inflyttning,
        type = 'scatter',
        mode = 'lines+markers',
        name = 'Inflyttade',
        line = list(color = colors[["Inrikes_inflyttning"]], width = 2),
        marker = list(color = colors[["Inrikes_inflyttning"]], size = 6),
        visible = FALSE,
        showlegend = FALSE
      ) %>%
      add_trace(
        data = region_data,
        x = ~år, 
        y = ~Inrikes_flyttnetto,
        type = 'scatter',
        mode = 'lines+markers',
        name = 'Flyttnetto',
        line = list(color = colors[["Inrikes_flyttnetto"]], width = 2),
        marker = list(color = colors[["Inrikes_flyttnetto"]], size = 6),
        visible = FALSE,
        showlegend = FALSE
      )
  }
  
  # lista för att spara annotations
  all_annotations <- list()
  
  # Källhänvisning
  source_annotation <- list(
    text = "Källa: SCB",
    x = 0,            
    y = -0.13,        
    xref = "paper",
    yref = "paper",
    xanchor = "left",
    yanchor = "bottom",
    showarrow = FALSE,
    font = list(size = 12)
  )
  
  
  # Det som ska synas
  all_annotations[[1]] <- list(
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
    bgcolor = "rgba(255,255,255,0.8)"
  )
  
  # Börjar från index 2
  annotation_index <- 2
  for(i in 1:length(regions)) {
    region_data <- df %>% filter(region == regions[i])
    region_last_year <- max(region_data$år)
    region_last_values <- region_data[region_data$år == region_last_year, ]
    
    if(nrow(region_last_values) > 0) {
      # utflyttade annotation
      all_annotations[[annotation_index]] <- list(
        x = region_last_year,
        y = region_last_values$Inrikes_utflyttning,
        text = "Utflyttade",
        xref = "x",
        yref = "y",
        showarrow = FALSE,
        xanchor = "left",
        xshift = 5,
        font = list(color = colors[["Inrikes_utflyttning"]], size = 16),
        visible = if(i == 1) TRUE else FALSE
      )
      annotation_index <- annotation_index + 1
      
      # Inflyttade annotation
      all_annotations[[annotation_index]] <- list(
        x = region_last_year,
        y = region_last_values$Inrikes_inflyttning,
        text = "Inflyttade",
        xref = "x",
        yref = "y",
        showarrow = FALSE,
        xanchor = "left",
        xshift = 5,
        font = list(color = colors[["Inrikes_inflyttning"]], size = 16),
        visible = if(i == 1) TRUE else FALSE
      )
      annotation_index <- annotation_index + 1
      
      # Netto annotation
      all_annotations[[annotation_index]] <- list(
        x = region_last_year,
        y = region_last_values$Inrikes_flyttnetto,
        text = "Flyttnetto",
        xref = "x",
        yref = "y",
        showarrow = FALSE,
        xanchor = "left",
        xshift = 5,
        font = list(color = colors[["Inrikes_flyttnetto"]], size = 16),
        visible = if(i == 1) TRUE else FALSE
      )
      annotation_index <- annotation_index + 1
    }
  }
  
  all_annotations <- c(all_annotations, list(source_annotation))
  
  # dropdown menu
  dropdown_buttons <- list()
  for(i in 1:length(regions)) {
    # Create visibility vector: show traces for selected region, hide others
    trace_visibility <- rep(FALSE, length(regions) * 3)
    trace_visibility[((i-1)*3 + 1):(i*3)] <- TRUE
    
    # Create visibility vector for annotations
    # First two annotations (title and prognosis) are always visible, then 3 annotations per region
    updated_annotations <- all_annotations
    # Keep first two annotations always visible
    updated_annotations[[1]]$visible <- TRUE
    # Update region-specific annotations
    for(j in 2:length(updated_annotations)) {
      region_index <- ceiling((j-1)/3)
      updated_annotations[[j]]$visible <- (region_index == i)
    }
    
    # True på källa
    updated_annotations[[length(updated_annotations)]]$visible <- TRUE
    
    dropdown_buttons[[i]] <- list(
      method = "update",
      args = list(
        list(visible = trace_visibility),
        list(annotations = updated_annotations)
      ),
      label = regions[i]
    )
  }
  
  # Layout
  p <- p %>%
    layout( 
      margin = list(t = 100, b=40),  # t = top padding i pixlar
      title = list(text=paste("<b>Antal inrikes in- och utflyttade samt flyttnetto (2003-",max(initial_data$år),')<b>', sep=""),
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(
        title = "",
        showgrid = TRUE
      ),
      yaxis = list(
        title = "<b>Antal<b>",
        showgrid = TRUE
      ),
      updatemenus = list(
        list(
          type = "dropdown",
          direction = "down",
          showactive = TRUE,
          x = 0.1,
          y = 1.13,
          buttons = dropdown_buttons
        )
      ),
      annotations = all_annotations,
      hovermode = 'x unified',
      showlegend = FALSE,
      shapes = list(
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
    )
  
  # Tar bort plotlyfunktioner
  p <- plotly::config(
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
  
  p
}

########################### In och utvandring #####################

antal_in_ut_vand_plot <- function(){
  # Läser in data
  df <- read.csv('Data/df_inut_flytt.csv')
  
  # prognosår
  df_fram <- read.csv('Data/df_folkmangdfram.csv')
  prognosar <- min(df_fram$år) +1 
  
  # 20 år framåt(utgår från att datat är ett år gammalt därav + 19): 
  cur_year <- as.integer(format(Sys.Date(), "%Y"))
  
  df <- df %>% filter(år<=cur_year+19)%>% group_by(region,år) %>%
    summarise(Invandring   = sum(Invandring   ),Utvandring  = sum(Utvandring ), .groups = 'drop')
  
  # skapa regionsvariabel
  region <- df %>% group_by(år) %>%summarise(Invandring  = sum(Invandring  ),
                                             Utvandring  = sum(Utvandring ), .groups = 'drop')
  
  region$region <- 'Länet'
  
  # Slår ihop data
  df <- rbind(
    region %>% select(år,  Invandring,Utvandring , region),
    df %>% select(år,  Invandring, Utvandring, region)
  )
  
  # Vixar variabler och netto
  df<-df %>%
    mutate(Invandring = as.integer(Invandring),Utvandring = as.integer(Utvandring))
  df<-df %>%
    mutate(Utrikes_flyttnetto = Invandring - Utvandring)
  
  # Färgschema
  colors <- c("Utvandring" = "#F9B000",
              "Invandring" = "#019CD7",
              "Utrikes_flyttnetto" = "#4AA271")
  
  regions  <- c("Länet", sort(kommuner))
  
  # Basplot för första 
  initial_region <- regions[1]
  initial_data <- df %>% filter(region == initial_region)
  
  last_year <- max(initial_data$år)
  
  # Traces för linjerna
  p <- plot_ly() %>%
    # Utvandring trace
    add_trace(
      data = initial_data,
      x = ~år, 
      y = ~Utvandring,
      type = 'scatter',
      mode = 'lines+markers',
      name = 'Utvandring',
      line = list(color = colors[["Utvandring"]], width = 2),
      marker = list(color = colors[["Utvandring"]], size = 6),
      visible = TRUE,
      showlegend = FALSE
    ) %>%
    # Invandring trace
    add_trace(
      data = initial_data,
      x = ~år, 
      y = ~Invandring,
      type = 'scatter',
      mode = 'lines+markers',
      name = 'Invandring',
      line = list(color = colors[["Invandring"]], width = 2),
      marker = list(color = colors[["Invandring"]], size = 6),
      visible = TRUE,
      showlegend = FALSE
    ) %>%
    # Utrikes_flyttnetto trace
    add_trace(
      data = initial_data,
      x = ~år, 
      y = ~Utrikes_flyttnetto,
      type = 'scatter',
      mode = 'lines+markers',
      name = 'Flyttnetto',
      line = list(color = colors[["Utrikes_flyttnetto"]], width = 2),
      marker = list(color = colors[["Utrikes_flyttnetto"]], size = 6),
      visible = TRUE,
      showlegend = FALSE
    )
  
  # Traces för resterande kommuner
  for(i in 2:length(regions)) {
    region_data <- df %>% filter(region == regions[i])
    
    p <- p %>%
      add_trace(
        data = region_data,
        x = ~år, 
        y = ~Utvandring,
        type = 'scatter',
        mode = 'lines+markers',
        name = 'Utvandring',
        line = list(color = colors[["Utvandring"]], width = 2),
        marker = list(color = colors[["Utvandring"]], size = 6),
        visible = FALSE,
        showlegend = FALSE
      ) %>%
      add_trace(
        data = region_data,
        x = ~år, 
        y = ~Invandring,
        type = 'scatter',
        mode = 'lines+markers',
        name = 'Invandring',
        line = list(color = colors[["Invandring"]], width = 2),
        marker = list(color = colors[["Invandring"]], size = 6),
        visible = FALSE,
        showlegend = FALSE
      ) %>%
      add_trace(
        data = region_data,
        x = ~år, 
        y = ~Utrikes_flyttnetto,
        type = 'scatter',
        mode = 'lines+markers',
        name = 'Flyttnetto',
        line = list(color = colors[["Utrikes_flyttnetto"]], width = 2),
        marker = list(color = colors[["Utrikes_flyttnetto"]], size = 6),
        visible = FALSE,
        showlegend = FALSE
      )
  }
  
  # Lista för annotations
  all_annotations <- list()
  
  # Källhänvisning
  source_annotation <- list(
    text = "Källa: SCB",
    x = 0,            
    y = -0.13,        
    xref = "paper",
    yref = "paper",
    xanchor = "left",
    yanchor = "bottom",
    showarrow = FALSE,
    font = list(size = 12)
  )
  
  # Första grafen
  all_annotations[[1]] <- list(
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
    bgcolor = "rgba(255,255,255,0.8)"
  )
  
  # Fyller med resterande platser
  annotation_index <- 2
  for(i in 1:length(regions)) {
    region_data <- df %>% filter(region == regions[i])
    region_last_year <- max(region_data$år)
    region_last_values <- region_data[region_data$år == region_last_year, ]
    
    if(nrow(region_last_values) > 0) {
      # Utvandring annotation
      all_annotations[[annotation_index]] <- list(
        x = region_last_year,
        y = region_last_values$Utvandring,
        text = "Utvandring",
        xref = "x",
        yref = "y",
        showarrow = FALSE,
        xanchor = "left",
        xshift = 5,
        font = list(color = colors[["Utvandring"]], size = 16),
        visible = if(i == 1) TRUE else FALSE
      )
      annotation_index <- annotation_index + 1
      
      # Invandring annotation
      all_annotations[[annotation_index]] <- list(
        x = region_last_year,
        y = region_last_values$Invandring,
        text = "Invandring",
        xref = "x",
        yref = "y",
        showarrow = FALSE,
        xanchor = "left",
        xshift = 5,
        font = list(color = colors[["Invandring"]], size = 16),
        visible = if(i == 1) TRUE else FALSE
      )
      annotation_index <- annotation_index + 1
      
      # Utrikes_flyttnetto annotation
      all_annotations[[annotation_index]] <- list(
        x = region_last_year,
        y = region_last_values$Utrikes_flyttnetto,
        text = "Flyttnetto",
        xref = "x",
        yref = "y",
        showarrow = FALSE,
        xanchor = "left",
        xshift = 5,
        font = list(color = colors[["Utrikes_flyttnetto"]], size = 16),
        visible = if(i == 1) TRUE else FALSE
      )
      annotation_index <- annotation_index + 1
    }
  }
  
  all_annotations <- c(all_annotations,list(source_annotation))
  
  # dropdown 
  dropdown_buttons <- list()
  for(i in 1:length(regions)) {
    # Create visibility vector: show traces for selected region, hide others
    trace_visibility <- rep(FALSE, length(regions) * 3)
    trace_visibility[((i-1)*3 + 1):(i*3)] <- TRUE
    
    # Create visibility vector for annotations
    # First two annotations (title and prognosis) are always visible, then 3 annotations per region
    updated_annotations <- all_annotations
    # Keep first two annotations always visible
    updated_annotations[[1]]$visible <- TRUE
    # Update region-specific annotations
    for(j in 2:length(updated_annotations)) {
      region_index <- ceiling((j-1)/3)
      updated_annotations[[j]]$visible <- (region_index == i)
    }
    
    # True på källor 
    updated_annotations[[length(updated_annotations)]]$visible <- TRUE
    
    dropdown_buttons[[i]] <- list(
      method = "update",
      args = list(
        list(visible = trace_visibility),
        list(annotations = updated_annotations)
      ),
      label = regions[i]
    )
  }
  
  # Layout
  p <- p %>%
    layout( 
      margin = list(t = 100,b=40),  # t = top padding i pixlar
      title =  list(text=paste("<b>Antal invandrade, utvandrade och utrikes flyttnetto (2003-",max(initial_data$år),')<b>', sep=""),
                    font = list(size = 20, color = "#B81867")),
      xaxis = list(
        title = "",
        showgrid = TRUE
      ),
      yaxis = list(
        title = "<b>Antal<b>",
        showgrid = TRUE
      ),
      updatemenus = list(
        list(
          type = "dropdown",
          direction = "down",
          showactive = TRUE,
          x = 0.1,
          y = 1.13,
          buttons = dropdown_buttons
        )
      ),
      annotations = all_annotations,
      hovermode = 'x unified',
      showlegend = FALSE,
      shapes = list(
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
    )
  
  # Tar bort plotly-funktioner
  p <- plotly::config(
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
  
  p
}
