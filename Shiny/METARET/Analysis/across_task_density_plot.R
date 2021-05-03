plotDensity <- function(tasklist) {
  
  data <- df %>% 
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
  
  values <- c(rev(brewer.pal(length(levels(data$task)), "Set1")))
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
    stat_summary(fun.data = mean_cl_boot, 
                 geom = "pointrange", position = position_nudge(x = - 0.2, y = 0),
                 show.legend = F)+
    geom_hline(yintercept = 1, color = 'red', linetype = 'dashed', show.legend = F)+
    labs(y = "risk aversion parameter r (CRRA, x*r)",
         x = "")+
    theme(legend.title = element_blank(),
          legend.position = "none")+
    coord_flip()
  
  plot %+% droplevels(data[data$task %in% tasklist,]) +
    scale_fill_manual(values = values)+
    scale_color_manual(values = values)
}