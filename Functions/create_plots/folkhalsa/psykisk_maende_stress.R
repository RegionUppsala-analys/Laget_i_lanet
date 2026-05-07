
psykist_valbefinnande <- function(){
  # Läser in data  
  df <- read.csv("Data/df_psykiskt.csv") %>% 
    mutate(År = factor(År, levels = sort(unique(År)))) %>% 
    filter(Region == "Uppsala län")
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y = Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = Konfidensintervall.nedre.gräns, ymax = Konfidensintervall.övre.gräns), alpha = 0.3, color =NA) +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=20),
                       limits = c(0,100))+
    labs(x="",
         title = str_wrap("Andel med gott eller mycket gott psykiskt välbefinnande – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         color="",
         y = "Andel (%)",
         fill="")+
    theme(plot.caption = element_text(hjust=0))
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/psykisk_valbefinnande.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/psykisk_valbefinnande.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}

psykisk_pafrestning <- function(){
  # Läser in data  
  df <- read.csv("Data/df_psykisk_halsa.csv") %>% 
    mutate(År = factor(År, levels = sort(unique(År)))) %>% 
    filter(Region == "Uppsala län")
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y = Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = Konfidensintervall.nedre.gräns, ymax = Konfidensintervall.övre.gräns), alpha = 0.3, color =NA) +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=20),
                       limits = c(0,100))+
    labs(x="",
         title = str_wrap("Andel med allvarlig psykisk påfrestning – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         color="",
         y = "Andel (%)",
         fill="")+
    theme(plot.caption = element_text(hjust=0))
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/psykisk_halsa.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/psykisk_halsa.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}

Psykisk_stress <- function(){
  # Läsa in data  
  df <- read.csv('Data/df_psykiska_variabler.csv') %>% filter(Region %in% c(
    "Riket","Uppsala län"))
  
  # Gör till wide
  df <- df %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                           names_from = `Andel.och.konfidensintervall`, 
                           values_from = Stressad)
  
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # Visa vart 5:e år på x-axeln
  ara <- unique(df$År)
  visa_ar <- ara[seq(1, length(ara), by = 2)]
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = `Konfidensintervall nedre gräns`, ymax = `Konfidensintervall övre gräns`), alpha = 0.3, color =NA) +
    # Riket – streckad linje
    geom_line(data = df_rik, aes(x = År, y = Andel, group = Kön, color = Kön),
              linewidth = 1, linetype = "dashed") +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = visa_ar) +
    labs(x="",
         title = str_wrap("Andel stressade – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         y = "Andel (%)",
         color="",
         fill="",
         subtitle = str_wrap("Streckade linjer är Riksandelen", width = 50))+
    theme(plot.caption = element_text(hjust=0),
          plot.subtitle = element_text(hjust=0.5, color = "#B81867", size = 16, face = 'bold'),
          axis.text.x = element_text(angle =45, hjust=1))
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/psykisk_stress.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/psykisk_stress.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
  
  
}

svar_psykisk_stress <-  function(){
  # Läsa in data  
  df <- read.csv('Data/df_psykiska_variabler.csv') %>% filter(Region %in% c(
    "Riket","Uppsala län"))
  
  # Gör till wide
  df <- df %>% pivot_wider(id_cols= c("Region", "Kön", "År"), 
                           names_from = `Andel.och.konfidensintervall`, 
                           values_from = Mycket.stressad)
  # delar upp på region
  df_rik <- df %>% filter(Region == "Riket")
  
  df <-  df %>% filter(Region == "Uppsala län")
  
  # Tar ut år för matchning
  year <- df$År
  
  df_rik <- df_rik %>% filter(År %in% year)
  
  # Visa vart 5:e år på x-axeln
  ara <- unique(df$År)
  visa_ar <- ara[seq(1, length(ara), by = 3)]
  
  # Färgschema
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # skapa plot 
  p <- ggplot(df, aes(x=År, y =Andel, group = Kön, color =Kön, fill=Kön))+
    geom_line(linewidth=1.5)+ geom_point(size=2)+
    geom_ribbon(aes(ymin = `Konfidensintervall nedre gräns`, ymax = `Konfidensintervall övre gräns`), alpha = 0.3, color =NA) +
    scale_color_manual(values = kon_col)+
    scale_fill_manual(values = kon_col)+
    scale_y_continuous(breaks = seq(0,100,by=10),
                       limits = c(0,100))+
    scale_x_discrete(breaks = visa_ar) +
    labs(x="",
         title = str_wrap("Andel mycket stressade – Uppsala län (4-årsmedelvärden)", width=50),
         caption = "Källa: Folkhälsomyndigheten, Nationella folkhälsoenkäten",
         y = "Andel (%)",
         color="",
         fill="")+
    theme(plot.caption = element_text(hjust=0),
          axis.text.x = element_text(angle = 45, hjust=1))
  
  
  
  p
  
  # Sparar plot 
  ggsave(
    paste0("Figurer/svar_psykisk_stress.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/svar_psykisk_stress.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}
