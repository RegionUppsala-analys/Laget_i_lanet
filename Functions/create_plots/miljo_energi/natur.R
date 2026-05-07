############ NATUR  ##############


andel_skyddadnatur <- function(){
  # Läser in data
  df <- read.csv('Data/df_skyddad_natur.csv') %>% 
    filter(title != "Medelavstånd till skyddad natur, km",
           title != "Skyddad natur totalt, andel (%)")
  
  # Tar ut senaste året
  latest_year <- max(df$year)
  
  df <- df %>% 
    filter(year == latest_year, !is.na(value))
  
  # Tar bort en del av texten
  df$title <- str_remove_all(df$title, "Skyddad natur |,\\s*andel\\s*\\(%\\)" )
  
  df$title <- tools::toTitleCase(df$title)
  
  # Colors
  kategori_col <- c("#4AA271", "#019CD7", "#F9B000")
  names(kategori_col) <- unique(df$title)
  
  # Ordnar efter kommunerna
  
  df <- df %>% mutate(municipality = factor(municipality, levels =sort(kommuner)))
  
  # Fixar ordning
  region <-  sort(unique(df$municipality))
  
  df <- df %>% arrange(municipality)
  
  # Tar ut antal per kategori
  trace_per_kategori <- table(df$title)/length(unique(df$year))
  ord <- c("Land","Inlandsvatten","Hav")
  
  trace_per_kategori <- trace_per_kategori[match(ord, names(trace_per_kategori))]
  
  # Skapar plot
  fig <- plot_ly()
  trace_region <- c()
  
  # Loopar över kommunerna
  for (kommun in region) {
    df_k <- df %>% filter(municipality == kommun)
    
    fig <- fig %>%
      add_trace(
        data = df_k,
        x = ~title,
        y = ~value,
        type = "bar",
        marker = list(color = kategori_col[df_k$title]),
        name = kommun,
        visible = ifelse(kommun == region[1], TRUE, FALSE),
        hovertemplate = paste0(
          "%{y:.1f} %"
        )
      )
    
    trace_region <- c(trace_region, kommun)
  }
  
  # Dropdown
  buttons <- lapply(region, function(reg) {
    vis_vec <- trace_region == reg
    
    list(
      method = "update",
      args = list(
        list(visible = vis_vec),
        list(title = paste0("<b>Andel skyddad natur – ", reg, " (", latest_year, ")</b>"))
      ),
      label = reg
    )
  })
  
  # Layout 
  fig <- fig %>%
    layout(
      barmode = "group",
      hovermode = "x unified",
      title = list (text =paste0("<b>Andel skyddad natur – ", region[1], " (", latest_year, ")</b>"),
                    font = list(size = 20, color = "#B81867")),
      
      xaxis = list(title = "",tickfont = list(size = 18)),
      yaxis = list(title = "<b>Andel (%)</b>", range = c(0, 100)),
      showlegend = FALSE,
      updatemenus = list(list(
        active = 0,
        buttons = buttons,
        direction = "down",
        x = 0,
        xanchor = "center",
        y = 1.15,
        yanchor = "top"
      )),
      annotations = list(
        text = "Källa: SCB",
        x = 0,
        y = -0.08,
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
  
  fig
  
}

# Avstånd till skyddad natur
avstand_skyddadnatur <- function(){
  # Läser in data
  df <- read.csv('Data/df_avstand_natur.csv') %>% 
    filter(year == max(year))
  
  # Barplot
  p <- ggplot(df, aes(x = municipality, y=value))+ 
    geom_col(position="dodge",fill="#B81867")+ 
    labs(title= paste("Medelavstånd till skyddad natur år",max(df$year)),
         x = "",y='Kilometer', caption = 'Källa: SCB')+ 
    theme(axis.text.x = element_text(angle = 90),
          legend.position="none",
          text = element_text(family = "sourcesanspro", size = 14),
          axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0, vjust=4))
  p
  # sparar som svg
  ggsave('Figurer/avstand_skyddadnatur.svg',plot = p,device = "svg", width = 7, height = 6)
  
  
  ggsave('Figurer/avstand_skyddadnatur.png',plot = p,device = "png", width = 7, height = 6, dpi =96)
  
}

# Ekologisk mark
ekomark <- function(){
  # Läser in data
  df <- read.csv('Data/df_eko.csv')
  
  # filtrerar data och skapar split på andel
  df <- df %>% filter(!is.na(value)) %>% filter(year == max(year))
  
  # Skapar barplot
  p <- ggplot(df, aes(x = municipality, y=value))+ 
    geom_col(position="dodge",fill="#B81867")+ 
    labs(title= paste("Ekologiskt brukad åkermark år", max(df$year)),
         x = "",y='Andel (%)', caption = 'Källa: Jordbruksverket')+ 
    ylim(0,50)+
    theme(axis.text.x = element_text(angle = 90),
          legend.position="none",
          text = element_text(family = "sourcesanspro", size = 14),
          axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0, vjust=4))
  p
  # sparar som svg
  ggsave('Figurer/eko_mark.svg',plot = p,device = "svg", width = 7, height = 6)
  
  
  ggsave('Figurer/eko_mark.png',plot = p,device = "png", width = 7, height = 6, dpi =96)
}

# betesmark
betesmark <- function(){
  # Läser in data
  df <- read.csv('Data/df_betesmark.csv') %>% filter(!is.na(year)) %>% 
    filter(year == max(year))
  
  # Ändrar titlarna till det kortare
  df$title <- ifelse(grepl('andel',df$title )==T, 'Andel (%)', 'Hektar')
  
  # Skapar plot
  p <- ggplot(df, aes(x = municipality, y=value))+ 
    geom_col(position="dodge",fill="#B81867")+ facet_wrap(~title, ncol=1, scales = 'free')+
    labs(title= paste("Total betesmark år",max(df$year)),
         x = "",y='', caption = 'Källa: Jordbruksverket')+ 
    theme(axis.text.x = element_text(angle = 90),
          legend.position="none",
          text = element_text(family = "sourcesanspro", size = 14),
          axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0, vjust=4))
  p
  # sparar som svg
  ggsave('Figurer/betesmark.svg',plot = p,device = "svg", width = 7, height = 8)
  
  
  
  ggsave('Figurer/betesmark.png',plot = p,device = "png", width = 7, height = 8, dpi =96)
  
}


#Slåtteräng
slatt_mark <- function(){
  # Läser in data
  df <- read.csv('Data/df_slatt.csv') %>% filter(!is.na(value)) %>% 
    filter(year == max(year))
  
  # Ändrar titlarna till det kortare
  df$title <- ifelse(grepl('andel',df$title )==T, 'Andel (%)', 'Hektar')
  
  # Skapar plot
  p <- ggplot(df, aes(x = municipality, y=value))+ 
    geom_col(position="dodge", fill="#B81867")+ facet_wrap(~title, ncol=1,scales = "free" )+
    scale_fill_manual(values = kommun_colors)+
    labs(title= paste("Slåtteräng år",max(df$year)),
         x = "",y='', caption = 'Källa: Jordbruksverket')+ 
    theme(axis.text.x = element_text(angle = 90),
          legend.position="none",
          text = element_text(family = "sourcesanspro", size = 14),
          axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0, vjust=4))
  p
  # sparar som svg
  ggsave('Figurer/slatterang.svg',plot = p,device = "svg", width = 7, height = 8)
  
  ggsave('Figurer/slatterang.png',plot = p,device = "png", width = 7, height = 8, dpi =96)
}
