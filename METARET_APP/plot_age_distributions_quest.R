## data: the rows from age_rows() in plot_age_distributions.R, already limited
## to the picked age range
plotage1 <- function(selectedquest, data) {
data %>% ggplot(aes(x=age, y=.data[[selectedquest]])) +
  geom_jitter(data = age_points(data), alpha = 0.5, color = '#87b0e8') +
  age_within_line(data, selectedquest) +
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
       y = "Choice of respondents")
}
