## Libraries
## Attached quietly: otherwise every start prints some sixty lines of "The
## following objects are masked" notes, the tidyverse banner and the spData and
## sf hints, which bury any real warning in the log.
suppressPackageStartupMessages({
library(shiny)
library(shinyjs)
library(shiny.semantic)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
library(semantic.dashboard)
library(DT)
library(tidyverse)      ## basic data wrangling and plotting libraries
library(RColorBrewer)   ## colors
library(dplyr)
source("flat_violin.R")
library(corrplot)
library(effectsize)     ## cohens_d, used by the gender distribution plots
library(markdown)
library(spData)  # world country polygons for the map
library(sf)      # spData::world is an sf object
library(ggplot2) # tidyverse data visualization package
library(leaflet) # tmap's interactive backend; leaflet::providers used in server.R
})


## Packages that used to be attached here but are never called. Dropped to cut
## the cold start from 4.8 s to 1.2 s -- put a line back if you start using one.
##   rbokeh                -- only used by map_crra_function.R, which is gone
##                            (and archived from CRAN, so it no longer installs)
##   shinipsum, babynames  -- leftovers from a dashboard template
##   broom, hrbrthemes, ggbeeswarm, GGally, circlize  -- no call remains
##   tmap                  -- the map is leaflet now; tmap was attached for its
##                            World dataset alone. spData::world replaces it.
##   corrmorant            -- the panels are drawn by corrplot from
##                            DATA/corr_cache.rds. Worth keeping out: it is not
##                            on CRAN and had to be installed by hand.
##   bib2df                -- the bibliography is parsed by Data/build_app_data.R
##                            and the app reads DATA/app_data.rds.

## list for the task choices 
mychoices = c("Holt and Laury" = "HL",
              "Binswanger / Eckel and Grossmann" = "EG",
              "Investment Game" = "IG",
              "Bomb Risk Elicitation Task" = "BRET",
              "Balloon Analog Risk Task" = "BART",
              "Certainty equivalent price list" = "CEPL",
              "Certainty equivalent staircase" = "CE_staircase",
              'Balloon Economic Risk Protocol'='BERP', 
              'Binswanger / Eckel and Grossmann with probability of loss'= 'EG_loss',
              'Payoff Varying Task' = "PV")

mychoicesgender = c("All tasks" = "all", 
                    "Holt and Laury" = "HL",
              "Binswanger / Eckel and Grossmann" = "EG",
              "Investment Game" = "IG",
              "Bomb Risk Elicitation Task" = "BRET",
              "Balloon Analog Risk Task" = "BART",
              "Certainty equivalent price list" = "CEPL",
              "Certainty equivalent staircase" = "CE_staircase",
              'Balloon Economic Risk Protocol'='BERP',
              'Payoff Varying Task' = "PV")
              #'Binswanger / Eckel and Grossmann with probability of loss'= 'EG_loss')

## list for the question choices 
questionchoice <- c("SOEP" = "soep",
                    "SOEP - financial" = "soep_financial",
                    "SOEP - patience" = "soep_patience",
                    "SOEP - impulsive" = "soep_impulsive",
                    "DOSPERT" = "doall",
                    "DOSPERT - health" = "dohealth",
                    "DOSPERT - social" = "dosocial",
                    "DOSPERT - investment" = "doinvest",
                    "DOSPERT - gamble" = "dogamble",
                    "DOSPERT - ethic" = "doethic",
                    "DOSPERT - recreation" = "dorecre", 
                    "Barratt impulsiveness scale" = 'BIS',
                    "Brief Sensation seeking scale" = 'BSSS',
                    'Alcohol Use DIsorders Test' = 'AuditS',
                    'Youth Risk Behavior Surveillance (risk)' = 'CDCrisk')

## list for the question choices 
questionchoice_cor <- c("SOEP" = "soep",
                    "SOEP - financial" = "soep_financial",
                    #"SOEP - patience" = "soep_patience",
                    #"SOEP - impulsive" = "soep_impulsive",
                    "DOSPERT" = "doall",
                    "DOSPERT - health" = "dohealth",
                    "DOSPERT - social" = "dosocial",
                    "DOSPERT - investment" = "doinvest",
                    "DOSPERT - gamble" = "dogamble",
                    "DOSPERT - ethic" = "doethic",
                    "DOSPERT - recreation" = "dorecre", 
                    "Barratt impulsiveness scale" = 'BIS',
                    "Brief Sensation seeking scale" = 'BSSS',
                    'Alcohol Use DIsorders Test' = 'AuditS',
                    'Youth Risk Behavior Surveillance (risk)' = 'CDCrisk')

## list for the question choices 
## The SOEP sub-items were left out here when they had little data; financial
## now has ~19,600 subjects with an age (23 papers), patience ~1,200 and
## impulsive ~800, so the age tab offers them like the gender tab does.
questionchoice_agetab <- c("SOEP" = "soep",
                    "SOEP - financial" = "soep_financial",
                    "SOEP - patience" = "soep_patience",
                    "SOEP - impulsive" = "soep_impulsive",
                    "DOSPERT" = "doall",
                    "DOSPERT - health" = "dohealth",
                    "DOSPERT - social" = "dosocial",
                    "DOSPERT - investment" = "doinvest",
                    "DOSPERT - gamble" = "dogamble",
                    "DOSPERT - ethic" = "doethic",
                    "DOSPERT - recreation" = "dorecre", 
                    "Barratt impulsiveness scale" = 'BIS',
                    "Brief Sensation seeking scale" = 'BSSS',
                    'Alcohol Use DIsorders Test' = 'AuditS',
                    'Youth Risk Behavior Surveillance (risk)' = 'CDCrisk')

## correlation tab
questionchoice_gender <- c("SOEP" = "soep",
                    "SOEP - financial" = "soep_financial",
                    "SOEP - patience" = "soep_patience",
                    "SOEP - impulsive" = "soep_impulsive",
                    "DOSPERT" = "doall",
                    "DOSPERT - health" = "dohealth",
                    "DOSPERT - social" = "dosocial",
                    "DOSPERT - investment" = "doinvest",
                    "DOSPERT - gamble" = "dogamble",
                    "DOSPERT - ethic" = "doethic",
                    "DOSPERT - recreation" = "dorecre")


