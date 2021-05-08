library(shiny)
library(shinydashboard)


ui <- fluidPage(
  theme = shinythemes::shinytheme("superhero"),
  navbarPage(
    title = "METARET Data Explorer",
    tabsetPanel(
      tabPanel("HOME", icon = icon("home"),
               "Introduction Markdown..."),
      tabPanel("Tasks", icon = icon("list"),
               taskdashboard <- dashboardPage(
                 dashboardHeader(disable = TRUE),
                 dashboardSidebar(
                   width = 270,
                   menuItem("Holt & Laury", tabName = "HL",
                            menuSubItem("Presentation", tabName = "HL_presentation", icon = icon("th")),
                            menuSubItem("Analysis", tabName = "HL_analysis", icon = icon("line-chart"))),
                   menuItem("Binswanger, Eckel and Grossmann", tabName = "BEG",
                            menuSubItem("Presentation", tabName = "BEG_presentation", icon = icon("th")),
                            menuSubItem("Analysis", tabName = "BEG_analysis", icon = icon("line-chart"))),
                   menuItem("Investment Game", tabName = "IG",
                            menuSubItem("Presentation", tabName = "IG_presentation", icon = icon("th")),
                            menuSubItem("Analysis", tabName = "IG_analysis", icon = icon("line-chart"))),
                   menuItem("Bomb Risk Elicitation Task", tabName = "Bomb",
                            menuSubItem("Presentation", tabName = "Bomb_presenation", icon = icon("th")),
                            menuSubItem("Analysis", tabName = "Bomb_analysis", icon = icon("line-chart"))),
                   menuItem("Balloon Analog Risk Task", tabName = "Balloon",
                            menuSubItem("Presentation", tabName = "Balloon_presentation", icon = icon("th")),
                            menuSubItem("Analysis", tabName = "Balloon_analysis", icon = icon("line-chart"))),
                   menuItem("Certainty equivalent price list", tabName = "Certainty",
                            menuSubItem("Presentation", tabName = "Certainty_presentation", icon = icon("th")),
                            menuSubItem("Analysis", tabName = "Certainty_analysis", icon = icon("line-chart")))
                 ),
                 dashboardBody(
                   
                 )
               )),
      tabPanel("Correlation among task", icon = icon("line-chart"),
               correlation_task_dashboard <- dashboardPage(
                 dashboardHeader(disable = TRUE),
                 dashboardSidebar(),
                 dashboardBody()
               )),
      tabPanel("Answers to questionnaires", icon = icon("pencil"),
               answers_dashboard <- dashboardPage(
                 dashboardHeader(disable = TRUE),
                 dashboardSidebar(),
                 dashboardBody()
               )),
      tabPanel("Correlations among questionnaires", icon = icon("line-chart"),
               correlations_questionnaires_dashboard <- dashboardPage(
                 dashboardHeader(disable = TRUE),
                 dashboardSidebar(),
                 dashboardBody()
               )),
      tabPanel("Correlations task <-> questionnaires", icon = icon("line-chart"),
               correlations_both_dashboard <- dashboardPage(
                 dashboardHeader(disable = TRUE),
                 dashboardSidebar(),
                 dashboardBody()
               ))
    )
  )
)


        
  
