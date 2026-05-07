

kostnad_intakt <- function(){
  # Hämtar data
  df <- read.csv("Data/df_Kostnad_intakt.csv")
  
  # Rensar titlar
  df$title <- gsub(", kr/inv","",df$title)
  
  # variabel som definierar intäkt/kostnad
  df$index <- grepl("Intäkt",df$title )
  df$index  <- ifelse(df$index==TRUE, "intäkt", "kostnad")
  
  # Kortar ned titlar
  df$title <- gsub("Kostnad ", "",df$title)
  df$title <- gsub("Intäkter ", "",df$title)
  
  # Stor bokstav
  df$title <- str_to_sentence(df$title) 
  
  # tar endast ut kulturverksamhet
  df <- df %>% filter(title == 'Kulturverksamhet')
  
  kommun_colors_r <- c("Riket" = "black",kommun_colors)
  
  # Skapar en plot per kommun   
  
  for (r in unique(df$index)){
    
    # tar ut kostnad/intäkt
    temp <- df %>% filter(index == r)
    
    p <- ggplot(
      temp,
      aes(
        x = year,
        y = value,
        color = municipality
      )
    ) +
      geom_line(linewidth  = 2) +
      geom_point(size = 3) +
      ylim(0, max(temp$value))+
      scale_color_manual(values=kommun_colors_r)+
      scale_x_continuous(breaks = seq(min(temp$year), max(temp$year), by = 2))+
      labs(
        x = "",
        y = "Kr/invånare",
        color = "",
        title = str_wrap(paste0("Utvecklingen av ", r, "en på kulturverksamhet"), width=50),
        caption = "Källa: SCB:s Räkenskapssammandrag"
      ) + theme(axis.text.x = element_text(angle =45,hjust=1),
                legend.position = "bottom",
                plot.caption = element_text(hjust=0))
    
    
    print(p)
    # Sparar plot 
    ggsave(
      paste0("Figurer/kostnad_intakt_", r, ".svg"),
      plot = p,
      width = 7,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/kostnad_intakt_", r, ".png"),
      plot = p,
      width = 7,
      height = 6,
      dpi = 96
    )
  }
  
}




nettokostnad_kultur <- function(){
  # Läser in data
  df <- read.csv('Data/df_nettokostnad.csv')
  
  # Rensar titlar
  df$title <- gsub(", kr/inv","",df$title)
  
  df$value <- round(df$value,2)
  
  df$title <- str_wrap(df$title, width= 50)
  titles <- unique(df$title)
  
  # Tar ut varaiabler till dropdownen
  regioner <- unique(df$municipality)
  n_region <- length(regioner)
  
  df <- df %>% mutate(municipality = factor(municipality, levels = c("Riket",sort(kommuner))))
  
  # Sätter names så det matchar titlarna
  names(titles) <- titles
  
  # Bygg plotly-objekt
  fig <- plot_ly()
  
  kommun_colors_r <- c("Riket" = 'black',
                       kommun_colors)
  
  df <- df %>% mutate(year = factor(year, levels = unique(year)))
  
  # loop över alla variabler och kommuner
  for (title in titles) {
    df_title <- df %>% filter(title == !!title)
    
    for (region in levels(df_title$municipality)) {
      # Filtrerar ut data och läger in trace
      df_region <- df_title %>% filter(municipality == region)
      
      
      
      fig <- fig %>%
        add_trace(
          x = df_region$year,
          y = df_region$value,
          type = "scatter",
          mode = "lines+markers",
          name = region,
          line = list(color = kommun_colors_r[region],width = 5),
          marker = list(color = kommun_colors_r[region],size = 8),
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
            title = paste("<b>Kr/invånare<b>"),
            rangemode =  "tozero"
          )
        )
      ),
      label = titles[i]
    )
  })
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 40,b=100),
      title = list(text = paste("<b>",titles[1],"<b>"), y = 0.97, x = 0.5,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = "", tickangle = -45),
      yaxis = list(title = "<b>Kr/invånare<b>", 
                   rangemode = "tozero"),
      hovermode = 'x unified',
      updatemenus = list(
        list(
          y = -0.15,
          x=1.3,
          buttons = buttons,
          direction = "up"
        )),
      annotations = list(
        text ='Källa: SCB:s Räkenskapssammandrag',
        x = 0,            
        y = -0.17,        
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

####### Kostnad_andel #######

andel_kost_kult <- function(){
  # Hämtar data
  df <- read.csv("Data/df_kost_andel.csv")
  
  # Rensar titlar
  df$title <- gsub(", andel \\(%\\)", "", df$title )
  
  kommun_colors_r <- c("Riket" = 'black',
                       kommun_colors)
  
  # Skapar en plot 
  p <- ggplot(
    df,
    aes(
      x = year,
      y = value,
      color = municipality
    )
  ) +
    geom_line(linewidth  = 2) +
    geom_point(size = 3) +
    ylim(-5,15)+
    scale_color_manual(values=kommun_colors_r)+
    scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 2))+
    labs(
      x = "",
      y = "Andel (%)",
      color = "",
      title = str_wrap(paste0(unique(df$title)), width=50),
      caption = "Källa: SCB:s Räkenskapssammandrag"
    ) + theme(axis.text.x = element_text(angle =45,hjust=1),
              legend.position = "bottom",
              plot.caption = element_text(hjust=0))
  
  
  print(p)
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/kost_andel", ".svg"),
    plot = p,
    width = 8,
    height = 7
  )
  
  ggsave(
    paste0("Figurer/kost_andel",  ".png"),
    plot = p,
    width = 8,
    height = 7,
    dpi = 96
  )
  
  
  
}