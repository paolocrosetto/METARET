#### Crosetto and Filippin, "The Bomb Risk Elicitation Task", JRU 2013

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_dta("Data/Crosetto_Filippin_Journal_Risk_Uncertainty_2013/Bomb_JRU.dta") %>% as_factor()

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(subject, gender, age, treatment, perc, soep, starts_with("do"))

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
df <- df %>% mutate(r = perc/(100-perc))

## Task-specific adjustments

# BRET: sometimes the computed r is /0 -> hence Inf in R --> correcting
df <- df %>% mutate(r = if_else(r == Inf, 99, r))

# BRET repeated: try something


# 
# 
# #### playground for the final plot -- commented away 
# 
# ## by treatment
# tests <- df %>% 
#   nest(-treatment) %>% 
#   mutate(
#     test = map(data, ~ cor.test(.x$perc, .x$soep, method = "pearson", conf.level = 0.95)), # S3 list-col
#     tidied = map(test, tidy)
#   ) %>% 
#   unnest(tidied, .drop = TRUE)
# 
# prova <- df %>% group_by(treatment) %>% summarise(N = n()) %>% left_join(tests, by = "treatment")
# 
# ## plot on non-transformed values
# prova %>% 
#   filter(treatment != "repeated") %>% 
#   mutate(p.value = cut(p.value, 
#                        breaks = c(-1, 0.01, 0.05, 0.1, 1), 
#                        labels = c("<1%", "<5%", "<10%", "n.s."))) %>% 
#   mutate(task = "BRET") %>% 
#   mutate(paper = "JRU2013") %>% 
#   mutate(treatment = paste(treatment, " (N = ", N, ")", sep ="")) %>% 
#   ggplot(aes(reorder(treatment,estimate), estimate, color= p.value))+
#   geom_errorbar(aes(ymin = conf.low , ymax = conf.high), width = 0.2)+
#    geom_point(size = 2)+
#    coord_flip()+
#    geom_hline(yintercept = 0, linetype = "dotted", color = "indianred")+
#    scale_color_manual(name = "significance", values = c("red", "orange", "yellow", "black"), drop = F)+
#    facet_grid(paper~task)
# ggsave("Bret_with_choices.png")
# 
# ## plot on implied r coefficients
# tests <- df %>% 
#   nest(-treatment) %>% 
#   mutate(
#     test = map(data, ~ cor.test(.x$r, .x$soep, method = "pearson", conf.level = 0.95)), # S3 list-col
#     tidied = map(test, tidy)
#   ) %>% 
#   unnest(tidied, .drop = TRUE)
# 
# prova <- df %>% group_by(treatment) %>% summarise(N = n()) %>% left_join(tests, by = "treatment")
# 
# prova %>% 
#   filter(treatment != "repeated") %>% 
#   mutate(p.value = cut(p.value, 
#                        breaks = c(-1, 0.01, 0.05, 0.1, 1), 
#                        labels = c("<1%", "<5%", "<10%", "n.s."))) %>% 
#   mutate(task = "BRET") %>% 
#   mutate(paper = "JRU2013") %>% 
#   mutate(treatment = paste(treatment, " (N = ", N, ")", sep ="")) %>% 
#   ggplot(aes(reorder(treatment,estimate), estimate, color= p.value))+
#   geom_errorbar(aes(ymin = conf.low , ymax = conf.high), width = 0.2)+
#   geom_point(size = 2)+
#   coord_flip()+
#   geom_hline(yintercept = 0, linetype = "dotted", color = "indianred")+
#   scale_color_manual(name = "significance", values = c("red", "orange", "yellow", "black"), drop = F)+
#   facet_grid(paper~task)
# ggsave("Bret_with_r.png")


