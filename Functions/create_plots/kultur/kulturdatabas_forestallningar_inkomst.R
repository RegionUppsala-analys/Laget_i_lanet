######## Kulturdatabasen ########


museer_konsthallar2 <- function(){
  # Hämtar kolnamn 
  df <- read_excel("Data/kulturdatabasen.xlsx", sheet = "Museer - Data", skip = 0) %>%
    mutate(
      besok_a_totalt = na_if(besok_a_totalt, "."),
      besok_a_totalt = na_if(besok_a_totalt, "A"),
      besok_v_totalt = na_if(besok_v_totalt, "."),
      besok_v_totalt = na_if(besok_v_totalt, "A"),
      besok_a_totalt = as.numeric(besok_a_totalt),
      besok_v_totalt = as.numeric(besok_v_totalt))
  
  df$museum <- ifelse(df$museum == "Uppsala konstmuseum","Uppsala Konstmuseum",df$museum  )
  
  # Fixar till strukturen på data
  df_clean <- df %>% select(museum, "år"=ar,"Anläggningsbesök"=besok_a_totalt,
                            "Verksamhetsbesök"=besok_v_totalt ) 
  
  
  tot <- df_clean %>% group_by(år) %>% summarise(Anläggningsbesök = sum(Anläggningsbesök,na.rm=T ),
                                                 Verksamhetsbesök = sum(Verksamhetsbesök,na.rm=T))
  
  tot$museum <- "totalt i länet"
  
  df_clean <- rbind(df_clean,tot)
  
  df_clean <- df_clean %>%
    pivot_longer(
      cols = c(Anläggningsbesök, Verksamhetsbesök),
      names_to = "typ_av_besök",
      values_to = "antal"
    )
  
  # Hitta senaste år i datan
  max_year <- max(df_clean$år, na.rm = TRUE)
  
  df_clean <- df_clean %>%
    group_by(museum) %>%
    filter(
      any(år == max_year & !is.na(antal)) |
        any(år == (max_year - 1) & !is.na(antal))
    ) %>%
    ungroup()
  
  # Antal platser
  kat <- unique(df_clean$museum)
  
  for (k in kat) {
    
    temp <- df_clean %>%  filter(museum == k, !is.na(antal))
    
    p <- ggplot(temp, aes(x=factor(år), y=antal, color= typ_av_besök, group = typ_av_besök))+ 
      geom_line(linewidth=2, alpha=0.7)+ geom_point(size=3)+
      scale_y_continuous(labels = scales::comma) +   # Tar bort scientific notation
      scale_color_manual(values = c("#019CD7","#F9B000"))+
      labs(x="",y="Antal",
           title= str_wrap(paste('Utvecklingen av antal besök',k), width=50),
           caption="Källa: Kulturdatabasen",
           color="")+
      theme(axis.text.x = element_text(angle=45, vjust=0.5),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            legend.position = "bottom")
    
    p  
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/besok_museer2_",k,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/besok_museer2_",k,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
    
    
  }
  
}

forestallning_konsert <- function(){
  # Hämtar kolnamn 
  df <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "3 - Tidsserier", skip = 5)
  namn <-colnames(df)
  
  # tar ut museer och konsthallar
  index <- which(df$...1=='4.3 Tidsserier scenkonst – föreställningar/konserter och publik')
  
  # Hämtar data
  KDB_Uppsala <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "3 - Tidsserier", skip = index+5)
  colnames(KDB_Uppsala)[-1] <- namn[-1]
  
  KDB_Uppsala[KDB_Uppsala == "#"] <- NA
  
  # Fixar till strukturen på data
  df_clean <- KDB_Uppsala %>%
    rename(kategori = 1) %>%
    mutate(år = if_else(str_detect(kategori, "^\\d{4}$"), kategori, NA_character_)) %>%
    fill(år, .direction = "down") %>%
    filter(!str_detect(kategori, "^\\d{4}$")) %>%
    remove_empty("cols") %>%  # Tar bort tomma kolumner
    relocate(år, .before = kategori) %>% mutate(år = as.integer(år),
                                                `totalt i länet` = as.numeric(Uppsala),
                                                `Region UppsalaKulturutvecklingTotalt interna övriga`=as.numeric(`Region UppsalaKulturutvecklingTotalt interna övriga`)) %>% 
    select(-Uppsala) %>% rename("Övriga interna"=`Region UppsalaKulturutvecklingTotalt interna övriga`)
  
  
  
  # gör till long
  df_clean <- df_clean %>% pivot_longer(names_to = "Plats",
                                        cols = c(where(is.numeric),-år))
  # Fixar till grupperna
  df2 <- df_clean %>%
    mutate(
      typ = case_when(
        str_detect(kategori, "Publik") ~ "Publik",
        str_detect(kategori, "Föreställningar") ~ "Föreställningar"
      ),
      grupp = case_when(
        str_detect(kategori, "Egen") ~ "Egen och samproduktion",
        str_detect(kategori, "Mottagna") ~ "Gästspel"
      )
    )
  
  # Tar bort NA
  df2 <- df2  %>% filter(!is.na(value), !is.na(typ))
  
  # Gör till wide för finare tabell
  df_ratio <- df2 %>%
    pivot_wider(
      id_cols = c(år, grupp, Plats),
      names_from = typ,
      values_from = value
    ) %>%
    mutate(
      publik_per_forest = Publik / Föreställningar
    )
  
  
  # Antal platser
  kat <- unique(df_ratio$Plats)
  
  for (k in kat) {
    
    temp <- df_ratio %>%  filter(Plats == k)
    
    p <- ggplot(temp, aes(x=factor(år), y=publik_per_forest, color= grupp, group = grupp))+ 
      geom_line(linewidth=2, alpha=0.7)+ geom_point(size=3)+
      scale_color_manual(values = c("#F9B000" ,"#019CD7"))+
      scale_y_continuous(labels = scales::comma) +   # Tar bort scientific notation
      labs(x="",y="Publiksnitt",
           title= str_wrap(paste('Utvecklingen av besökare per föreställning/konsert',k), width=50),
           caption="Källa: Kulturdatabasen",
           color="")+
      theme(axis.text.x = element_text(angle=45, vjust=0.5),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            legend.position = "bottom")+ 
      guides(fill = guide_legend(nrow = 3))
    
    p  
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/forestallning_konsert_",k,".svg"),
      plot = p,
      width = 8,
      height = 4
    )
    
    ggsave(
      paste0("Figurer/forestallning_konsert_",k,".png"),
      plot = p,
      width = 8,
      height = 4,
      dpi = 96
    )
    
    
  }
  
  
}

forestallning_konsert_ant <- function(){
  # Hämtar kolnamn 
  df <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "3 - Tidsserier", skip = 5)
  namn <-colnames(df)
  
  # tar ut museer och konsthallar
  index <- which(df$...1=='4.3 Tidsserier scenkonst – föreställningar/konserter och publik')
  
  # Hämtar data
  KDB_Uppsala <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "3 - Tidsserier", skip = index+5)
  colnames(KDB_Uppsala)[-1] <- namn[-1]
  
  KDB_Uppsala[KDB_Uppsala == "#"] <- NA
  
  # Fixar till strukturen på data
  df_clean <- KDB_Uppsala %>%
    rename(kategori = 1) %>%
    mutate(år = if_else(str_detect(kategori, "^\\d{4}$"), kategori, NA_character_)) %>%
    fill(år, .direction = "down") %>%
    filter(!str_detect(kategori, "^\\d{4}$")) %>%
    remove_empty("cols") %>%  # Tar bort tomma kolumner
    relocate(år, .before = kategori) %>% mutate(år = as.integer(år),
                                                `totalt i länet` = as.numeric(Uppsala),
                                                `Region UppsalaKulturutvecklingTotalt interna övriga`=as.numeric(`Region UppsalaKulturutvecklingTotalt interna övriga`)) %>% 
    select(-Uppsala) %>% rename("Övriga interna"=`Region UppsalaKulturutvecklingTotalt interna övriga`)
  
  
  
  # gör till long
  df_clean <- df_clean %>% pivot_longer(names_to = "Plats",
                                        cols = c(where(is.numeric),-år))
  # Fixar till grupperna
  df2 <- df_clean %>%
    mutate(
      typ = case_when(
        str_detect(kategori, "Publik") ~ "Publik",
        str_detect(kategori, "Föreställningar") ~ "Föreställningar"
      ),
      grupp = case_when(
        str_detect(kategori, "Egen") ~ "Egen och samproduktion",
        str_detect(kategori, "Mottagna") ~ "Gästspel"
      )
    )
  
  # Tar bort NA
  df2 <- df2  %>% filter(!is.na(value), !is.na(typ))
  
  # Gör till wide för finare tabell
  df_ratio <- df2 %>%
    pivot_wider(
      id_cols = c(år, grupp, Plats),
      names_from = typ,
      values_from = value
    ) 
  
  
  # Antal platser
  kat <- unique(df_ratio$Plats)
  
  for (k in kat) {
    
    temp <- df_ratio %>%  filter(Plats == k)
    
    p <- ggplot(temp, aes(x=factor(år), y=Föreställningar, color= grupp, group = grupp))+ 
      geom_line(linewidth=2, alpha=0.7)+ geom_point(size=3)+
      scale_color_manual(values = c("#F9B000" ,"#019CD7"))+
      scale_y_continuous(labels = scales::comma) +   # Tar bort scientific notation
      labs(x="",y="Antal",
           title= str_wrap(paste('Utvecklingen av antal föreställning/konsert',k), width=50),
           caption="Källa: Kulturdatabasen",
           color="")+
      theme(axis.text.x = element_text(angle=45, vjust=0.5),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            legend.position = "bottom")+ 
      guides(fill = guide_legend(nrow = 3))
    
    p  
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/forestallning_konsert_ant_",k,".svg"),
      plot = p,
      width = 8,
      height = 4
    )
    
    ggsave(
      paste0("Figurer/forestallning_konsert_ant_",k,".png"),
      plot = p,
      width = 8,
      height = 4,
      dpi = 96
    )
    
    
  }
  
  
}


forestallning_konsert_pub <- function(){
  # Hämtar kolnamn 
  df <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "3 - Tidsserier", skip = 5)
  namn <-colnames(df)
  
  # tar ut museer och konsthallar
  index <- which(df$...1=='4.3 Tidsserier scenkonst – föreställningar/konserter och publik')
  
  # Hämtar data
  KDB_Uppsala <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "3 - Tidsserier", skip = index+5)
  colnames(KDB_Uppsala)[-1] <- namn[-1]
  
  KDB_Uppsala[KDB_Uppsala == "#"] <- NA
  
  # Fixar till strukturen på data
  df_clean <- KDB_Uppsala %>%
    rename(kategori = 1) %>%
    mutate(år = if_else(str_detect(kategori, "^\\d{4}$"), kategori, NA_character_)) %>%
    fill(år, .direction = "down") %>%
    filter(!str_detect(kategori, "^\\d{4}$")) %>%
    remove_empty("cols") %>%  # Tar bort tomma kolumner
    relocate(år, .before = kategori) %>% mutate(år = as.integer(år),
                                                `totalt i länet` = as.numeric(Uppsala),
                                                `Region UppsalaKulturutvecklingTotalt interna övriga`=as.numeric(`Region UppsalaKulturutvecklingTotalt interna övriga`)) %>% 
    select(-Uppsala) %>% rename("Övriga interna"=`Region UppsalaKulturutvecklingTotalt interna övriga`)
  
  
  
  # gör till long
  df_clean <- df_clean %>% pivot_longer(names_to = "Plats",
                                        cols = c(where(is.numeric),-år))
  # Fixar till grupperna
  df2 <- df_clean %>%
    mutate(
      typ = case_when(
        str_detect(kategori, "Publik") ~ "Publik",
        str_detect(kategori, "Föreställningar") ~ "Föreställningar"
      ),
      grupp = case_when(
        str_detect(kategori, "Egen") ~ "Egen och samproduktion",
        str_detect(kategori, "Mottagna") ~ "Gästspel"
      )
    )
  
  # Tar bort NA
  df2 <- df2  %>% filter(!is.na(value), !is.na(typ))
  
  # Gör till wide för finare tabell
  df_ratio <- df2 %>%
    pivot_wider(
      id_cols = c(år, grupp, Plats),
      names_from = typ,
      values_from = value
    ) 
  
  
  
  # Antal platser
  kat <- unique(df_ratio$Plats)
  
  for (k in kat) {
    
    temp <- df_ratio %>%  filter(Plats == k)
    
    p <- ggplot(temp, aes(x=factor(år), y=Publik, color= grupp, group = grupp))+ 
      geom_line(linewidth=2, alpha=0.7)+ geom_point(size=3)+
      scale_color_manual(values = c("#F9B000" ,"#019CD7"))+
      scale_y_continuous(labels = scales::comma) +   # Tar bort scientific notation
      labs(x="",y="Antal",
           title= str_wrap(paste('Utvecklingen av publiktotalen ',k), width=50),
           caption="Källa: Kulturdatabasen",
           color="")+
      theme(axis.text.x = element_text(angle=45, vjust=0.5),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            legend.position = "bottom")+ 
      guides(fill = guide_legend(nrow = 3))
    
    p  
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/forestallning_konsert_pub_",k,".svg"),
      plot = p,
      width = 8,
      height = 4
    )
    
    ggsave(
      paste0("Figurer/forestallning_konsert_pub_",k,".png"),
      plot = p,
      width = 8,
      height = 4,
      dpi = 96
    )
    
    
  }
  
  
}


inkomst_per_verksamhet_1 <- function(){
  
  # Hämta data
  df <- read_excel("Data/kulturdatabasen.xlsx", sheet = "Museer - Data", skip = 0)%>%
    mutate(
      intakter_totalt = na_if(intakter_totalt, "."),
      intakter_totalt = na_if(intakter_totalt, "A"),
      intakter_totalt = as.numeric(intakter_totalt)) %>% 
    select(museum, ar, KategoriB, intakter_totalt) 
  
  
  # Tar bort de som inte har data senaste åren
  df <- df %>%
    group_by(museum) %>%
    filter(
      any(ar == max_year & !is.na(intakter_totalt)) |
        any(ar == (max_year - 1) & !is.na(intakter_totalt))
    ) %>%
    ungroup()
  
  # Antal platser
  kat <- unique(df$museum)
  
  
  for (k in kat) {
    
    temp <- df %>%  filter(museum == k)
    
    # gör ej en graf om det endast finns 1 observation
    if(nrow(temp)==1){
      next()
    }
    
    p <- ggplot(temp, aes(x=factor(ar), y=intakter_totalt,  group = KategoriB))+ 
      geom_line(linewidth=2, alpha=0.7,color="#4AA271")+ geom_point(size=3, color="#4AA271" )+
      scale_y_continuous(labels = scales::comma) +   # Tar bort scientific notation
      labs(x="",y="Belopp (kr)",
           title= str_wrap(paste('Utvecklingen av intäkterna på',k), width=50),
           caption="Källa: Kulturdatabasen")+
      theme(axis.text.x = element_text(angle=45, vjust=0.5),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            legend.position = "bottom")
    
    p  
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/inkomst_per_verksamhet_",k,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/inkomst_per_verksamhet_",k,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
    
    
  }
  
  
  
  
}

inkomst_per_verksamhet_2 <- function(){
  # Hämtar kolnamn 
  df <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "3 - Tidsserier", skip = 5)
  namn <-colnames(df)
  
  # tar ut museer och konsthallar
  index <- which(df$...1=='4.1 Tidsserier intäkter och kostnader i kronor')
  
  # Hämtar data
  KDB_Uppsala <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "3 - Tidsserier", skip = index+5)
  colnames(KDB_Uppsala)[-1] <- namn[-1]
  
  index <- which(df$...1=='4.2 Tidsserier årsarbetskrafter')
  
  KDB_Uppsala <- KDB_Uppsala[1:index,]
  
  KDB_Uppsala[KDB_Uppsala == "#"] <- NA
  
  # Fixar till strukturen på data
  df_clean <- KDB_Uppsala %>%
    rename(kategori = 1) %>%
    mutate(år = if_else(str_detect(kategori, "^\\d{4}$"), kategori, NA_character_)) %>%
    fill(år, .direction = "down") %>%
    filter(!str_detect(kategori, "^\\d{4}$")) %>%
    remove_empty("cols") %>%  # Tar bort tomma kolumner
    relocate(år, .before = kategori) %>% mutate(år = as.integer(år),
                                                `totalt i länet` = as.numeric(Uppsala),
                                                `Region UppsalaKulturutvecklingTotalt interna övriga`=as.numeric(`Region UppsalaKulturutvecklingTotalt interna övriga`)) %>% 
    select(-Uppsala) %>% rename("Övriga interna"=`Region UppsalaKulturutvecklingTotalt interna övriga`)
  
  
  
  # gör till long
  df_clean <- df_clean %>% pivot_longer(names_to = "Plats",
                                        cols = c(where(is.numeric),-år))
  
  df_clean$kategori <- gsub(", kr", "", df_clean$kategori)
  
  # Antal platser
  kat <- unique(df_clean$Plats)
  
  cols <- c("Kostnader"="#F9B000"  ,
            "Intäkter" = "#4AA271" )
  
  
  for (k in kat) {
    
    temp <- df_clean %>%  filter(Plats == k, !is.na(value))
    
    # gör ej en graf om det endast finns 1 observation
    if(nrow(temp)==1){
      next()
    }
    
    p <- ggplot(temp, aes(x=factor(år), y= value, color= kategori  , group = kategori  ))+ 
      geom_line(linewidth=2, alpha=0.7)+ geom_point(size=3)+
      scale_y_continuous(labels = scales::comma) +   # Tar bort scientific notation
      scale_color_manual(values = cols )+
      labs(x="",y="Belopp (kr)",
           title= str_wrap(paste('Utvecklingen av intäkterna och kostnader på',k), width=50),
           caption="Källa: Kulturdatabasen",
           color="")+
      theme(axis.text.x = element_text(angle=45, vjust=0.5),
            plot.subtitle = element_text( hjust = 0.5, size=16, face="bold",color =  "#B81867" ),
            plot.margin =grid::unit(c(15, 15, 15, 15), "pt"),
            plot.caption = element_text(hjust=0),
            legend.position = "bottom")
    
    p  
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/inkomst_per_verksamhet_",k,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/inkomst_per_verksamhet_",k,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
    
    
  }
  
  
  
  
}


bidrag_per_verksamhet <- function(){
  
  # Hämtar kolnamn 
  df <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "4 - Org, ekonomi och personal", skip = 5)
  namn <-colnames(df)
  
  # tar ut museer och konsthallar
  index <- which(df$...1=='2.1 Intäkter i kronor')
  
  # Hämtar data
  KDB_Uppsala <- read_excel("Data/KDB-Uppsala.xlsx", sheet = "4 - Org, ekonomi och personal", skip = index+5)
  colnames(KDB_Uppsala)[-1] <- namn[-1]
  
  # Tar bort andra variabler
  index <- which(KDB_Uppsala$`2.1 Intäkter i kronor`=='2.1b Årliga bidrag')
  
  KDB_Uppsala <- KDB_Uppsala[1:(index-1),]
  
  # Fixar till strukturen på data
  df_clean <- KDB_Uppsala %>%
    rename(kategori = 1) %>%
    mutate(år = str_extract(kategori, "\\d{4}"),
           # flag which rows are data rows
           is_data = str_detect(kategori, "^Intäkter \\d{4}")) %>%
    # fill category name downward so data rows inherit it
    mutate(kategori_clean = if_else(!is_data, kategori, NA_character_)) %>%
    fill(kategori_clean, .direction = "down") %>%
    fill(år, .direction = "down") %>%
    # now keep only the data rows
    filter(is_data) %>%
    select(-kategori, -is_data) %>%
    rename(kategori = kategori_clean) %>%
    remove_empty("cols") %>%
    relocate(år, kategori) %>%
    mutate(
      år = as.integer(år),
      `totalt i länet` = as.numeric(Uppsala),
      `Region UppsalaKulturutvecklingTotalt interna övriga` = as.numeric(`Region UppsalaKulturutvecklingTotalt interna övriga`)
    ) %>%
    select(-Uppsala) %>%
    rename(`Övriga interna` = `Region UppsalaKulturutvecklingTotalt interna övriga`)
  
  columns <- colnames(df_clean)[-(1:2)]
  
  ar <- unique(df_clean$år)
  
  # Loopar över varje kolumn
  for (c in columns) {
    # Tar ut data och ordnar efter längden på kategorin
    temp <- df_clean %>% select(år,kategori, c) %>% filter(.data[[c]] > 0) %>% mutate(kategori = reorder(kategori, desc(.data[[c]])))
    
    p <- ggplot(temp, aes(y = kategori, x = .data[[c]]))+ 
      geom_col(position = "dodge", fill = "#B81867")+
      geom_text(aes(label = scales::comma(.data[[c]])), 
                hjust = -0.1, size = 3.5) +
      scale_x_continuous(
        labels = scales::comma,
        expand = expansion(mult = c(0, 0.50))  # extra space so text isn't clipped
      )+
      labs(
        title = str_wrap(paste0("Intäkt per kategori - ",c, ", år ",ar), width = 50),
        y = NULL,
        x = "Belopp (kr)",
        caption = "Källa: Kulturdatabasen"
      ) +
      theme(axis.text.x = element_text(angle=45, hjust=1),
            plot.caption = element_text(hjust=0),
            plot.title = element_text(hjust=1),
            plot.margin =grid::unit(c(15, 35, 15, 1), "pt"),
            axis.text = element_text(size = 11),
      )
    
    p
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/intakt_bidrag_",c,".svg"),
      plot = p,
      width = 8,
      height = 6
    )
    
    ggsave(
      paste0("Figurer/intakt_bidrag_",c,".png"),
      plot = p,
      width = 8,
      height = 6,
      dpi = 96
    )
    
    
  }  
}
