library(shinydashboard)
library(shiny)
library(tidyverse)

ui <- navbarPage(
  theme = shinythemes::shinytheme("superhero"),
  title = "METARET Data Explorer",
  tabPanel("HOME", icon = icon("home"),
           home_dashboard <- dashboardPage(
             dashboardHeader(disable = TRUE),
             dashboardSidebar(disable = TRUE),
             dashboardBody()
           )),
  tabPanel("Tasks", icon = icon("list"),
           navbarPage(
             title = "Tasks Explorer:",
             navbarMenu("Holt and Laury",
                        tabPanel("Presentation", icon = icon("th"),
                                 HL_dashboard1 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Analysis", icon = icon("line-chart"),
                                 HL_dashboard2 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))
             ),
             navbarMenu("Binswanger, Eckel and Grossmann",
                        tabPanel("Presentation", icon = icon("th"),
                                 BEG_dashboard1 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Analysis", icon = icon("line-chart"),
                                 BEG_dashboard2 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))
           ),
           navbarMenu("Investment Game", icon = icon("dollar"),
                      tabPanel("Presentation", icon = icon("th"),
                               IG_dashboard1 <- dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               )),
                      tabPanel("Analysis", icon = icon("line-chart"),
                               IG_dashboard2 <- dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               ))
           ),
           navbarMenu("Bomb Risk Elicitation Task", icon = icon("bomb"),
                      tabPanel("Presentation", icon = icon("th"),
                               bomb_dashboard1 <- dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               )),
                      tabPanel("Analysis", icon = icon("line-chart"),
                               bombdashboard2 <- dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               ))
           ))),
  tabPanel("Questionnaires", icon = icon("pencil"),
           navbarPage(
             title = "Select a questionnaire:",
             navbarMenu("SOEP",
                        tabPanel("Presentation", icon = icon("th"),
                                 SOEP_dashboard1 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Results", icon = icon("pencil"),
                                 SOEP_dashboard2 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))
                        )
           )),
  tabPanel("Correlations among tasks", icon = icon("line-chart")),
  tabPanel("Correlations among questionnaires", icon = icon("line-chart")),
  tabPanel("Correlations tasks <-> questionnaires", icon = icon("line-chart"))
)

  




