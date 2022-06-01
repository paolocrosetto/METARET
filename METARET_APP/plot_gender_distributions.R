colnames_given_pattern <- function(.data, pattern){
  
  suppressWarnings(names(.data)[stringr::str_detect(.data, pattern)])
  
}

plotgender <- function(selectedtask, data) {
  if (selectedtask == 'all'){
    data = data %>% 
      select(r, gender) %>% 
      drop_na() %>%
      mutate(gender = case_when(gender == 1  ~ "female",
                                gender == 0 ~ "male"))
  }
  else {
  data = data %>% 
  select(r, gender, task) %>% 
  drop_na() %>%
  mutate(gender = case_when(gender == 1  ~ "female",
                            gender == 0 ~ "male"))
  }

  mean_effect_df <- data %>%
    group_by(gender) %>%
    summarize(mean=mean(r))
  
  den1 = density(filter(data, gender == 'female')$r)
  
  coh_D = round(cohens_d(filter(data, gender == 'male')$r,
                         filter(data, gender == 'female')$r, hedges_correction == TRUE)[[1]],2)
  
  mean_diff= round(mean(filter(data, gender == 'male')$r) -
                     mean(filter(data, gender == 'female')$r),2)
  
  nonmetric_label = c(paste0("Cohen\'s d: ", coh_D),
                      paste0("Mean diff :", mean_diff)) 
  
  data %>% ggplot(aes(x=r, 
                      color=gender, 
                      fill=gender)) +
    geom_density(alpha= 0.5) + scale_fill_brewer(palette = "Paired")+
    scale_color_brewer(palette = "Paired") +
    geom_vline(data = mean_effect_df, aes(xintercept = mean, 
                                          color = gender), size=0.5) + theme_bw() +
    #eliminates background, gridlines, and chart border
    theme(
      text = element_text(size=15),
      plot.background = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      legend.title=element_blank(),
    ) +
    theme(axis.line = element_line(color = 'black')) + 
    labs(x = "Risk aversion parameter CRRA",
         y = "Density",
         title = paste0("Distribution of elicited risk attitudes using ", if (selectedtask == 'all'){"all tasks"} else {paste0(colnames_given_pattern(mychoicesgender, data$task[[1]]), ' task')}, ", by gender")) +
    annotate(geom="text", x=max(data$r), hjust = 1.1,
             y = c(max(den1$y) - 0.1*max(den1$y), max(den1$y)-0.2*max(den1$y)), 
             fontface = "bold", 
             label=nonmetric_label,
             color="black") + 
    scale_y_continuous(expand = c(0,0))+
    scale_x_continuous(expand = c(0,0))
}