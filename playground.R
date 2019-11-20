
### playing around with the correlation plots
library(tidyverse)
library(broom)
library(hrbrthemes)
library(viridis)

theme_set(theme_ipsum_rc()+
            theme(legend.position = "bottom"))

## getting data from all the "formatted_dataset.csv" files in each subdirectory of /Data
df <- list.files(recursive = T, pattern = "^formatted_dataset") %>% 
  map_dfr(read_csv)

## save the df to the shiny director for deployment
df %>% write_csv("/home/paolo/Dropbox/METARET/METARET_github/Shiny/METARET/df.csv")

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
  # filter(bibkey == "Crosetto2016") %>% 
  ggplot(aes(r, color = task, fill = task))+
  geom_density(alpha = 0.3, adjust = 0.2)+
  coord_cartesian(xlim = c(-1,2))+
  facet_wrap(~task)

library(ggridges)

tasks <- c("IG","EG","HL",'BART',"BRET")
# tasks <- c("IG","EG")
# tasks <- "HL"
df %>% 
  filter(task %in% tasks) %>% 
  ggplot(aes(x = r, y = task, color = task, fill = task))+
  geom_density_ridges(alpha = 0.3, scale = 2, bandwidth = 0.1, from = -1.5, to = 2.5)+
  coord_cartesian(xlim = c(-1.5,2.5))+
  geom_vline(xintercept = 1, color = "red", linetype = "dashed")+
  labs(x = "risk aversion parameter r (CRRA, x^r)",
       y = "task")+
  theme(legend.title = element_blank())

## raincloud plot
source("flat_violin.R")
library(ggbeeswarm)
df %>% 
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
  mutate(task = paste0(task, " (N = ",n,")")) %>% 
  ggplot(aes(reorder(task,m), r, colour = task, fill = task)) +
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
  labs(y = "risk aversion parameter r (CRRA, x^r)",
       x = "")+
  theme(legend.title = element_blank(),
        legend.position = "none")+
  scale_fill_brewer(palette = "Set1")+
  scale_color_brewer(palette = "Set1")+
  coord_flip()
ggsave("map_elicited_r_preliminary.png", width = 10, height = 7, units = "in", dpi = 500)


## raincloud plot DR
plot_dr <- df %>% 
  filter(r > -1.2 & r < 2.2) %>% 
  filter(task != "EG_loss") %>% 
  group_by(task) %>% 
  mutate(m = mean(r, na.rm = T),
         sd = sd(r, na.rm = T),
         se = sd/sqrt(n()),
         ci = se * qt(.95/2 + .5, n()-1),
         cih = m+ci,
         cil = m-ci) %>% 
  mutate(n = n()) %>% 
  mutate(CE = round(0.5*(100)^m,1)) %>% 
  ungroup() %>% 
  mutate(task = paste0(task, " (N = ",n,")")) %>% 
  ggplot(aes(reorder(task,m), r)) +
  geom_flat_violin(position = position_nudge(x = 0.15, y = 0),
                   alpha = 0.7, 
                   adjust = 0.8,
                   scale = "width",
                   color = "grey10",
                   fill = "grey80",
                   size = 0.1) +
  geom_point(alpha = 0.4,
             position = position_jitter(width = 0.12, height = 0),
             size = 0.5, show.legend = F, 
             shape = 20) +  
  geom_boxplot(fill = 'white',
               color = 'grey30',
               width = 0.25,
               outlier.alpha = 0,
               alpha = 0) +
  # geom_errorbar(aes(ymin = cil, ymax = cih), width = 0.05, position = position_nudge(x = -0.2), show.legend = F)+
  # geom_point(aes(y = m), shape = 21, size = 2, position = position_nudge(x = -0.2), show.legend = F)+
  stat_summary(fun.data = mean_cl_boot, 
               geom = "pointrange", position = position_nudge(x = - 0.2, y = 0),
               show.legend = F,
               size = 0.5)+
  geom_hline(yintercept = 1, color = 'red', linetype = 'dashed', show.legend = F)+
  labs(y = "paramètre d'aversion au risque",
       x = "")+
  theme(legend.title = element_blank(),
        legend.position = "none")+
  scale_fill_brewer(palette = "Set1")+
  scale_color_brewer(palette = "Set1")+
  coord_flip()
plot_dr
ggsave("map_elicited_r_DR_1.png", width = 12, height = 7, units = "in", dpi = 600)


extradata <- df %>% 
  filter(r > -1.2 & r < 2.2) %>% 
  filter(task != "EG_loss") %>% 
  group_by(task) %>% 
  mutate(m = mean(r, na.rm = T),
         sd = sd(r, na.rm = T),
         se = sd/sqrt(n()),
         ci = se * qt(.95/2 + .5, n()-1),
         cih = m+ci,
         cil = m-ci) %>% 
  mutate(n = n()) %>% 
  mutate(CE = round(0.5*(100)^m,1)) %>% 
  ungroup() %>% 
  mutate(task = paste0(task, " (N = ",n,")")) %>% 
  select(task, m, CE) %>% 
  distinct()


plot_dr + geom_label(data = extradata, aes(x = reorder(task,m), y = m, label = CE), position = position_nudge(x = - 0.3, y = 0))
ggsave("map_elicited_r_DR.png", width = 12, height = 7, units = "in", dpi = 600)

## simple dot + whisker plot
df %>% 
  filter(r > -1.5 & r < 2.5) %>% 
  group_by(task) %>% 
  summarise(m = mean(r, na.rm = T),
            sd = sd(r, na.rm = T),
            se = sd/sqrt(n()),
            ci = se * qt(.95/2 + .5, n()-1),
            cih = m+ci,
            cil = m-ci) %>% 
  ggplot(aes(m, reorder(task,m), color = task, fill = task))+
  geom_point(shape = 21, size = 3)+
  geom_errorbarh(aes(xmin = cil, xmax = cih), height = 0.1)+
  theme(legend.title = element_blank())

## simple dot and whisker plot, DR
df %>% 
  filter(r > -1.5 & r < 2.5) %>% 
  filter(task != "EG_loss") %>% 
  group_by(task) %>% 
  summarise(m = mean(r, na.rm = T),
            sd = sd(r, na.rm = T),
            se = sd/sqrt(n()),
            ci = se * qt(.95/2 + .5, n()-1),
            cih = m+ci,
            cil = m-ci) %>% 
  mutate(CE = round(0.5*(100)^m,1)) %>% 
  mutate(CE = paste0(CE, "*")) %>% 
  ggplot(aes(m, reorder(task,m), label = CE))+
  geom_point(shape = 20, size = 3)+
  geom_label(position = position_nudge(y = .3))+
  geom_errorbarh(aes(xmin = cil, xmax = cih), height = 0.1)+
  labs(x = "paramètre d'aversion au risque",
       y = "",
       caption = "*equivalent certain d'une loterie qui donne 100€ une fois sur deux")+
  theme_ipsum_ps()
  # scale_x_continuous(limits = c(0,1), breaks = seq(0,1,0.2))
ggsave("explained_r_DR.png", width = 9, height = 6, units = "in", dpi = 600)
  
df %>% 
  filter(task == "BRET") %>% 
  ggplot(aes(r))+
  geom_histogram()
