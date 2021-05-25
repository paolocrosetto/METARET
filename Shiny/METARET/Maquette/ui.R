library(shinydashboard)
library(shiny)
library(tidyverse)
library(shinipsum)
library(babynames)
library(shinydashboardPlus)


ui <- navbarPage(
  theme = shinythemes::shinytheme("superhero"),
  title = "METARET Data Explorer",
  tabPanel("HOME", icon = icon("home"),
            dashboardPage(
             dashboardHeader(disable = TRUE),
             dashboardSidebar(disable = TRUE),
             dashboardBody(
               box(title = "Contributed papers",
                   solidHeader = TRUE,
                   status = "primary",
                   attachmentBlock(
                     image = "",
                     title = "The Bomb Risk Elicitation Task",
                     href = "https://link.springer.com/article/10.1007/s11166-013-9170-z"
                   ),
                   attachmentBlock(
                     image = "",
                     title = "A Theoretical and Experimental Appraisal of Four Risk ELicitation Methods",
                     href = "https://link.springer.com/article/10.1007/s10683-015-9457-9"
                   ))
             )
            )
  ),
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
                                       box(title = "What is Holt and Laury experimentation ?",
                                           status = "primary",
                                           solidHeader = TRUE,
                                           attachmentBlock(
                                             image = "",
                                             title = "Article's link",
                                             href = "https://www.aeaweb.org/articles?id=10.1257/000282802762024700",
                                             "Link toward the article's Google Scholar Page"
                                           )),
                                       box(title = "How to get the data from the experimentation ?",
                                           status = "success",
                                           solidHeader = TRUE,
                                           attachmentBlock(
                                             image = "",
                                             title = "Get access to the Holt and Laury data base",
                                             href = "https://google.com",
                                             "Link toward the data used for the experimentation"
                                           ))
                                       
                                     )
                                   )
                                 )),
                        tabPanel("Analysis", icon = icon("line-chart"),
                                  dashboardPage(
                                   dashboardHeader(disable = TRUE),
                                   dashboardSidebar(disable = TRUE),
                                   dashboardBody(
                                     box(title = "Name trend over year",
                                         solidHeader = TRUE,
                                         status = "primary",
                                         textInput("name", "Enter your Name", "David"),
                                         plotOutput("trend")),
                                     box(title = "Top 10 Names",
                                         solidHeader = TRUE,
                                         status = "primary",
                                         selectInput("sex","Select Sex", choices = c("M","F"),selected = "F"),
                                         sliderInput("year","Select Year", min = 1900, max = 2010, value = 1900),
                                         plotOutput("plot_top_10_names")),
                                     box(title = "Table Top 10",
                                         solidHeader = TRUE,
                                         status = "primary",
                                         DT::DTOutput("table_top_10_names"))
                                   )
                                  )
                        )
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
                                 dashboardBody(
                                   box(title = "What is Bomb Risk Elicitation Task?",
                                       status = "primary",
                                       solidHeader = TRUE,
                                       attachmentBlock(
                                         title = "Article's link",
                                         image = "",
                                         href = "https://link.springer.com/article/10.1007/s11166-013-9170-z",
                                         "Link toward the article page"
                                       )),
                                   box(title = "How could I get the data?",
                                       status = "success",
                                       solidHeader = TRUE,
                                       attachmentBlock(
                                         title = "Get the data here",
                                         image = "",
                                         href = "http://www.google.com",
                                         "Link toward the data base"
                                       ))
                                 )
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


  




