
# Läget i länet

Detta dokument beskriver uppbyggnad, användning och framtida utveckling av rapportserien *Läget i länet*.

För att påbörja arbetet behöver du tillgång till GitHub-kontot **RegionUppsala-analys**.
Där finns kod till samtliga rapporter, mallar och övriga resurser.

Rapporterna skapas genom rendering av `.qmd`-filer till HTML i R (Quarto).
För att säkerställa en enhetlig struktur används en gemensam mall som kan laddas ned från:\
[Mall](https://github.com/RegionUppsala-analys/Laget_i_lanet_Mall)

Vid skapande av nya rapporter kan strukturen och inledande kod enkelt kopieras från tidigare rapporter, eftersom dessa följer samma uppbyggnad.

För mer dokumentation om varje rapport så finns det funktionsbeskrivningar i mappen Functions/documents, detta är skapat med AI(Claude) för att få allt i samma struktur.
Alla funktioner tillhörande en rapport laddas ej upp här, detta beror på att de behandlar känslig information och hittas i enskilt repo för rapporten.
Data ska aldrig laddas upp.

Om nya bilder laddas ned från regionens mediabank så ska de läggas in och pushas upp till detta repo!
För tillfället måste mediabanken laddas ned innan rendering av rapporter, att ha dem lokalt kan ge fördelar vid rendering.

------------------------------------------------------------------------

## Struktur

### Script

-   **settings.R**\
    Innehåller definitioner av kommuner och län (namn och koder), ggplot-tema samt färgkoder.

-   **install_load_packages.R**\
    Installerar (vid behov) och laddar alla paket som används i rapporten.

-   **load_save_data.R**\
    Hanterar inhämtning av data.
    Större delen av dataladdningen sker här, oftast utanför funktioner.
    När skriptet körs hämtas aktuell data till rapporten.

    -   create_save_ploots.R I detta skript så ligger alla funktioner som skapar plots till rapporten, funktionerna sparar plots både som svg och png så att användaren ska få välja format vid nedladdning. Svg används för rendering. Funktionerna kan också vara interaktiva plots i plotly eller leaflet som inte sparar plots i sig utan ska läggas in och köras i qmd-filen vid rendering.

-   **create_save_plots.R**\
    Innehåller funktioner för att skapa visualiseringar.

    -   Grafer sparas både som SVG och PNG.\
    -   SVG används vid rendering.\
    -   Interaktiva grafer (t.ex. med Plotly eller Leaflet) skapas här men körs i `.qmd`-filen och sparas inte som filer.

-   **create_tables.R**\
    Skapar tabeller, med eller utan interaktivitet.
    Vissa tabeller kan även definieras direkt i `.qmd`.

-   **run_all_functions.R**\
    Kör dataladdning och samtliga plotfunktioner för att generera och spara figurer.\
    Alla funktioner som skapar och sparar grafer ska inkluderas här.\
    Detta är huvudskriptet för att uppdatera rapporter.
    Läs noggrant igenom eventuella kommentarer!

-   **övriga funktioner** Utöver dessa så kan det skilja sig mellan vilka filer som tillhör en rapport, vissa har filer som skrapar data från olika hemsidor eller gör speciella beräkningar etc. ---

### Data

Här lagras data.
Det mesta sparas automatiskt via skript, men vissa dataset kräver manuell nedladdning.\
Detta beskrivs i respektive rapports README och kommenteras ofta i `run_all_functions.R`.

------------------------------------------------------------------------

### Figurer

Alla genererade grafer sparas här.
Mallen innehåller även statiska resurser, t.ex.
regionens logotyp.

------------------------------------------------------------------------

### \_site

Den renderade webbplatsen sparas här (HTML, figurer, JSON, `site_libs`, CSS).\
För närvarande ska hela innehållet i denna mapp kopieras till det separata Git-repot för webbpublicering.

------------------------------------------------------------------------

## Tillvägagång för uppdatering av rapport

### Felsökning

Något fungerar inte?
Följ dessa steg för att systematiskt hitta och lösa felet:

**1. Hitta var felet uppstår** Läs felmeddelandet noga – det brukar ange vilket skript/funktion och vilken rad som krånglar.
Leta upp den filen och funktionen.

**2. Hitta den senaste fungerande koden** Identifiera var i koden det senast fungerade som det skulle.
Det är ett bra ställe att börja felsöka ifrån.

**3. Kör koden rad för rad** Markera och kör varje rad manuellt (t.ex. med Ctrl+Enter i RStudio), från toppen av funktionen ned mot den rad som ger fel.
På så vis ser du exakt vilket steg som misslyckas och vilket värde varje variabel har längs vägen.

**4. Vanliga orsaker** - **Paket** – en äldre eller nyare version av ett paket kan ha förändrat hur en funktion beter sig.
Kontrollera paketversioner (se avsnittet *Paket* nedan).
- **URL:er** – API:er och nedladdningslänkar kan ändras mellan år.
Sök på "Boverket" i `load_save_data` och uppdatera url:en vid behov.
- **Saknade filer** – kontrollera att alla manuellt nedladdade filer finns på rätt plats och har rätt namn.

### Steg 1

Säkerställ tillgång till organisationens GitHub-konto och konfigurera det lokalt.

Om du redan använder ett GitHub-konto på din dator behöver du bli tillagd som *collaborator* i relevanta privata repos.\
Detta kräver att du är inloggad på organisationens konto i webbläsaren.

Introduktion:\
För att komma igång med github så finns det en kort intro här: [Intro](https://github.com/RegionUppsala-analys/Github-intro).

------------------------------------------------------------------------

### Steg 2

Klona repot för den aktuella rapporten och skapa ett R-projekt kopplat till detta.

------------------------------------------------------------------------

### Steg 3

Läs igenom README-filen noggrant.
Den kan innehålla instruktioner om manuella steg (t.ex. datanedladdning).

------------------------------------------------------------------------

### Steg 4

Kör:

``` r
run run_all_funtions.R
```

Vid fel:

-   Använd sökning (Ctrl + F) för att lokalisera relevant kod.
-   Vid datafel: identifiera senaste datasteg och kör efterföljande kod manuellt.
-   Vid fel i visualisering: kör funktionen rad för rad.

Vid svåridentifierade problem kan AI användas genom att inspektera variabler stegvis (t.ex. print()), så att struktur och innehåll blir tydligt.
Var försiktig med hanering av känsliga data och AI-användning här.

### Steg 5

Rendera rapporten via terminal:

``` bash
quarto render
```

Fel kan uppstå, särskilt i interaktiva komponenter.
Felsök genom att:

-   Köra berörd funktion manuellt
-   Köra enskilda kodblock (chunks) i .qmd

### Steg 6

Granska den renderade rapporten:

-   Uppdatera text vid behov i .qmd
-   Kontrollera alt-texter (uppdateras inte automatiskt), mest årtal som ska ändras.
-   Kontrollera index.html

### Steg 7.

Kör rendering igen:

``` bash
quarto render
```

Kopiera därefter innehållet i \_site och publicera till webb-repot.

## Förbättringsarbete

-   Alla funktioner ska tas in via source() → bättre versionshantering och minskad duplicering

Detta är påbörjat för att skapa en struktur genom att ha laddat upp kod, source är ej inlaggt i rapporterna än, eftersom många funktioner för datahantering ska uppdateras till pxweb v2 i höst så får detta arbete tas vid då.

Exempel på hur man kan läsa in:

``` r
base_url <- "https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions"

files <- c(
  "general_functions/install_load_packages.R",
  "general_functions/settings.R",
  "get_data/search_kolada.R"
)

lapply(paste0(base_url, "/", files), source)
```

-   Centralisera mediabank (bilder) i GitHub → undvik lokala beroenden Mediabanken är uppladdad i detta repo, men ingen rapporter sourcar dem än!(
    Kanske ej behövs)

-   Använd explicita paketanrop, t.ex.: ggplot2::ggplot() istället för ggplot() → minskar risk för konflikter mellan paket

-   Inför kontroll i datahämtning:

    -   jämför senaste sparade år med tillgängligt data
    -   undvik onödig nedladdning

-   Automatisera uppdatering av innehåll i index.html

-   En del rapporter kan utökas med mer data tex så saknar bostadsrapporten statistik för försäljningspriser på lägenheter/hus.
