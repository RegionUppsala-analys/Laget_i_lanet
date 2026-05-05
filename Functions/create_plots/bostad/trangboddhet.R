####### Trångboddhet #########

trangbodd_kom <- function(){
  # Läser in data
  df <- read.csv("Data/trandboddhet.csv") %>% filter(year == max(year))
  
  # fixar snyggare titlar: 
  df$title <- gsub("Trångboddhet i flerbostadshus, enligt ", "", df$title)
  df$title <- gsub(", andel \\(%\\)", "", df$title)
  
  df$title <- tools::toTitleCase(df$title)
  
  df <- df %>% mutate(gender = case_when(gender== 'K'~'Kvinnor',
                                         gender== 'M'~'Män'))
  
  # Byter namn till "Länet"
  df$municipality <- ifelse( df$municipality == "Region Uppsala", "Länet",df$municipality)
  
  # Färgtema
  cols <- c('Män' = "#4AA271",
            'Kvinnor' = "#D57667")
  
  # loopar över alla kommuner
  for (r in unique(df$municipality)){
    
    # Filtrerar kommun
    temp <- df %>% filter(municipality == r)
    
    # Tidserieplots
    p<- ggplot(temp, aes(x = gender, y = value, fill= gender))+
      geom_col() + facet_wrap(~title, ncol=2)+
      labs(title=paste0('Trångboddhet i flerbostadshus i \n', r, ', år ', unique(temp$year)), 
           y='Andel (%)', x='', fill = '')+ylim(0,60)+
      scale_fill_manual(values=cols)+ 
      theme(legend.position = 'bottom',
            plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: Kolada och SCB')
    
    # Sparar en plot per kommun
    filename <-  paste0('Figurer/trangboddhet_',r ,'.svg')
    ggsave(filename,plot = p,device = "svg", width = 7, height = 5)
    
    # png
    
    filename <-  paste0('Figurer/trangboddhet_',r ,'.png')
    ggsave(filename,plot = p,device = "png", width = 7, height = 5,
           dpi = 96)
    #print(p)
  }
  
}

trangboddhet_andel <- function(){
  
  # Läser in data
  df <- read.csv('Data/df_trang.csv') %>% filter(födelseregion  != 'okänt')
  
  df$födelse <- ifelse(df$födelseregion=='Sverige','Födda i Sverige', 'Utrikesfödda')
  
  # Longformat för att få i samma column
  df_long <- df %>% pivot_longer(cols = c(`Personer.0.17.år` ,`Personer.minst.18.år`),
                                 names_to = 'Åldersgrupp')
  
  df_long$Åldersgrupp <- ifelse(df_long$Åldersgrupp == "Personer.0.17.år", 'Under 18 år','Minst 18 år' )
  
  # Slår ihop grupperna
  
  df_long <- df_long %>% group_by(födelse,Åldersgrupp,år,trångboddhet) %>% 
    summarise(Antal = sum(value), .groups='drop')
  
  # Läser in data om folkmängd
  df_f <- df_long %>% filter(trångboddhet == 'totalt')
  df_long <- df_long %>% filter(trångboddhet != 'totalt')
  
  
  # Gör andelar
  df_long$Andel <-(df_long$Antal/df_f$Antal) *100
  
  
  # Färggrupp
  
  df_long$color <- paste(df_long$födelse,'-',df_long$Åldersgrupp)
  
  df_long$color <- factor(df_long$color,
                          levels = unique(df_long$color))
  
  
  # Färgschema
  cols <- c( "#F9B000", "#019CD7")
  
  # skapar plotten
  p <- ggplot(df_long, aes(x=år, y =Andel, color=Åldersgrupp,group = Åldersgrupp))+ 
    geom_line(linewidth = 2)+geom_point(size=4)+ facet_wrap(~födelse, nrow=2)+
    scale_x_continuous(
      breaks = seq(min(df_long$år), max(df_long$år) , by = 2))+
    scale_y_continuous(labels = scales::label_percent(scale = 1))+
    scale_color_manual(values = cols)+ labs(
      title= str_wrap(paste("Andel trångbodda (enligt norm 2) personer i flerbostadshus i Uppsala län"),
                      width=50),
      y = "Andel", color='',
      x = " ",caption = 'Källa: SCB'
    )+ guides(
      color = guide_legend(nrow = 2, byrow = TRUE),
      linetype = guide_legend(nrow = 2, byrow = TRUE)
    )+
    theme(
      legend.title = element_text(size = 12),
      legend.text = element_text(size = 14),
      panel.grid.major = element_line(),
      axis.title.y = element_text(angle=90, size=16),
      plot.title = element_text(hjust = 0.5,size=20,face = "bold"),
      axis.text.x = element_text(angle = 0),
      plot.caption = element_text(hjust = 0),
      strip.text = element_text(size = 18)
    )
  p
  
  svg_filename <- paste0("Figurer/trang.svg")
  ggsave(svg_filename, plot = p, device = "svg", width = 8, height = 7) # sparar plot
  
  filename <-  paste0('Figurer/trang.png')
  ggsave(filename,plot = p,device = "png", width = 7, height = 7,
         dpi = 96)
  
}



trangboddhet_antal <- function(){
  
  # Läser in data
  df <- read.csv('Data/df_trang.csv') %>% filter(födelseregion  != 'okänt')
  
  df$födelse <- ifelse(df$födelseregion=='Sverige','Födda i Sverige', 'Utrikesfödda')
  
  # Longformat för att få i samma column
  df_long <- df %>% pivot_longer(cols = c(`Personer.0.17.år` ,`Personer.minst.18.år`),
                                 names_to = 'Åldersgrupp')
  
  df_long$Åldersgrupp <- ifelse(df_long$Åldersgrupp == "Personer.0.17.år", 'Under 18 år','Minst 18 år' )
  
  # Slår ihop grupperna
  
  df_long <- df_long %>%filter(trångboddhet  != 'totalt') %>%  group_by(födelse,Åldersgrupp,år) %>% 
    summarise(Antal = sum(value), .groups='drop')
  
  
  # Färggrupp
  
  df_long$color <- paste(df_long$födelse,'-',df_long$Åldersgrupp)
  
  df_long$color <- factor(df_long$color,
                          levels = unique(df_long$color))
  
  
  # Färgschema
  cols <- c( "#F9B000", "#019CD7")
  
  # skapar plotten
  p <- ggplot(df_long, aes(x=år, y =Antal, color=Åldersgrupp,group = Åldersgrupp))+ 
    geom_line(linewidth = 2)+geom_point(size=4)+ facet_wrap(~födelse, nrow=2)+
    scale_x_continuous(
      breaks = seq(min(df_long$år), max(df_long$år) , by = 2)
    )+
    scale_color_manual(values = cols)+ labs(
      title= str_wrap(paste("Antal trångbodda (enligt norm 2) personer i flerbostadshus i Uppsala län"),
                      width=50),
      y = "Antal", color='',
      x = " ",caption = 'Källa: SCB'
    )+ guides(
      color = guide_legend(nrow = 2, byrow = TRUE),
      linetype = guide_legend(nrow = 2, byrow = TRUE)
    )+
    theme(
      legend.title = element_text(size = 12),
      legend.text = element_text(size = 14),
      panel.grid.major = element_line(),
      axis.title.y = element_text(angle=90, size=16),
      plot.title = element_text(hjust = 0.5,size=20,face = "bold"),
      axis.text.x = element_text(angle = 0),
      plot.caption = element_text(hjust = 0),
      strip.text = element_text(size = 18)
    )
  p
  
  svg_filename <- paste0("Figurer/trang_antal.svg")
  ggsave(svg_filename, plot = p, device = "svg", width = 8, height = 7) # sparar plot
  
  filename <-  paste0('Figurer/trang_antal.png')
  ggsave(filename,plot = p,device = "png", width = 7, height = 7,
         dpi = 96)
  
}

