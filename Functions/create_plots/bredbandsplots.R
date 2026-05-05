

########### Tillgång fast bredband ###########

tillgang_bred <- function(){
  # Läser in data
  df <- read.csv('Data/df_internet.csv')
  
  df$title <- str_wrap(df$title, width= 50)
  
  # Tar ut varaiabler till dropdownen
  regioner <- sort(unique(df$municipality))
  
  # gör till factor
  df <- df %>% mutate(municipality = factor(municipality, levels = sort(kommuner)))
  
  # Bygg plotly-objekt
  fig <- plot_ly()
  
  # loop över alla variabler och kommuner
  for (region in regioner) {
    # Filtrerar ut data och läger in trace
    df_region <- df %>% filter(municipality == region)
    
    df_region <- df_region %>% mutate(year = factor(year, levels = unique(year)))
    
    fig <- fig %>%
      add_trace(
        x = df_region$year,
        y = df_region$value,
        type = "scatter",
        mode = "lines+markers",
        name = region,
        line = list(color = kommun_colors[region],width = 5),
        marker = list(color = kommun_colors[region],size = 8)
      )
  }
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 120,b=60),
      title = list(text = paste("<b>",unique(df$title),"<b>"), y = 0.95, x = 0.55,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = "", tickangle = -45),
      yaxis = list(title = "<b>Andel (%)<b>", 
                   rangemode = "tozero"),
      hovermode = 'x unified',
      annotations = list(
        text ='Källa: Kolada och Post- och telestyrelsen',
        x = 0,            
        y = -0.2,        
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

### Tillgång till minst 1 gb
tillgang_bred_gb <- function(){
  # Läser in data
  df <- read.csv('Data/df_internet_gb.csv')
  
  df$title <- str_wrap(df$title, width= 50)
  
  # Tar ut varaiabler till dropdownen
  regioner <- sort(unique(df$municipality))
  titles <- unique(df$title)
  n_region <- length(regioner)
  
  y_titles <- c(
    "Alla hushåll",
    "Hushåll i tätbebyggt område",
    "Hushåll i glesbebyggt område"
  )
  
  # Gör till factor
  df <- df %>% mutate(municipality = factor(municipality, levels = sort(kommuner)))
  
  # Bygg plotly-objekt
  fig <- plot_ly()
  
  # loop över alla variabler och kommuner
  for (t in titles){
    df_title <- df %>% filter(title == t)
    for (region in regioner) {
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
          visible = ifelse(t == titles[1], TRUE, FALSE)
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
            title = paste("<b>Andel (%)<b>"),
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
          y = -0.15,
          x=1.1,
          buttons = buttons,
          direction = "up"
        )),
      annotations = list(
        text ='Källa: Kolada och Post- och telestyrelsen',
        x = 0,            
        y = -0.22,        
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



bredbandskollen <- function(){
  # Läser in data
  df <- read.csv('Data/df_bredbandskollen.csv')
  
  # Bryter titel i 2 kolumner, upp/nerströms och webb/mobil
  df <- df %>%
    mutate(
      riktning = case_when(
        str_detect(title, "uppströms") ~ "Uppströms",
        str_detect(title, "nedströms") ~ "Nedströms"
      ),
      plattform = case_when(
        str_detect(title, "webb") ~ "Webb",
        str_detect(title, "mobil") ~ "Mobil"
      )
    )
  # Färgschema
  
  cols <- c("#019CD7","#E67E22")
  
  # variabler till plot
  regions <- sort(unique(df$municipality))
  
  
  # Skapar plot
  for (r in regions){
    
    temp <- df %>% filter(municipality == r)
    
    p <- ggplot(temp, aes(x = year, y=value, color=riktning))+ 
      facet_wrap(~plattform, nrow =2)+
      geom_line(linewidth= 2)+ geom_point(size= 3)+
      scale_color_manual(values = cols)+
      labs(title= str_wrap(paste("Genimsnittligt mätresultat från bredbandskollen för",r), width=50),
           x = "",y='Mbit/s',caption = 'Källa: Kolada, Bredbandskollen och Internetstiftelsen',
           color = "")+ 
      theme(
        text = element_text(family = "sourcesanspro", size = 14),
        axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
        plot.caption = element_text(hjust = 0, vjust=1),
        plot.margin = grid::unit(c(t=40, 30, 15, 15), "pt"))
    
    print(p)
    # sparar som svg
    ggsave(paste0('Figurer/bredbandskollen_',r,'.svg'),plot = p,device = "svg", width = 7, height = 5)
    ggsave(paste0('Figurer/bredbandskollen_',r,'.png'),plot = p,device = "png", width = 7, height = 5, dpi=96) # png
  }
}


##### Hushåll med Tillgång till 5g ####

femg <- function(){
  # Läser in och filtrerar data
  df <- read_excel("Data/teknik.xlsx", sheet=4) %>% filter(Kommunnamn %in% kommuner,Årtal == max(Årtal)) %>% 
    select(Årtal, Kommunnamn,Område,`Antal hushåll`,`Tillgång via NR (5G)`)
  
  # Tar ut antal med tillgång, kör ceiling för att avrunda upp
  df <- df %>% filter(Område != 'total') %>% 
    mutate(Antal = ceiling(`Tillgång via NR (5G)`*`Antal hushåll`),
           Område = str_to_sentence(Område),
           Kommunnamn = factor(Kommunnamn, levels= sort(kommuner,decreasing=TRUE)))
  
  # Gör till long for grafen
  df_long <- df %>% 
    pivot_longer(
      cols = c(`Tillgång via NR (5G)`, Antal),
      names_to  = "Mått",
      values_to = "Värde"
    ) %>% 
    mutate(
      Mått = recode(
        Mått,
        `Tillgång via NR (5G)` = "Andel (%)",
        Antal = "Antal hushåll"
      ),
      Värde = if_else(Mått == "Andel (%)", Värde * 100, Värde)
    ) 
  
  for(i in unique(df$Område)){
    # Tar ut området
    temp <- df_long %>% filter(Område == i)
    
    p <- ggplot(temp, aes(y = Kommunnamn, x= Värde))+
      geom_col(position='dodge', fill = "#B81867")+ 
      facet_wrap(~Mått, ncol =1,  scales = "free")+
      labs(title = str_wrap(paste0("Hushåll med tillgång till NR (5G) i ",str_to_lower(i),
                                   ifelse(i=='Tätbyggt', " område", ""),", år ", max(temp$Årtal)),width=50),
           y = "",x='',caption = 'Källa: Post- och telestyrelsen (PTS)',
      )+ 
      theme(
        text = element_text(family = "sourcesanspro", size = 14),
        axis.text.y = element_text(color='black'),
        plot.caption = element_text(hjust = 0, vjust=1),
        plot.margin = grid::unit(c(t=40, 30, 15, 15), "pt"))
    
    print(p)
    # sparar som svg
    ggsave(paste0('Figurer/femg_',i,'.svg'),plot = p,device = "svg", width = 7, height = 7)
    ggsave(paste0('Figurer/femg_',i,'.png'),plot = p,device = "png", width = 7, height = 7, dpi=96) # png
    
  }
  
}



########## Teknik #########

teknik <- function(){
  # Läser in och filtrerar data
  df <- read_excel("Data/teknik.xlsx", sheet=4) %>% filter(Kommunnamn %in% kommuner,Årtal == max(Årtal),
                                                           Område =='total') %>% 
    select(!c(Bas  ,   `Aggregerat på`, Område, Lännamn))
  
  # Gör till long för att få variabler i en kolumn
  df_long <- df %>%
    pivot_longer(
      cols = -c(Årtal, Kommunnamn, `Antal hushåll`),
      names_to = "Typ_av_tillgång",
      values_to = "Andel"
    ) %>% 
    mutate(Andel = Andel*100)
  
  # variabler till plot
  regions <- sort(unique(df_long$Kommunnamn))
  unique(df_long$Typ_av_tillgång)
  
  # Skapar plot
  for (r in regions){
    
    temp <- df_long %>% filter(Kommunnamn  == r, Andel >0)
    
    
    
    p <- ggplot(temp, aes(y = Typ_av_tillgång, x=Andel))+
      geom_col(position='dodge', fill = "#B81867")+
      labs(title = paste0("Andel med tillgång till olika tekniker i ", r),
           subtitle = paste0("År ", max(temp$Årtal)),
           y = "",x='Andel (%)',caption = 'Källa: Post- och telestyrelsen (PTS)',
      )+ 
      theme(
        text = element_text(family = "sourcesanspro", size = 12),
        axis.text.y = element_text(color='black'),
        plot.title = element_text(hjust = 1),
        plot.subtitle = element_text(hjust = -0.5,color="#B81867"),
        plot.caption = element_text(hjust = 2, vjust=1),
        plot.margin = grid::unit(c(t=40, 30, 15, 15), "pt"))
    
    print(p)
    # sparar som svg
    ggsave(paste0('Figurer/teknik_',r,'.svg'),plot = p,device = "svg", width = 7, height = 5)
    ggsave(paste0('Figurer/teknik_',r,'.png'),plot = p,device = "png", width = 7, height = 5, dpi=96) # png
  }
  
  
}
