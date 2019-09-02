#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(broom)
library(hrbrthemes)

theme_set(theme_ipsum_rc()+
              theme(legend.position = "bottom")+
              theme(strip.text.x = element_text(hjust = 0.5))+
              theme(panel.spacing.x = unit(0.2, "lines")))


## getting data -- dirty manual hack
df <- read_csv("df.csv")


## TODO/ need to automate this in a function, adn don't know how. MESSY!
compute_corr <- function(data, var, name) {
    data %>%
        nest(-paper, -task, -treatment) %>%
        mutate(
            test = map(data, ~ cor.test(.x$choice, .x[[var]], method = "pearson", conf.level = 0.95)), 
            tidied = map(test, tidy)
        ) %>%
        unnest(tidied, .drop = TRUE) %>% 
        mutate(questionnaire = name)
}


# SOEP
soep <- df %>% filter(!is.na(soep)) %>% 
    compute_corr("soep", "SOEP")

# DOSPERT
dospert <- df %>% filter(!is.na(doall)) %>% 
    compute_corr("doall", "DOSPERT")

# DOSPERT-GAMBLE
dogamble <- df %>% filter(!is.na(dogamble)) %>% 
    compute_corr("dogamble", "D-gamble")

# DOSPERT-INVESTMENT
doinvest <- df %>% filter(!is.na(doinvest)) %>% 
    compute_corr("doinvest", "D-invest")

# DOSPERT-HEALTH
dohealth <- df %>% filter(!is.na(dohealth)) %>% 
    compute_corr("dohealth", "D-health")

# rbind
corr <- rbind(soep, dospert, dogamble, doinvest, dohealth) %>% 
    mutate(questionnaire = fct_relevel(as_factor(questionnaire), "SOEP", "DOSPERT"))

# join  the N of observations oer study
corr <- df %>% 
    group_by(paper, task, treatment) %>% 
    summarise(N = n()) %>% 
    left_join(corr, by = c("paper", "task", "treatment"))

# another stupid hack
corr <- corr %>% mutate(treatment = if_else(is.na(treatment), "", treatment))

##function that uses input from the UI to subset the task and give out details

plotcor <- function(inputtask, inputquestionnaire) {
    
    if (inputtask == "all" & inputquestionnaire == "all") {
        plotdf <- corr %>%
            filter(treatment != "repeated")
    }
    
    if (inputtask != "all" & inputquestionnaire != "all") {
        plotdf <- corr %>%
            filter(treatment != "repeated") %>%
            filter(task == inputtask, questionnaire == inputquestionnaire)
    }
    
    if (inputtask == "all" & inputquestionnaire != "all") {
        plotdf <- corr %>%
            filter(treatment != "repeated") %>%
            filter(questionnaire == inputquestionnaire)
    }
    if (inputtask != "all" & inputquestionnaire == "all") {
        plotdf <- corr %>%
            filter(treatment != "repeated") %>%
            filter(task == inputtask)
    }
    
    plotdf %>% 
        mutate(p.value = cut(p.value,
                             breaks = c(-1, 0.01, 0.05, 0.1, 1),
                             labels = c("<1%", "<5%", "<10%", "n.s."))) %>%
        mutate(treatment = paste(paper, ": ", treatment, " (N = ", N, ")", sep ="")) %>%
        ggplot(aes(reorder(treatment, estimate), estimate, color= p.value))+
        geom_errorbar(aes(ymin = conf.low , ymax = conf.high), width = 0.2)+
        geom_point(size = 2)+
        coord_flip(ylim = c(-0.3, 0.5))+
        geom_hline(yintercept = 0, linetype = "dotted", color = "indianred")+
        scale_color_manual(name = "significance", values = c("red", "orange", "yellow", "black"), drop = F)+
        scale_y_continuous(breaks = c(-0.2, 0, 0.2, 0.4), labels = c("-0.2","0","0.2","0.4"))+
        facet_grid(task~questionnaire, scales = "free_y", space = "free_y")+
        xlab("")+ylab("Pearson correlation")+
        labs(title = "Spearman correlation between risk elicitation task and questionnaire",
             subtitle = "by versions of the task")
    
}

## function that generates the description for each task 

describe <- function(taskorquest) {
    out <- "mamama"
    if (taskorquest == "all") {
        out <- ""
    }
    if (taskorquest == "BRET") {
        out <- "The BRET was developed by XXX.... The BRET was developed by XXX.... The BRET was developed by XXX.... The BRET was developed by XXX.... The BRET was developed by XXX....The BRET was developed by XXX.... "
    }
    if (taskorquest == "HL") {
        out <- "The HL task was developed by Charles Holt and Susan K Laury in 2002 AER..."
    }
 out   
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        task <- input$task
        questionnaire <- input$questionnaire
        
        plotcor(task, questionnaire)

    })
    
    output$description <- renderText(describe(input$task))

})
