colnames_given_pattern <- function(.data, pattern){
  
  suppressWarnings(names(.data)[stringr::str_detect(.data, pattern)])
  
}

plotDensity2 <- function(tasklist, data) {
  data %>% 
    ggplot(aes(x = values)) +
    geom_density(color="white", fill="orange", alpha = 0.7, 
                 adjust = 0.8)  + 
    geom_boxplot(fill = 'white',
                 color = 'grey30',
                 width = 0.1,
                 outlier.alpha = 0,
                 alpha = 0) +
    geom_jitter(aes(values,0), height = 0.05, color = 'green', size = 0.05) +
    labs(x = "Choices",
         y = "Density",
         title = paste0("Distribution of answers for the ", colnames_given_pattern(questionchoice, data$name[1]), " questionnaire")) + 
    theme(
      text = element_text(size=15),
      plot.background = element_blank(),
      panel.background = element_rect(fill = "white"), 
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank()
    ) +
    
    #draws x and y axis line
    theme(axis.line = element_line(color = 'black'))
}