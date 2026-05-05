samband_inkomster <- function(){
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_inkomststruktur.gpkg")
      df_inkomststruktur <- st_read("Data/df_inkomststruktur.gpkg", quiet = TRUE)
    })
  })
  
  # Filtrerar ut totalt
  df_gender <- df_inkomststruktur %>% filter(kön != "totalt")
  
  
  # regsonamn
  regso <- read_excel('Data/koppling-deso2018-regso2020.xlsx',col_names = T, skip=3)
  
  regso <- regso %>%  rename(desokod = 'DeSO_2018',
                             'Område' = RegSO_2020)
  
  
  # Slår ihop data
  df_gender <- df_gender %>% left_join(regso %>% select(desokod, Område), by='desokod')
  
  # variabelnamn
  top_components <- c(
    "löneinkomst ",
    "näringsinkomst med mera",
    "inkomst av kapital",
    "pensioner",
    "sjuk- och aktivitetsersättning",
    "sjukpenning med mera",
    "föräldrapenning",
    "arbetsmarknadsstöd",
    "ekonomiskt bistånd",
    "barnbidrag"
  )
  
  
  # Pivotera så att varje inkomstkomponent blir en kolumn, separerat på kön
  df_wide_plot <- df_gender %>%
    st_drop_geometry() %>%
    filter(inkomstkomponent %in% top_components) %>%
    select(inkomstkomponent, kön, år, desokod, Område, Medelvärde.för.samtliga..tkr) %>%
    pivot_wider(
      names_from = inkomstkomponent,
      values_from = Medelvärde.för.samtliga..tkr
    )
  
  # Lista över x-variabler (alla utom löneinkomst)
  x_vars <- setdiff(names(df_wide_plot), c("desokod","Område","år","kön","löneinkomst "))
  
  
  
  # Pivotera data wide men behåll kön som kolumn
  df_wide_plot <- df_gender %>%
    st_drop_geometry() %>%
    filter(inkomstkomponent %in% top_components) %>%
    select(inkomstkomponent, kön, år, desokod, Område, Medelvärde.för.samtliga..tkr) %>%
    pivot_wider(
      names_from = inkomstkomponent,
      values_from = Medelvärde.för.samtliga..tkr
    )
  
  # tar ut variabler för x axeln
  x_vars <- setdiff(names(df_wide_plot), c("desokod","Område","år","kön","löneinkomst "))
  
  x_vars <- sort(x_vars)
  
  ar <- unique(df_wide_plot$år)
  
  # Skapa figurer för män och kvinnor separat
  fig_men <- plot_ly()
  fig_women <- plot_ly()
  
  for (var in x_vars) {
    # Filtera per kön och skapar hoverover info
    df_m <- df_wide_plot %>% filter(kön == "män")%>%
      mutate(hovertext = paste0("DeSO: ", desokod, "<br>",
                                "Område: ", Område, "<br>",
                                "Löneinkomst: ", `löneinkomst `, "<br>",
                                paste0(tools::toTitleCase(var), ": "), get(var)))
    
    df_w <- df_wide_plot %>% filter(kön == "kvinnor")%>%
      mutate(hovertext = paste0("DeSO: ", desokod, "<br>",
                                "Område: ", Område, "<br>",
                                "Löneinkomst: ", `löneinkomst `, "<br>",
                                paste0(tools::toTitleCase(var), ": "), get(var)))
    
    fig_men <- fig_men %>%
      add_trace(
        data = df_m,
        x = as.formula(paste0("~`", var, "`")),
        y = ~`löneinkomst ` ,
        type = 'scatter',
        mode = 'markers',
        name = 'Män',
        text = ~hovertext,
        hoverinfo = "text",
        visible = ifelse(var == x_vars[1], TRUE, FALSE),
        marker = list(color = "#4AA271")
      )
    
    fig_women <- fig_women %>%
      add_trace(
        data = df_w,
        x = as.formula(paste0("~`", var, "`")),
        y = ~`löneinkomst ` ,
        type = 'scatter',
        mode = 'markers',
        name = 'Kvinnor',
        text = ~hovertext,
        hoverinfo = "text",
        visible = ifelse(var == x_vars[1], TRUE, FALSE),
        marker = list(color = "#D57667")
      )
  }
  
  # Skapa subplots: män överst, kvinnor nederst
  fig <- subplot(fig_men, fig_women, nrows = 2, shareX = TRUE, titleY = TRUE)
  x_labels <- tools::toTitleCase(x_vars)
  
  # Dropdown för att byta x-variabel
  buttons <- lapply(seq_along(x_vars), function(i) {
    list( method = "update", 
          args = list(list(visible = rep(sapply(seq_along(x_vars), function(j) j == i), 2)), # två subplots 
                      list(title =list(text =paste("<b>Löneinkomst vs", x_vars[i],'(tkr),',ar,'<b>'), x=0.6,
                                       font = list(size = 20, color = "#B81867")),
                           xaxis2.title = paste('<b>',x_labels[i],'<b>'))),
          label = x_labels[i] ) })
  
  # Layout
  fig <- fig %>%
    layout(margin = list(t = 100,b=100), 
           title = list(text =paste("<b>Löneinkomst vs", x_labels[1],'(tkr),',ar,'<b>'),x=0.6, y=1.2,
                        font = list(size = 20, color = "#B81867")),
           updatemenus = list(
             list(
               type = "dropdown",
               x = 0,
               y = 1.06,
               buttons = buttons
             )
           ),
           xaxis = list(title = '',showticklabels = TRUE),
           xaxis2 = list(title = x_labels[1],showticklabels = TRUE), # andra subplotens x-axel
           yaxis = list(title = "<b>Löneinkomst<b>"),
           yaxis2 = list(title = "<b>Löneinkomst<b>"),
           annotations = list(list(
             text = "Källa: SCB",
             x = 0,          
             y = -0.1,      
             xref = "paper",
             yref = "paper",
             xanchor = "left",
             yanchor = "bottom",
             showarrow = FALSE,
             font = list(size = 12)
           ))
    )
  
  # Tar bort plotlyfunktioner
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



samband_inkomster2 <- function(){
  
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_desocioindex.gpkg")
      deso_sf <- st_read("Data/df_desocioindex.gpkg", quiet = TRUE)
    })})
  
  
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_inkomststruktur.gpkg")
      df_inkomststruktur <- st_read("Data/df_inkomststruktur.gpkg", quiet = TRUE)
    })
  })
  
  # Filtrerar ut totalt
  df_gender <- df_inkomststruktur %>% filter(kön != "totalt")
  
  # regsonamn
  regso <- read_excel('Data/koppling-deso2018-regso2020.xlsx',col_names = T, skip=3)
  
  regso <- regso %>%  rename(desokod = 'DeSO_2018',
                             'Område' = RegSO_2020)
  
  
  # Slår ihop data
  df_gender <- df_gender %>% left_join(regso %>% select(desokod, Område), by='desokod')
  
  # variabelnamn
  top_components <- c(
    "löneinkomst ",
    "näringsinkomst med mera",
    "inkomst av kapital",
    "pensioner",
    "sjuk- och aktivitetsersättning",
    "sjukpenning med mera",
    "föräldrapenning",
    "arbetsmarknadsstöd",
    "ekonomiskt bistånd",
    "barnbidrag"
  )
  
  
  # Pivotera så att varje inkomstkomponent blir en kolumn, separerat på kön
  df_wide_plot <- df_gender %>%
    st_drop_geometry() %>%
    filter(inkomstkomponent %in% top_components) %>%
    select(inkomstkomponent, kön, år, desokod, Område, Medelvärde.för.samtliga..tkr) %>%
    pivot_wider(
      names_from = inkomstkomponent,
      values_from = Medelvärde.för.samtliga..tkr
    )
  
  # Lista över x-variabler (alla utom löneinkomst)
  x_vars <- setdiff(names(df_wide_plot), c("desokod","Område","år","kön","löneinkomst "))
  
  
  
  # Pivotera data wide men behåll kön som kolumn
  df_wide_plot <- df_gender %>%
    st_drop_geometry() %>%
    filter(inkomstkomponent %in% top_components) %>%
    select(inkomstkomponent, kön, år, desokod, Område, Medelvärde.för.samtliga..tkr,kommunnamn ) %>%
    pivot_wider(
      names_from = inkomstkomponent,
      values_from = Medelvärde.för.samtliga..tkr
    )
  
  
  # Lägger in index
  df_wide_plot <- df_wide_plot %>%
    left_join(deso_sf %>%  select(desokod,area_type_description)%>%
                st_drop_geometry() ,
              by ='desokod')
  
  # Gör om till factorvariabel för att skapa ordning och snygg legend
  df_wide_plot$area_type_description <- factor(df_wide_plot$area_type_description, levels = c(
    "Områden med stora socioekonomiska utmaningar",
    "Områden med socioekonomiska utmaningar",
    "Socioekonomiskt blandade områden",
    "Områden med goda socioekonomiska förutsättningar",
    "Områden med mycket goda socioekonomiska förutsättningar"))
  
  df_wide_plot<- df_wide_plot %>% arrange(area_type_description)
  
  
  # tar ut variabler för x axeln
  x_vars <- setdiff(names(df_wide_plot), c("desokod","Område","år","kön","löneinkomst ","area_type_description","kommunnamn"))
  
  x_vars <- sort(x_vars)
  
  ar <- unique(df_wide_plot$år)
  
  
  # Färgschema# Farea_type_description_sdärgschema
  colormap <- c("Områden med stora socioekonomiska utmaningar"="#D57667",
                "Områden med socioekonomiska utmaningar"="#EABAB3",
                "Socioekonomiskt blandade områden"="#FFFFFF",
                "Områden med goda socioekonomiska förutsättningar"="#A4D0B8",
                "Områden med mycket goda socioekonomiska förutsättningar"="#4AA271")
  
  # Ordning för legenden
  levels <- levels(df_wide_plot$area_type_description)
  
  # Variabelr till plotskapande
  legend_ranks <- setNames(seq_along(levels), levels)
  
  categories <- levels(df_wide_plot$area_type_description)
  
  kommuners <- unique(df_wide_plot$kommunnamn)
  
  n_cat <- length(categories)
  n_vars <- length(x_vars)
  
  # skapa figurer
  fig_men <- plot_ly()
  fig_women <- plot_ly()
  
  # Räkna spår och spara index
  men_trace_count <- 0
  women_trace_count <- 0
  
  # Spara index 
  men_indices_by_var <- vector("list", n_vars)
  women_indices_by_var <- vector("list", n_vars)
  
  #MÄN (per var per kategori) 
  for (i in seq_along(x_vars)) {
    var <- x_vars[i]
    men_indices <- integer(0)
    for (cat in categories) {
      # filtrera data för denna kategori och kön
      df_m_cat <- df_wide_plot %>% filter(kön == "män", area_type_description == cat)
      # skapa hovertext (om det finns rader; annars blir trace tom)
      if (nrow(df_m_cat) > 0) {
        df_m_cat <- df_m_cat %>%
          mutate(hovertext = paste0("DeSO: ", desokod, "<br>",
                                    "Område: ", Område, "<br>",
                                    "Löneinkomst: ", `löneinkomst `, "<br>",
                                    paste0(tools::toTitleCase(var), ": "), get(var)))
      }
      men_trace_count <- men_trace_count + 1
      men_indices <- c(men_indices, men_trace_count)
      # Lägg till trace (showlegend = FALSE eftersom dummy tar legend)
      fig_men <- fig_men %>%
        add_trace(
          data = df_m_cat,
          x = as.formula(paste0("~`", var, "`")),
          y = ~`löneinkomst `,
          type = "scatter",
          mode = "markers",
          name = cat,
          legendgroup = cat,
          showlegend = T,                    # dummy visar legend
          marker = list(size = 12, opacity = 1,
                        line = list(width = 0.5, color = 'black'),
                        color = colormap[cat]),
          text = ~hovertext,
          hoverinfo = "text",
          visible = ifelse(i == 1, TRUE, FALSE)  # första variabeln synlig initialt
        )
    }
    men_indices_by_var[[i]] <- men_indices
  }
  
  #KVINNOR (per var per kategori)
  for (i in seq_along(x_vars)) {
    var <- x_vars[i]
    women_indices <- integer(0)
    for (cat in categories) {
      df_w_cat <- df_wide_plot %>% filter(kön == "kvinnor", area_type_description == cat)
      if (nrow(df_w_cat) > 0) {
        df_w_cat <- df_w_cat %>%
          mutate(hovertext = paste0("DeSO: ", desokod, "<br>",
                                    "Område: ", Område, "<br>",
                                    "Löneinkomst: ", `löneinkomst `, "<br>",
                                    paste0(tools::toTitleCase(var), ": "), get(var)))
      }
      women_trace_count <- women_trace_count + 1
      women_indices <- c(women_indices, women_trace_count)
      fig_women <- fig_women %>%
        add_trace(
          data = df_w_cat,
          x = as.formula(paste0("~`", var, "`")),
          y = ~`löneinkomst `,
          type = "scatter",
          mode = "markers",
          name = cat,
          legendgroup = cat,
          showlegend = F,                    # dummy visar legend
          marker = list(size = 12, opacity = 1,
                        line = list(width = 0.5, color = 'black'),
                        color = colormap[cat]),
          text = ~hovertext,
          hoverinfo = "text",
          visible = ifelse(i == 1, TRUE, FALSE)
          
        )
    }
    women_indices_by_var[[i]] <- women_indices
  }
  
  # Kombinera figurer i subplot
  total_m_traces <- men_trace_count
  total_w_traces <- women_trace_count
  
  # När subplot kombinerar fig_men och fig_women så ligger fig_men's traces först,
  fig <- subplot(fig_men, fig_women, nrows = 2, shareX = T, titleY = TRUE)
  
  
  # Men-indices_by_var är redan i fig_men-nummer, women måste offsettas
  
  men_indices_abs <- men_indices_by_var
  women_indices_abs <- lapply(women_indices_by_var, function(vec) vec + total_m_traces)
  
  # För varje variabel bygg en visible-vektor av längd total_traces
  total_traces <- total_m_traces + total_w_traces
  visible_list <- vector("list", n_vars)
  for (i in seq_len(n_vars)) {
    vis <- rep(FALSE, total_traces)
    # visible for the chosen var: men + women traces
    vis[men_indices_abs[[i]]] <- TRUE
    vis[women_indices_abs[[i]]] <- TRUE
    visible_list[[i]] <- vis
  }
  
  # Bygg knappar med pre-komponerade visible-vektorer
  x_labels <- tools::toTitleCase(x_vars)
  buttons <- lapply(seq_along(x_vars), function(i) {
    list(
      method = "update",
      args = list(
        list(visible = visible_list[[i]]),
        list(title = list(text = paste("<b>Löneinkomst vs", x_labels[i], "(tkr),", ar,'<b>'), x = 0.6,
                          font = list(size = 20, color = "#B81867")),
             xaxis2 = list(title = x_labels[i]) )
      ),
      label = x_labels[i]
    )
  })
  
  # Layout
  fig <- fig %>%
    layout(
      autosize = T,
      margin = list(t = 80, b = 120), 
      font = list(family = "sourcesanspro"),
      title = list(text = paste("<b>Löneinkomst vs", x_labels[1], "(tkr),", ar, "</b>"), x = 0.6,
                   font = list(size = 20, color = "#B81867")),
      updatemenus = list(
        list(type = "dropdown", x = 0, y = 1.15, buttons = buttons)
      ),
      uirevision = "fixed",
      xaxis = list(title = "", showticklabels = TRUE),
      xaxis2 = list(title = x_labels[1], showticklabels = TRUE),
      yaxis = list(title = "<b>Löneinkomst<b>"),
      yaxis2 = list(title = "<b>Löneinkomst<b>"),
      annotations = list(
        list(text = "<b>Män</b>", x = 0.5, y = 1.02, xref = "paper", yref = "paper", showarrow = FALSE, font = list(size = 16)),
        list(text = "<b>Kvinnor</b>", x = 0.5, y = 0.5, xref = "paper", yref = "paper", showarrow = FALSE, font = list(size = 16)),
        list(text = "Källa: SCB", x = 0, y = -0.08, xref = "paper", yref = "paper", xanchor = "left", showarrow = FALSE, font = list(size = 12))
      ),
      legend = list(
        orientation = "h",
        x = 0.5, y = -0.15,
        xanchor = "center", yanchor = "top",
        traceorder = "normal"
      )
    )
  
  # Ta bort onödiga verktyg
  fig <- plotly::config(fig,
                        modeBarButtonsToRemove = c('zoom2d','pan2d','select2d','lasso2d','zoomIn2d','zoomOut2d'),
                        displaylogo = FALSE)
  
  fig
  
}