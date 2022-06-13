# density by task 

colnames_given_pattern <- function(.data, pattern){
  
  suppressWarnings(names(.data)[stringr::str_detect(.data, pattern)])
  
}


plotDensity <- function(task, data) {
  
  data <- data %>% 
    filter(r > -1.5 & r < 2.5) %>% 
    mutate(m = mean(r, na.rm = T)) %>% 
    mutate(n = n()) 
  
  data %>% 
    ggplot(aes(x = r)) +
    geom_density(color="white", fill="orange", alpha = 0.7, 
                 adjust = 0.8)  + 
    geom_boxplot(fill = 'white',
                 color = 'grey30',
                 width = 0.25,
                 outlier.alpha = 0,
                 alpha = 0) +
    geom_jitter(aes(r,0), height = 0.1, color = 'purple', size = 0.1, alpha = 0.3) +
    geom_vline(xintercept = 1, color = 'red', linetype = 'dashed', show.legend = F) +
    labs(x = "Risk aversion parameter CRRA",
         y = "Density",
         title = paste0("Distribution of elicited risk attitudes for the ", colnames_given_pattern(mychoices, data$task[[1]]), " task")) +
    theme_bw() + 
    theme(
      text = element_text(size=15),
      plot.background = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank()
    ) +
    
    #draws x and y axis line
    theme(axis.line = element_line(color = 'black'))
  
}