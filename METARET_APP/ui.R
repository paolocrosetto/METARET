## packages for the project
source("libraries.R")

### function to create linebreaks for the page Q+T
linebreaks <- function(n){HTML(strrep(br(), n))}

## user interface function
ui <- dashboardPage(theme  = "solar", dashboardHeader(title = 'METARET'),
      dashboardSidebar(    
        sidebarMenu(
          menuItem("Overview", tabName = "tab_homepage", icon = icon("home")),
          menuItem("Tasks", tabName = "tab_lotteries", icon = icon("chart pie")),
          menuItem("Questionnaires", tabName = "tab_questionnaires", icon = icon("question")),
          menuItem("Correlations", tabName = "tab_lotteries_and_questionnaires", icon = icon("sync alternate")),
          menuItem("Demographics", tabName = 'demography', icon = icon("user")),
          menuItem('Map', tabName = "tab_map", icon = icon("compass")),
          menuItem("Download", tabName = "tab_download", icon = icon("download"))
          
          #menuItem("About", tabName = "tab_about", icon = icon("info"))
        )),
        dashboardBody(
        tags$style(type="text/css",
                ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"
        ),
        tags$head(tags$style(HTML(".small-box {height: 50px}"))),
        ### Home page 
        tabItem("tab_homepage", 
                ## Key information 
                fluidRow(
                  valueBoxOutput("contributors", width = 5),
                  valueBoxOutput("lotteries_num", width = 5),
                  valueBoxOutput("participants_num", width = 5)), 
                fluidRow(
                  box(title = "Our project",
                      color = "black", 
                      solidHeader = TRUE,
                      includeMarkdown("info_detail.md"), width = 15)),
                fluidRow(
                  box(title = "Future developments",
                      color = "black", 
                      solidHeader = TRUE,
                      includeMarkdown("info_future.md"), width = 15)),
                fluidRow(
                  box(title = "Contribute",
                      color = "black", 
                      solidHeader = TRUE,
                      includeMarkdown("info_contribute.md"), width = 15))
                ),
        
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
                      column(3, box(selectInput("Tasks", "Tasks:",
                                      mychoices),  width = 3),
                      h5(),
                      box(title = "Explanatory note",
                          color = "black", 
                          solidHeader = TRUE,
                          includeMarkdown("note_task_tab1.md"), width = 3)),
                      ## Information about tasks
                      box(title = "Information about tasks",
                          solidHeader = TRUE,
                          color = "black", 
                          width = 16,
                          infoBoxOutput("info_markdown")),
                      
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
                    list(menu = "Across-task, between-subject comparison", content = list(
                      
                      ## Multiple checkbox for the tasks selection
                      column(3, 
                             h5(),
                             actionButton("selectalltaskdist","Select/Deselect all"),
                             h5(), 
                             multiple_checkbox("id_selectInput", 
                                  label = HTML('<B><FONT size="3">Choose RETs to display density distributions</FONT></B><br><br>'), 
                                  multiple = TRUE,
                                  choices = mychoices, 
                                  position = 'inline',
                                  selected = c('HL', 'EG')
                                  ), 
                             h5(), 
                             box(title = "Explanatory note",
                                 color = "black", 
                                 solidHeader = TRUE,
                                 includeMarkdown("infodistributions.md"))
                            ),
                      ## Plot with many distributions 
                      column(12, h5(), style = "height: 80vh;", plotOutput("lotteries_comp")))),
                    
                    ## Third tab of tasks page 
                    list(menu = "Across-task, within-subject correlations", content = list(
                      ## Select box for correlation among tasks 
                      column(4, 
                             actionButton("selectalltaskcorrs","Select/Deselect all"),
                             h5(), 
                             multiple_checkbox("amongcorrs", 
                                                   label = HTML('<B><FONT size="3">Choose RETs to display correlations</FONT></B><br><br>'), 
                                                   multiple = TRUE,
                                                   choices = mychoices, 
                                                   position = 'inline',
                                                   selected = c("HL", "EG", 'BART')),
                      h5(), 
                      box(title = "Explanatory note",
                          color = "black", 
                          solidHeader = TRUE,
                          includeMarkdown("infocorrtasks.md"))
                      ),
                      ## Plot correlations among tasks 
                      column(11, style = "height: 80vh;", plotOutput("corr_tasks")))),
                    
                    ## Fourth tab for task page
                    
                    list(menu = 'Within-task, across-paper comparison', content = list(
                      ## Plot with possibility to chose one type of task
                             column(11, style = "height: 80vh;", plotOutput("everytask")),

                             ## Select box for the plot 
                             column(4, box(selectInput("selectedtask", "Tasks:",
                                             mychoices)), h5(), 
                                    box(title = "Explanatory note",
                                        color = "black", 
                                        solidHeader = TRUE,
                                        includeMarkdown("infotasksevrpaper.md"))
                                    )))
                    ))
                  ),
        
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
                    
                    column(3,box(selectInput("Questionnaires", "Questionnaires:",
                                    questionchoice), width = 3),
                    h5(),
                    box(title = "Explanatory note",
                        color = "black", 
                        solidHeader = TRUE,
                        includeMarkdown("note_quest_tab1.md"),  width = 3)),
                    
                    ## Information about questions
                    box(title = "Information about questions",
                        solidHeader = TRUE,
                        color = "black", 
                        width = 16,
                        infoBoxOutput("info_markdown_quest")),
                    
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
                    column(4,  
                           actionButton("selectallcorrquest","Select/Deselect all"),
                           h5(), h5(),
                           multiple_checkbox("amongquest", 
                                      label = HTML('<B><FONT size="3">Choose types of questions to display correlations</FONT></B><br><br>'), 
                                      multiple = TRUE,
                                      choices = questionchoice_gender, 
                                      position = 'inline',
                                      selected = c("soep", "dohealth", 'dogamble')),
                           h5(), 
                           box(title = "Explanatory note",
                               color = "black", 
                               solidHeader = TRUE,
                               includeMarkdown("infocorrquest.md"))),
                    
                    ## Plot correlations among questions 
                    column(11, style = "height: 80vh;", plotOutput("corr_quest")))))
                 )),
        
        ## Tasks and questionnaire page
        tabItem("tab_lotteries_and_questionnaires", 
                column(4, actionButton("selectalltasks","Select/Deselect all"),
                       
                       h5(), h5(),
                       multiple_checkbox("amongcorrs_1", 
                                             label = HTML('<B><FONT size="3">Select RET types</FONT></B><br><br>'), 
                                             multiple = TRUE,
                                             choices = mychoices, 
                                             position = 'inline',
                                             selected = c("HL", "EG")),
                       h5(), h5(),
                       actionButton("selectallquest","Select/Deselect all"),
                       h5(), h5(),
                       multiple_checkbox("amongquest_1", 
                                        label = HTML('<B><FONT size="3">Select question types</FONT></B><br><br>'), 
                                        multiple = TRUE,
                                        choices = questionchoice_cor, 
                                        position = 'inline',
                                        selected = c("soep", "dohealth", 'dogamble'))),
            
                column(12,
                       style = "height: 80vh;",  
                       plotOutput("corr_quest_task"),
                       linebreaks(13),
                       box(title = "Explanatory note",
                           color = "black", 
                           solidHeader = TRUE,
                           includeMarkdown("note_taskquest_tab1.md"))
               
        )),
        
        tabItem("demography",
                tabBox(color = "black", width = 16,
                       tabs = list(
                         list(menu = "Gender differences by task",  content = list(
                           fluidRow(valueBoxOutput("quant_gend_contr", width = 5),
                                    valueBoxOutput("quant_femmes", width = 5),
                                    valueBoxOutput("quant_hommes", width = 5)),
                           ## Plot with possibility to chose one task
                           box(plotOutput("gender_dist"),
                               width = 12),
                           
                           ## Select box for the plot 
                           column(3, box(selectInput("genderdist", "Tasks:",
                                                     mychoicesgender),  width = 3),
                                  h5(), 
                                  box(title = "Explanatory note",
                                      color = "black", 
                                      solidHeader = TRUE,
                                      includeMarkdown("demography_gender.md")))
                           )
                       ),
                       list(menu = "Gender differences by questionnaire",  content = list(
                         fluidRow(valueBoxOutput("quant_gend_contr_q", width = 5),
                                  valueBoxOutput("quant_femmes_q", width = 5),
                                  valueBoxOutput("quant_hommes_q", width = 5)),
                         
                         box(plotOutput("gender_dist_quest"),
                             width = 12),
                         
                         ## Select box for the plot 
                         column(3, box(selectInput("genderdist_quest", "Questions:",
                                                   questionchoice_gender),  width = 3),
                                h5(), 
                                box(title = "Explanatory note",
                                    color = "black", 
                                    solidHeader = TRUE,
                                    includeMarkdown("demography_gender.md")))
                       )),
                       list(menu = "Age gradient by task",  content = list(
                         
                         fluidRow(valueBoxOutput("quant_contr_a", width = 5),
                                  valueBoxOutput("quant_femmes_a", width = 5),
                                  valueBoxOutput("quant_hommes_a", width = 5)),
                         
                         ## Plot with possibility to chose one task
                         box(plotOutput("age_dist"),
                             width = 12),
                         
                         ## Select box for the plot 
                         column(3, 
                                box(selectInput("agedist", "Tasks:",
                                                mychoicesgender),  width = 3)
                                )
                       )), 
                       list(menu = "Age gradient by questionaire",  content = list(
                         fluidRow(valueBoxOutput("quant_contr_aq", width = 5),
                                  valueBoxOutput("quant_femmes_aq", width = 5),
                                  valueBoxOutput("quant_hommes_aq", width = 5)),
                         
                         ## Plot with possibility to chose one task
                         box(plotOutput("age_dist_quest"),
                             width = 12),
                         
                         ## Select box for the plot 
                         column(3, 
                                box(selectInput("agedist_q", "Questions:",
                                                questionchoice_agetab),  width = 3)
                         )
                       )))
                       )),
        
        ## Explore page
        tabItem("tab_download",
                tabBox(color = "black", width = 16,
                  tabs = list(
                  
                  ## First tab with tasks 
                  list(menu = "Tasks",  content = c(fluidPage(
                    
                    h5(), h5(),
                    
                    ## info tooltip
                    box(title = "Explanatory note",
                        color = "black", 
                        solidHeader = TRUE,
                        includeMarkdown("info_download_task.md")),
                    
                    
                    ## Download button code 
                    h5(), h5(),
                    downloadButton('downloadData', 'Download all task data',  
                                   style="color: #fff; background-color: green; border-color: Black; padding: 5px 14px 5px 14px;margin: 5px 5px 5px 5px; ",
                                   icon = shiny::icon('download')),
                    h5()),
                    
                    ## Table with tasks information
                    fluidPage(h5(),
                            dataTableOutput("page1")))),
                  
                  ## Second tab with tasks 
                  list(menu = "Questionnaires", content = c(fluidPage(
                    
                    h5(), h5(),
                    
                    ## info tooltip
                    box(title = "Explanatory note",
                        color = "black", 
                        solidHeader = TRUE,
                        includeMarkdown("info_download_quest.md")),
                    
                    ## Download button code 
                    h5(), h5(),
                    downloadButton('downloadData2', 'Download all questionnaire data',  
                                   style="color: #fff; background-color: green; border-color: Black; padding: 5px 14px 5px 14px;margin: 5px 5px 5px 5px; ",
                                   icon = shiny::icon('download')),
                    h5()),
                    ## Table with questions information
                    fluidPage(h5(), 
                            dataTableOutput("page2")))))
                )),
        ## About page
        #tabItem("tab_about", includeMarkdown('info.md'))
        
        ## Explore page
        tabItem("tab_map",
                tabBox(color = "black", width = 16,
                       tabs = list(
                         
                         ## First tab with tasks 
                         list(menu = "Risk propensity map", 
                              content = 
                                tmapOutput("map_crra", 
                                           width = "100%", 
                                           height = 700)))
                       ))
        ))
