
## Libraries
library(tidyverse)      ## basic data wrangling and plotting libraries
library(broom)          ## apply correlations to whole papers in one go
library(hrbrthemes)     ## cool ggplot theming
source("flat_violin.R") ## used for creating the 'raincloud' plot
library(ggbeeswarm)     ## quasirandom jitter
library(GGally)         ## correlation plot

## theming
theme_set(theme_ipsum_rc()+
            theme(legend.position = "bottom")+
            theme(strip.text.x = element_text(hjust = 0.5))+
            theme(panel.spacing.x = unit(0.2, "lines")))

## getting data -- dirty manual hack
df <- read_csv("df.csv")

## plotting the density of elicited risk attitudes by task
plotDensity <- function(tasklist) {
  df %>% 
    filter(r > -1.5 & r < 2.5) %>% 
    filter(task %in% tasklist) %>% 
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
}

## plotting the correlations among tasks

#1. computing correlations
corrdf <- df %>% 
  filter(bibkey != "Crosetto2013") %>% 
  select(-starts_with("do"), -soep, -inconsistent, -treatment,
         -age, -gender, - key, -soep_financial)

#2. choosing r or choices
corr_choice <- corrdf %>% 
  select(bibkey, subject, task, choice)  %>% 
  group_by(bibkey, subject) %>% 
  mutate(n = n()) %>% 
  filter(n>1) %>% 
  # filter(!is.na(r)) %>% 
  # filter(!is.na(subject)) %>% 
  select(-n) %>% 
  # filter(r > -1.5 & r < 2.5) %>% 
  group_by(bibkey,subject) %>% 
  spread(task, choice)
  
corr_r <- corrdf %>% 
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


shinyServer(function(input, output){
  
  output$markdown <- renderUI({
    
    mdfile <- read_file(paste0("./md/", input$RET, ".md"))
    HTML(markdown::markdownToHTML(text = mdfile))
  })
  
  output$density <- renderPlot({
    
    tasklist <- input$task
    
    plotDensity(tasklist)
    
  })
  
  output$corrplot <- renderPlot({
    if (input$r_or_choice == "r") {
     dataset <- corr_r
    }
    if (input$r_or_choice == "choice") {
     dataset <- corr_choice
    }
    ggpairs(dataset, columns = input$corrtask)
  })
} 
)
