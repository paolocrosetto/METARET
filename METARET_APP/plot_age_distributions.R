plotage <- function(selectedtask, data) {
  
  data = data %>% 
         filter(age >= 18) %>% 
  select(r, age, task) %>% 
  drop_na() 

data %>% ggplot(aes(x=age, y=r)) +
  geom_jitter(alpha = 0.5, color = '#87b0e8') +
  geom_smooth(method = 'lm') +
  theme_bw() +
  #eliminates background, gridlines, and chart border
  theme(
    text = element_text(size=20),
    plot.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    legend.title=element_blank(),
  ) + theme(axis.line = element_line(color = 'black')) + 
  labs(x = "Age of respondents",
       y = "CRRA")
}
