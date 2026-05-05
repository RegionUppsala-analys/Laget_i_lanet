#### Befolkningsträd ###
# Med sliders för år
# Används ej
befolknigstree_years <- function(){
  
  df_fram <- read.csv('Data/df_folkmangdfram.csv')
  
  # Region 
  minar <- min(df_fram$år) # sorterar bort senaste året plus att jag tar total av inrikes utrikes
  df_fram <- df_fram %>%filter(år>minar,år<=minar+20 , inrikes.utrikes.född == 'inrikes och utrikes födda') %>% 
    select(region, kön, ålder, år, Antal)
  
  df <- read.csv('Data/df_folkmangd.csv')
  df <- df %>% filter(år > 2001)  %>% rename('Antal' = Folkmängd )              # Väljer 2002 som basår
  
  regionmax <- max(df$år)
  # Region , total folkmängd per kön 1986 - 2070
  region <- rbind(df, df_fram)
  region <- region %>% group_by(år, kön, ålder) %>% summarise(Total = ceiling(sum(Antal)), .groups = 'drop')
  region$region <- "Länet"
  
  # Kommun 
  df_kommunfram <- df_fram %>% group_by(region, år, kön, ålder) %>% 
    summarise(Total = ceiling(sum(Antal)), .groups='drop') # Summerar per region år kön ålder
  
  df_kommun <- df %>% group_by(region, år, kön , ålder) %>% 
    summarise(Total = sum(Antal), .groups='drop')
  
  kommun <- rbind(df_kommunfram,df_kommun)
  
  
  # Skapa plotly 
  
  # Kombinera Region + Kommun 
  df_plot <- rbind(
    region %>% select(år,  Total, ålder, region, kön),
    kommun %>% select(år,  Total, ålder, region, kön)
  )
  
  # Gör om mäns värden till negativa för pyramid
  df_plot <- df_plot %>%
    mutate(Total_plot = ifelse(kön == "män", -Total, Total))
  
  # Sortera kommuner alfabetiskt, Region först
  alfabetiska_kommuner <- sort(kommuner)
  unika_regioner <- c("Länet", alfabetiska_kommuner)
  
  
  genders <- c("kvinnor", "män")
  colors <- c("kvinnor" = "#D57667", "män" = "#4AA271")
  # Alla år
  ar_sorterade <- sort(unique(df_plot$år))
  
  # Konvertera år till faktor med rätt levels
  df_plot$år <- factor(df_plot$år, levels = ar_sorterade)
  # Lista som håller grafer
  plots <- list()
  
  for (r in unika_regioner) {
    temp <- df_plot %>% filter(region == r)
    
    p <- plot_ly()
    
    for (k in genders) {
      temp_k <- temp %>% filter(kön == k)
      if(nrow(temp_k) == 0) next
      
      p <- p %>%
        add_bars(
          data = temp_k,
          x = ~Total_plot,
          y = ~ålder,
          frame = ~år,
          name = tools::toTitleCase(k),
          orientation = "h",
          marker = list(color = colors[k],line = list(width = 0)),
          legendgroup = k,
          showlegend = TRUE,
          text = ~paste0(
            "<b>Kön:</b> ", tools::toTitleCase(k), "<br>",
            "<b>Ålder:</b> ", ålder, "<br>",
            "<b>Befolkning:</b> ", formatC(abs(Total_plot), format = "d", big.mark = " "), " personer<br>",
            "<b>År:</b> ", år
          ),
          hoverinfo = "text",
          textposition = "none"
        )
    }
    max_total <- ceiling(max(temp$Total_plot))
    # Symmetrisk x-axel med 0 i mitten och endast heltal
    tick_vals <- c(-max_total,-round(max_total/2),-round(max_total/4), 0 ,round(max_total/4),round(max_total/2),max_total )
    
    p <- p %>%
      layout(font = list(family = "sourcesanspro"),
             margin = list(t = 40),
             barmode = 'overlay',
             bargap = 0.01,
             title = list(
               text = paste('Befolkningsutveckling i',r),
               font = list(size = 18),
               x = 0.5,       
               y = 1.3
             ),
             yaxis = list(title = "Ålder"),
             xaxis = list(title = "Befolkning", tickformat = ",", 
                          zeroline = TRUE,
                          tickvals = tick_vals,
                          ticktext = abs(tick_vals))) %>%
      animation_opts(frame = 200, transition = 150, redraw = TRUE) %>% ## Här ändras hastigheten på slidern :)
      animation_slider(
        currentvalue = list(prefix = "År: ")
      )
    
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
    
    plots[[r]] <- p
  }
  
  # Exempel: visa graf för Länet
  #plots[["Uppsala"]]
  
  # Spara alla grafer som html-filer (en per region)
  for (r in names(plots)) {
    file_base  <- paste0("Figurer/pyramid_ar_", gsub(" ", "_", r), ".html")
    file_base <- iconv(file_base, to="ASCII//TRANSLIT")
    # Ta bort filen om den redan finns
    html_file <- paste0(file_base, ".html")
    assets_dir <- paste0(file_base, "_files")
    
    # Ta bort HTML och assets om det exist
    if (file.exists(html_file)) unlink(html_file)
    if (dir.exists(assets_dir)) unlink(assets_dir, recursive = TRUE)
    
    htmlwidgets::saveWidget(
      plots[[r]],
      file_base,
      selfcontained = TRUE
    )
  }
  
}

# utan slider:

befolknigstree <- function(){
  # Läser in data
  df <- read.csv('Data/df_folkmangd.csv')
  df <- df %>% filter(år == max(år))
  
  # Summerar per år kön och ålder
  region <- df %>% group_by(år, kön, ålder) %>% summarise(Folkmängd = sum(Folkmängd), .groups = 'drop') %>% 
    mutate(region = "Länet") %>% select(region,ålder,kön,år,Folkmängd)
  
  
  df_plot <- rbind(df, region)
  # Gör om mäns värden till negativa för pyramid
  df_plot <- df_plot %>%
    mutate(Total_plot = ifelse(kön == "män", -Folkmängd, Folkmängd))
  
  # Sortera kommuner alfabetiskt, Region först 
  alfabetiska_kommuner <- sort(kommuner)
  unika_regioner <- c("Länet", alfabetiska_kommuner)
  
  
  genders <- c("kvinnor", "män")
  colors <- c("kvinnor" = "#D57667", "män" = "#4AA271")
  
  # loopar över alla regioner
  for(r in unika_regioner){
    temp <- df_plot %>% filter(region ==r) # temporär data
    # Gränser för x-axeln
    max_val <- max(abs(temp$Total_plot))
    pop_range <- c(-max_val,-round(max_val/2),0,round(max_val/2), max_val)
    
    # skapar plot
    p <-ggplot(temp, aes(x = Total_plot, y=as.factor(ålder), fill=kön)) + geom_col(width = 1) +
      scale_fill_manual(values = colors,
                        labels = tools::toTitleCase(names(colors))) + 
      scale_x_continuous(breaks=pop_range, labels=abs(pop_range))+ 
      scale_y_discrete(breaks = as.character(seq(0, 100, by = 10)))+
      labs(x="Antal", y='Ålder',title =paste('Befolkningspyramid',max(temp$år) ), 
           fill='')+
      theme_get()+ theme(
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
    
    svg_filename <- paste0("Figurer/pyramid_", gsub(" ", "_", r), ".svg")
    ggsave(svg_filename, plot = p, device = "svg", width = 8, height = 6)
    
    png_filename <- paste0("Figurer/pyramid_", gsub(" ", "_", r), ".png")
    ggsave(png_filename, plot = p, device = "png", width = 8, height = 6,dpi = 96)
    
  }
}

befolknigstree_fodelse <- function(){
  # Läser in data
  df <- read.csv('Data/df_folkmangd_fodd.csv')
  
  # Summerar per år kön och ålder
  region <- df %>% group_by(år, kön, ålder,födelseregion) %>% summarise(Antal = sum(Antal), .groups = 'drop') %>% 
    mutate(region = "Länet") %>% select(region,ålder,födelseregion,kön,år,Antal) 
  
  
  df_plot <- rbind(df, region)
  # Gör om mäns värden till negativa för pyramid
  df_plot <- df_plot %>%
    mutate(Total_plot = ifelse(kön == "män", -Antal, Antal),
           födelseregion = str_to_sentence(födelseregion))
  
  # Sortera kommuner alfabetiskt, Region först 
  alfabetiska_kommuner <- sort(kommuner)
  unika_regioner <- c("Länet", alfabetiska_kommuner)
  
  # variabler för att fixa färger 
  df_plot <- df_plot %>%
    mutate(kön = factor(kön, levels = c("män", "kvinnor")))
  genders <- c("kvinnor", "män")
  colors <- c("män" = "#4AA271","kvinnor" = "#D57667")
  
  # loopar över alla regioner
  for(r in unika_regioner){
    for(f in unique(df_plot$födelseregion)){
      temp <- df_plot %>% filter(region ==r,födelseregion==f ) # temporär data
      # Gränser för x-axeln
      max_val <- max(abs(temp$Total_plot))
      pop_range <- c(-max_val,-round(max_val/2),0,round(max_val/2), max_val)
      
      # skapar plot, en per födelseregion
      if(f == "Född i sverige"){
        p <- ggplot(temp, aes(x = Total_plot, y=as.factor(ålder), fill=kön)) + geom_col(width = 1) +
          scale_fill_manual(values = colors,
                            labels = tools::toTitleCase(names(colors)),guide="none") + 
          scale_x_continuous(breaks=pop_range, labels=abs(pop_range))+ 
          scale_y_discrete(breaks = as.character(seq(0, 100, by = 10)))+
          labs(x="Antal", y='Ålder',title =paste('Född i Sverige -',max(temp$år) ), 
               fill='')+
          theme_get() +theme(legend.position='bottom',
                             plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
        
        svg_filename <- paste0("Figurer/pyramid_fodd_", r,'_sve', ".svg")
        ggsave(svg_filename, plot = p, device = "svg", width = 8, height = 6)
        
        png_filename <- paste0("Figurer/pyramid_fodd_", r,'_sve', ".png")
        ggsave(png_filename, plot = p, device = "png", width = 8, height = 6,dpi = 96)
        
      }else{
        
        p <- ggplot(temp, aes(x = Total_plot, y=as.factor(ålder), fill=kön)) + geom_col(width = 1) +
          scale_fill_manual(values = colors,
                            labels = tools::toTitleCase(names(colors))) + 
          scale_x_continuous(breaks=pop_range, labels=abs(pop_range))+ 
          scale_y_discrete(breaks = as.character(seq(0, 100, by = 10)))+
          labs(x="Antal", y='Ålder',title =paste('Utrikesfödda','-',max(temp$år)), 
               fill='')+
          theme_get() + theme(legend.position='bottom',
                              plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
        
        svg_filename <- paste0("Figurer/pyramid_fodd_", r,'_utl', ".svg")
        ggsave(svg_filename, plot = p, device = "svg", width = 8, height = 6)
        
        # png
        png_filename <- paste0("Figurer/pyramid_fodd_", r,'_utl', ".png")
        ggsave(png_filename, plot = p, device = "png", width = 8, height = 6,dpi = 96)
        
      }
      
    }
  }
}