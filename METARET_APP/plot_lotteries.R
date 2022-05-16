# density by task 
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
         title = paste0("Distribution of ", data$task[[1]], " task")) +
    theme_bw() + 
    theme(
      panel.background = element_rect(fill = "white"), 
      panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                      colour = "grey"), text=element_text(size=20)
    ) 
}