source("flat_violin.R")

# density by task 
plotDensity1 <- function(tasklist, data) {
  
  data <- data %>% 
    filter(r > -1.5 & r < 2.5) %>% 
    group_by(task) %>% 
    mutate(m = mean(r, na.rm = T),
           sd = sd(r, na.rm = T),
           se = sd/sqrt(n()),
           ci = se * qt(.95/2 + .5, n()-1),
           cih = m+ci,
           cil = m-ci) %>% 
    mutate(n = n()) %>% 
    ungroup() %>% 
    mutate(task = reorder(task,r))
  
  values = c(brewer.pal(8,"Dark2"), '#632d00')[1:length(levels(data$task))]
  names(values) <- levels(data$task)
  
  plot <- data %>% 
    mutate(task = paste0(task, " (N = ",n,")")) %>% 
    ggplot(aes(task, r, colour = task, fill = task)) +
    geom_flat_violin(position = position_nudge(x = 0.15, y = 0),
                     alpha = 0.7, 
                     adjust = 0.8,
                     scale = "width",
                     color = "white") +
    geom_point(alpha = 0.4,
               position = position_jitter(width = 0.12, height = 0),
               size = 0.8, show.legend = F, 
               shape = 21,
               color = "white") +  
    geom_boxplot(fill = 'white',
                 color = 'grey30',
                 width = 0.25,
                 outlier.alpha = 0,
                 alpha = 0) +
    # geom_errorbar(aes(ymin = cil, ymax = cih), width = 0.05, position = position_nudge(x = -0.2), show.legend = F)+
    # geom_point(aes(y = m), shape = 21, size = 2, position = position_nudge(x = -0.2), show.legend = F)+
    
    geom_hline(yintercept = 1, color = 'red', linetype = 'dashed', show.legend = F)+
    labs(y = "Risk aversion parameter CRRA",
         x = "")+
    theme(
      text = element_text(size=15),
      plot.background = element_blank(),
      panel.background = element_rect(fill = "white"), 
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank()
    ) +
    
    #draws x and y axis line
    theme(axis.line = element_line(color = 'black')) +
    coord_flip() 
  
  plot %+% droplevels(data[data$task %in% tasklist,]) +
    scale_fill_manual(values = values)+
    scale_color_manual(values = values)
}
