
### playing around with the correlation plots
library(tidyverse)
library(broom)
library(hrbrthemes)

theme_set(theme_ipsum_rc()+
            theme(legend.position = "bottom"))

## getting data from all the "formatted_dataset.csv" files in each subdirectory of /Data
df <- list.files(recursive = T, pattern = "^formatted_dataset") %>% 
  map_dfr(read_csv)

#### playground for the final plot -- commented away

## by treatment
tests <- df %>%
  nest(-paper, -task, -treatment) %>%
  mutate(
    test = map(data, ~ cor.test(.x$choice, .x$soep, method = "pearson", conf.level = 0.95)), # S3 list-col
    tidied = map(test, tidy)
  ) %>%
  unnest(tidied, .drop = TRUE)

prova <- df %>% group_by(paper, task, treatment) %>% summarise(N = n()) %>% left_join(tests, by = c("paper", "task", "treatment"))

## plot on non-transformed values
prova %>%
  filter(treatment != "repeated") %>%
  mutate(p.value = cut(p.value,
                       breaks = c(-1, 0.01, 0.05, 0.1, 1),
                       labels = c("<1%", "<5%", "<10%", "n.s."))) %>%
  mutate(treatment = paste(task, ": ", treatment, " (N = ", N, ")", sep ="")) %>%
  ggplot(aes(reorder(treatment, estimate), estimate, color= p.value))+
  geom_errorbar(aes(ymin = conf.low , ymax = conf.high), width = 0.2)+
   geom_point(size = 2)+
   coord_flip()+
   geom_hline(yintercept = 0, linetype = "dotted", color = "indianred")+
   scale_color_manual(name = "significance", values = c("red", "orange", "yellow", "black"), drop = F)
ggsave("main_META_plot_playground.png")
