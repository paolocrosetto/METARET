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
             title = "Tasks:",
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
           ),
           navbarMenu("Balloon Analog Risk Task",
                      tabPanel("Presentation", icon = icon("th"),
                               balloon_dashboard1 <- dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               )),
                      tabPanel("Analysis", icon = icon("line-chart"),
                               balloon_dashboard2 <- dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               ))),
           navbarMenu("Certainty equivalent price list",
                      tabPanel("Presentation", icon = icon("th"),
                               certainty_dashboard1 <- dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               )),
                      tabPanel("Analysis", icon = icon("line-chart"),
                               certainty_dashboard2 <- dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               )))
           )),
  tabPanel("Questionnaires", icon = icon("pencil"),
           navbarPage(
             title = "Questionnaires:",
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
                        ),
             navbarMenu("DOPSERT",
                        tabPanel("Presentation", icon = icon("th"),
                                 DOPSERT_dasboard1 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Results", icon = icon("pencil"),
                                 DOPSERT_dasboard2 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))
             ),
             navbarMenu("Gamble", icon = icon("piggy-bank"),
                        tabPanel("Presentation", icon = icon("th"),
                                 gamble_dashboard1 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Results", icon = icon("pencil"),
                                 gamble_dashboard2 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))),
             navbarMenu("Investment", icon = icon("dollar"),
                        tabPanel("Presentation", icon = icon("th"),
                                 investment_dashboard1 <- dashboardPage(
                                   dashboardHeader(disable=TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Results", icon = icon("pencil"),
                                 investment_dashboard2 <- dashboardPage(
                                   dashboardHeader(disable=TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))),
             navbarMenu("Health", icon = icon("tint"),
                        tabPanel("Presentation", icon=icon("th"),
                                 health_dashboard1 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Results", icon = icon("pencil"),
                                 health_dashboard2 <- dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE), 
                                   dashboardBody()
                                 )))
           )
  )
)


  




