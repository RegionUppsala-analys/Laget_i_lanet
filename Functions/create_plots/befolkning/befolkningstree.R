#### Befolkningsträd ###

.save_population_pyramids <- function(df, colors, file_prefix, title) {
  df <- df %>%
    filter(år == 2025, region %in% kommuner)

  # Länet summeras från kommunernas ettårsåldrar
  county <- df %>%
    group_by(år, kön, ålder, fill_group) %>%
    summarise(Antal = sum(Antal), .groups = "drop") %>%
    mutate(region = "Länet")

  df_plot <- bind_rows(df, county) %>%
    mutate(Total_plot = ifelse(kön == "män", -Antal, Antal))

  for (r in c("Länet", sort(kommuner))) {
    temp <- df_plot %>% filter(region == r)

    # Axelgränserna måste rymma hela stapeln, inte bara en födelseregion.
    totals <- temp %>%
      group_by(kön, ålder) %>%
      summarise(Total = sum(Antal), .groups = "drop")
    max_value <- max(totals$Total)
    breaks <- pretty(c(0, max_value), n = 3)
    breaks <- sort(unique(c(-breaks, breaks)))
    axis_limit <- max(1, max_value, abs(breaks))

    p <- ggplot(temp, aes(x = Total_plot, y = as.factor(ålder), fill = fill_group)) +
      geom_col(width = 1, orientation = "y") +
      scale_fill_manual(values = colors, breaks = names(colors)) +
      scale_x_continuous(
        breaks = breaks,
        labels = format(abs(breaks), big.mark = " ", trim = TRUE),
        limits = c(-axis_limit, axis_limit)
      ) +
      scale_y_discrete(
        breaks = as.character(seq(0, 100, by = 10)),
        labels = c(as.character(seq(0, 90, by = 10)), "100+")
      ) +
      labs(
        x = "Antal", y = "Ålder", title = paste0(title, ", ", r, ", 2025"),
        fill = "", caption = "Källa: SCB"
      ) +
      theme_get() +
      theme(
        plot.title.position = "plot", legend.position = "bottom",
        plot.caption = element_text(hjust = 0)
      )

    filename <- paste0("Figurer/", file_prefix, "_", gsub(" ", "_", r))
    ggsave(paste0(filename, ".svg"), plot = p, device = "svg", width = 8, height = 6)
    ggsave(paste0(filename, ".png"), plot = p, device = "png", width = 8, height = 6, dpi = 300)
  }
}

befolkningstree <- function() {
  df <- read.csv("Data/df_folkmangd.csv") %>%
    rename(Antal = Folkmängd) %>%
    mutate(fill_group = factor(kön, levels = c("män", "kvinnor"), labels = c("Män", "Kvinnor")))

  .save_population_pyramids(
    df,
    colors = c("Män" = "#4AA271", "Kvinnor" = "#D57667"),
    file_prefix = "pyramid",
    title = "Befolkningspyramid"
  )
}

befolkningstree_fodelse <- function() {
  colors <- c(
    "Män, födda i Sverige" = "#4AA271",
    "Män, utrikesfödda" = "#8B4A9C",
    "Kvinnor, födda i Sverige" = "#D57667",
    "Kvinnor, utrikesfödda" = "#F9B000"
  )

  # Faktorordningen placerar utrikesfödda närmast noll på båda sidor.
  df <- read.csv("Data/df_folkmangd_fodd.csv") %>%
    mutate(fill_group = factor(
      paste0(
        ifelse(kön == "män", "Män", "Kvinnor"), ", ",
        case_when(
          födelseregion == "född i Sverige" ~ "födda i Sverige",
          födelseregion == "utrikes född" ~ "utrikesfödda",
          TRUE ~ NA_character_
        )
      ),
      levels = names(colors)
    ))

  .save_population_pyramids(
    df, colors,
    file_prefix = "pyramid_fodd",
    title = "Befolkningspyramid efter födelseregion"
  )
}
