
########### kommunens köp av kultur och fritid totalt, andel #######

kop_kf <- function(){
  
  # Läser in data
  df <- read.csv("Data/df_kop_kf.csv")
  
  # Rensar titlar
  df$title <- gsub(", andel \\(%\\)", "", df$title )
  
  df <- df %>% mutate(Aktor = case_when(
    grepl("totalt", title, ignore.case = TRUE) ~ "Totalt",
    grepl("offentlig", title, ignore.case = TRUE) ~ "Offentlig utförare",
    grepl("privata utförare", title, ignore.case = TRUE) ~ "Privat utförare",
    grepl("privatägda", title, ignore.case = TRUE) ~ "Privatägda företag",
    TRUE ~ NA_character_
  )) %>% filter(Aktor != "Totalt")
  
  
  cols <- c("#F9B000" , "#019CD7" ,"#D57667" , "#4AA271")
  
  # Skapar en plot per kommun
  for (r in kommuner) {
    # temporär data
    temp <- df %>%  filter(municipality ==r)
    
    p <- ggplot(temp, aes(x=year, y=value, color= Aktor))+ 
      geom_line(linewidth=2, alpha=0.7) + geom_point(size=3)+ 
      scale_color_manual(values=cols)+
      scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 2))+
      labs(title=str_wrap(paste("Kommunens köp av kultur och fritid i", r),width=50),
           x="",
           y="Andel (%)",
           color="",
           caption = "Källa: Kulturrådet")+ 
      theme(legend.position="bottom",
            axis.text.x = element_text(angle=45),
            plot.caption = element_text(hjust=0))
    
    p
    
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/kop_kf_",r, ".svg"),
      plot = p,
      width = 8,
      height = 7
    )
    
    ggsave(
      paste0("Figurer/kop_kf_",r,  ".png"),
      plot = p,
      width = 8,
      height = 7,
      dpi = 96
    )
  }
  
}




####### Syssel kolada #######

syssel_kol <- function(){
  # Hämtar data
  df <- read.csv("Data/df_sysselkolada.csv") %>% filter(gender != "T")
  
  # Rensar titlar
  df$title <- gsub(", andel \\(%\\)", "", df$title )
  # beroende på titel
  df$index <- ifelse(grepl("efter arbetsställets belägenhet", df$title), "Arbetsställets belägenhet","Bostadens belägenhet")
  df$title <- gsub(" m.m., efter arbetsställets belägenhet", "", df$title )
  df$title <- gsub(" m.m., efter bostadens belägenhet", "", df$title )
  
  df$gender <- ifelse(df$gender =="M", "Män", "Kvinnor")
  
  # Värden till y-axlar
  max_y <- (max(df$value))
  
  kon_col <- c("Män" = "#4AA271",
               "Kvinnor" = "#D57667")
  
  # loopar över kommuner
  for (r in kommuner) {
    
    # tar ut kommun
    temp <- df %>% filter(municipality ==r)
    
    # skapar plot
    p <- ggplot(temp, aes(x=year,y=value,color=gender))+
      geom_line(linewidth=2)+geom_point(size=3)+ facet_wrap(~index, ncol=1)+
      scale_color_manual(values=kon_col)+
      ylim(0, max_y+0.5)+
      labs(x="",
           y="Andel (%)",
           title = str_wrap(paste(unique(temp$title), "i", r), width=50),
           color ="",
           caption="Källa: SCB - Befolkningens arbetsmarknadsstatus (BAS)")+
      theme(plot.caption = element_text(hjust=0))
    
    print(p)
    
    # Sparar plot 
    ggsave(
      paste0("Figurer/syssel_kol_",r, ".svg"),
      plot = p,
      width = 8,
      height = 7
    )
    
    ggsave(
      paste0("Figurer/syssel_kol_", r, ".png"),
      plot = p,
      width = 8,
      height = 7,
      dpi = 96
    )
    
  }
  
}


deltagande<- function(){
  # Hämtar data
  df <- read.csv("Data/df_deltagande.csv")
  
  # Rensar titlar
  df$title <- gsub(", andel \\(%\\)", "", df$title )
  
  # Variabel för färg
  df$index <- ifelse(df$municipality=="Region Uppsala", "1","0")
  
  # Byter från region till län
  df$municipality <- ifelse(
    df$municipality == "Region Uppsala",
    "Uppsala län",
    sub("Region (.*)", "\\1s län", df$municipality)
  )
  
  # Färger
  col <- c("1"="#B81867",
           "0"= "grey")
  
  # text
  label_df <- df %>%
    filter(year == max(year)) %>%
    mutate(
      is_max = value == max(value, na.rm = TRUE),
      is_min = value == min(value, na.rm = TRUE),
      is_region = index == 1
    ) %>%
    filter(is_max | is_min | is_region)
  
  p <- ggplot(
    df,
    aes(
      x = year,
      y = value,
      color = index,
      group = municipality,
      linewidth = index,
      size = index
    )
  ) +
    geom_line() +
    geom_point() +
    scale_color_manual(values = col) +
    scale_x_continuous(breaks = seq(min(df$year), max(df$year), by = 2))+
    scale_linewidth_manual(values = c("0" = 1, "1" = 2)) + # olika linje / pointstorlekar
    scale_size_manual(values = c("0" = 2, "1" = 3)) +
    ylim(0,50)+
    coord_cartesian(clip = "off") +
    geom_text(
      data = label_df,
      aes(label = municipality),
      size = 4.5,
      show.legend = FALSE,
      nudge_x = 1.5
    )+
    labs(
      x = "",
      y = "Andel (%)",
      color = "",
      title = str_wrap(paste("Deltagarandel inom kultur i Sverige"), width=50),
      caption = "Källa: Folkhälsomyndigheten"
    ) + theme(plot.caption = element_text(hjust = 0),
              plot.subtitle = element_text(hjust = 0.5),
              legend.position = "none",
              plot.margin =grid::unit(c(15, 70, 15, 15), "pt"))
  
  
  
  print(p)
  # Sparar plot 
  ggsave(
    paste0("Figurer/deltagande.svg"),
    plot = p,
    width = 8,
    height = 6
  )
  
  ggsave(
    paste0("Figurer/deltagande.png"),
    plot = p,
    width = 8,
    height = 6,
    dpi = 96
  )
  
}

