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
  
  ## one colour per task; the list held 9 colours, so with 10 tasks the last one
  ## in the order (BERP) got NA and was drawn invisible
  palette <- c(brewer.pal(8,"Dark2"), '#632d00', '#1f5f8b', '#8c2d6b', '#4d4d4d')
  values = palette[1:length(levels(data$task))]
  names(values) <- levels(data$task)
  
  ## Built straight on the selected tasks. It used to be built on labels with
  ## "(N = ...)" appended and then given new data with %+% (deprecated in
  ## ggplot2 4.0), which threw those labels away -- so the picture is the same.
  plot <- droplevels(data[data$task %in% tasklist, ]) %>%
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
      text = element_text(size = 16),
      plot.background = element_blank(),
      panel.background = element_rect(fill = "white"), 
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      ## the legend read "task" over a list of task names -- the heading said
      ## nothing the entries did not already say, so it goes
      legend.title = element_blank(),
      legend.text = element_text(size = 16),
      legend.key = element_blank(),
      legend.key.size = unit(1.5, "lines"),
      legend.background = element_blank(),
      ## along the bottom rather than down the right: the panel is taller than
      ## it is wide, so a side legend was stealing width from the densities
      legend.position = "bottom",
      legend.direction = "horizontal",
      legend.margin = margin(t = 6),
      legend.spacing.x = unit(14, "pt")
    ) +
    ## two rows once there are more than five tasks, or the legend runs off the panel
    guides(fill  = guide_legend(nrow = ifelse(length(tasklist) > 5, 2, 1), byrow = TRUE,
                                override.aes = list(alpha = 1, colour = NA)),
           color = "none") +
    
    #draws x and y axis line
    theme(axis.line = element_line(color = 'black')) +
    coord_flip() 
  
  plot +
    scale_fill_manual(values = values)+
    scale_color_manual(values = values)
}
