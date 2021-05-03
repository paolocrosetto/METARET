# correlations with questionnaires -- task level

compute_corr <- function(data, var, name, level, choicevar) {
  if (level == "task") {
    out <- data %>%
      group_by(task) %>% 
      nest() %>%
      mutate(
        test = map(data, ~ cor.test(.x[[choicevar]], .x[[var]], method = "p", conf.level = 0.95)), 
        tidied = map(test, tidy)
      ) %>%
      unnest(tidied, .drop = TRUE) %>% 
      mutate(questionnaire = name)
    
  }
  if (level == "treatment"){
    out <- data %>% 
      group_by(paper, task, treatment) %>% 
      nest() %>% 
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
      geom_text(aes(label = round(estimate, 2)), color = "black", size = 8, position = position_nudge(x = 0.1))+
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
      geom_text(aes(label = round(estimate, 2)), color = "black", size = 8, position = position_nudge(x = 0.1))+
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
  filter(bibkey != "Gnambs2015") %>% 
  #filter(task != "BART") %>% 
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