acrossQuestPlot <- function(data){
  data %>% 
    ggplot(aes(reorder(subsample, m), choice)) +
    # geom_flat_violin(position = position_nudge(x = 0.15, y = 0),
    #                  alpha = 0.7, 
    #                  adjust = 0.8,
    #                  scale = "width",
    #                  fill = "grey70") +
    # geom_point(alpha = 0.4,
    #            position = position_jitter(width = 0.12, height = 0),
    #            size = 0.8, show.legend = F, 
    #            shape = 21,
    #            fill = "grey70") +  
    # geom_boxplot(fill = 'white',
  #              color = 'grey30',
  #              width = 0.25,
  #              outlier.alpha = 0,
  #              alpha = 0) +
  # geom_errorbar(aes(ymin = cil, ymax = cih), width = 0.05, position = position_nudge(x = -0.2), show.legend = F)+
  # geom_point(aes(y = m), shape = 21, size = 2, position = position_nudge(x = -0.2), show.legend = F)+
  stat_summary(fun.data = mean_cl_boot, 
               geom = "pointrange", position = position_nudge(x = 0, y = 0),
               show.legend = F)+
    # geom_hline(yintercept = 5, color = 'red', linetype = 'dashed', show.legend = F)+
    labs(y = "Likert scale answer",
         x = "")+
    theme(legend.title = element_blank(),
          legend.position = "none")+
    scale_fill_brewer(palette = "Set1")+
    scale_color_brewer(palette = "Set1")+
    coord_flip()
}