# Återstående medellivslängd vid 30 års ålder efter kön och utbildningsnivå
livslangd <- function(){
  # Läser in data
  df <- read.csv('Data/df_livslangd.csv')
  
  # Antal intervall
  intervall <- unique(df$årsintervall)
  
  # Filtrerar och fixar till snyggare variabler
  df_plot <- df %>% filter(utbildningsnivå != 'samtliga utbildningsnivåer', ålder == '30 år') %>% 
    select(region, utbildningsnivå, kön , ålder, Antal.återstående.år) %>%
    mutate(
      utbildningsnivå = str_to_title(utbildningsnivå),
      kön = str_to_title(kön)
    )
  
  df_plot$utbildningsnivå[df_plot$utbildningsnivå =="Uppgift Om Utbildningsnivå Saknas"] <- 'Uppgift Saknas'
  
  # Order på dropdown
  ordr <- c('Riket', 'Dalarnas län', 'Gävleborgs län', lan, 'Västmanlands län')
  
  df_plot <- df_plot %>% arrange(factor(region, levels=ordr))# ordnar data
  
  # Färgtema
  col_map <- c(
    "Förgymnasial Utbildning" = "#D57667",
    "Gymnasial Utbildning" = "#F9B000",
    "Eftergymnasial Utbildning" = "#019CD7",
    "Uppgift Saknas" = "#4AA271"
  )
  
  # Antal regioner
  regions <- unique(df_plot$region)
  
  # Skapar figur och trace index
  fig <- plot_ly()
  trace_index <- 0
  trace_map <- list()   # hålla koll på traces, så att dropdownen kopplas enkelt
  
  # trace per region
  for (r in regions){
    # filtrerar kommun
    temp <- df_plot %>% filter(region == r)
    utbildningsnivåer <- unique(temp$utbildningsnivå) # olika per plats
    
    trace_ids <- c() # vector med ids
    
    # Trace per utbildningsnivå
    for (u in utbildningsnivåer){
      # +1 på index och filtrerar utbildningsnivå 
      trace_index <- trace_index + 1
      temp_u <- temp %>% filter(utbildningsnivå == u)
      
      # Lägger till en bar per utbildningsnivå
      fig <- fig %>% add_trace(
        data = temp_u,
        x = ~kön,
        y = ~Antal.återstående.år,
        name = u,
        type = "bar",
        visible = ifelse(r == regions[1], TRUE, FALSE),
        marker = list(color = col_map[u])
        
      )
      
      # Spara id och index
      trace_ids <- c(trace_ids, trace_index)
    }
    # lägg in i listan
    trace_map[[r]] <- trace_ids
  }
  
  #  Dropdown buttons
  buttons <- lapply(seq_along(regions), function(i){
    vis <- rep(FALSE, trace_index)# Börjar med att markera allt som false
    vis[ trace_map[[ regions[i] ]] ] <- TRUE # Markerar som true när regionen väljs i dropdownen
    
    list(
      method = "update", # uppdatera allt när val görs.
      args = list(
        list(visible = vis),
        list(title = paste("<b>Återstående medellivslängd vid 30 per utbildningsnivå,", 
                           intervall,'<b>'))
      ),
      label = regions[i] # namn i dropdownen
    )
  })
  
  # Layout
  fig <- fig %>% layout( 
    hovermode = 'x unified',
    barmode = "group",
    margin = list(t = 100),
    title =  list(text=paste("<b>Återstående medellivslängd vid 30 per utbildningsnivå,",
                             intervall,'<b>'),
                  font = list(size = 20, color = "#B81867")),
    xaxis = list(title = ""),
    yaxis = list(title = "<b>Återstående år<b>",
                 range = c(0, 70)),   # Fixed axis för alla regioner
    updatemenus = list( # placering på dropdown
      list(
        x = -0.2,
        xanchor = "left",
        y = 1.03,
        yanchor = "bottom",
        buttons = buttons
      )
    ),
    annotations = list(list(
      text = "Källa: SCB",
      x = 0,          
      y = -0.13,      
      xref = "paper",
      yref = "paper",
      xanchor = "left",
      yanchor = "bottom",
      showarrow = FALSE,
      font = list(size = 12)
    ))
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


####### Utbildningsnivåer #######