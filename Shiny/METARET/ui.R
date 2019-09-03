# TfL Data Exploration Shiny Application ---------------------------------------


# set up -----------------------------------------------------------------------
# load packages that will be used for the application
library(shiny)
library(leaflet)
library(DT)
library(markdown)

# Set up the application ui
shinyUI(navbarPage("METARET Data Explorer",
                   
                   # define the tabs to be used in the app ----------------------------------------
                   # introduction splash
                   tabPanel("Intro",
                            includeMarkdown("./md/intro.md"),
                            hr()),
                   
                 # journey time histogram(s)
                 tabPanel("Risk Elicitation Tasks",
                          sidebarPanel(h4("RETs"),
                                                # helpText("Select which RET you need info about"),
                                                radioButtons("RET", NULL,
                                                             c("Holt and Laury" = "HL",
                                                               "Binswanger / Eckel and Grossmann" = "EG",
                                                               "Investment Game" = "IG",
                                                               "Bomb Risk Elicitation Task" = "BRET",
                                                               "Balloon Analog Risk Task" = "BART",
                                                               "Certainty equivalent price list" = "CEPL"))),
                                   mainPanel(htmlOutput('markdown', inline = T))
                 ),
                   # visualisation of visits mapped on to interactive map
                   tabPanel("Elicited Risk Attitudes - across tasks",
                            sidebarPanel(
                              helpText("Choose a RET to display the elicited values"),
                              checkboxGroupInput("task", NULL,
                                           c("Holt and Laury" = "HL",
                                             "Binswanger / Eckel and Grossmann" = "EG",
                                             "Investment Game" = "IG",
                                             "Bomb Risk Elicitation Task" = "BRET",
                                             "Balloon Analog Risk Task" = "BART",
                                             "Certainty equivalent price list" = "CEPL"))
                            ),
                            
                            # Show a plot of the generated distribution
                            mainPanel(
                              plotOutput("density", height = "800px")
                            )
                   ),
                 tabPanel("Elicited Risk Attitudes - within tasks",
                          sidebarPanel(
                            helpText("Choose a RET to display the elicited values"),
                            radioButtons("vartask", NULL,
                                               c("Holt and Laury" = "HL",
                                                 "Binswanger / Eckel and Grossmann" = "EG",
                                                 "Investment Game" = "IG",
                                                 "Bomb Risk Elicitation Task" = "BRET",
                                                 "Balloon Analog Risk Task" = "BART",
                                                 "Certainty equivalent price list" = "CEPL"))
                          ),
                          
                          # Show a plot of the generated distribution
                          mainPanel(
                            plotOutput("variabilityplot", height = "800px")
                          )
                 ),
                   tabPanel("Correlations among tasks",
                            sidebarPanel(
                              helpText("Choose a RET to display cross correlations"),
                              checkboxGroupInput("corrtask", NULL,
                                                 c("Holt and Laury" = "HL",
                                                   "Binswanger / Eckel and Grossmann" = "EG",
                                                   "Investment Game" = "IG",
                                                   "Bomb Risk Elicitation Task" = "BRET",
                                                   # "Balloon Analog Risk Task" = "BART",
                                                   "Certainty equivalent price list" = "CEPL")),
                              radioButtons("r_or_choice","choice or risk parameter",
                                           choices = c("risk parameter" = "r",
                                                       "raw choices" = "choice"))
                            ),
                            
                            mainPanel(
                              plotOutput("corrplot", height = "800px")
                            )
                    ),
                   
                   # simple data table output
                   tabPanel("Correlations with questionnaires",
                            column(2,
                                   h1("The raw data"),
                                   p("This tabs shows the raw data as received from TfL.
                    Filter, sort and search. If you'd like to know more, get in
                    touch with the app creator via",
                                     span(tags$a(href="https://twitter.com/leach_jim", "twitter.")))),
                            column(10, dataTableOutput("data", height = "100%")))
)
)
