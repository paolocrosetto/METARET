library(shinydashboard)
library(shiny)
library(tidyverse)
library(babynames)

ui <- navbarPage(
  theme = shinythemes::shinytheme("superhero"),
  title = "METARET Data Explorer",
  tabPanel("HOME", icon = icon("home"),
            dashboardPage(
             dashboardHeader(disable = TRUE),
             dashboardSidebar(disable = TRUE),
             dashboardBody(
               fluidRow(
                 box(
                   textInput("name", "Enter your name", "David"),
                   plotOutput("trend")
                 )
               )
             )
           )),
  tabPanel("Taks", icon = icon("list"),
           navbarPage(
             title = "Tasks",
             navbarMenu("Holt and Laury",
                        tabPanel("Presentation", icon = icon("th"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody(
                                     fluidRow(
                                       valueBox(20, "Number", icon = icon("list")
                                       )
                                     )
                                   )
                                 )),
                        tabPanel("Analysis", icon = icon("line-chart"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))
             ),
             navbarMenu("Binswanger, Eckel and Grossmann",
                        tabPanel("Presentation", icon = icon("th"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Analysis", icon = icon("line-chart"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))
           ),
           navbarMenu("Investment Game", icon = icon("dollar"),
                      tabPanel("Presentation", icon = icon("th"),
                                dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               )),
                      tabPanel("Analysis", icon = icon("line-chart"),
                                dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               ))
           ),
           navbarMenu("Bomb Risk Elicitation Task", icon = icon("bomb"),
                      tabPanel("Presentation", icon = icon("th"),
                                dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               )),
                      tabPanel("Analysis", icon = icon("line-chart"),
                                dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               ))
           ),
           navbarMenu("Balloon Analog Risk Task",
                      tabPanel("Presentation", icon = icon("th"),
                                dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               )),
                      tabPanel("Analysis", icon = icon("line-chart"),
                                dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               ))),
           navbarMenu("Certainty equivalent price list",
                      tabPanel("Presentation", icon = icon("th"),
                                dashboardPage(
                                 dashboardHeader(disable = TRUE),
                                 dashboardSidebar(disable = TRUE),
                                 dashboardBody()
                               )),
                      tabPanel("Analysis", icon = icon("line-chart"),
                                dashboardPage(
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
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Results", icon = icon("pencil"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))
                        ),
             navbarMenu("DOPSERT",
                        tabPanel("Presentation", icon = icon("th"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Results", icon = icon("pencil"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))
             ),
             navbarMenu("Gamble", icon = icon("piggy-bank"),
                        tabPanel("Presentation", icon = icon("th"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Results", icon = icon("pencil"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))),
             navbarMenu("Investment", icon = icon("dollar"),
                        tabPanel("Presentation", icon = icon("th"),
                                  dashboardPage(
                                   dashboardHeader(disable=TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Results", icon = icon("pencil"),
                                 dashboardPage(
                                   dashboardHeader(disable=TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 ))),
             navbarMenu("Health", icon = icon("tint"),
                        tabPanel("Presentation", icon=icon("th"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody()
                                 )),
                        tabPanel("Results", icon = icon("pencil"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE), 
                                   dashboardBody()
                                 )))
             
           )
  ),
  tabPanel("Correlations among tasks", icon = icon("line-chart"),
           dashboardPage(
             dashboardHeader(disable = TRUE),
             dashboardSidebar(disable = TRUE),
             dashboardBody()
           )),
  tabPanel("Correlations among questionnaires", icon = icon("line-chart"),
           dashboardPage(
             dashboardHeader(disable = TRUE),
             dashboardSidebar(disable = TRUE),
             dashboardBody()
           )),
  tabPanel("Correlations tasks <-> questionnaires", icon = icon("line-chart"),
           dashboardPage(
             dashboardHeader(disable = TRUE),
             dashboardSidebar(disable = TRUE),
             dashboardBody()
           ))
)


  




