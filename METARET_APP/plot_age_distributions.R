plotage <- function(selectedtask, data) {
  
  data = data %>% 
  ## Adults only used to be the rule here. Many of the contributed studies are
  ## run with schoolchildren and adolescents (Alan et al. 2019 from age 6.6,
  ## Roig et al. 2025 from 7, Aschenwald et al. 2024 and Alfonso et al. 2025
  ## from 10-11), so cutting at 18 hid about 13,000 observations. The bound is
  ## now a plausibility guard only: the youngest genuine subject in the whole
  ## dataset is 6.6, and the single value below that is one subject recorded as
  ## 2 years old in Engl et al. 2021, which cannot be a real age.
         filter(age >= 5) %>%
  select(r, age, task) %>% 
  drop_na() 

data %>% ggplot(aes(x=age, y=r)) +
  geom_jitter(alpha = 0.5, color = '#87b0e8') +
  geom_smooth(method = 'lm', formula = y ~ x) +
  theme_bw() +
  #eliminates background, gridlines, and chart border
  theme(
    text = element_text(size = 16),
    plot.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    legend.title=element_blank(),
  ) + theme(axis.line = element_line(color = 'black')) + 
  labs(x = "Age of respondents",
       y = "CRRA")
}
