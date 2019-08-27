
### playing around with the correlation plots
library(tidyverse)
library(broom)
library(hrbrthemes)

theme_set(theme_ipsum_rc()+
            theme(legend.position = "bottom"))

## getting data from all the "formatted_dataset.csv" files in each subdirectory of /Data
df <- list.files(recursive = T, pattern = "^formatted_dataset") %>% 
  map_dfr(read_csv)

## save the df to the shiny director for deployment
df %>% write_csv("home/paolo/METARET/METARET_github/Shiny/METARET/df.csv")

#### playground for the final plot -- commented away

## by treatment
tests <- df %>%
  nest(-paper, -task, -treatment) %>%
  mutate(
    test = map(data, ~ cor.test(.x$choice, .x$soep, method = "pearson", conf.level = 0.95)), # S3 list-col
    tidied = map(test, tidy)
  ) %>%
  unnest(tidied, .drop = TRUE)

prova <- df %>% 
  group_by(paper, task, treatment) %>% 
  summarise(N = n()) %>% left_join(tests, by = c("paper", "task", "treatment"))

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

## plot to visualize the 'r' parameter estimates from different tasks and treatments
df %>% 
  filter(bibkey == "Crosetto2016") %>% 
  ggplot(aes(r, color = task, fill = task))+
  geom_density(alpha = 0.3, adjust = 0.2)+
  coord_cartesian(xlim = c(-1,2))+
  facet_wrap(~task)

library(ggridges)

df %>% 
  ggplot(aes(x = r, y = task, color = task, fill = task))+
  geom_density_ridges(alpha = 0.3, bandwidth = 0.001, scale = 2)+
  coord_cartesian(xlim = c(-1.5,2.5))+
  geom_vline(xintercept = 1, color = "red", linetype = "dashed")+
  labs(x = "risk aversion parameter r (CRRA, x^r)",
       y = "task")+
  theme(legend.title = element_blank())
