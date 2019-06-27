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

setwd("..")
## getting data from all the "formatted_dataset.csv" files in each subdirectory of /Data
df <- list.files(recursive = T, pattern = "^formatted_dataset") %>% 
    map_dfr(read_csv)


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
soep <- compute_corr(df, "soep", "SOEP")

# DOSPERT
dospert <- compute_corr(df, "doall", "DOSPERT")

# DOSPERT-GAMBLE
dogamble <- compute_corr(df, "dogamble", "D-gamble")

# DOSPERT-INVESTMENT
doinvest <- compute_corr(df, "doinvest", "D-invest")

# DOSPERT-HEALTH
dohealth <- compute_corr(df, "dohealth", "D-health")

# rbind
corr <- rbind(soep, dospert, dogamble, doinvest, dohealth) %>% 
    mutate(questionnaire = fct_relevel(as_factor(questionnaire), "SOEP", "DOSPERT"))

# join  the N of observations oer study
corr <- df %>% group_by(paper, task, treatment) %>% summarise(N = n()) %>% left_join(corr, by = c("paper", "task", "treatment"))

# another stupid hack
corr <- corr %>% mutate(treatment = if_else(is.na(treatment), "", treatment))

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        corr %>%
            filter(treatment != "repeated") %>%
            mutate(p.value = cut(p.value,
                                 breaks = c(-1, 0.01, 0.05, 0.1, 1),
                                 labels = c("<1%", "<5%", "<10%", "n.s."))) %>%
            mutate(treatment = paste(treatment, " (N = ", N, ")", sep ="")) %>%
            ggplot(aes(reorder(treatment, estimate), estimate, color= p.value))+
            geom_errorbar(aes(ymin = conf.low , ymax = conf.high), width = 0.2)+
            geom_point(size = 2)+
            coord_flip()+
            geom_hline(yintercept = 0, linetype = "dotted", color = "indianred")+
            scale_color_manual(name = "significance", values = c("red", "orange", "yellow", "black"), drop = F)+
            scale_y_continuous(breaks = c(-0.2, 0, 0.2, 0.4), labels = c("-0.2","0","0.2","0.4"))+
            facet_grid(task~questionnaire, scales = "free_y", space = "free_y")+
            xlab("")+ylab("Pearson correlation")

    })

})
