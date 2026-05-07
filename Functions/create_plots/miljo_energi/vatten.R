
########### Vatten ########

eko_vatten <- function(){
  # Läser in data
  df <- read.csv('Data/df_ekovatten.csv') %>% filter(!is.na(value)) %>% 
    filter(year == max(year), title != "Kustvatten med god ekologisk status, andel (%)",
           value > 0)
  
  # Tar bort andel från titel
  df$title <- str_remove(df$title,', \\s*andel\\s*\\(%\\)')
  
  for(t in unique(df$title)){
    # Filtrerar ut titeln
    temp <- df %>% filter(title==t)
    
    # Skapar plot
    p <- ggplot(temp, aes(x = municipality, y=value))+ 
      geom_col(position="dodge", fill="#B81867")+
      labs(title= paste(t, 'år',max(df$year)),
           x = "",y='Andel (%)', caption = 'Källa: Jordbruksverket')+ 
      theme(axis.text.x = element_text(angle = 90),
            legend.position="none",
            text = element_text(family = "sourcesanspro", size = 14),
            axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
            axis.text.x.bottom  = element_text(angle = 45, hjust=1),
            plot.caption = element_text(hjust = 0, vjust=4))
    print(p)
    # sparar som svg
    text <- str_split(t, " ")[[1]][1]
    ggsave(paste0('Figurer/eko_vatten_',text
                  ,'.svg'),plot = p,device = "svg", width = 7, height = 6)
    
    
    ggsave(paste0('Figurer/eko_vatten_',text
                  ,'.png'),plot = p,device = "png", width = 7, height = 6, dpi=96)
    
  }
  
  
}



########## Vatten kolada #########

avgift_vatten <- function(){
  # Läser in data
  df <- read.csv('Data/avgift_vatten_NHM.csv')
  
  # fixar titeln
  df$title <- gsub(", kr/inv", "", df$title)
  
  # Skapar plot
  p <- ggplot(df, aes(x = year, y=value, color=municipality))+ 
    geom_line(linewidth=2) + geom_point(size=3)+
    scale_color_manual(values=kommun_colors)+
    labs(title= str_wrap(paste(unique(df$title)),width=50),
         x = "",y='Avgift (kr/kvm)', caption = 'Källa: Nils Holgersson gruppen',
         color="")+ 
    theme(axis.text.x = element_text(angle = 90),
          text = element_text(family = "sourcesanspro", size = 14),
          axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0, vjust=4))
  p
  # sparar som svg
  ggsave('Figurer/avgift_vatten.svg',plot = p,device = "svg", width = 8, height = 6)
  
  
  
  ggsave('Figurer/avgift_vatten.png',plot = p,device = "png", width = 8, height = 6, dpi =96)
  
  
}


inv_vatten <- function(){
  # Läser in data
  df <- read.csv('Data/investering_vatten.csv') %>% filter(value > 0)
  
  # fixar titeln
  df$title <- gsub(", kr/inv", "", df$title)
  
  # Skapar plot
  p <- ggplot(df, aes(x = year, y=value, color=municipality))+ 
    geom_line(linewidth=2) + geom_point(size=3)+
    scale_color_manual(values=kommun_colors)+
    labs(title= str_wrap(paste(unique(df$title)),width=50),
         x = "",y='Utgift (kr/inv)', caption = 'Källa: SCB',
         color="")+ 
    theme(axis.text.x = element_text(angle = 90),
          text = element_text(family = "sourcesanspro", size = 14),
          axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0, vjust=4))
  p
  # sparar som svg
  ggsave('Figurer/inv_vatten.svg',plot = p,device = "svg", width = 8, height = 6)
  
  
  
  ggsave('Figurer/inv_vatten.png',plot = p,device = "png", width = 8, height = 6, dpi =96)
  
  
}

netto_vatten <- function(){
  # Läser in data
  df <- read.csv('Data/nettokostnad_vatten.csv') %>% filter(!is.na(value)) 
  
  # fixar titeln
  df$title <- gsub(", kr/inv", "", df$title)
  
  # Skapar plot
  p <- ggplot(df, aes(x = year, y=value, color=municipality))+ 
    geom_line(linewidth=2) + geom_point(size=3)+
    scale_color_manual(values=kommun_colors)+
    labs(title= str_wrap(paste(unique(df$title)),width=50),
         x = "",y='Nettokostnad (kr/inv)', caption = 'Källa: SCB Räkenskapssammandrag',
         color="")+ 
    theme(axis.text.x = element_text(angle = 90),
          text = element_text(family = "sourcesanspro", size = 14),
          axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0, vjust=4))
  
  p
  # sparar som svg
  ggsave('Figurer/netto_vatten.svg',plot = p,device = "svg", width = 8, height = 6)
  
  
  
  ggsave('Figurer/netto_vatten.png',plot = p,device = "png", width = 8, height = 6, dpi =96)
  
  
}


grundvatten_kolada <- function(){
  # Läser in data
  df <- read.csv('Data/df_grund.csv') 
  
  # fixar titeln
  df$title <- gsub(", andel (%)", "", df$title)
  
  # Skapar plot
  p <- ggplot(df, aes(x = year, y=value, color="#B81867"))+ 
    geom_line(linewidth=2) + geom_point(size=3)+ylim(0,100)+ facet_wrap(~municipality)+
    scale_color_manual(values="#B81867")+
    labs(title= str_wrap(paste(unique(df$title)),width=50),
         x = "",y='Andel (%)', caption = 'Källa: VISS, Länsstyrelserna',
         color="")+ 
    theme(axis.text.x = element_text(angle = 90),
          text = element_text(family = "sourcesanspro", size = 14),
          axis.title.y = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
          axis.text.x.bottom  = element_text(angle = 45, hjust=1),
          plot.caption = element_text(hjust = 0, vjust=4),
          legend.position = "none")
  
  p
  # sparar som svg
  ggsave('Figurer/grundvatten_kolada.svg',plot = p,device = "svg", width = 8, height = 7)
  
  
  
  ggsave('Figurer/grundvatten_kolada.png',plot = p,device = "png", width = 8, height = 7, dpi =96)
  
  
}




vattenanvändning <- function(){
  
  # Läser in data och ta bort siffror från länsnamn
  df <- read.csv("Data/vattenanvandning.csv")
  
  # Rensar titlar
  df$title <- gsub(", senaste mätning, kbm/inv", "", df$title)
  df$title <- gsub(",", "", df$title)
  
  # Variabler till plot
  titles <- unique(df$title)
  n_region <- length(unique(df$municipality))
  
  # fixar ordningen på legenden
  regions <- unique(df$municipality)[-1]
  df <- df %>% mutate(municipality = factor(municipality,levels = c("Riket",sort(regions))))
  
  # Skapar plot
  fig <- plot_ly()
  
  #  Lägg till alla län (grå linjer) och frågor i dropdown
  for (t in titles){
    for (region in levels(df$municipality)) {
      
      temp <- df %>% filter(municipality == region, title == t)
      
      # färg och storlekar på linjer
      col <- ifelse(region=="Region Uppsala","#B81867","#6F787E")
      sizeL <- ifelse(region=="Region Uppsala",5,1.2)
      sizeM <- ifelse(region=="Region Uppsala",8,1.2)
      
      
      # Linje och marker
      fig <- fig %>%
        add_trace(
          data = temp ,
          x = ~year,
          y = ~value,
          type = "scatter",
          mode = "lines+markers",
          name = region,
          line = list(color = col, width =sizeL),
          marker = list(color = col, size = sizeM),
          visible = ifelse(t == titles[1], TRUE, FALSE) ,
          text = I(paste(temp$municipality, "<br>År:",temp$year, "<br>Användning:", round(temp$value, 1)))
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
        list( title = paste("<b>",titles[i],"<b>"))
      ),
      label = titles[i]
    )
  })
  
  #  Layout
  fig <- fig %>%
    layout(
      margin = list(t = 50),
      title = list(text = paste("<b>",titles[1],"<b>"), y = 0.95, x = 0.50,
                   font = list(size = 20, color = "#B81867")),
      xaxis = list(title = "",
                   dtick = 2),
      yaxis = list(title = paste("<b> Kbm/inv <b>"), 
                   rangemode = "tozero"),
      updatemenus = list(
        list(
          y = -0.1,
          x=1.1,
          buttons = buttons,
          direction = "up"
        )),
      annotations = list(
        text ='Källa: SCB',
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
  
  fig
  
  
}