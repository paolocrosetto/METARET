## packages for the project
source("libraries.R")

## user interface function
ui <- dashboardPage(theme  = "solar", dashboardHeader(title = 'METARET'),
      dashboardSidebar(    
        sidebarMenu(
          menuItem("Home page ", tabName = "tab_homepage", icon = icon("home")),
          menuItem("Tasks", tabName = "tab_lotteries", icon = icon("trophy")),
          menuItem("Questionnaires", tabName = "tab_questionnaires", icon = icon("question")),
          menuItem("Tasks and Questionnaires", tabName = "tab_lotteries_and_questionnaires", icon = icon("images")),
          menuItem("Explore", tabName = "tab_explore", icon = icon("compass")),
          menuItem("About", tabName = "tab_about", icon = icon("info"))
        )),
      dashboardBody(
        tags$head(tags$style(HTML(".small-box {height: 50px}"))),
        ### Home page 
        tabItem("tab_homepage", 
                ## Key information 
                fluidRow(
                  valueBoxOutput("contributors", width = 5),
                  valueBoxOutput("lotteries_num", width = 5),
                  valueBoxOutput("participants_num", width = 5))),
        
        ## Tasks page  
        tabItem("tab_lotteries",
                tabBox(color = "black", width = 16,
                  tabs = list(
                    
                    ## First tab of tasks page
                    list(menu = "Tasks",  content = list(fluidRow(
                      
                      ## Key information 
                      valueBoxOutput("contributors_lot", width = 5),
                      valueBoxOutput("participants_num_lot", width = 5),
                      valueBoxOutput("num_obs", width = 5)),
                     
                       ## Plot with possibility to chose one task
                      box(plotOutput("lotteries"),
                          width = 12),
                      
                      ## Select box for the plot 
                      box(selectInput("Tasks", "Tasks:",
                                      mychoices), width = 3),
                      
                      ## Information about tasks
                      box(title = "Information about tasks",
                          solidHeader = TRUE,
                          color = "black", 
                          width = 16,
                          includeMarkdown("info_tasks.md")),
                      
                     ## Contributed papers
                      box(title = "Contributed papers",
                              solidHeader = TRUE,
                              collapsed = FALSE, 
                              collapsible = TRUE,
                              width = 16,
                              color = 'black',
                              status = "success",
                              dataTableOutput('table_papers_name')))),
                    
                    ## Second tab of tasks page
                    list(menu = "Across tasks", content = list(
                      
                      ## Multiple checkbox for the tasks selection
                      column(3, multiple_checkbox("id_selectInput", 
                                  label = HTML('<B><FONT size="3">Choose RETs to display density distributions</FONT></B><br><br>'), 
                                  multiple = TRUE,
                                  choices = mychoices, 
                                  position = 'inline',
                                  selected = c('HL', 'EG')
                                  )),
                      
                      ## Plot with many distributions 
                      column(12, style = "height: 100vh;", plotOutput("lotteries_comp")))),
                    ## Third tab of tasks page 
                    list(menu = "Among tasks", content = list(
                      ## Select box for correlation among tasks 
                      column(3,  multiple_checkbox("amongcorrs", 
                                                   label = HTML('<B><FONT size="3">Choose RETs to display correlations</FONT></B><br><br>'), 
                                                   multiple = TRUE,
                                                   choices = mychoices, 
                                                   position = 'inline',
                                                   selected = c("HL", "EG", 'BART'))),
                      
                      ## Plot correlations among tasks 
                      column(12, style = "height: 100vh;", plotOutput("corr_tasks")))))
                  )),
        
        ## Questionnaires page  
        tabItem("tab_questionnaires", 
                tabBox(color = "black", width = 16,
                  tabs = list(
                  ## First tab of questionnaires page  
                  list(menu = "Questionnaires",  content = list(fluidRow(
                    
                    ## Key information 
                    valueBoxOutput("paper_num", width = 5),
                    valueBoxOutput("task_num", width = 5),
                    valueBoxOutput("quest_num", width = 5),
                    ),
                    
                    # Plot with possibility to chose one type of question
                    box(plotOutput("questionnaires"), width = 12),
                    
                    # Select box for the plot
                    box(selectInput("Questionnaires", "Questionnaires:",
                                    questionchoice), width = 3),
                    
                    ## Information about questions
                    box(title = "Information about questions",
                        solidHeader = TRUE,
                        color = "black", 
                        width = 16,
                        includeMarkdown("questionnaires.md")),
                    
                    ## Contributed papers
                    box(title = "Contributed papers",
                        solidHeader = TRUE,
                        collapsed = FALSE, collapsible = TRUE,
                        width = 16,
                        color = 'black',
                        status = "success",
                        dataTableOutput('table_papers_name_quest')))),
                  
                  ## Second tab of questionnaires page 
                  list(menu = "Correlations", content = list( 
                    
                    ## Select box for correlation among questions 
                    column(3,  multiple_checkbox("amongquest", 
                                      label = HTML('<B><FONT size="3">Choose types of questions to display correlations</FONT></B><br><br>'), 
                                      multiple = TRUE,
                                      choices = questionchoice, 
                                      position = 'inline',
                                      selected = c("soep", "dohealth", 'dogamble'))),
                    
                    ## Plot correlations among questions 
                    column(12, style = "height: 100vh;", plotOutput("corr_quest")))))
                 )),
        
        ## Tasks and questionnaire page
        tabItem("tab_lotteries_and_questionnaires", 
                column(3,  multiple_checkbox("amongcorrs_1", 
                                             label = HTML('<B><FONT size="3">Select RET types</FONT></B><br><br>'), 
                                             multiple = TRUE,
                                             choices = mychoices, 
                                             position = 'inline',
                                             selected = c("HL", "EG")),
                       h5(), h5(),
                       multiple_checkbox("amongquest_1", 
                                        
                                        label = HTML('<B><FONT size="3">Select question types</FONT></B><br><br>'), 
                                        multiple = TRUE,
                                        choices = questionchoice, 
                                        position = 'inline',
                                        selected = c("soep", "dohealth", 'dogamble'))),
                column(12, style = "height: 100vh;", plotOutput("corr_quest_task"))
               
        ),

        ## Explore page
        tabItem("tab_explore",
                tabBox(color = "black", width = 16,
                  tabs = list(
                  
                  ## First tab with tasks 
                  list(menu = "Tasks",  content = c(fluidPage(
                    
                    ## Download button code 
                    h5(), h5(),
                    downloadButton('downloadData', 'Download',  
                                   style="color: #fff; background-color: green; border-color: Black; padding: 5px 14px 5px 14px;margin: 5px 5px 5px 5px; ",
                                   icon = shiny::icon('download')),
                    h5()),
                    
                    ## Table with tasks information
                    fluidPage(h5(),
                            dataTableOutput("page1")))),
                  
                  ## Second tab with tasks 
                  list(menu = "Questionnaires", content = c(fluidPage(
                    
                    ## Download button code 
                    h5(), h5(),
                    downloadButton('downloadData2', 'Download',  
                                   style="color: #fff; background-color: green; border-color: Black; padding: 5px 14px 5px 14px;margin: 5px 5px 5px 5px; ",
                                   icon = shiny::icon('download')),
                    h5()),
                    ## Table with questions information
                    fluidPage(h5(), 
                            dataTableOutput("page2")))))
                )),
        ## About page
        tabItem("tab_about", includeMarkdown('info.md'))))
