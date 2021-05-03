task_variability_plot <- function(selectedtask) {
  
  if ({{selectedtask}} != "HL") {
    df %>% 
      filter(task == {{selectedtask}}) %>% 
      filter(r > -1.5 & r < 2.5) %>% 
      group_by(task, paper) %>% 
      mutate(m = mean(r, na.rm = T),
             sd = sd(r, na.rm = T),
             se = sd/sqrt(n()),
             ci = se * qt(.95/2 + .5, n()-1),
             cih = m+ci,
             cil = m-ci) %>% 
      mutate(n = n()) %>% 
      ungroup() %>% 
      mutate(paper = paste0(paper, " (N = ",n,")")) %>% 
      ggplot(aes(reorder(paper,m), r)) +
      geom_flat_violin(position = position_nudge(x = 0.15, y = 0),
                       alpha = 0.7, 
                       adjust = 0.8,
                       scale = "width",
                       fill = "grey70") +
      geom_point(alpha = 0.4,
                 position = position_jitter(width = 0.12, height = 0),
                 size = 0.8, show.legend = F, 
                 shape = 21,
                 fill = "grey70") +  
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
      scale_fill_brewer(palette = "Set1")+
      scale_color_brewer(palette = "Set1")+
      coord_flip()}
  else {
    df %>% 
      filter(task == {{selectedtask}}) %>% 
      filter(r > -1.5 & r < 2.5) %>% 
      group_by(task, paper) %>% 
      mutate(m = mean(r, na.rm = T),
             sd = sd(r, na.rm = T),
             se = sd/sqrt(n()),
             ci = se * qt(.95/2 + .5, n()-1),
             cih = m+ci,
             cil = m-ci) %>% 
      mutate(n = n()) %>% 
      ungroup() %>% 
      mutate(paper = paste0(paper, " (N = ",n,")")) %>% 
      ggplot(aes(reorder(paper,m), r)) +
      stat_summary(fun.data = mean_cl_boot, 
                   geom = "pointrange",
                   show.legend = F)+
      geom_hline(yintercept = 1, color = 'red', linetype = 'dashed', show.legend = F)+
      labs(y = "risk aversion parameter r (CRRA, x^r)",
           x = "")+
      theme(legend.title = element_blank(),
            legend.position = "none")+
      scale_fill_brewer(palette = "Set1")+
      scale_color_brewer(palette = "Set1")+
      coord_flip()
  }
}