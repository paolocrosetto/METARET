  
  ## Libraries
  library(tidyverse)      ## basic data wrangling and plotting libraries
  library(broom)          ## apply correlations to whole papers in one go
  library(hrbrthemes)     ## cool ggplot theming
  source("flat_violin.R") ## used for creating the 'raincloud' plot
  library(ggbeeswarm)     ## quasirandom jitter
  library(GGally)         ## correlation plot
  library(RColorBrewer)   ## colors
  
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
                   metabibkey = col_character(),
                   soep_financial = col_double()
                 ))
  
  ## import functions to generate plots
  source("Analysis/across_task_density_plot.R")
  source("Analysis/within_task_density_plot.R")
  source("Analysis/prepare_questionnaire_data.R")
  source("Analysis/across_questionnaire_plot.R")
  source("Analysis/correlations.R")

dfsoep <- preparedata(df, soep)
dfdoall <- preparedata(df, doall)
dfdogamble <- preparedata(df, dogamble)
dfdoinvest <- preparedata(df, doinvest)
dfdohealth <- preparedata(df, dohealth)

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
    ggpairs(dataset, 
            columns = input$corrtask, 
            lower = list(continuous = "smooth", na = "blank"),
            upper = list(continuous = wrap("cor", size=12)), na = "blank")
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
  
  output$distquestplot <- renderPlot({
    dq <- input$distquest
    
    if (dq == "soep") {
      out <- acrossQuestPlot(dfsoep)
    }
    if (dq == "doall") {
      out <- acrossQuestPlot(dfdoall)
    }
    if (dq == "dogamble") {
      out <- acrossQuestPlot(dfdogamble)
    }
    if (dq == "doinvest") {
      out <- acrossQuestPlot(dfdoinvest)
    }
    if (dq == "dohealth") {
      out <- acrossQuestPlot(dfdohealth)
    }
    out
  })
  
  output$corquestplot <- renderPlot({
    cq <- input$corquest
    
    df %>% 
      ggpairs(columns = cq, 
              upper = list(continuous = wrap("cor", size=12)),
              lower = list(continuous = "smooth"))
  })
} 
)