




# `survey_berakning.R` – Surveyberäkningar

## Syfte

Innehåller hjälpfunktionen `make_survey_plot_df()` som används för att beräkna viktade proportionsskattningar med konfidensintervall från enkätdata. Funktionen är utformad för att leverera ett plotklart dataframe.

------------------------------------------------------------------------

## `make_survey_plot_df(df, var, weight, group1, group2, psu = NULL, strata = NULL)`

Skapar ett long-format dataframe med proportionsskattningar och logit-baserade konfidensintervall per grupp och variabelnivå, med stöd för komplex surveydesign (vikter, PSU/kluster och strata).

### Parametrar

| Parameter | Typ | Beskrivning |
|------------------------|------------------------|------------------------|
| `df` | data.frame | Enkätdataframe |
| `var` | character | Variabelnamn att analysera (binär eller flernivå-faktor) |
| `weight` | character | Namn på kalibreringsviktvariabeln |
| `group1` | character | Första gruppvariabel (används för färg/facet) |
| `group2` | character | Andra gruppvariabel (används för facet) |
| `psu` | character | PSU/klustervariabel (valfri, default `NULL` → `~1`) |
| `strata` | character | Stratavariabel (valfri, default `NULL`) |

### Returnerar

Ett long-format dataframe med kolumnerna:

| Kolumn   | Beskrivning                                 |
|----------|---------------------------------------------|
| `group1` | Värde på första grupperingsvariabeln        |
| `group2` | Värde på andra grupperingsvariabeln         |
| `level`  | Nivå av den analyserade variabeln           |
| `prop`   | Skattad andel                               |
| `ci_l`   | Nedre konfidensintervallgräns (logit-metod) |
| `ci_u`   | Övre konfidensintervallgräns (logit-metod)  |

### Metod

Funktionen loopar över varje unik nivå av `var` och anropar `svyby()` + `svyciprop()` med `method = "logit"` separat. Denna approach ger robustare konfidensintervall nära 0 och 1 jämfört med lineariseringsmetoden. Resultaten slås ihop med `bind_rows()`.

### Exempel

``` r
plot_df <- make_survey_plot_df(
  df      = enkätdata,
  var     = "Hälsofråga",
  weight  = "wk",
  group1  = "Kön",
  group2  = "Åldersgrupp",
  psu     = "psu_variabel",
  strata  = "strata_variabel"
)
```

## Ej offentlig funktionalitet

Projektet innehåller ytterligare analys- och visualiseringsfunktioner som inte ingår i den publika dokumentationen.

Dessa komponenter behandlar känsliga eller sekretessreglerade data och har därför exkluderats från det öppna repositoriet. De omfattar bland annat:

- känsliga surveyvariabler

De interna funktionerna följer samma övergripande arkitektur som övriga diagramfunktioner:
- datainläsning
- transformation
- statistisk bearbetning
- ggplot-/plotly-baserad visualisering
- export till SVG/PNG

Publik dokumentation beskriver endast de delar som kan delas öppet utan risk för röjande av känslig information.

------------------------------------------------------------------------