##
## Plots for the ESA Dijon presentation
## by Paolo Crosetto
## end august - beginning of september 2019
##

#### Setup ####

## Libraries
library(tidyverse)      ## basic data wrangling and plotting libraries
library(broom)          ## apply correlations to whole papers in one go
library(hrbrthemes)     ## cool ggplot theming
source("flat_violin.R") ## used for creating the 'raincloud' plot
library(ggbeeswarm)     ## quasirandom jitter

## plot theming
theme_set(theme_ipsum_rc()+
            theme(legend.position = "bottom"))

## dataset
df <- list.files(recursive = T, pattern = "^formatted_dataset") %>% 
  map_dfr(read_csv)

#### Analysis ####

#### 0. questionnaires


## across papers
acrossQuestPlot <- function(quest){
  df %>% 
    filter(!is.na({{quest}})) %>% 
    mutate(subsample = case_when(paper == "Crosetto and Filippin EXEC 2016" ~ task,
                                 paper == "Crosetto and Filippin, JRU 2013" ~ treatment,
                                 paper == "Menkhoff and Sakha 2017" ~ "",
                                 TRUE ~ "")) %>% 
    mutate(subsample = paste0(paper, ' -- ', subsample)) %>% 
    select(subsample, subject, {{quest}}) %>% 
    distinct() %>% 
    group_by(subsample) %>% 
    mutate(m = mean({{quest}}, na.rm = T),
           sd = sd({{quest}}, na.rm = T),
           se = sd/sqrt(n()),
           ci = se * qt(.95/2 + .5, n()-1),
           cih = m+ci,
           cil = m-ci) %>% 
    mutate(n = n()) %>% 
    ungroup() %>% 
    mutate(subsample = paste0(subsample, " (N = ",n,")")) %>% 
    ggplot(aes(reorder(subsample, m), {{quest}})) +
    geom_flat_violin(position = position_nudge(x = 0.15, y = 0),
                     alpha = 0.7, 
                     adjust = 0.8,
                     scale = "width",
                     fill = "grey70") +
    geom_point(alpha = 0.4,
               position = position_jitter(width = 0.12, height = 0),
               size = 0.8, show.legend = F, 
               shape = 21,
               fill = "grey70") +  
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
    # geom_hline(yintercept = 5, color = 'red', linetype = 'dashed', show.legend = F)+
    labs(y = "Likert scale answer",
         x = "")+
    theme(legend.title = element_blank(),
          legend.position = "none")+
    scale_fill_brewer(palette = "Set1")+
    scale_color_brewer(palette = "Set1")+
    coord_flip()
}

withinQuestPlot <- {
  
}

my_custom_cor <- function(data, mapping, color = I("grey50"), sizeRange = c(1, 5), ...) {
  
  # get the x and y data to use the other code
  x <- eval(mapping$x, data)
  y <- eval(mapping$y, data)
  
  ct <- cor.test(x,y)
  sig <- symnum(
    ct$p.value, corr = FALSE, na = FALSE,
    cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
    symbols = c("***", "**", "*", ".", " ")
  )
  
  r <- unname(ct$estimate)
  rt <- format(r, digits=2)[1]
  
  # since we can't print it to get the strsize, just use the max size range
  cex <- max(sizeRange)
  
  # helper function to calculate a useable size
  percent_of_range <- function(percent, range) {
    percent * diff(range) + min(range, na.rm = TRUE)
  }
  
  # plot the cor value
  ggally_text(
    label = as.character(rt), 
    mapping = aes(),
    xP = 0.5, yP = 0.5, 
    size = I(percent_of_range(cex * abs(r), sizeRange)),
    color = color,
    ...
  ) + 
    # add the sig stars
    geom_text(
      aes_string(
        x = 0.8,
        y = 0.8
      ),
      label = sig, 
      size = I(cex),
      color = color,
      ...
    ) + 
    # remove all the background stuff and wrap it with a dashed line
    theme_classic() + 
    theme(
      panel.background = element_rect(
        color = color, 
        linetype = "longdash"
      ), 
      axis.line = element_blank(), 
      axis.ticks = element_blank(), 
      axis.text.y = element_blank(), 
      axis.text.x = element_blank()
    )
}

df %>% 
  filter(!is.na(soep)) %>% 
  ggpairs(columns = c("soep", "doall"), 
          upper = list(continuous = wrap("cor", size=12)),
          lower = list(continuous = "smooth"))

#### 1. ELicited risk parameters 

## 1a: across tasks

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


# 1b: within tasks

task_variability_plot <- function(selectedtask) {
  df %>% 
    filter(task == {{selectedtask}}) %>% 
    filter(r > -1.5 & r < 2.5) %>% 
    group_by(task, paper) %>% 
    mutate(m = mean(r, na.rm = T),
           sd = sd(r, na.rm = T),
           se = sd/sqrt(n()),
           ci = se * qt(.95/2 + .5, n()-1),
           cih = m+ci,
           cil = m-ci) %>% 
    mutate(n = n()) %>% 
    ungroup() %>% 
    mutate(paper = paste0(paper, " (N = ",n,")")) %>% 
    ggplot(aes(reorder(paper,m), r)) +
    geom_flat_violin(position = position_nudge(x = 0.15, y = 0),
                     alpha = 0.7, 
                     adjust = 0.8,
                     scale = "width",
                     fill = "grey70") +
    geom_point(alpha = 0.4,
               position = position_jitter(width = 0.12, height = 0),
               size = 0.8, show.legend = F, 
               shape = 21,
               fill = "grey70") +  
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
}

task_variability_plot("EG")
task_variability_plot("IG")
task_variability_plot("BRET")
task_variability_plot("BART")
task_variability_plot("EG_loss")


#### 2. Correlation across tasks

corrdf <- df %>% 
  filter(bibkey != "Crosetto2013") %>% 
  select(-starts_with("do"), -soep, -inconsistent, -treatment,
         -age, -gender, - key, -soep_financial) %>% 
  select(-choice)

corrdf <- corrdf %>% 
  select(bibkey, subject, task, r)  %>% 
  group_by(bibkey, subject) %>% 
  mutate(n = n()) %>% 
  filter(n>1) %>% 
  # filter(!is.na(r)) %>% 
  # filter(!is.na(subject)) %>% 
  select(-n) %>% 
  # filter(r > -1.5 & r < 2.5) %>% 
  group_by(bibkey,subject) %>% 
  spread(task, r)

library(ggforce)
library(corrplot)
res1 <- cor.mtest(corrdf[,3:8], conf.level = .95)
corrplot(cor(corrdf[,3:8], use = "pairwise.complete.obs"), method = "color", type = "upper",
         na.label = "NA", addCoef.col = "black", diag = F, insig = "blank")

corrdf %>% 
  ungroup() %>% 
  filter(bibkey == "Holzmeister2019") %>% 
  select(-bibkey, -subject) %>% 
   ggplot(aes(x = .panel_x, y = .panel_y))+
   geom_jitter(alpha = 0.5)+
  geom_smooth(method = "lm")+
  geom_autodensity(fill = "grey70", alpha = 0.5)+
   facet_matrix(vars(BRET, CEPL, HL, EG), layer.diag = 3)+
   theme(panel.grid.major = element_blank(),
         panel.grid.minor = element_blank())

library(GGally)
ggpairs(corrdf, columns = c("BRET", "HL", "EG", "CEPL", "IG", "EG_loss"))


## correlation with questionnaires

