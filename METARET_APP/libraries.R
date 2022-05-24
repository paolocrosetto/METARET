## Libraries
library(shiny)
library(shinyjs)
library(shiny.semantic)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
library(semantic.dashboard)
library(shinipsum)
library(babynames)
library(DT)
library(tidyverse)      ## basic data wrangling and plotting libraries
library(broom)          ## apply correlations to whole papers in one go
library(hrbrthemes)     ## cool ggplot theming
library(ggbeeswarm)     ## quasirandom jitter
library(GGally)         ## correlation plot
library(RColorBrewer)   ## colors
library(dplyr)    
library(bib2df) 
source("flat_violin.R")
library(corrmorant)
library(corrplot)
library(circlize)
library(effectsize)

## list for the task choices 
mychoices = c("Holt and Laury" = "HL",
              "Binswanger / Eckel and Grossmann" = "EG",
              "Investment Game" = "IG",
              "Bomb Risk Elicitation Task" = "BRET",
              "Balloon Analog Risk Task" = "BART",
              "Certainty equivalent price list" = "CEPL",
              'Balloon Economic Risk Protocol'='BERP', 
              'Binswanger / Eckel and Grossmann with probability of loss'= 'EG_loss')

mychoicesgender = c("All tasks" = "all", 
                    "Holt and Laury" = "HL",
              "Binswanger / Eckel and Grossmann" = "EG",
              "Investment Game" = "IG",
              "Bomb Risk Elicitation Task" = "BRET",
              "Balloon Analog Risk Task" = "BART",
              #"Certainty equivalent price list" = "CEPL",
              'Balloon Economic Risk Protocol'='BERP')
              #'Binswanger / Eckel and Grossmann with probability of loss'= 'EG_loss')

## list for the question choices 
questionchoice <- c("SOEP" = "soep",
                    "SOEP - financial" = "soep_financial",
                    "DOSPERT" = "doall",
                    "DOSPERT - health" = "dohealth",
                    "DOSPERT - social" = "dosocial",
                    "DOSPERT - investment" = "doinvest",
                    "DOSPERT - gamble" = "dogamble",
                    "DOSPERT - ethic" = "doethic",
                    "DOSPERT - recreation" = "dorecre")


questionchoice_gender <- c("SOEP" = "soep",
                    #"SOEP - financial" = "soep_financial",
                    "DOSPERT" = "doall",
                    "DOSPERT - health" = "dohealth",
                    "DOSPERT - social" = "dosocial",
                    "DOSPERT - investment" = "doinvest",
                    "DOSPERT - gamble" = "dogamble",
                    "DOSPERT - ethic" = "doethic",
                    "DOSPERT - recreation" = "dorecre")

