#
# User interface for the METARET data exploration APP
# 
# Paolo Crosetto
#
# This Version: June 2019

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Explore the METARET database"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("task", label = h3("Select a Risk Elicitation Task"), 
                        choices = list("BRET" = "BRET", "Holt & Laury" = "HL",
                                       "Eckel & Grossmann" = "EG",
                                       "Investment Game" = "IG"), 
                        selected = 1),
            hr(),
            selectInput("questionnaire", label = h3("Select a risk Questionnaire"), 
                        choices = list("SOEP" = "SOEP", "DOSPERT" = "DOSPERT"), 
                        selected = 1),
            
            hr(),
            fluidRow(column(3, verbatimTextOutput("value")))
            ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot")
        )
    )
))
