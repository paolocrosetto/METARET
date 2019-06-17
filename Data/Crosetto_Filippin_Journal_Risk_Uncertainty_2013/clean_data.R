#### Crosetto and Filippin, "The Bomb Risk Elicitation Task", JRU 2013

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)
library(hrbrthemes)


##
theme_set(theme_ipsum_rc())


#### getting the data
df <- read_dta("Data/Crosetto_Filippin_Journal_Risk_Uncertainty_2013/Bomb_JRU.dta") %>% as_factor()


df <- df %>% select(subject, gender, age, treatment, rep, period, perc, soep, starts_with("do"))

## by treatment
tests <- df %>% 
  nest(-treatment) %>% 
  mutate(
    test = map(data, ~ cor.test(.x$perc, .x$soep, method = "pearson", conf.level = 0.95)), # S3 list-col
    tidied = map(test, tidy)
  ) %>% 
  unnest(tidied, .drop = TRUE)

prova <- df %>% group_by(treatment) %>% summarise(N = n()) %>% left_join(tests, by = "treatment")

prova %>% 
  filter(treatment != "repeated") %>% 
  mutate(p.value = cut(p.value, 
                       breaks = c(-1, 0.01, 0.05, 0.1, 1), 
                       labels = c("<1%", "<5%", "<10%", "n.s."))) %>% 
  mutate(task = "BRET") %>% 
  mutate(paper = "JRU2013") %>% 
  mutate(treatment = paste(treatment, " (N = ", N, ")", sep ="")) %>% 
  ggplot(aes(reorder(treatment,estimate), estimate, color= p.value))+
  geom_errorbar(aes(ymin = conf.low , ymax = conf.high), width = 0.2)+
   geom_point(size = 2)+
   coord_flip()+
   geom_hline(yintercept = 0, linetype = "dotted", color = "indianred")+
   scale_color_manual(name = "significance", values = c("red", "orange", "yellow", "black"))+
   facet_grid(paper~task)

## putting it all together
tests <- df %>% 
  nest() %>% 
  mutate(
    test = map(data, ~ cor.test(.x$perc, .x$soep, method = "pearson", conf.level = 0.95)), # S3 list-col
    tidied = map(test, tidy)
  ) %>% 
  unnest(tidied, .drop = TRUE)

