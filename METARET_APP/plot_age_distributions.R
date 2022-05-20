plotage <- function(selectedtask, data) {
  
  data = data %>% 
         filter(age >= 18 & age <= 80) %>% 
  select(r, age, task) %>% 
  drop_na() %>%  
  group_by(age, task) %>% 
  summarise(r = mean(r)) 

data %>% ggplot(aes(x=age, y=r, color=task, fill = task)) +
  geom_smooth(method="auto",
              se=TRUE,
              fullrange=FALSE, 
              level=0.95,
              alpha = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2")+
  scale_color_brewer(palette = "Dark2") +
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
       y = "CRRA")+ 
  scale_y_continuous(expand = c(0,0))+
  scale_x_continuous(expand = c(0,0))
}
