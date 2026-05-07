########### Avfall ###########

avfall <- function(){
  df <- read.csv('Data/df_avfall.csv')
  
  
  df$title <- str_wrap(df$title, width= 50)
  titles <- unique(df$title)
  # Tar ut varaiabler till dropdownen
  regioner <- unique(df$municipality)
  n_region <- length(regioner)
  
  # Namn till dropdown
  y_titles <- c(
    "Materialåtervinning (%)",
    "Avfall till deponi (kg/invånare)",
    "Totalt insamlat avfall (kg/invånare)"
  )
  
  df <- df %>% mutate(municipality = factor(municipality, levels = sort(kommuner)))
  
  # Sätter names så det matchar titlarna
  names(y_titles) <- titles
  
  # Bygg plotly-objekt
  fig <- plot_ly()
  
  # loop över alla variabler och kommuner
  for (title in titles) {
    df_title <- df %>% filter(title == !!title)
    
    for (region in levels(df_title$municipality)) {
      # Filtrerar ut data och läger in trace
      df_region <- df_title %>% filter(municipality == region)
      
      df_region <- df_region %>% mutate(year = factor(year, levels = unique(year)))
      
      fig <- fig %>%
        add_trace(
          x = df_region$year,
          y = df_region$value,
          type = "scatter",
          mode = "lines+markers",
          name = region,
          line = list(color = kommun_colors[region],width = 5),
          marker = list(color = kommun_colors[region],size = 8),
          visible = ifelse(title == titles[1], TRUE, FALSE)
        )
    }
  }
  
  # Skapa dropdown-knappar
  buttons <- lapply(seq_along(titles), function(i) {
    visible_vec <- rep(FALSE, length(titles)*n_region)
    visible_vec[((i-1)*n_region + 1):(i*n_region)] <- TRUE
    
    list(
      method = "update",
      args = list(
        list(visible = visible_vec),
        list(
          title = paste("<b>",titles[i],"<b>"),
          yaxis = list(
            title = paste("<b>",y_titles[[titles[i]]],"<b>"),
            rangemode =  "tozero"
          )
        )
      ),
      label = y_titles[i]
    )
  })
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 120,b=60),
      title = list(text = paste("<b>",titles[1],"<b>"), y = 0.95, x = 0.55,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = "", tickangle = -45),
      yaxis = list(title = "<b>Andel (%)<b>", 
                   rangemode = "tozero"),
      hovermode = 'x unified',
      updatemenus = list(
        list(
          y = -0.1,
          x=1.1,
          buttons = buttons,
          direction = "up"
        )),
      annotations = list(
        text ='Källa: Kolada och Avfall Sverige',
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
  
  return(fig)
  
}


Avfall_kategoori <- function(){
  # Läser in data
  df <- read.csv('Data/df_matavf.csv') %>% bind_rows(
    read.csv('Data/df_returpapp.csv'))%>% bind_rows(
      read.csv('Data/df_grovt.csv'))%>% bind_rows(
        read.csv('Data/df_farligt.csv'))
  
  
  titles <- unique(df$title)
  # Tar ut varaiabler till dropdownen
  regioner <- unique(df$municipality)
  n_region <- length(regioner)
  
  # Kortar ned titlar
  df <- df %>%
    mutate(
      title_short = case_when(
        title == "Insamlat mat- och restavfall, kg/invånare (justerat)" ~ "Mat- och restavfall",
        title == "Insamlat förpackningar och returpapper, kg/invånare (justerat)" ~ "Förpackningar och returpapper",
        title == "Insamlat grovavfall, kg/invånare (justerat)" ~ "Grovavfall",
        title == "Insamlat farligt avfall (inkl. elavfall och batterier), kg/invånare (justerat)" ~ "Farligt avfall",
        TRUE ~ title
      )
    )
  df$title <- str_wrap(df$title, width= 50)
  
  # Färgschema
  kategori_col <- c("#4AA271","#F9B000","#8B4A9C", "#6F787E")
  
  names(kategori_col) <- unique(df$title_short)
  
  
  # Tar bort NA
  df <- df %>% filter(!is.na(value))
  
  # Ordnar efter kommunerna
  df <- df %>% mutate(municipality = factor(municipality, levels =sort(kommuner)))
  
  df <- df %>% arrange(municipality, title_short, year)
  
  fig <- plot_ly()
  
  region <-  sort(unique(df$municipality))
  
  # Loopar över kommuner och kategorier för traces
  for (kommun in region) {
    for (kategori in unique(df$title_short)) {
      
      df_k <- df %>% filter(municipality == kommun, title_short == kategori)
      
      fig <- fig %>%
        add_trace(
          data = df_k,
          x = ~year,
          y = ~value,
          type = "scatter",
          mode = "lines+markers",
          name = kategori,
          line = list(color = kategori_col[kategori], width = 5),
          marker = list(color = kategori_col[kategori],size = 8),
          visible = ifelse(kommun == unique(df$municipality)[1], TRUE, FALSE),
          hovertemplate = paste0(
            " %{y:.1f} kg/inv"
          )
        )
    }
  }
  
  
  # Dropdown för kommuner
  buttons <- lapply(seq_along(region), function(i) {
    vis_vec <- rep(FALSE, length(region) * length(unique(df$title_short)))
    vis_vec[((i - 1) * length(unique(df$title_short)) + 1):(i * length(unique(df$title_short)))] <- TRUE
    list(
      method = "update",
      args = list(list(visible = vis_vec),
                  list(title = paste("<b>Insamlat avfall per kategori –", region[i],"<b>"))),
      label = region[i]
    )
  })
  
  #  Lägg till dropdownmenyn 
  fig <- fig %>%
    layout(hovermode = 'x unified',
           title = list(text =paste("<b>Insamlat avfall per kategori –", region[1],"<b>"),
                        font = list(size = 20, color = "#B81867")),
           xaxis = list(title = "", tickmode = "linear", tickangle = -45),
           yaxis = list(title = "<b>Kg/invånare<b>"),
           showlegend = TRUE,
           margin = list(t = 120,b=100),
           legend = list(
             orientation = "h",   # horisontell legend
             x = 0.5,            # centrerad
             y = -0.25,           # under grafen
             xanchor = "center",
             yanchor = "bottom",
             font = list(size = 14)
           ),
           updatemenus = list(list(
             active = 0,
             buttons = buttons,
             direction = "down",
             x = 0,
             xanchor = "center",
             y = 1.1,
             yanchor = "top"
           )),
           annotations = list(
             text = "Källa: Kolada och Avfall Sverige",
             x = 0,
             y = -0.15,
             xref = "paper",
             yref = "paper",
             xanchor = "left",
             yanchor = "bottom",
             showarrow = FALSE,
             font = list(size = 12)
           )
    ) %>%
    plotly::config(
      modeBarButtonsToRemove = c('zoom2d','pan2d','select2d','lasso2d','zoomIn2d','zoomOut2d'),
      displaylogo = FALSE
    )
  
  return(fig)
  
}


avfall_avgift <- function(){
  # Läser in data
  df <- read.csv('Data/df_avfall_avgift.csv') %>% filter(!is.na(value)) %>% 
    filter(year == max(year))
  
  
  # Skapar plot
  p <- ggplot(df, aes(x = municipality, y=value))+ 
    geom_col(position="dodge", fill="#B81867")+ 
    labs(title= paste("Avgift för avfallshämtning",max(df$year)),
         x = "",y='kr/kvm',caption = 'Källa: Nils Holgersson gruppen')+ 
    theme(axis.text.x = element_text(angle = 90),
          legend.position="none",
          text = element_text(family = "sourcesanspro", size = 14),
          axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0, vjust=4),
          plot.margin = grid::unit(c(t=40, 30, 15, 15), "pt"))
  p
  # sparar som svg
  ggsave('Figurer/avgift_avfall.svg',plot = p,device = "svg", width = 7, height = 5)
  ggsave('Figurer/avgift_avfall.png',plot = p,device = "png", width = 7, height = 5, dpi=96) # png
}

avfall_kostnad <- function(){
  # Läser in data
  df <- read.csv('Data/df_avfall_kost.csv') %>% filter(!is.na(value)) %>% 
    filter(year == max(year))
  
  df$title <- ifelse(df$title=="Kostnad avfallshantering, kr/inv", 'Kostnad', "Nettokostnad")
  
  
  # Skapar plot
  p <- ggplot(df, aes(x = municipality, y=value))+ 
    geom_col(position="dodge",fill="#B81867")+ facet_wrap(~title, ncol=1, scales ='free')+
    labs(title= paste("Kostnad avfallshantering",max(df$year)),
         x = "",y='kr/inv', ,caption = 'Källa: SCB')+ 
    theme(axis.text.x = element_text(angle = 90),
          legend.position="none",
          text = element_text(family = "sourcesanspro", size = 14),
          axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0, vjust=4))
  p
  # sparar som svg
  ggsave('Figurer/kost_avfall.svg',plot = p,device = "svg", width = 7, height = 8)
  
  ggsave('Figurer/kost_avfall.png',plot = p,device = "png", width = 7, height = 8, dpi =96)
}