# Återstående medellivslängd vid 30 års ålder efter kön och utbildningsnivå
livslangd <- function(){
  # Läser in data
  df <- read.csv('Data/df_livslangd.csv') 
  
  # Tar ut senaste intervallet och filtrerar
  slutår <- as.numeric(sub(".*-", "", df$årsintervall))
  
  df <- df[slutår == max(slutår, na.rm = TRUE), ]
  
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
        list(title = str_wrap(paste("<b>Återstående medellivslängd från 30, per utbildningsnivå,", 
                                    intervall,'<b>'),width=50))
      ),
      label = regions[i] # namn i dropdownen
    )
  })
  
  # Layout
  fig <- fig %>% layout( 
    hovermode = 'x unified',
    barmode = "group",
    margin = list(t = 100),
    title =  list(text=str_wrap(paste("<b>Återstående medellivslängd från 30, per utbildningsnivå,",
                                      intervall,'<b>'),width=50),
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


livslangd_uppsalalan <- function(){
  # Läser in data
  df <- read.csv('Data/df_livslangd.csv')
  
  # Filtrerar och fixar till snyggare variabler
  df_plot <- df %>% 
    filter(
      ålder == "30 år",
      !utbildningsnivå %in% c(
        "samtliga utbildningsnivåer",
        "uppgift om utbildningsnivå saknas"
      ),
      region %in% c("Riket", "Uppsala län")
    ) %>% 
    select(region, utbildningsnivå, kön, ålder,
          Antal.återstående.år, årsintervall) %>%
    mutate(
      utbildningsnivå = recode(utbildningsnivå,
        "förgymnasial utbildning" = "Förgymnasial",
        "gymnasial utbildning" = "Gymnasial",
        "eftergymnasial utbildning" = "Eftergymnasial"
      ),
      kön = str_to_title(kön)
    )

  # Senaste tillgängliga årsintervallet
  senaste_period <- max(df_plot$årsintervall)

  df_plot <- df_plot %>%
    filter(årsintervall == senaste_period)

  # Färger för regioner
  col_region <- c(
    "Riket" = "#019CD7",
    "Uppsala län" = "#D57667"
  )

  levels_x <- c("Förgymnasial", "Gymnasial", "Eftergymnasial")
  levels_fill <- c("Uppsala län", "Riket")

  p <- ggplot(
    df_plot,
    aes(
      x = factor(utbildningsnivå, levels = levels_x),
      y = Antal.återstående.år,
      fill = factor(region, levels = levels_fill)
    )
  ) +
    geom_col(
      position = position_dodge(width = 0.8),
      width = 0.7
    ) +
    facet_wrap(~ kön, ncol = 2) +
    scale_fill_manual(values = col_region) +
    labs(
      title = str_wrap(paste(
        "Återstående medellivslängd från 30 års ålder",
        senaste_period, "utifrån utbildningsnivå"
      ), width = 50),
      subtitle = str_wrap("Jämförelse mellan Uppsala län och Riket", width = 50),
      x = "",
      y = "Antal återstående år",
      fill = "",
      caption = "Källa: SCB"
    ) +
    theme(
      axis.text.x = element_text(angle = 20, hjust = 1),
      legend.position = "bottom",
      plot.caption = element_text(hjust = 0),
      plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold')
    )
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/livslangd_uppsalalan.svg"),
      plot = p,
      width = 8,
      height = 7
    )
    
    ggsave(
      paste0("Figurer/livslangd_uppsalalan.png"),
      plot = p,
      width = 8,
      height = 7,
      dpi = 96
    )
    
    
    
  } 



# Livslängd kommuner:

livslangd_kom <- function(){
  # Läser in data
  df <- read.csv("Data/df_livslangd_kom.csv")
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # Visa vart 4:e år på x-axeln
  ara <- unique(df$År)
  visa_ar <- ara[seq(1, length(ara), by = 2)]

  # Sätter y-axel till det lägsta värdet och det högsta värdet avrundat till närmaste 2-tal
  y_min <- floor(min(df$Medellivslängd..återstående.vid.födelsen..medelvärde.för.perioden.,
                   na.rm = TRUE))

  y_max <- max(df$Medellivslängd..återstående.vid.födelsen..medelvärde.för.perioden.,
              na.rm = TRUE)

  y_max_axis <- (floor((y_max - y_min) / 2) + 1) * 2 + y_min

  y_breaks <- seq(y_min, y_max_axis, by = 2)
  
  # En plot per kommun
  for(r in kommuner){
    temp <- df %>% filter(Region ==r)
    
    
    p <- ggplot(temp, aes(x =År, y =  Medellivslängd..återstående.vid.födelsen..medelvärde.för.perioden., color=Kön, group=Kön))+
      geom_line(linewidth=2)+ geom_point(size=3)+scale_color_manual(values = kon_col)+
      scale_x_discrete(breaks = visa_ar) +
      scale_y_continuous(breaks = y_breaks, limits = c(y_min, y_max_axis))+
      labs(x="",
           title = str_wrap(paste("Medellivslängden i",r, "(5-årsmedelvärden)"), width=50),
           caption = "Källa: SCB",
           y = "Medellivslängd",
           color="")+
      theme(plot.caption = element_text(hjust=0),
            axis.text.x = element_text(angle = 45, hjust=1))
    
    p
    
    
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/livslangd_kom_",r,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/livslangd_kom_",r,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
    
    
    
  }
  
}


