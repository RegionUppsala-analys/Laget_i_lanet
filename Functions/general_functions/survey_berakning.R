#' make_survey_plot_df
#'
#' Skapar ett dataframe redo för plotting av proportionsskattningar och konfidensintervall 
#' från surveydata med vikter, PSU och strata. Funktionen hanterar både binära och 
#' flernivå-faktorer.
#'
#' @param df Data frame med din enkätdata.
#' @param var Namn på variabel som ska analyseras (karaktär/faktor). T.ex. "Hej".
#' @param weight Namn på viktvariabeln (kalibreringsvikt) i df. T.ex. "wk".
#' @param group1 Namn på första gruppvariabeln (för facetning/färg). T.ex. "A".
#' @param group2 Namn på andra gruppvariabeln (för facetning). T.ex. "B".
#' @param psu Namn på PSU/klustervariabel (valfri). Default = NULL.
#' @param strata Namn på strata-variabel (valfri). Default = NULL.
#' @param ci_method Metod för konfidensintervall: "survey" använder survey-paketets
#'   designbaserade variansberäkning, medan "fhm" följer Folkhälsomyndighetens
#'   metod med kalibreringsviktad andel och n som antal giltiga svarande.
#'
#' @return Ett long-format dataframe med kolumner:
#' \itemize{
#'   \item group1
#'   \item group2
#'   \item level (nivå av variabeln)
#'   \item prop (andel)
#'   \item ci_l (nedre konfidensintervall)
#'   \item ci_u (övre konfidensintervall)
#' }
#'
#' @examples
#' plot_df <- make_survey_plot_df(
#'   df = df2,
#'   var = "Hej",
#'   weight = "wk",
#'   group1 = "A",
#'   group2 = "B",
#'   psu = "psu",
#'   strata = "strata"
#' )
#'
#' @export
make_survey_plot_df <- function(df, var, weight, group1, group2,
                                psu = NULL, strata = NULL,
                                ci_method = c("survey", "fhm")) {
  ci_method <- match.arg(ci_method)
  
  # ---- Bibliotek som behövs ----
  if (!requireNamespace("survey", quietly = TRUE)) {
    stop("Paketet 'survey' måste vara installerat")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Paketet 'dplyr' måste vara installerat")
  }
  if (!requireNamespace("tidyr", quietly = TRUE)) {
    stop("Paketet 'tidyr' måste vara installerat")
  }
  if (!requireNamespace("stringr", quietly = TRUE)) {
    stop("Paketet 'stringr' måste vara installerat")
  }
  
  library(survey)
  library(dplyr)
  library(tidyr)
  library(stringr)
  
  levels_var <- levels(as.factor(df[[var]]))

  if (ci_method == "fhm") {
    results <- lapply(levels_var, function(lvl) {
      df %>%
        mutate(
          .fhm_indicator = as.character(.data[[var]]) == as.character(lvl),
          .fhm_valid = !is.na(.data[[var]]) & !is.na(.data[[weight]])
        ) %>%
        group_by(.data[[group1]], .data[[group2]]) %>%
        summarise(
          prop = sum(.data[[weight]][.fhm_valid] * .fhm_indicator[.fhm_valid]) /
            sum(.data[[weight]][.fhm_valid]),
          n = sum(.fhm_valid),
          .groups = "drop"
        ) %>%
        mutate(
          ci_l = pmax(0, prop - 1.96 * sqrt(prop * (1 - prop) / n)),
          ci_u = pmin(1, prop + 1.96 * sqrt(prop * (1 - prop) / n)),
          level = lvl
        )
    })
  } else {
    ids_formula <- if (!is.null(psu)) as.formula(paste0("~", psu)) else ~1
    strata_formula <- if (!is.null(strata)) as.formula(paste0("~", strata)) else NULL
    weights_formula <- as.formula(paste("~", weight))
    group_formula <- as.formula(paste0("~", group1, " + ", group2))

    design <- svydesign(
      ids = ids_formula,
      strata = strata_formula,
      weights = weights_formula,
      data = df,
      nest = TRUE
    )

    results <- lapply(levels_var, function(lvl) {
      form <- as.formula(paste0("~I(", var, " == '", lvl, "')"))

      est <- svyby(
        form,
        group_formula,
        design,
        svyciprop,
        vartype = "ci",
        method = "logit"
      )

      prop_col <- grep("^I\\(", names(est), value = TRUE)
      ci_l_col <- grep("^ci_l", names(est), value = TRUE)
      ci_u_col <- grep("^ci_u", names(est), value = TRUE)

      est %>%
        rename(prop = all_of(prop_col),
               ci_l = all_of(ci_l_col),
               ci_u = all_of(ci_u_col)) %>%
        mutate(level = lvl)
    })
  }
  
  # slår ihop listan till df
  plot_df <- dplyr::bind_rows(results) %>%
    select(all_of(c(group1, group2)), level, prop, ci_l, ci_u)
  
  return(plot_df)
}