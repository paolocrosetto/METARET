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
                   
                 # # explanation of what RETs are -- on hold for the moment
                 # tabPanel("Risk Elicitation Tasks",
                 #          sidebarPanel(h4("RETs"),
                 #                                # helpText("Select which RET you need info about"),
                 #                                radioButtons("RET", NULL,
                 #                                             c("Holt and Laury" = "HL",
                 #                                               "Binswanger / Eckel and Grossmann" = "EG",
                 #                                               "Investment Game" = "IG",
                 #                                               "Bomb Risk Elicitation Task" = "BRET",
                 #                                               "Balloon Analog Risk Task" = "BART",
                 #                                               "Certainty equivalent price list" = "CEPL"))),
                 #                   mainPanel(htmlOutput('markdown', inline = T))
                 # ),
                   # visualisation of visits mapped on to interactive map
                 navbarMenu("Elicited Risk Attitudes",
                            tabPanel("Across tasks",
                            sidebarPanel(width = 3,
                              helpText("Choose a RET to display the elicited values"),
                              checkboxGroupInput("task", NULL,
                                           c("Holt and Laury" = "HL",
                                             "Binswanger / Eckel and Grossmann" = "EG",
                                             "Investment Game" = "IG",
                                             "Bomb Risk Elicitation Task" = "BRET",
                                             "Balloon Analog Risk Task" = "BART",
                                             "Certainty equivalent price list" = "CEPL"),
                                           selected = "HL")
                            ),
                            
                            # Show a plot of the generated distribution
                            mainPanel(
                              plotOutput("density", height = "800px")
                            )
                   ),
                 tabPanel("Within tasks",
                          sidebarPanel(width = 3,
                            helpText("Choose a RET to display the elicited values"),
                            radioButtons("vartask", NULL,
                                               c("Holt and Laury" = "HL",
                                                 "Binswanger / Eckel and Grossmann" = "EG",
                                                 "Investment Game" = "IG",
                                                 "Bomb Risk Elicitation Task" = "BRET",
                                                 "Balloon Analog Risk Task" = "BART",
                                                 "Certainty equivalent price list" = "CEPL"),
                                         selected = "HL")
                          ),
                          
                          # Show a plot of the generated distribution
                          mainPanel(
                            plotOutput("variabilityplot", height = "800px")
                          )
                 )),
                   tabPanel("Correlations among tasks",
                            sidebarPanel(width = 3,
                              helpText("Choose a RET to display cross correlations"),
                              checkboxGroupInput("corrtask", NULL,
                                                 c("Holt and Laury" = "HL",
                                                   "Binswanger / Eckel and Grossmann" = "EG",
                                                   "Investment Game" = "IG",
                                                   "Bomb Risk Elicitation Task" = "BRET",
                                                   # "Balloon Analog Risk Task" = "BART",
                                                   "Certainty equivalent price list" = "CEPL"),
                                                 selected = c("HL","EG")),
                              radioButtons("r_or_choice","choice or risk parameter",
                                           choices = c("risk parameter" = "r",
                                                       "raw choices" = "choice"),
                                           selected = 'choice')
                            ),
                            
                            mainPanel(
                              plotOutput("corrplot", height = "800px")
                            )
                    ),
                   
                   # simple data table output
                            tabPanel("Answers to questionnaires",
                                     sidebarPanel(width = 3,
                                     helpText("Choose one questionnaire"),
                                     radioButtons("distquest", NULL,
                                                        c("SOEP" = "soep", 
                                                          "DOSPERT" = "doall",
                                                          "DOSPERT-Gamble" = "dogamble",
                                                          "DOSPERT-investment" = "doinvest",
                                                          "DOSPERT-health" = "dohealth"),
                                                        selected = "soep")
                                     ),
                                     mainPanel(
                                       plotOutput("distquestplot", height = "800px")
                                     )
                                     ),
                            tabPanel("Correlations among questionnaires",
                                     sidebarPanel(width = 3,
                                                  helpText("Choose two or more questionnaires"),
                                                  checkboxGroupInput("corquest", NULL,
                                                               c("SOEP" = "soep", 
                                                                 "DOSPERT" = "doall",
                                                                 "DOSPERT-Gamble" = "dogamble",
                                                                 "DOSPERT-investment" = "doinvest",
                                                                 "DOSPERT-health" = "dohealth"),
                                                               selected = c("soep","doall"))
                                     ),
                                     mainPanel(
                                       plotOutput("corquestplot", height = "800px")
                                     )
                            ),
                 navbarMenu("Correlations task <-> questionnaires",
                            tabPanel("By risk elicitation task",
                            sidebarPanel(width = 3,
                              helpText("Choose one or more RETs"),
                              checkboxGroupInput("qtask", NULL,
                                                 c("Holt and Laury" = "HL",
                                                   "Binswanger / Eckel and Grossmann" = "EG",
                                                   "Investment Game" = "IG",
                                                   "Bomb Risk Elicitation Task" = "BRET",
                                                   # "Balloon Analog Risk Task" = "BART",
                                                   "Certainty equivalent price list" = "CEPL"),
                                                 selected = "HL"),
                              hr(),
                              helpText("Choose one or more questionnaires"),
                              checkboxGroupInput("tquest", NULL,
                                                 c("SOEP" = "SOEP", 
                                                   "DOSPERT" = "DOSPERT",
                                                   "DOSPERT-Gamble" = "D-gamble",
                                                   "DOSPERT-investment" = "D-invest",
                                                   "DOSPERT-health" = "D-health"),
                                                 selected = "SOEP"),
                              hr(),
                              helpText("Raw choices or risk parameter"),
                              radioButtons("choicevar",NULL,
                                           choices = c("risk parameter" = "r",
                                                       "raw choices" = "choice"),
                                           selected = "choice")
                              ),
                              
                            mainPanel(
                              plotOutput("questplottask", height = "800px")
                            )
                    ),
                    tabPanel("By versions of each risk elicitation task",
                             sidebarPanel(width = 3,
                               helpText("Choose one RET"),
                               radioButtons("qtask_treat", NULL,
                                                  c("Holt and Laury" = "HL",
                                                    "Binswanger / Eckel and Grossmann" = "EG",
                                                    "Investment Game" = "IG",
                                                    "Bomb Risk Elicitation Task" = "BRET",
                                                    # "Balloon Analog Risk Task" = "BART",
                                                    "Certainty equivalent price list" = "CEPL"),
                                            selected = "EG"),
                               hr(),
                               helpText("Choose one or more questionnaires"),
                               checkboxGroupInput("tquest_treat", NULL,
                                                  c("SOEP" = "SOEP", 
                                                    "DOSPERT" = "DOSPERT",
                                                    "DOSPERT-Gamble" = "D-gamble",
                                                    "DOSPERT-investment" = "D-invest",
                                                    "DOSPERT-health" = "D-health"),
                                                  selected = "SOEP"),
                               hr(),
                               helpText("Raw choices or risk parameter"),
                               radioButtons("choicevar_treat",NULL,
                                            choices = c("risk parameter" = "r",
                                                        "raw choices" = "choice"),
                                            selected = "choice")
                             ),
                             
                             mainPanel(
                               plotOutput("questplottreat", height = "800px")
                             )
                    ))
))
