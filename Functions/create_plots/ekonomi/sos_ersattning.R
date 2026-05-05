# Används ej nu
sos_ersattning <- function(){
  # Läser in data och fixar till kön-variabeln
  df <- read.csv('Data/df_sos_ersatt.csv')
  df  <- df%>% mutate(kön = tools::toTitleCase(kön))
  
  # skillnader mellan män och kvinnor
  df_long <- df %>%
    select(-matches("Folkmängd")) %>%
    pivot_longer(
      cols = where(is.numeric),
      names_to = "Variable",
      values_to = "Value"
    )
  
  # Gör om data till long och skapar en indikatorvariabel
  df_plot <- df_long %>%
    pivot_wider(names_from = kön, values_from = Value) %>%
    mutate(
      Ratio = Kvinnor / Män -1,
      kön_color = case_when(
        Ratio > 0 ~ "Fler kvinnor",
        TRUE      ~ "Fler män"
      )
    )
  
  
  # Kommunerna
  regions <- unique(df_plot$region)
  colors <- c("Fler kvinnor" = "#D57667", "Fler män" = "#4AA271")
  
  fig <- plot_ly()
  
  # Loopar över alla kommuner
  for (i in seq_along(regions)) {
    # Filtrerar dataa
    reg <- regions[i]
    tmp <- df_plot %>% filter(region == reg)
    
    # Lägger till en trace per kön
    for (kc in unique(tmp$kön_color)) {
      tmp_kc <- tmp %>% filter(kön_color == kc)
      
      tmp_kc <- tmp_kc %>%
        mutate(
          hover_text = paste0(
            "Kvinnor: ", Kvinnor, "<br>",
            "Män: ", Män, "<br>",
            ifelse(
              Ratio > 0,
              round(Ratio * 100, 1), # percentage
              round(abs(Ratio) * 100, 1)
            ),
            ifelse(Ratio > 0, "% Fler kvinnor", "% Fler män")
          )
        )
      
      fig <- fig %>%
        add_trace(
          data = tmp_kc,
          x = ~Variable,
          y = ~Ratio,
          type = "bar",
          name = kc,                  # legend shows Fler kvinnor / Fler män
          hovertext = ~hover_text,
          hoverinfo = 'text',
          marker = list(color = colors[kc]),
          visible = ifelse(i == 1, TRUE, FALSE)
        )
    }
  }
  
  # Each region has 2 traces, so update visibility accordingly
  fig <- fig %>%
    layout(font = list(list(family = "sourcesanspro")),
           title = list(text=paste("Skillnad mellan kvinnor och män -", regions[1]),
                        font = list(size = 20, color = "#B81867")),
           xaxis = list(title = ""),
           yaxis = list(title = "(Kvinnor / Män) - 1",
                        zeroline = FALSE,
                        showline = TRUE),
           barmode = 'group',
           updatemenus = list(
             list(
               y = 1.15,
               buttons = lapply(seq_along(regions), function(i) {
                 vis <- rep(FALSE, length(regions)*2)
                 vis[((i-1)*2+1):((i-1)*2+2)] <- TRUE  # turn on the 2 traces for this region
                 
                 list(
                   method = "update",
                   label = regions[i],
                   args = list(
                     list(visible = vis),
                     list(title = paste("Skillnad mellan kvinnor och män -", regions[i]))
                     
                     
                   )
                 )
               })
             )
           )
    )
  
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

sos_ersattning_static <- function(){
  # Läser in data
  df <- read.csv('Data/df_sos_ersatt.csv')
  df  <- df%>% mutate(kön = tools::toTitleCase(kön))
  
  # Gör till longformat
  df_long <- df %>%
    select(-matches("Folkmängd")) %>%
    pivot_longer(
      cols = where(is.numeric),
      names_to = "Variable",
      values_to = "Value"
    )
  
  # Gör om variabelnamnen till snyggare etiketter
  df_long <- df_long %>%
    mutate(
      Variable = case_when(
        Variable == "Sjukpenning" ~ "Sjukpenning",
        Variable == "Sjuk..och.aktivitetsersersättning" ~ "Sjuk- och aktivitetsersättning",
        Variable == "Arbetslöshetsersättning" ~ "Arbetslöshetsersättning",
        Variable == "Arbetsmarknadsåtgärder" ~ "Arbetsmarknadsåtgärder",
        Variable == "Ekonomiskt.bistånd" ~ "Ekonomiskt bistånd",
        Variable == "Etableringsersättning" ~ "Etableringsersättning",
        Variable == "Summa.helårsekvivalenter" ~ "Summa helårsekvivalenter",
        Variable == "Andel.av.befolkningen" ~ "Andel av befolkningen",
        TRUE ~ Variable
      )
    )
  
  
  regions <- unique(df_long$region)
  colors <- c("Kvinnor" = "#D57667", "Män" = "#4AA271")
  
  for(r in regions){
    # filtrerar ut data
    temp <- df_long %>% filter(region == r)
    andel <- temp %>% filter(Variable == "Andel av befolkningen")
    temp <- temp %>% filter(Variable != "Andel av befolkningen")
    
    # Skapar plot
    p <- ggplot(temp, aes(y=Variable, x= Value, fill = kön))+ 
      geom_col(position='dodge') + scale_fill_manual(values =colors)+
      labs(x="Antal",y='',title =paste('Biståndsersättningar' ), 
           fill='') + theme(legend.position='bottom',
                            axis.text.y = element_text(size =14),
                            plot.title = element_text(size=24))
    
    
    max_x <- max(temp$Value)
    min_y <- min(as.numeric(factor(temp$Variable)))
    y_base <- min_y + 0.3           # lite under den sista raden
    y_step <- 0.4                  # vertikalt mellanrum mellan könsrader
    
    andel <- andel %>%
      mutate(
        label_text = paste0(kön, ": ", round(Value, 1), "%"),
        x_pos = max_x * 0.55,                 # långt till höger i grafen
        y_pos = y_base - (as.numeric(factor(kön)) - 1) * y_step
      )
    
    # Lägg till titel för rutan
    p <- p +
      annotate(
        "text",
        x = max_x * 0.50,
        y = y_base + y_step +0.1,
        label = "Andel av befolkningen",
        hjust = 0,
        vjust = 1,
        size = 5,
        fontface = "bold"
      )
    
    # Lägg till färgrutor + text
    p <- p +
      geom_tile(
        data = andel,
        aes(x = x_pos, y = y_pos, fill = kön),
        width = max_x * 0.02,
        height = y_step * 0.6,
        inherit.aes = FALSE
      ) +
      geom_text(
        data = andel,
        aes(x = x_pos + max_x * 0.03, y = y_pos, label = label_text),
        hjust = 0,
        vjust = 0.5,
        size = 5,
        color = "black",
        inherit.aes = FALSE
      ) + theme(plot.caption = element_text(hjust = 0))+ labs(caption = 'Källa: SCB')
    
    # sparar plot
    svg_filename <- paste0("Figurer/sos_ersatt_", r, ".svg")
    ggsave(svg_filename, plot = p, device = "svg", width = 8, height = 6)
  }
  
  
  
}

