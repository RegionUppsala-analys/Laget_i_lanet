########## Måste ändra namnet manuellt  på filen ########### 
########## Och i ID
temperatur <- function(){
  
  # Läser in data (byt 2022 mot nytt år)
  file_path <- "Data/uppsala_tm_1722-2022.dat"
  data <- read.table(file_path, header = TRUE, sep = "", stringsAsFactors = FALSE)
  
  # Fixar kolumnnamnen
  names(data) <- c('År','Månad','Dag','Medeltemp', 'Medeltemp korr', 'Id' )
  
  ################################### Detta får ändras manuellt
  data <- data %>% filter(Id == 1 ) # plockar ut Uppsala 
  
  # tar medelvärde för rekonstruerad temp
  data <- data %>% group_by(År) %>% summarize(
    Medeltemp = mean(`Medeltemp korr`),
    .groups ='drop')
  
  # Beräkna medelvärdet för årsmedeltemperatur
  mean_temperature <- mean(data$Medeltemp, na.rm = TRUE)
  
  # Skapa en kolumn för att ange om temperaturen är över eller under medelvärdet
  data$Diff_from_mean <- data$Medeltemp - mean_temperature
  data$Color <- ifelse(data$Diff_from_mean >= 0, "Över medelvärde", "Under medelvärde")
  
  # Skapar glidande medelvärden
  # 10 år
  data$Glidande.medelvarde_10 <- rollmean(data$Diff_from_mean, k = 10, fill = NA, align = "right")
  
  # 30-års glidande medelvärde
  data$Glidande.medelvarde_30 <- rollmean(data$Diff_from_mean, k = 30, fill = NA, align = "right")
  
  fig <- plot_ly()
  
  #  Stapeldiagram
  fig <- fig %>%
    add_bars(
      data = data,
      x = ~År,
      y = ~Diff_from_mean,
      color = ~Color,
      colors = c("Över medelvärde" = "#D63636", "Under medelvärde" = "#3599d5"),
      hoverinfo = "text",
      text = ~paste(
        "<b>År:</b>", År,
        "<br><b>Avvikelse från medel:</b>", sprintf("%.2f °C", Diff_from_mean)
      ),
      name = "Årsavvikelse"
    )
  
  # 10-års glidande medel
  fig <- fig %>%
    add_lines(
      data = data,
      x = ~År,
      y = ~Glidande.medelvarde_10,
      name = "10-års medelvärde",
      line = list(color = "black", width = 3),
      hoverinfo = "text",
      text = ~paste(
        "<br><b>Glidande medelvärde 10 år:</b>", sprintf("%.2f °C", Glidande.medelvarde_10)
      )
    )
  
  # 30-års glidande medel
  fig <- fig %>%
    add_lines(
      data = data,
      x = ~År,
      y = ~Glidande.medelvarde_30,
      name = "30-års medelvärde",
      line = list(color = "darkgreen", width = 3),
      hoverinfo = "text",
      text = ~paste(
        "<br><b>Glidande medelvärde 30 år:</b>", sprintf("%.2f °C", Glidande.medelvarde_30)
      )
    )
  
  # Layout 
  fig <- fig %>%
    layout(hovermode = 'x unified',margin = list(t = 50),
           title = list(
             text = paste0("<b>Rekonstruerad årsmedeltemperatur, Uppsala 1722–",max(data$År),"<b>"),
             x = 0.5,
             font = list(size = 20, color = "#B81867" )),
           xaxis = list(title = " ", showgrid = T,font = list(size = 14 )),
           yaxis = list(title = "<b>°C<b>", zeroline = FALSE,font = list(size = 14 )),
           barmode = "overlay",
           plot_bgcolor = "white",
           paper_bgcolor = "white",
           showlegend=FALSE,
           hoverlabel = list(bgcolor = "white", font = list(color = "black")),
           annotations = list(
             text = 'Källa: SMHI',
             x = 0,            
             y = -0.1,        
             xref = "paper",
             yref = "paper",
             xanchor = "left",
             yanchor = "bottom",
             showarrow = FALSE,
             font = list(size = 12)
           )
    )
  
  
  # tar bort en del plotlyfunktioner
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





######### SMHI ladda ned filen manuellt ########
# https://www.smhi.se/klimat/framtidens-klimat/klimatscenariotjansten/klimatscenariotjansten/met/uppsala_lan/medeltemperatur/rcp45/2071-2100/year/anom

#Temperaturprognos

temp_prog <- function(){
  # Läser in data
  ################ Data laddas ned från 
  # https://www.smhi.se/klimat/framtidens-klimat/klimatscenariotjansten/klimatscenariotjansten/met/uppsala_lan/medeltemperatur/rcp26/2071-2100/year/anom
  # Genom att välja alla 3 RCP kategorioer under "Utsläppsscenario" och Temperatur som " Klimatindikator
  df2 <- read.csv2('Data/tasAnom_rcp26_ANN_yr_1951_2100_uppsala_lan.csv', skip=27) %>% mutate(scenario = "2,6")
  df4 <- read.csv2('Data/tasAnom_rcp45_ANN_yr_1951_2100_uppsala_lan.csv', skip=27) %>% mutate(scenario = "4,5")
  df8 <- read.csv2('Data/tasAnom_rcp85_ANN_yr_1951_2100_uppsala_lan.csv', skip=27) %>% mutate(scenario = "8,5")
  
  # Slår ihop
  df <- rbind(df2,df4,df8)
  
  # Gör om till numeriskt
  df[, 2:5] <- lapply(df[, 2:5], as.numeric)
  
  # Prognosstart
  ar <- max(df[!is.na(df$obs_based),1])+1
  
  # Färgscheman
  color <- c("2,6"= "#4AA271",
             "4,5" = "#F9B000",
             "8,5" = "#D57667")
  
  color2 <- c("2,6"= "#DBECE3",
              "4,5" = "#FEEFCC",
              "8,5" = "#F7E4E1")
  
  # Skapar plot utan intervall
  p <- ggplot(df, aes(x =year,y = ensemble_mean, color=scenario, fill=scenario))+ 
    geom_line(linewidth = 1.5) + 
    geom_vline(xintercept = ar, color = "red", linetype = "dashed", linewidth = 1) +
    geom_hline(yintercept = 0, color = "black", linetype = "dashed", linewidth = 1) +
    scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 10))+
    scale_color_manual(values= color)+
    scale_fill_manual(values= color2)+
    annotate("text",
             x = ar, y = max(df$ensemble_mean, na.rm = TRUE),
             label = paste("Prognosstart -",ar),
             color = "red",      # vertical text
             vjust = -0.05,           # adjust vertical position
             hjust = -0.15,            # adjust horizontal position
             size = 4) +
    
    labs(
      title = str_wrap(paste("Förändring av temperatur med interval och prognos - Uppsala Län"), width=50),
      x = "",
      y = "Medeltemperatur °C",
      color ='RCP',
      fill='RCP'
    )+
    theme_get() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "bottom",
      plot.title.position = "plot",
      plot.caption.position = "plot", 
      legend.direction = "horizontal",
      plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SMHI') 
  
  # Sparar plot
  ggsave("Figurer/temp_prognos.svg", plot = p, device = "svg", width = 8, height = 6)
  
  ggsave("Figurer/temp_prognos.png", plot = p, device = "png", width = 8, height = 6, dpi=96)
  
  # En plot per RCP inklusive intervall
  for(r in unique(df$scenario)){
    # Filtrarar rcp
    temp <- df %>% filter(scenario == r)
    
    # Skapar plot
    p <- ggplot(temp, aes(x =year,y = ensemble_mean, color=scenario, fill=scenario))+ 
      geom_line(linewidth = 1.5) + 
      geom_vline(xintercept = ar, color = "red", linetype = "dashed", linewidth = 1) +
      geom_hline(yintercept = 0, color = "black", linetype = "dashed", linewidth = 1) +
      geom_ribbon(aes(x =year,ymin = tenthPercentile, ymax = nintiethPercentile), alpha = 0.3)+
      geom_line(linewidth = 0.5,aes(y = tenthPercentile))+
      geom_line(linewidth = 0.5,aes(y = nintiethPercentile))+ 
      scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 10))+
      scale_color_manual(values= color)+
      scale_fill_manual(values= color2)+
      annotate("text",
               x = ar, y = max(temp$nintiethPercentile, na.rm = TRUE),
               label = paste("Prognosstart -",ar),
               color = "red",      # vertical text
               vjust = -0.05,           # adjust vertical position
               hjust = -0.15,            # adjust horizontal position
               size = 4) +
      
      labs(
        title = str_wrap(paste("Förändring av temperatur med interval och prognos - Uppsala Län"), width=50),
        x = "",
        y = "Medeltemperatur °C",
        color ='RCP',
        fill='RCP'
      )+
      theme_get() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        plot.title.position = "plot",
        plot.caption.position = "plot", 
        legend.direction = "horizontal",
        plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SMHI') 
    
    # Sparar plot
    ggsave(paste0("Figurer/temp_prognos_",r,".svg"),
           plot = p, device = "svg", width = 8, height = 6)
    
    ggsave(paste0("Figurer/temp_prognos_",r,".png"),
           plot = p, device = "png", width = 8, height = 6, dpi=96)
  }
}

