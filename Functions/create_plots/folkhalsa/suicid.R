# Suicid per 100 000 invånare

suicid <- function(){

  # Kommundata
  df <- read.csv("Data/df_suicid.csv")

  # Regiondata
  df_region <- read.csv("Data/df_suicid_region.csv") %>%
    filter(Region == "Uppsala län")

  # Färgschema
  kon_col <- c(
    "Män" = "#4AA271",
    "Kvinnor" = "#D57667"
  )

  # Loopar över varje kommun
  for (r in kommuner) {

    kommun <- df %>%
      filter(Region == r)

    # Matcha gemensamma år
    gemensamma_ar <- intersect(
      unique(kommun$År),
      unique(df_region$År)
    )

    kommun <- kommun %>%
      filter(År %in% gemensamma_ar)

    uppsala <- df_region %>%
      filter(År %in% gemensamma_ar)

    etiketter <- kommun %>%
      group_by(Kön) %>%
      filter(År == max(År)) %>%
      ungroup()

    p <- ggplot() +

      # Kommun (heldragen)
      geom_line(
        data = kommun,
        aes(
          x = År,
          y = X25..åldersstandardiserad,
          colour = Kön,
          group = Kön
        ),
        linewidth = 2
      ) +

      geom_point(
        data = kommun,
        aes(
          x = År,
          y = X25..åldersstandardiserad,
          colour = Kön
        ),
        size = 3
      ) +

      geom_text_repel(
        data = etiketter,
        aes(
          x = År,
          y = X25..åldersstandardiserad,
          label = round(X25..åldersstandardiserad, 1),
          color = Kön
        ),
        direction = "y",
        nudge_x = 2,
        hjust = 0,
        segment.color = NA,
        fontface = "bold",
        show.legend = FALSE
      ) +

      # Uppsala län (streckad)
      geom_line(
        data = uppsala,
        aes(
          x = År,
          y = X25..åldersstandardiserad,
          colour = Kön,
          group = Kön
        ),
        linewidth = 1.5,
        linetype = "dashed"
      ) +

      scale_color_manual(values = kon_col) +

      scale_x_discrete(
        breaks = c(min(gemensamma_ar), max(gemensamma_ar)),
        expand = expansion(mult = c(0.02, 0.10))
      ) +

      scale_y_continuous(
        limits = c(0, max(df$X25..åldersstandardiserad) + 5)
      ) +

      labs(
        x = "",
        title = str_wrap(
          paste("Suicid per 100 000 invånare –", r),
          width = 50
        ),
        subtitle = "Streckade linjer visar Uppsala län",
        caption = "Källa: Folkhälsomyndigheten, Socialstyrelsen, Dödsorsaksregistret",
        y = "Antal per 100 000",
        color = ""
      ) +

      theme(
        plot.caption = element_text(hjust = 0),
        plot.subtitle = element_text(
          hjust = 0.5,
          colour = "#B81867",
          face = "bold"
        ),
        axis.text.x = element_text(
          angle = 45,
          hjust = 1
        )
      )

    ggsave(
      paste0("Figurer/suicid_", r, ".svg"),
      plot = p,
      width = 8,
      height = 6
    )

    ggsave(
      paste0("Figurer/suicid_", r, ".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
  }
}