####### Socioindex med PCA #######
##################################

# Se till att working dir är i rätt mapp då filer kommer att sparas.

# Globala variabler för att fungera för flera regioner

lan <- "Uppsala län"
lanskod <- "03"

# Dessa behövs ej #
kommunkod <- c("330", "331", "360", "380", "381", "382", "305", "319")
kommuner <- c("Knivsta", "Heby", "Tierp", "Uppsala", "Enköping", "Östhammar", "Håbo", "Älvkarleby")
#                #

############ Läser in paket ###########
install_and_load <- function() {
  # CRAN-paket
  cran_packages <- c(
    "pxweb",
    "dplyr",
    "ggplot2",
    "tidyr",
    "httr",
    "sf",
    "patchwork",
    "leaflet",
    "leaftime",
    "readxl",
    "stringr",
    "plotly",
    "gt"
  )
  
  # Installera och ladda CRAN-paket
  for (pkg in cran_packages) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }
  
}

#install_and_load()

# Lokala filer för snyggare grafer
{
  source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/general_functions/install_load_packages.R")
  source("https://raw.githubusercontent.com/RegionUppsala-analys/Laget_i_lanet/main/Functions/general_functions/settings.R")
  install_and_load()
  settings <- get_settings()
  
  kommunkod <- settings$kommunkod
  kommuner <- settings$kommuner
  kommun_colors <- settings$kommun_colors
  lanskod <- settings$lanskod
  lan <- settings$lan
  
}


########### Laddar hem data ############

download_data_deso <- function(){
  ##### Deso
  # 2025
  
  url <- "https://geodata.scb.se/geoserver/stat/wfs?service=WFS&REQUEST=GetFeature&version=1.1.0&TYPENAMES=stat:DeSO_2025&outputFormat=geopackage"
  output_file <- "Data/DeSO_2025.gpkg"
  
  # Kollar om den redan finns
  if (file.exists(output_file)) {
    
  } else {
    
    response <- GET(url, write_disk(output_file, overwrite = TRUE))
    
  }
  
  # 2018
  
  url <- "https://geodata.scb.se/geoserver/stat/wfs?service=WFS&REQUEST=GetFeature&version=1.1.0&TYPENAMES=stat:DeSO_2018&outputFormat=geopackage"
  output_file <- "Data/DeSO_2018.gpkg"
  
  # Kollar om den redan finns
  if (file.exists(output_file)) {
    
  } else {
    
    response <- GET(url, write_disk(output_file, overwrite = TRUE))
    
  }
  
  # Kopplingar 
  # 2025
  url <- 'https://www.scb.se/contentassets/e3b2f06da62046ba93ff58af1b845c7e/koppling-deso2025-regso2025.xlsx'
  output_file <- "Data/koppling-deso2025-regso2025.xlsx"
  
  # Kollar om den redan finns
  if (file.exists(output_file)) {
    
  } else {
    
    response <- GET(url, write_disk(output_file, overwrite = TRUE))
    
  }
  # 2018
  url <- 'https://www.scb.se/contentassets/e3b2f06da62046ba93ff58af1b845c7e/koppling-deso2018-regso2020.xlsx'
  output_file <- "Data/koppling-deso2018-regso2020.xlsx"
  
  # Kollar om den redan finns
  if (file.exists(output_file)) {
    
  } else {
    
    response <- GET(url, write_disk(output_file, overwrite = TRUE))
    
  }
  
  
  
  # Tätorter
  # https://www.scb.se/vara-tjanster/oppna-data/oppna-geodata/statistiska-tatorter/
  url <- 'https://geodata.scb.se/geoserver/stat/wfs?service=WFS&REQUEST=GetFeature&version=1.1.0&TYPENAMES=stat:Tatorter_2018&outputFormat=geopackage'
  output_file <- "Data/Tatorter_2018.gpkg"
  
  # Kollar om den redan finns
  if (file.exists(output_file)) {
    
  } else {
    
    response <- GET(url, write_disk(output_file, overwrite = TRUE))
    
  }
  
}

#download_data_deso()


##### Här finns flera rader som ska kommenteras bort och ändras så rätt data finns!
skapa_index_laddaned_data_tid <- function(){
  {
    
    # Den här behöver uppdateras när data släpps!!
    # Arbetsmarknadsstatus efter bostadens belägenhet, region (DeSO 2018 t.o.m. år 2023/RegSO 2020 t.o.m. år 2023), kön och ålder. Årligt register. År 2020 - 2023
    # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__AM__AM0210__AM0210G/ArRegDesoStatus/
    url <- pxweb_url("TAB6680")
    
    # pxweb v2
    #  url <- print_pxwebv2('TAB6680')
    
    meta  <- pxweb_get(url)
    # Visa tillgängliga regionkoder
    regioner <- meta$variables[[1]]$values
    
    # Välj endast regioner som börjar med "03"
    uppsala_koder <- regioner[startsWith(regioner, lanskod)]
    
    
    senaste_aret <- max(as.integer(meta$variables[[5]]$values))
    
    # Låg respektive hög ekonomisk standard efter region och ålder. År 2011 - 2024
    # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__HE__HE0110__HE0110I/Tab4InkDesoRegso/
    url2 <- pxweb_url("TAB6685")
    
    
    # pxweb v2
    #  url2 <- print_pxwebv2('TAB6685')
    
    meta2  <- pxweb_get(url2)
    
    senaste_aret2 <- max(as.integer(meta2$variables[[4]]$values))
    
    # Befolkning 25-64 år efter region, utbildningsnivå och år
    # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__UF__UF0506__UF0506D/UtbSUNBefDesoRegsoN/
    url3 <- pxweb_url("TAB6534")
    
    # pxweb v2
    #  url3 <- print_pxwebv2('TAB6534')
    
    meta3  <- pxweb_get(url3)
    
    senaste_aret3 <- max(as.integer(meta3$variables[[4]]$values))
    
    senaste_aret <- min(senaste_aret,senaste_aret2,senaste_aret3) # kollar senaste matchande året mellan tabellerna
    
    if (senaste_aret > 2023){
      suppressMessages({
        suppressWarnings({
          st_layers("Data/DeSO_2025.gpkg")
          deso_sf <- st_read("Data/DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE)  # we keep only Uppsala län
        })
      })
    }else{
      suppressMessages({
        suppressWarnings({
          st_layers("Data/DeSO_2018.gpkg")
          deso_sf <- st_read("Data/DeSO_2018.gpkg", layer = "DeSO_2018", quiet = TRUE) # we keep only Uppsala län
        })
      })
    }  
    
    # Tar ut desokoder 
    regioner <- paste0(deso_sf$desokod,'_DeSO2025')
    
    
    px_get_list <- list(Region =regioner,
                        Alder = '20-65',
                        Kon = '1+2',
                        ContentsCode = c("0000089W","0000089Y"),
                        Tid ='*')
    
    px_get <- pxweb_get(url,px_get_list)
    
    # laddar data och gör till rätt format
    df_arbetsloshet <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    df_arbetsloshet <- df_arbetsloshet |>
      tidyr::pivot_wider(
        names_from = "tabellinnehåll",
        values_from = "value"
      )
    
    # min för Årsintervall
    min_arb <- min(df_arbetsloshet$år)
    
    df_arbetsloshet <- df_arbetsloshet %>% rename(desokod=region)
    
    
    px_get_list <- list(Region = regioner,
                        Alder = 'tot',
                        ContentsCode =  '000008AC',
                        Tid = '*')
    
    px_get <- pxweb_get(url2,px_get_list)
    
    # laddar data och gör till rätt format
    df_lag_standard <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    df_lag_standard <- df_lag_standard |>
      tidyr::pivot_wider(
        names_from = "tabellinnehåll",
        values_from = "value"
      )
    # sparar data med variabler:
    
    # min för Årsintervall
    min_standard <- min(df_lag_standard$år)
    # Finns dubbletter med NA 
    
    df_lag_standard <- df_lag_standard %>% rename(desokod=region) %>%
      filter(!is.na(`Låg ekonomisk standard, procent`))
    
    ## Utbildningsnivåer
    # Visa tillgängliga regionkoder
    
    # Välj endast regioner som börjar med "03"
    uppsala_koder <- regioner[startsWith(regioner, lanskod)]
    
    px_get_list <- list(Region = regioner,
                        UtbildningsNiva = '*',
                        ContentsCode = '*',
                        Tid = '*')
    
    px_get <- pxweb_get(url3,px_get_list)
    
    # laddar data och gör till rätt format
    df_utbildning <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    df_utbildning <- df_utbildning |>
      tidyr::pivot_wider(
        names_from = "tabellinnehåll",
        values_from = "value"
      )
    
    # Finns dubbletter med NA 
    
    df_utbildning <- df_utbildning %>% rename(desokod=region)
    
    # min för Årsintervall
    min_utb <- min(df_utbildning$år)
    
    
    # min i intervallet
    min_intervall <- max(c(min_arb,min_standard,min_utb))
    
    intervall <- min_intervall:senaste_aret
    
    # Tar ut data för åren
    df_deso_arbetslos <- df_arbetsloshet %>% filter(år %in% intervall)
    
    df_deso_lag_standard <- df_lag_standard %>% filter(år %in% intervall) %>% 
      select(desokod, år, `Låg ekonomisk standard, procent`)
    
    df_deso_utbildning <- df_utbildning %>% filter(år %in% intervall)
    #  Räkna andelar per DeSO 
    
    andelar_deso_utb <- df_deso_utbildning %>%
      group_by(desokod,år) %>%
      mutate(
        Total = sum(Befolkning, na.rm = TRUE),
        Andel_forgymnasial = round(100 * Befolkning / Total, 1)
      ) %>%
      ungroup()
    
    andelar_deso_utb_for <- andelar_deso_utb %>% filter(utbildningsnivå == 'förgymnasial utbildning') %>% 
      select(desokod,år,Andel_forgymnasial)
    
    
    deso_sf_arbets <- df_deso_arbetslos %>% filter(kön == 'totalt') %>% 
      mutate(Andel_arbetslösa = ( `antal arbetslösa` / `antal totalt` )*100) %>% 
      select(desokod, år, Andel_arbetslösa)
    
    # Bostadsbyggnader efter region och byggnadstyp År 2010 - 2024
    # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__MI__MI0803__MI0803B/Bostadsbyggnad3/
    url <- pxweb_url("TAB6620")
    
    # pxweb v2
    #  url <- print_pxwebv2('TAB6620')
    
    # Hämta metadata för Region
    meta <- pxweb_get(url)
    
    
    px_get_list <- list(Region = regioner,
                        Byggnadstyp = "005",
                        ContentsCode = "0000082X",
                        Tid = as.character(intervall)) # tar senaste året från förra datan
    
    px_get <- pxweb_get(url,px_get_list)
    
    # laddar data och gör till rätt format
    df_flerbostadshus <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    df_flerbostadshus <- df_flerbostadshus |>
      tidyr::pivot_wider(
        names_from = "tabellinnehåll",
        values_from = "value"
      )
    # Finns dubbletter med NA 
    df_flerbostadshus <- df_flerbostadshus %>% rename(desokod=region) %>% 
      select(desokod,år, `Andel i procent`)
    
    
    print('Nedladdning av "df_flerbostadshus" genomfördes')  
    
    
  }
  
  # Antal hushåll per region efter hushållstyp. År 2011 - 2024
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101Y/HushallDesoTyp/
  url <- pxweb_url("TAB6568")
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6568')
  
  # Hämta metadata för Region
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = regioner,
                      Hushallstyp = c('ESMB','TOTALT'),
                      ContentsCode = '*',
                      Tid = as.character(intervall)) # tar senaste året från förra datan
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_hushall<- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_hushall <- df_hushall |>
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )
  
  # Finns dubbletter med NA 
  df_hushall <- df_hushall %>% rename(desokod=region)
  
  df_hushall <- df_hushall %>% 
    group_by(desokod, år, hushållstyp) %>% 
    # behåll raden om värdet inte är NA
    filter(!(is.na(`Antal hushåll`) & n() > 1))  %>% 
    ungroup()
  
  # Gör wide och ta sen andel
  df_hushall <- df_hushall %>% pivot_wider(names_from = hushållstyp, values_from = `Antal hushåll`)
  
  df_hushall <- df_hushall %>% group_by(desokod, år) %>% 
    mutate(Andel_ensamstaende =  (`ensamstående med barn` / `totalt antal hushåll`)*100) %>% 
    select(desokod, år, Andel_ensamstaende)
  
  
  df_hushall$Andel_ensamstaende <- ifelse(is.na(df_hushall$Andel_ensamstaende), 0, df_hushall$Andel_ensamstaende)
  
  print('Nedladdning av "df_hushall" genomfördes')  
  
  # Bistånd - Inkomststruktur nettoinkomst efter region och kön. År 2011 - 2024
  # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__HE__HE0110__HE0110I/Tab2InkDesoRegso/
  url <- pxweb_url("TAB6683")
  
  # pxweb v2
  #  url <- print_pxwebv2('TAB6683')
  
  # Hämta metadata för Region
  meta <- pxweb_get(url)
  
  
  px_get_list <- list(Region = regioner,
                      Inkomstkomponenter = "170",
                      Kon = '1+2',
                      ContentsCode = '*',
                      Tid = as.character(intervall)) # tar senaste året från förra datan
  
  px_get <- pxweb_get(url,px_get_list)
  
  # laddar data och gör till rätt format
  df_bistand<- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
  df_bistand <- df_bistand |>
    tidyr::pivot_wider(
      names_from = "tabellinnehåll",
      values_from = "value"
    )
  
  # Finns dubbletter med NA 
  df_bistand <- df_bistand %>% rename(desokod=region) %>% filter(!is.na(`Andel med inkomstslag, procent`)) %>% 
    select(desokod,år, `Andel med inkomstslag, procent` )
  
  
  
  
  
  # kombinerar all data och tar endast ut deso
  
  deso_sf <- deso_sf %>% st_drop_geometry()
  
  deso_sf <- deso_sf %>%
    crossing(år = as.character(intervall))
  
  
  # Slår ihop datan använder deso för att inte ta ut andra områden
  
  deso_sf <- deso_sf %>% 
    left_join(deso_sf_arbets, by = c("desokod","år")) %>% 
    left_join(df_bistand, by = c("desokod","år")) %>% 
    left_join( df_hushall, by = c("desokod","år")) %>% 
    left_join(andelar_deso_utb_for, by = c("desokod","år")) %>% 
    left_join(df_deso_lag_standard, by = c("desokod","år")) %>% 
    left_join(df_flerbostadshus , by = c("desokod","år")) 
  
  
  # Gör till 0 om det är NA
  deso_sf$`Andel med inkomstslag, procent` <- ifelse(is.na(deso_sf$`Andel med inkomstslag, procent`),
                                                     0, deso_sf$`Andel med inkomstslag, procent`)
  
  write.csv(deso_sf, "Data/df_data_till_index_pca.csv", row.names = F)
  
  # Deso födelseort
  
  {
    # https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101Y/FolkmDesoLandKon/
    url <- pxweb_url("TAB6572")
    
    # pxweb v2
    #  url <- print_pxwebv2('TAB6572')
    # Hämta metadata för Region
    meta <- pxweb_get(url)
    # Visa tillgängliga regionkoder
    
    
    # Välj endast regioner som börjar med "03" då detta ej ska vara med i indexet
    uppsala_koder <- regioner[startsWith(regioner, lanskod)] 
    
    
    px_get_list <- list(Region = uppsala_koder,
                        Kon = "1+2",
                        Fodelseregion = '*',
                        ContentsCode = '*',
                        Tid = as.character(intervall)) # tar senaste året från förra datan
    
    px_get <- pxweb_get(url,px_get_list)
    
    # laddar data och gör till rätt format
    df_deso_fodelse <- as.data.frame(px_get, column.name.type = "text", variable.value.type = "text")
    df_deso_fodelse <- df_deso_fodelse |>
      tidyr::pivot_wider(
        names_from = "tabellinnehåll",
        values_from = "value"
      )
    # Finns dubbletter med NA 
    df_deso_fodelse <- df_deso_fodelse %>% rename(desokod=region) 
    df_deso_fodelse <- na.omit(df_deso_fodelse)
    
    df_deso_fodelse <- df_deso_fodelse %>% filter(födelseregion !='totalt') %>%  mutate(
      Födelsereg = ifelse(födelseregion =='Sverige','Sverige','Utrikes')) %>% group_by(desokod,Födelsereg, år) %>% 
      summarise(
        Antal = sum(Antal), .groups = 'drop'
      ) %>% group_by(desokod, år) %>%  mutate(Totalt = sum(Antal)) %>% ungroup()
    
    # Andelar
    df_deso_fodelse <- df_deso_fodelse %>% group_by(desokod,år) %>% 
      mutate(Andel_utrikes = (Antal /sum(Antal)) *100) %>% ungroup() %>% filter(Födelsereg == 'Utrikes') %>% 
      select(desokod ,år,Andel_utrikes )
    
    # Sparar data
    st_write(df_deso_fodelse, "Data/df_deso_fodelse_index_tid.gpkg",  delete_dsn = TRUE)
    
    print('Nedladdning av "df_deso_fodelse_index_tid.gpkg" genomfördes')  
    
    
    
    
  }
  
}




########### Skapar principalkoponenter ###########


pca_func <- function(){
  # Läser in data och tar ut år
  df <- read.csv("Data/df_data_till_index_pca.csv")
  
  years <- sort(unique(df$år))
  
  # Lista för att lagra PC1-loadings
  loading_list <- list()
  
  for (y in years) {
    
    df_pca <- df %>% 
      dplyr::filter(år == y) %>%
      dplyr::select(
        Andel.med.inkomstslag..procent, # bistånd
        Andel_ensamstaende,
        Andel.i.procent,       
        Andel_arbetslösa,       
        Andel_forgymnasial,
        Låg.ekonomisk.standard..procent
      ) %>%
      dplyr::mutate(across(everything(), as.numeric))
    
    # tar bort NA
    df_pca <- na.omit(df_pca)
    
    # PCA med scale trots andelar, då spridningen kan skilja sig
    pc <- prcomp(df_pca, scale. = TRUE, center = TRUE)
    
    # Hämta loadings för PC1 som en vektor
    pc1_loading <- pc$rotation[,1]
    
    loading_list[[as.character(y)]] <- pc1_loading # lägger det i listan
  }
  
  # Bind samman till en matris
  loading_matrix <- do.call(cbind, loading_list)
  
  # Printar matrisen så man ser att det nästan är samma för varje år
  # print('Principalkomponent 1 per år')
  #  print(loading_matrix)
  
  # Medelvärdesvektor över år
  mean_vector <- rowMeans(abs(loading_matrix))
  
  # print('Medelvärdesvektor över åren')
  #  print(mean_vector)
  
  return(mean_vector)
}


# mean_vec <- pca_func()

########### Skapa och spara index ###########

create_index <- function(){
  # Läser in data och skapar komponenter
  df <- read.csv("Data/df_data_till_index_pca.csv")
  mean_vector <- pca_func()
  
  # tar bort na
  
  df <- na.omit(df)
  
  # Åren
  years <- sort(unique(df$år))
  
  vars <- c(
    "Andel.med.inkomstslag..procent",
    "Andel_ensamstaende",
    "Andel.i.procent",          
    "Andel_arbetslösa",        
    "Andel_forgymnasial",       
    "Låg.ekonomisk.standard..procent"
  )
  
  X <- df %>%
    dplyr::select(all_of(vars)) %>%
    dplyr::mutate(across(everything(), as.numeric))
  
  X <- X[, names(mean_vector)]
  
  # matrismultiplikation för att skapa indexet
  df$index <- as.vector(as.matrix(X) %*% mean_vector)
  
  # Skapar klasser
  mean_index <- mean(df$index, na.rm = TRUE)
  sd_index <- sd(df$index, na.rm = TRUE)
  
  # klasserna
  df <- df %>%
    mutate(
      index_class = case_when(
        index < mean_index - 1* sd_index       ~ 6,   # mycket bättre än medel
        index >= mean_index - 1*sd_index & index < mean_index - 0.5*sd_index ~ 5,
        index >= mean_index - 0.5*sd_index & index < mean_index  + 0.5*sd_index         ~ 4,
        index >= mean_index  + 0.5*sd_index & index < mean_index + 1.5*sd_index           ~ 3,
        index >= mean_index + 1.5*sd_index & index < mean_index + 2.5*sd_index ~ 2,
        index >= mean_index + 2.5*sd_index       ~ 1   # sämst
      )
    )
  
  
  write.csv(df, "Data/df_data_index_pca.csv", row.names = F)
  
}


# Indelning för indexet för 24-* index
breaks <- function(){
  # Läser in data
  df <-  read.csv("Data/df_data_index_pca.csv") 
  
  # Statistik
  mean_index <- mean(df$index, na.rm = TRUE)
  sd_index <- sd(df$index, na.rm = TRUE)
  
  # Klassgränser enligt dina case_when
  breaks <- c(
    mean_index - 1*sd_index,     # mellan klass 6 och 5
    mean_index - 0.5*sd_index,   # mellan klass 5 och 4
    mean_index + 0.5*sd_index,   # mellan klass 4 och 3
    mean_index + 1.5*sd_index,   # mellan klass 3 och 2
    mean_index + 2.5*sd_index    # mellan klass 2 och 1
  )
  
  # retunerar
  breaks
  
}


# Medel och sd 

index_stats <- function(){
  # Läser in data
  df <-  read.csv("Data/df_data_index_pca.csv") # sparat detta en gång genom att byta namn på den som sparas av pca_func()
  
  # tar ut statistik
  mean_index <- mean(df$index, na.rm = TRUE)
  sd_index <- sd(df$index, na.rm = TRUE)
  
  
  # retunerar som en vektor
  return(c(mean_index,sd_index))
  
}

########### Plotta index  ###########


# fördelning
index_density <- function(){
  # läser in data, tar ut medelvärdet och skapar klasser
  df <-  read.csv("Data/df_data_index_pca.csv") 
  
  mean_index <- mean(df$index, na.rm = TRUE)
  sd_index <- sd(df$index, na.rm = TRUE)
  maxx <- max(df$index, na.rm = TRUE)
  
  # Klassgränser enligt dina case_when
  breaks <- c(
    mean_index - 1*sd_index,     # mellan klass 6 och 5
    mean_index - 0.5*sd_index,   # mellan klass 5 och 4
    mean_index + 0.5*sd_index,   # mellan klass 4 och 3
    mean_index + 1.5*sd_index,   # mellan klass 3 och 2
    mean_index + 2.5*sd_index    # mellan klass 2 och 1
  )
  
  # Density plot
  riket <- ggplot(df, aes(x = index)) +
    geom_histogram(fill = "#B81867") +
    geom_vline(xintercept = breaks, linetype = "dashed", color = "black", linewidth = 1) +
    xlim(0,maxx)+
    labs(
      title = str_wrap(paste("Fördelning av index med klassgränser för riket"),width=50),
      x = "Index",
      y = "Frekvens"
    ) 
  
  laskoden <- str_split(lanskod,"")[[1]][2]
  
  
  df <- df %>% 
    filter(lanskod== laskoden)
  
  lanet <- ggplot(df, aes(x = index)) +
    geom_histogram(fill = "#B81867") +
    geom_vline(xintercept = breaks, linetype = "dashed", color = "black", size = 1) +
    xlim(0,maxx)+
    labs(
      title = str_wrap(paste("Fördelning av index med klassgränser för Uppsala län"),width=50),
      x = "Index",
      y = "Frekvens",
      caption = 'Källa: SCB, bearbetat av Region Uppsala'
    ) + theme( plot.caption = element_text(hjust = 0))
  
  
  p <- riket / lanet
  
  ggsave("Figurer/density_PCA_Simpelt_index.svg",
         plot = p,
         width = 7,        # bredd i tum
         height = 8,        # höjd i tum
         dpi = 300,         # upplösning (för SVG används dpi mest för text/annotations)
         device = "svg") 
  
  ggsave("Figurer/density_PCA_Simpelt_index.png",
         plot = p,
         width = 10,        # bredd i tum
         height = 8,        # höjd i tum
         device = "png",
         dpi =96) 
}



# karta
socioindex_karta_tid <- function(){
  # läser in datasets
  df <- read.csv('Data/df_data_index_pca.csv')
  
  senaste_aret <- unique(df$år)
  
  if (senaste_aret > 2023){
    suppressMessages({
      suppressWarnings({
        st_layers("Data/DeSO_2025.gpkg")
        deso_joined <- st_read("Data/DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE)  # we keep only Uppsala län
      })
    })
  }else{
    suppressMessages({
      suppressWarnings({
        st_layers("Data/DeSO_2018.gpkg")
        deso_joined <- st_read("Data/DeSO_2018.gpkg", layer = "DeSO_2018", quiet = TRUE) # we keep only Uppsala län
      })
    })
  }
  
  komnamn <- data.frame(kommunnamn=c("Knivsta", "Heby", "Tierp", "Uppsala", "Enköping", "Östhammar", "Håbo", "Älvkarleby"),
                        kommunkod=c("0330", "0331", "0360", "0380", "0381", "0382", "0305", "0319"))
  
  deso_joined <- deso_joined %>% left_join(komnamn, by="kommunkod" )
  
  laskoden <- str_split(lanskod,"")[[1]][2]
  
  df <- df %>% left_join(deso_joined %>% select(desokod,sp_geometry, kommunnamn), by="desokod")%>%
    st_as_sf() %>% filter(lanskod == !!laskoden)
  
  
  # popup och label
  df_sf <- df %>%
    mutate(
      popup = paste0("<b>", kommunnamn, "</b><br>",
                     "Deso: ",desokod,"<br>",
                     "År: ", år, "<br>",
                     "Index: ", index,'<br>',
                     'Andel med endast förgymnasial utbildning: ', Andel_forgymnasial , "%", "<br>",
                     
                     'Andel arbetslösa: ' , round(Andel_arbetslösa ,1), "%", "<br>",
                     'Andel med låg ekonomisk standard: ', round(Låg.ekonomisk.standard..procent,1), "%","<br>",
                     'Andel boende i flerbostadshus: ', Andel.i.procent , "%", "<br>",     
                     'Andel ensamstående: ' , round(Andel_ensamstaende ,1), "%", "<br>",
                     'Andel som går på biståndsbigrag: ' , round(Andel.med.inkomstslag..procent ,1), "%", "<br>"),
      label = paste0(kommunnamn,': ',desokod, " (", år, ")")
    )
  
  # Anta df_sf redan innehåller geometri, index_class, popup och label
  min_y <- min(df_sf$år, na.rm = TRUE)
  max_y <- max(df_sf$år, na.rm = TRUE)
  first_year <- df_sf %>% filter(år ==min_y)
  last_year  <- df_sf %>% filter(år==max_y)
  
  
  # Gemensam palett och legend
  custom_colors <- c("#D57667", "#EABAB3",'#F9B000',"#FFFFFF", "#A4D0B8", "#4AA271")
  pal <- colorFactor(palette = custom_colors, domain = df_sf$index_class)
  
  # Skapa mapview-objekt
  m1 <- mapview(first_year, zcol = "index_class", 
                map.types = NULL,
                col.regions = custom_colors, 
                legend = TRUE,
                popup = first_year$popup,
                layer.name = paste('Index'), 
                label=first_year$label)
  
  m2 <- mapview(last_year, zcol = "index_class", 
                map.types = NULL,
                col.regions = custom_colors, 
                legend = F ,
                popup = last_year$popup,
                label=last_year$label)  
  
  # Slå ihop kartorna
  map <- m1 | m2
  map <- map %>% leaflet::addTiles(
    urlTemplate = "https://basemaps.cartocdn.com/rastertiles/positron/{z}/{x}/{y}.png?key=cb1_2u50_1_d6a866f2a70b7f9289d8f6d6"
  )
  
  
  # Variabel för att skapa text på kartan
  js_code <- sprintf("
function(el, x) {
  setTimeout(function() {

    var leftLabel = document.createElement('div');
    leftLabel.style.position = 'absolute';
    leftLabel.style.left = '10px';
    leftLabel.style.top = '50%%';
    leftLabel.style.transform = 'translateY(-50%%)';
    leftLabel.style.background = 'rgba(255,255,255,0.8)';
    leftLabel.style.padding = '4px 8px';
    leftLabel.style.borderRadius = '6px';
    leftLabel.style.fontSize = '16px';
    leftLabel.style.zIndex = '1000';
    leftLabel.innerHTML = '%s';

    var rightLabel = document.createElement('div');
    rightLabel.style.position = 'absolute';
    rightLabel.style.right = '10px';
    rightLabel.style.top = '50%%';
    rightLabel.style.transform = 'translateY(-50%%)';
    rightLabel.style.background = 'rgba(255,255,255,0.8)';
    rightLabel.style.padding = '4px 8px';
    rightLabel.style.borderRadius = '6px';
    rightLabel.style.fontSize = '16px';
    rightLabel.style.zIndex = '1000';
    rightLabel.innerHTML = '%s';

    el.appendChild(leftLabel);
    el.appendChild(rightLabel);
  }, 500);
}
", min_y, max_y)
  
  
  # HTML för att få in åren på rätt sida slidern
  map@map <- map@map %>% htmlwidgets::onRender(js_code)
  
  map
}



# scatterplot
scatter_socioindex_tid <- function() {
  
  # läser in datasets
  df <- read.csv('Data/df_data_index_pca.csv')
  # Läser in data
  suppressMessages({
    suppressWarnings({
      
      st_layers("Data/df_deso_fodelse_index_tid.gpkg")
      deso_sf2 <- st_read("Data/df_deso_fodelse_index_tid.gpkg", quiet = TRUE)
    })
  })
  
  
  komnamn <- data.frame(kommunnamn=c("Knivsta", "Heby", "Tierp", "Uppsala", "Enköping", "Östhammar", "Håbo", "Älvkarleby"),
                        kommunkod=c("0330", "0331", "0360", "0380", "0381", "0382", "0305", "0319"))
  
  deso_sf2 <- deso_sf2 %>% left_join(komnamn, by="kommunkod" )
  
  laskoden <- str_split(lanskod,"")[[1]][2]
  
  df <- df %>% filter(lanskod == laskoden) 
  
  
  koppling <- read_excel("Data/koppling-deso2025-regso2025.xlsx", skip=2) %>% select(Kommunnamn, DeSO_2025,RegSO_2025 ) %>% 
    rename(desokod=DeSO_2025)
  
  deso_sf2 <- deso_sf2  %>% mutate(år = as.integer(år))
  
  # Slår ihop datan
  deso_sf <- left_join(df,deso_sf2, by=c('desokod','år')) %>% 
    left_join(koppling, by='desokod')
  
  deso_sf$index_class <- factor(deso_sf$index_class, levels = 1:6)
  
  # Färgschema# Farea_type_description_sdärgschema
  colormap <- c("#D57667", "#EABAB3",'#F9B000',"#FFFFFF", "#A4D0B8", "#4AA271")
  
  # Beräknar korrelationen
  corr_val <- cor(deso_sf$index , deso_sf$Andel_utrikes , use = "complete.obs")
  corr_text <- paste0("Korrelation = ", round(corr_val, 2))
  
  # Tickvals för procent på y axeln: 
  tick_vals <- seq(0, 100, by = 10)
  tick_texts <- paste0(tick_vals, "%")
  
  # Hoverover
  deso_sf <- deso_sf %>% group_by(desokod) %>% 
    mutate(hoveroverinfo = paste0('<b>Regso: </b>',RegSO_2025,'<br>',
                                  '<b>DeSO: </b>',desokod,'<br>',
                                  '<b>År: </b>',år,'<br>',
                                  "<b>Index: </b>", round(index,2),'<br>',
                                  '<b>Andel med endast förgymnasial utbildning: </b>', Andel_forgymnasial , " %", "<br>",
                                  '<b>Andel arbetslösa: </b>' , round(Andel_arbetslösa ,1), " %", "<br>",
                                  '<b>Andel med låg ekonomisk standard: </b>', round(Låg.ekonomisk.standard..procent,1), " %","<br>",
                                  '<b>Andel boende i flerbostadshus: </b>', Andel.i.procent , " %", "<br>",
                                  '<b>Andel ensamstående: </b>' , round(Andel_ensamstaende ,1), " %", "<br>",
                                  '<b>Andel som går på biståndsbigrag: </b>' , round(Andel.med.inkomstslag..procent ,1), " %", "<br>"
                                  
    ))
  
  
  # Variabel för att följa vilka som byter klass över tid: 
  deso_sf <- deso_sf %>%
    group_by(desokod) %>%
    mutate(byter_klass = n_distinct(index_class, na.rm = TRUE) > 1) %>%
    ungroup()
  
  # Fixar ordningen
  deso_sf <- deso_sf %>% arrange(by=desokod)
  
  # Skapar plot
  fig <- plot_ly(
    data = deso_sf,
    x = ~index,
    y = ~Andel_utrikes ,
    type = 'scatter',
    mode = 'markers',
    color = ~index_class,
    colors =  colormap,
    showlegend=T,
    marker = list(
      size = 12, 
      opacity = 1,
      line = list(width = 1, color = "black")
    ),
    text = ~hoveroverinfo,
    hoverinfo = 'text',
    frame=~år,
    ids = ~desokod,
    legendgroup = ~index_class
  )%>%
    animation_opts(
      1000, easing = "elastic", redraw = FALSE
    )
  
  # Layout
  fig <- fig %>% layout(
    title = list(
      text = "<b>Samband mellan socioekonomiskt index och födelseregion på DeSO-nivå<b>",
      font = list(size = 20, color = "#B81867")
    ),
    xaxis = list(
      title = list(text = "<b>Socioekonomiskt Index<b>", font = list(size = 18, bold=T)),
      zeroline = FALSE,
      linecolor = 'rgba(128,128,128,0.5)'
    ),
    yaxis = list(
      title = list(text = "<b>Andel utrikesfödda<b>", font = list(size = 22, bold=T)),
      zeroline = FALSE,
      linecolor = 'rgba(128,128,128,0.5)',
      tickvals = tick_vals,
      ticktext = tick_texts,
      range = c(0, 100)
    ), # Textbox med korrelation 
    annotations = list(
      list(
        xref = "paper",
        yref = "paper",
        x = 0.02,  # nära vänstra kanten
        y = 0.98,  # nära toppen
        text = paste0("<b>", corr_text, "</b>"),
        showarrow = FALSE,
        font = list(size = 16, color = "black"),
        bgcolor = "rgba(255,255,255,0.8)",  # halvtransparent vit bakgrund
        bordercolor = "rgba(0,0,0,0.3)",
        borderwidth = 1,
        borderpad = 4
      ),
      list(
        xref = "paper",
        yref = "paper",
        x = 0,  # nära vänstra kanten
        y = -0.35,  # nära toppen
        text = paste0("Källa: SCB, bearbetat av Region Uppsala"),
        showarrow = FALSE,
        font = list(size = 12)
      )
    ),
    plot_bgcolor = 'rgba(0,0,0,0)',
    paper_bgcolor = 'rgba(0,0,0,0)',
    hovermode = 'closest',
    margin = list(l = 60, r = 60, t = 60, b = 60),
    legend = list(
      orientation = "h",      
      x = 0.5,                # mitten av grafen
      y = -0.35,               # under grafen
      xanchor = "center",
      yanchor = "top",
      xref = "paper",    # viktigt! position relativt plot paper
      yref = "paper",    # viktigt! position relativt plot paper
      font = list(size = 16)
    ))
  
  
  # tar bort plotlyfunktioner
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



# tabeller för förändrade klasser
table_switches <- function(){
  
  # läser in datasets
  df <- read.csv('Data/df_data_index_pca.csv')
  
  
  suppressMessages({
    suppressWarnings({
      st_layers("Data/DeSO_2025.gpkg")
      deso_joined <- st_read("Data/DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE)  # we keep only Uppsala län
    })
  })
  
  
  
  laskoden <- str_split(lanskod,"")[[1]][2]
  
  df <- df %>% left_join(deso_joined %>% select(desokod), by="desokod")%>%
    st_as_sf() %>% filter(lanskod == laskoden) %>%  st_drop_geometry()
  
  
  koppling <- read_excel("Data/koppling-deso2025-regso2025.xlsx", skip=2) %>% select(Kommunnamn, DeSO_2025 ,RegSO_2025 ) %>% 
    rename(desokod=DeSO_2025)
  
  deso_sf2 <- deso_sf2  %>% mutate(år = as.integer(år))
  
  # Slår ihop datan
  deso_sf <- left_join(df,deso_sf2, by=c('desokod','år')) %>% 
    left_join(koppling, by='desokod')
  
  deso_sf$index_class <- factor(deso_sf$index_class, levels = 1:6)
  
  # Färgschema# Farea_type_description_sdärgschema
  colormap <- c("#D57667", "#EABAB3",'#F9B000',"#FFFFFF", "#A4D0B8", "#4AA271")
  
  
  
  # Variabel för att följa vilka som byter klass över tid: 
  deso_sf <- deso_sf %>%
    group_by(desokod) %>%
    mutate(byter_klass = n_distinct(index_class, na.rm = TRUE) > 1) %>%
    ungroup()
  
  # Klassen vid första året
  original_class <- deso_sf %>%
    arrange(desokod, år) %>%
    group_by(desokod) %>%
    summarise(original_index_class = first(index_class))
  
  # tar ut förbättring/försämring och gör nya variabler
  deso_transitions <- deso_sf %>%
    arrange(desokod, år) %>%                   
    group_by(desokod) %>%
    mutate(prev_class = lag(index_class),
           prev_year  = lag(år)) %>%
    filter(!is.na(prev_class) & prev_class != index_class) %>% 
    mutate(
      Förändring = paste0(prev_class, " → ", index_class),
      direction = case_when(
        as.numeric(index_class) > as.numeric(prev_class) ~ "Förbättring",
        as.numeric(index_class) < as.numeric(prev_class) ~ "Försämring",
        TRUE ~ "no_change"
      )
    ) %>%
    ungroup()
  
  # Om ett område byter flera gånger så tas endast senaste med
  deso_transitions <- deso_transitions %>%
    group_by(desokod) %>%
    slice_max(order_by = år, n = 1) %>%
    ungroup()
  
  deso_transitions <- deso_transitions %>%
    left_join(original_class, by = "desokod") %>%
    filter(index_class != original_index_class) %>%   # ← Ta bort oscillationer
    select(-original_index_class)
  
  # Nytt färgschema
  # Blir fel i tabellen??!!!!!!!
  direction_colors <- c(
    "Försämring"  = "#D57667",
    "Förbättring" = "#4AA271"
  )
  # Räknar antalet
  transition_counts <- deso_transitions %>%
    count(Förändring, direction, sort = TRUE) 
  
  # Förbättringar
  improvements <- deso_transitions %>%
    filter(direction == "Förbättring") %>%
    select(desokod, RegSO_2025,prev_year, år, prev_class, index_class, Förändring)
  # försämringar
  decreases <- deso_transitions %>%
    filter(direction == "Försämring") %>%
    select(desokod,RegSO_2025, prev_year, år, prev_class, index_class, Förändring)
  
  #  transition_counts med färg på n 
  transition_counts_gt <- transition_counts %>% arrange(direction) %>% 
    gt() %>%
    tab_header(
      title = "Antal förändringar",
      subtitle = "Frekvens av alla förändringar"
    ) %>%
    cols_label(
      n = "Antal"        
    ) %>% 
    cols_hide(columns = direction) %>%  
    data_color(
      columns = "Förändring",        
      palette = direction_colors[transition_counts$direction],     
      apply_to = "fill"
    ) %>%
    tab_options(
      table.width = pct(60),
      table.border.top.width = px(2),
      table.border.bottom.width = px(2)
    )
  
  
  # förbättringar med grön färg
  improvements_gt <- improvements %>%
    gt() %>%
    cols_label(
      desokod = "desokod",
      RegSO_2025 = "RegSO_2025",
      prev_year = "Tidigare år",
      år = "År vid förbättring",
      Förändring = "Förändring"
    ) %>% 
    tab_header(
      title = "Förbättringar",
      subtitle = "DESO som förbättras"
    ) %>%
    
    data_color(
      columns = c(Förändring),
      palette = colormap[4:6],  # de gröna/ljusa färgerna
      apply_to = "fill"
    ) %>%
    cols_hide(
      columns = c(prev_class, index_class)
    ) %>%
    tab_options(
      table.width = pct(100)
    )
  
  
  #försämringar med röd färg 
  decreases_gt <- decreases %>%
    gt() %>%
    cols_label(
      desokod = "desokod",
      RegSO_2025 = "RegSO_2025",
      prev_year = "Tidigare år",
      år = "År vid försämring",
      Förändring = "Förändring"
    ) %>% 
    tab_header(
      title = "Försämringar",
      subtitle = "DESO som försämrats"
    )%>%
    cols_hide(
      columns = c(prev_class, index_class)
    )  %>%
    data_color(
      columns = c(Förändring),
      palette = colormap[1:3],  # röda/orange färgerna
      apply_to = "fill"
    ) %>%
    tab_options(
      table.width = pct(100)
    )
  
  
  # Visa tabellerna
  return(list(transition_counts_gt,
              improvements_gt,
              decreases_gt))
  
}

# skapar tabell för de områden som har störst indexskillnad 
table_diff <- function(){
  
  # läser in datasets
  df <- read.csv('Data/df_data_index_pca.csv')
  
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/DeSO_2025.gpkg")
      deso_joined <- st_read("Data/DeSO_2025.gpkg", quiet = TRUE)
      
      st_layers("Data/df_deso_fodelse_index_tid.gpkg")
      deso_sf2 <- st_read("Data/df_deso_fodelse_index_tid.gpkg", quiet = TRUE)
    })
  })
  
  laskoden <- str_split(lanskod,"")[[1]][2]
  
  df <- df %>% left_join(deso_joined %>% select(desokod), by="desokod")%>%
    st_as_sf() %>% filter(lanskod == laskoden) %>%  st_drop_geometry()
  
  deso_sf2 <- deso_sf2  %>% mutate(år = as.integer(år))
  
  # Slår ihop datan
  deso_sf <- left_join(df,deso_sf2, by=c('desokod','år')) %>% 
    left_join(koppling, by='desokod')
  
  deso_sf$index_class <- factor(deso_sf$index_class, levels = 1:6)
  
  # Färgschema# Farea_type_description_sdärgschema
  colormap <- c("#D57667", "#4AA271")
  
  
  # Tar ut skillnaden mellan första och senaste året
  deso_diff <- deso_sf %>% 
    group_by(desokod) %>% 
    summarise(
      index_start = index[år == min(år)],
      index_end   = index[år == max(år)],
      diff        = index_start - index_end,
      .groups = "drop"
    )
  
  deso_diff<- deso_diff %>% left_join(deso_sf %>% select(Kommunnamn, RegSO_2025, desokod),
                                      by = 'desokod')
  
  # byternamn på kolumnerna
  years <- sort(unique(deso_sf$år))
  year_cols <- as.character(c(years[1], years[length(years)]))
  
  deso_diff <- deso_diff %>% 
    dplyr::select(Kommunnamn, RegSO_2025, desokod,index_start,index_end , diff )
  
  # plockar ut dom största skillnaderna
  
  top10 <- deso_diff[order(-abs(deso_diff$diff)), ][1:10, ]
  
  #  transition_counts med färg på n 
  top10_gt <- top10 %>% 
    gt() %>%
    tab_header(
      title = paste("Områdena med störst förändring sedan", year_cols[1]),
    ) %>%
    cols_label(
      index_start = paste("Index",year_cols[1] ) ,
      index_end = paste("Index", year_cols[2] ), 
      
      diff ="Skillnad"
    ) %>% 
    data_color(
      columns = "diff",        
      palette = colormap,     
      apply_to = "fill"
    ) %>%
    tab_options(
      table.width = pct(100),
      table.border.top.width = px(2),
      table.border.bottom.width = px(2)
    )
  
  
  top10_gt  
}


# Korrelation mellan indexen!
korrelation_index <- function(){
  # Läser in data
  
  df <- read.csv('Data/df_data_index_pca.csv')
  
  
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_desocioindex.gpkg")
      deso_sf2 <- st_read("Data/df_desocioindex.gpkg", quiet = TRUE)
    })
  })
  # tar ut rätt år
  ar <- unique(deso_sf2$år)
  
  # Filtrerar så de blir samma
  df <- df %>% filter(år == ar, desokod %in% deso_sf2$desokod) %>% arrange(desokod)
  deso_sf2 <- deso_sf2 %>% filter(desokod %in% df$desokod)%>% arrange(desokod)
  
  # slår ihop till samma df
  df2 <- data.frame('Simpeltindex'=deso_sf2$Socioekonomiskt_index,"Simpelklass"=deso_sf2$area_type,
                    'PCAindex' = df$index, 'PCAklass'=df$index_class)
  
  # gör till faktorvariabler for plott och standardiserar variabler: 
  df2 <- df2 %>%
    mutate(
      Simpeltindex = as.numeric(Simpeltindex),
      PCAindex = as.numeric(PCAindex),
      Simpelklass = as.factor(Simpelklass),
      PCAklass = as.factor(PCAklass)
    )
  
  # Korrelationsanalys av pearson och spearman 
  cor_pearson <- cor(df2$Simpeltindex, df2$PCAindex, method = "pearson")
  cor_spearman <- cor(df2$Simpeltindex, df2$PCAindex, method = "spearman")
  
  cor_pearson
  cor_spearman
  
  # Färgsschema
  colormap <- c("#D57667", "#EABAB3",'#F9B000',"#FFFFFF", "#A4D0B8", "#4AA271")
  
  # shapemap
  shape_map <- c(21, 22, 23, 24, 25)
  
  # sambandet mellan indexen
  p <- ggplot(df2, aes(PCAindex, Simpeltindex,fill = PCAklass)) +
    geom_point(
      aes(
        # Fyllnad efter simpelt index
        shape = factor(Simpelklass)   # Form efter simpelt index
      ),
      color = "black",    # svart kantlinje
      size = 4,
      alpha = 0.8,
      stroke = 1
    ) +
    
    scale_shape_manual(values = shape_map) +
    scale_fill_manual(values = colormap) +
    guides(
      shape = guide_legend(order = 1, byrow = TRUE, override.aes = list(color = "black", size = 5)),
      fill = guide_legend(order = 2, byrow = TRUE, override.aes = list(shape = 21, color = "black", size = 5))
    ) +
    labs(
      title = str_wrap(paste("Relation mellan PCA-index och simpelt socioekonomiskt index år",ar), width=50),
      fill = "PCA-index (klass)",
      shape = "Simpelt index (klass)",
      x = "PCA-index",
      y = "Simpelt index",
      caption='Källa: Region Uppsala'
    )+theme(legend.position = 'bottom',
            legend.box = "vertical",text = element_text(family = "sourcesanspro", size = 16),
            plot.title = element_text(family = "Arial", face = "bold", size = 22, hjust = 0),
            axis.title = element_text(size = 16, face = "bold"),
            axis.text = element_text(size = 16),
            legend.text = element_text(size = 16),
            legend.title = element_text(family = "Arial", face = "bold", size = 16),
            strip.text = element_text(family = "Arial", face = "bold", size = 16),
            plot.caption = element_text(hjust = 0, size = 12),
            plot.margin = grid::unit(c(15, 30, r=30, 15), "pt"))
  
  p
  ggsave("Figurer/Relation_PCA_Simpelt_index.svg",
         plot = p,
         width = 8,        # bredd i tum
         height = 7,        # höjd i tum
         dpi = 300,         # upplösning (för SVG används dpi mest för text/annotations)
         device = "svg") 
  
  ggsave("Figurer/Relation_PCA_Simpelt_index.png",
         plot = p,
         width = 8,        # bredd i tum
         height = 7,        # höjd i tum
         device = "png",
         dpi =96) 
}


# Korrelation mellan indexen temporärt
korrelation_index_temp <- function(){
  # Läser in data
  
  df <- read.csv('Data/df_data_index_pca.csv')
  
  
  # Läser in data
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_desocioindex.gpkg")
      deso_sf2 <- st_read("Data/df_desocioindex.gpkg", quiet = TRUE)
    })
  })
  # tar ut rätt år
  ar <- unique(deso_sf2$år)
  
  # Filtrerar så de blir samma
  df <- df %>% filter(desokod %in% deso_sf2$desokod) %>% arrange(desokod)
  deso_sf2 <- deso_sf2 %>% filter(desokod %in% df$desokod)%>% arrange(desokod)
  
  # slår ihop till samma df
  df2 <- data.frame('Simpeltindex'=deso_sf2$Socioekonomiskt_index,"Simpelklass"=deso_sf2$area_type,
                    'PCAindex' = df$index, 'PCAklass'=df$index_class)
  
  # gör till faktorvariabler for plott och standardiserar variabler: 
  df2 <- df2 %>%
    mutate(
      Simpeltindex = as.numeric(Simpeltindex),
      PCAindex = as.numeric(PCAindex),
      Simpelklass = as.factor(Simpelklass),
      PCAklass = as.factor(PCAklass)
    )
  
  # Korrelationsanalys av pearson och spearman 
  cor_pearson <- cor(df2$Simpeltindex, df2$PCAindex, method = "pearson")
  cor_spearman <- cor(df2$Simpeltindex, df2$PCAindex, method = "spearman")
  
  cor_pearson
  cor_spearman
  
  # Färgsschema
  colormap <- c("#D57667", "#EABAB3",'#F9B000',"#FFFFFF", "#A4D0B8", "#4AA271")
  
  # shapemap
  shape_map <- c(21, 22, 23, 24, 25)
  
  # sambandet mellan indexen
  p <- ggplot(df2, aes(PCAindex, Simpeltindex,fill = PCAklass)) +
    geom_point(
      aes(
        # Fyllnad efter simpelt index
        shape = factor(Simpelklass)   # Form efter simpelt index
      ),
      color = "black",    # svart kantlinje
      size = 4,
      alpha = 0.8,
      stroke = 1
    ) +
    
    scale_shape_manual(values = shape_map) +
    scale_fill_manual(values = colormap) +
    guides(
      shape = guide_legend(order = 1, byrow = TRUE, override.aes = list(color = "black", size = 5)),
      fill = guide_legend(order = 2, byrow = TRUE, override.aes = list(shape = 21, color = "black", size = 5))
    ) +
    labs(
      title = str_wrap(paste("Relation mellan PCA-index och simpelt socioekonomiskt index år",ar,'-', as.numeric(ar)+1), width=50),
      fill = "PCA-index (klass)",
      shape = "Simpelt index (klass)",
      x = "PCA-index",
      y = "Simpelt index",
      caption='Källa: Region Uppsala'
    )+theme(legend.position = 'bottom',
            legend.box = "vertical",text = element_text(family = "sourcesanspro", size = 16),
            plot.title = element_text(family = "Arial", face = "bold", size = 22, hjust = 0),
            axis.title = element_text(size = 16, face = "bold"),
            axis.text = element_text(size = 16),
            legend.text = element_text(size = 16),
            legend.title = element_text(family = "Arial", face = "bold", size = 16),
            strip.text = element_text(family = "Arial", face = "bold", size = 16),
            plot.caption = element_text(hjust = 0, size = 12),
            plot.margin = grid::unit(c(15, 30, r=30, 15), "pt"))
  
  p
  ggsave("Figurer/Relation_PCA_Simpelt_index.svg",
         plot = p,
         width = 8,        # bredd i tum
         height = 7,        # höjd i tum
         dpi = 300,         # upplösning (för SVG används dpi mest för text/annotations)
         device = "svg") 
  
  ggsave("Figurer/Relation_PCA_Simpelt_index.png",
         plot = p,
         width = 8,        # bredd i tum
         height = 7,        # höjd i tum
         device = "png",
         dpi =96) 
}



# karta mellan enkelt index och pca-index -> ska bytas ut när ny data finns tillgängligt
socioindex_karta_tid_temp <- function(){
  # läser in datasets
  df <- read.csv('Data/df_data_index_pca.csv')
  
  senaste_aret <- unique(df$år)
  
  if (senaste_aret > 2023){
    suppressMessages({
      suppressWarnings({
        st_layers("Data/DeSO_2025.gpkg")
        deso_joined <- st_read("Data/DeSO_2025.gpkg", layer = "DeSO_2025", quiet = TRUE)  # we keep only Uppsala län
      })
    })
  }else{
    suppressMessages({
      suppressWarnings({
        st_layers("Data/DeSO_2018.gpkg")
        deso_joined <- st_read("Data/DeSO_2018.gpkg", layer = "DeSO_2018", quiet = TRUE) # we keep only Uppsala län
      })
    })
  }  
  
  
  laskoden <- str_split(lanskod,"")[[1]][2]
  
  df <- df %>% left_join(deso_joined %>% select(desokod,sp_geometry), by="desokod")%>%
    st_as_sf() %>% filter(lanskod == !!laskoden)
  
  # popup och label
  df_sf <- df %>%
    mutate(
      popup = paste0("<b>", kommunnamn, "</b><br>",
                     "Deso: ",desokod,"<br>",
                     "År: ", år, "<br>",
                     "Index: ", round(index,2),'<br>',
                     'Andel med endast förgymnasial utbildning: ', Andel_forgymnasial , "%", "<br>",
                     'Andel arbetslösa: ' , round(Andel_arbetslösa ,1), "%", "<br>",
                     'Andel med låg ekonomisk standard: ', round(Låg.ekonomisk.standard..procent,1), "%","<br>",
                     'Andel boende i flerbostadshus: ', Andel.i.procent , "%", "<br>",     
                     'Andel ensamstående: ' , round(Andel_ensamstaende ,1), "%", "<br>",
                     'Andel som går på biståndsbigrag: ' , round(Andel.med.inkomstslag..procent ,1), "%", "<br>"),
      label = paste0(kommunnamn,': ',desokod, " (", år, ")")
    )
  
  # Anta df_sf redan innehåller geometri, index_class, popup och label
  
  max_y <- max(df_sf$år, na.rm = TRUE)
  
  last_year  <- df_sf %>% filter(år==max_y)
  
  
  # Gemensam palett och legend
  custom_colors <- c("#D57667", "#EABAB3",'#F9B000',"#FFFFFF", "#A4D0B8", "#4AA271")
  pal <- colorFactor(palette = custom_colors, domain = df_sf$index_class)
  
  # läser in datasets
  suppressMessages({
    suppressWarnings({
      st_layers("Data/df_desocioindex.gpkg")
      deso_joined <- st_read("Data/df_desocioindex.gpkg", quiet = TRUE)
    })
  })
  
  
  min_y <- max(deso_joined$år, na.rm = TRUE)
  
  #  Bygg popup-texten med andelar
  popup_text <- deso_joined %>%
    group_by(desokod) %>%
    summarise(
      popup = paste0(
        "DeSO: ", unique(desokod), "<br>",
        paste0(
          'Andel med endast förgymnasial utbildning: ', Andel, "%", "<br>",
          'Andel arbetslösa: ' , round(Andel_arbetslösa,1), "%", "<br>",
          'Andel med låg ekonomisk standard: ', round(Låg.ekonomisk.standard..procent,1), "%",
          collapse = "<br>"
        )
      ),
      .groups = "drop"
    ) %>%
    st_drop_geometry()
  
  # slår ihop
  deso_sf_pop_join <- deso_joined %>%
    left_join(popup_text, by = "desokod")
  
  deso_sf_pop_join$label <- paste(
    "DeSO: ", deso_sf_pop_join$desokod,  " | ",
    'Socioekonomiskt index:',
    deso_sf_pop_join$area_type_description)
  deso_sf_pop_join$area_type <- factor(deso_sf_pop_join$area_type, levels = 1:5)
  
  # färgschema
  custom_colors2 <- c("#D57667", "#EABAB3", "#FFFFFF", "#A4D0B8", "#4AA271")
  
  # skapar karta
  m1 <- mapview(
    deso_sf_pop_join,
    map.types = NULL,
    zcol = "area_type",
    legend = TRUE,
    layer.name = paste("Simpelt index",min_y),
    at =  1:5,
    col.regions = custom_colors2,
    popup = deso_sf_pop_join$popup,
    label =  deso_sf_pop_join$label
  )
  
  
  
  
  
  m2 <- mapview(last_year, zcol = "index_class", 
                map.types = NULL,
                col.regions = custom_colors, 
                legend = T ,
                popup = last_year$popup,
                label=last_year$label,
                layer.name = paste("PCA-index", max_y))  
  
  # Slå ihop kartorna
  
  map <- m1 | m2
  map <- map %>% leaflet::addTiles(
    urlTemplate = "https://basemaps.cartocdn.com/rastertiles/positron/{z}/{x}/{y}.png?key=cb1_2u50_1_d6a866f2a70b7f9289d8f6d6"
  )
  
  
  # Variabel för att skapa text på kartan
  js_code <- sprintf("
function(el, x) {
  setTimeout(function() {

    var leftLabel = document.createElement('div');
    leftLabel.style.position = 'absolute';
    leftLabel.style.left = '10px';
    leftLabel.style.top = '50%%';
    leftLabel.style.transform = 'translateY(-50%%)';
    leftLabel.style.background = 'rgba(255,255,255,0.8)';
    leftLabel.style.padding = '4px 8px';
    leftLabel.style.borderRadius = '6px';
    leftLabel.style.fontSize = '16px';
    leftLabel.style.zIndex = '1000';
    leftLabel.innerHTML = '%s';

    var rightLabel = document.createElement('div');
    rightLabel.style.position = 'absolute';
    rightLabel.style.right = '10px';
    rightLabel.style.top = '50%%';
    rightLabel.style.transform = 'translateY(-50%%)';
    rightLabel.style.background = 'rgba(255,255,255,0.8)';
    rightLabel.style.padding = '4px 8px';
    rightLabel.style.borderRadius = '6px';
    rightLabel.style.fontSize = '16px';
    rightLabel.style.zIndex = '1000';
    rightLabel.innerHTML = '%s';

    el.appendChild(leftLabel);
    el.appendChild(rightLabel);
  }, 500);
}
", "Simpelt index", "PCA-index")
  
  
  # HTML för att få in åren på rätt sida slidern
  map@map <- map@map %>% htmlwidgets::onRender(js_code)
  
  map
}



