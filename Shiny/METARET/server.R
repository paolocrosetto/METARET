
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
df <- read_csv("df.csv",col_types = cols(
                 .default = col_double(),
                 bibkey = col_character(),
                 paper = col_character(),
                 task = col_character(),
                 treatment = col_character(),
                 inconsistent = col_logical(),
                 key = col_character(),
                 metabibkey = col_logical(),
                 soep_financial = col_logical()
               ))

## functions to generate plots

# density by task 
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

# density within versions of each task
task_variability_plot <- function(selectedtask) {
  
  if ({{selectedtask}} != "HL") {
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
    coord_flip()}
  else {
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
      stat_summary(fun.data = mean_cl_boot, 
                 geom = "pointrange",
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
}

# correlations with questionnaires -- task level

compute_corr <- function(data, var, name, level, choicevar) {
  if (level == "task") {
    out <- data %>%
      nest(-task) %>%
      mutate(
        test = map(data, ~ cor.test(.x[[choicevar]], .x[[var]], method = "p", conf.level = 0.95)), 
        tidied = map(test, tidy)
      ) %>%
      unnest(tidied, .drop = TRUE) %>% 
      mutate(questionnaire = name)
    
  }
  if (level == "treatment"){
    out <- data %>%
      nest(-paper, -task, -treatment) %>%
      mutate(
        test = map(data, ~ cor.test(.x[[choicevar]], .x[[var]], method = "p", conf.level = 0.95)), 
        tidied = map(test, tidy)
      ) %>%
      unnest(tidied, .drop = TRUE) %>% 
      mutate(questionnaire = name)
  }
  out
}

merge_corr <- function(data, level, choicevar){
  
    # SOEP
    soep <- data %>% filter(!is.na(soep)) %>% 
      compute_corr("soep", "SOEP", level, choicevar)
    
    # DOSPERT
    dospert <- data %>% filter(!is.na(doall)) %>% 
      compute_corr("doall", "DOSPERT", level, choicevar)
    
    # DOSPERT-GAMBLE
    dogamble <- data %>% filter(!is.na(dogamble)) %>% 
      compute_corr("dogamble", "D-gamble", level, choicevar)
    
    # DOSPERT-INVESTMENT
    doinvest <-data %>% filter(!is.na(doinvest)) %>% 
      compute_corr("doinvest", "D-invest", level, choicevar)
    
    # DOSPERT-HEALTH
    dohealth <- data %>% filter(!is.na(dohealth)) %>% 
      compute_corr("dohealth", "D-health", level, choicevar)
    
    # rbind
    corr <- rbind(soep, dospert, dogamble, doinvest, dohealth) %>% 
      mutate(questionnaire = fct_relevel(as_factor(questionnaire), "SOEP", "DOSPERT"))
    
    # join  the N of observations oer study
    if (level == "task"){
    corr <- data %>% 
      group_by(task) %>% 
      summarise(N = n()) %>% 
      left_join(corr, by = c("task"))
    }
    
    if (level == "treatment"){
      corr <- data %>% 
        group_by(paper, task, treatment) %>% 
        summarise(N = n()) %>% 
        left_join(corr, by = c("paper", "task", "treatment"))      
    }
  
    corr <- corr %>% filter(!is.na(statistic))
  
    # adding "level" and "choicevar" as variable for further filtering
    corr <- corr %>%  mutate(level = level, choicevar = choicevar)
    
    # # managing the treatment = "NA" thing
    # if (level == "treatment") {
    #   corr <- corr %>% mutate(treatment = if_else(is.na(treatment), "", treatment))
    #   
    # }
    corr
}

quest_cor_plot <- function(data, inputtask, inputquestionnaire, level, choicevar) {
  
  if (level == "task") {
  out <- data %>% 
    filter(level == {{level}}) %>% 
    filter(choicevar == {{choicevar}}) %>% 
    filter(task %in% inputtask) %>% 
    filter(questionnaire %in% inputquestionnaire) %>% 
    mutate(p.value = cut(p.value,
                         breaks = c(-1, 0.01, 0.05, 0.1, 1),
                         labels = c("<1%", "<5%", "<10%", "n.s."))) %>%
    mutate(task = paste(task, ": ", " (N = ", N, ")", sep ="")) %>%
    ggplot(aes(reorder(task, estimate), estimate, color= p.value))+
    geom_errorbar(aes(ymin = conf.low , ymax = conf.high), width = 0.2)+
    geom_point(size = 2)+
    coord_flip(ylim = c(-0.3, 0.5))+
    geom_hline(yintercept = 0, linetype = "dotted", color = "indianred")+
    scale_color_manual(name = "significance", values = c("red", "orange", "yellow", "black"), drop = F)+
    scale_y_continuous(breaks = c(-0.2, 0, 0.2, 0.4), labels = c("-0.2","0","0.2","0.4"))+
    facet_grid(.~questionnaire, scales = "free_y", space = "free_y")+
    xlab("")+ylab("Pearson correlation")+
    labs(title = "Pearson correlation between risk elicitation task and questionnaire",
         subtitle = "by task")
  }
  if (level == "treatment"){
    out <- data %>% 
      filter(level == {{level}}) %>% 
      filter(choicevar == {{choicevar}}) %>% 
      filter(task %in% inputtask) %>% 
      filter(questionnaire %in% inputquestionnaire) %>% 
      mutate(p.value = cut(p.value,
                           breaks = c(-1, 0.01, 0.05, 0.1, 1),
                           labels = c("<1%", "<5%", "<10%", "n.s."))) %>%
      mutate(treatment = paste(paper, " - ", treatment, ": ", " (N = ", N, ")", sep ="")) %>%
      ggplot(aes(reorder(treatment, estimate), estimate, color= p.value))+
      geom_errorbar(aes(ymin = conf.low , ymax = conf.high), width = 0.2)+
      geom_point(size = 2)+
      coord_flip(ylim = c(-0.3, 0.5))+
      geom_hline(yintercept = 0, linetype = "dotted", color = "indianred")+
      scale_color_manual(name = "significance", values = c("red", "orange", "yellow", "black"), drop = F)+
      scale_y_continuous(breaks = c(-0.2, 0, 0.2, 0.4), labels = c("-0.2","0","0.2","0.4"))+
      facet_grid(.~questionnaire, scales = "free_y", space = "free_y")+
      xlab("")+ylab("Pearson correlation")+
      labs(title = "Pearson correlation between risk elicitation task and questionnaire",
           subtitle = "by versions of a task")
  }
  out
}


## creating needed datasets

corr_task_c <- merge_corr(df, "task", "choice")
corr_treat_c <- merge_corr(df, "treatment", "choice")
corr_task_r <- merge_corr(df, "task", "r")
corr_treat_r <- merge_corr(df, "treatment", "r")

corr_task <- rbind(corr_task_c, corr_task_r)
corr_treat <- rbind(corr_treat_c, corr_treat_r)

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
  
  output$variabilityplot <- renderPlot({
    vartask <- input$vartask
    
    task_variability_plot(vartask)
    
  })
  
  output$questplottask <- renderPlot({
    
    qlist <- input$tquest
    tlist <- input$qtask
    
    cvar <- input$choicevar
    level <- "task"
    
    quest_cor_plot(corr_task, tlist, qlist, level, cvar)
  })
  
  output$questplottreat <- renderPlot({
    qlist <- input$tquest_treat
    tlist <- input$qtask_treat
    
    cvar <- input$choicevar_treat
    level <- "treatment"
    
    quest_cor_plot(corr_treat, tlist, qlist, level, cvar)
  })
} 
)
