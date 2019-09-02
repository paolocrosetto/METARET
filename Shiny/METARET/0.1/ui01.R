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
    headerPanel("Explore the METARET database", windowTitle = "METARET -- a METa Analysis of the external validity of Risk Elicitation Tasks"),
    
    

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            helpText("Select a Risk Elicitation Task and a 
                     risk attitude self-eported questionnaire.
                     On the right you will see the correlation
                     from current included studies"),
            selectInput("task", label = h3("Select a Risk Elicitation Task"), 
                        choices = list("All" = "all",
                                       "BRET" = "BRET", "Holt & Laury" = "HL",
                                       "Eckel & Grossmann" = "EG",
                                       "Investment Game" = "IG"
                                       ), 
                        selected = 1),
            hr(),
            selectInput("questionnaire", label = h3("Select a risk Questionnaire"), 
                        choices = list("All" = "all",
                                       "SOEP" = "SOEP", "DOSPERT" = "DOSPERT",
                                       "DOSPERT-Gamble" = "D-gamble",
                                       "DOSPERT-investment" = "D-invest",
                                       "DOSPERT-health" = "D-health"), 
                        selected = 1),
            
            hr(),
            textOutput("description")
            ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot",height = "800px")
        )
    )
))
