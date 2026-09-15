## packages for the project
source("libraries.R")

### Stamps a file in www/ with its own modification time, so a new deploy
### never gets served from a browser's cache of the old one.
asset <- function(file) {
  paste0(file, "?v=", as.integer(file.mtime(file.path("www", file))))
}

box <- function(..., collapsible = FALSE) {
  semantic.dashboard::box(..., collapsible = collapsible)
}

### Clickable entry card for the Overview page
nav_card <- function(tabname, icon_class, title, text, color) {
  tags$a(
    class = paste("ui", color, "card metaret-nav-card"),
    href = "#",
    `data-target-tab` = tabname,
    tags$div(
      class = "content",
      tags$i(class = paste(icon_class, "icon metaret-nav-icon")),
      tags$div(class = "header metaret-nav-title", title),
      tags$div(class = "description metaret-nav-text", text)
    )
  )
}

step_card <- function(n, title, text, chips = NULL, goal = FALSE) {
  tags$div(
    class = if (goal) "metaret-step metaret-step-goal" else "metaret-step",
    tags$div(class = "metaret-step-number", n),
    tags$div(
      class = "metaret-step-body",
      tags$div(class = "metaret-step-title", title),
      tags$p(class = "metaret-step-text", text),
      if (!is.null(chips)) {
        tags$div(class = "metaret-chips",
                 lapply(chips, function(c) tags$span(class = "metaret-chip", c)))
      }))
}

step_sequence <- function(...) {
  tags$div(class = "metaret-steps", list(...))
}

### An explanatory note under the figure it explains
note <- function(md) {
  tags$div(class = "metaret-note",
           tags$b("Explanatory note:"), " ", includeMarkdown(md))
}

## user interface function
ui <- dashboardPage(theme  = "solar", dashboardHeader(title = 'METARET'),
      dashboardSidebar(size = "",
        sidebarMenu(
          menuItem("Overview", tabName = "tab_homepage", icon = icon("home")),
          menuItem("Tasks", tabName = "tab_lotteries", icon = icon("balance scale")),
          menuItem("Questionnaires", tabName = "tab_questionnaires", icon = icon("question")),
          menuItem("Correlations", tabName = "tab_lotteries_and_questionnaires", icon = icon("th")),
          menuItem("Demographics", tabName = 'demography', icon = icon("users")),
          menuItem('Map', tabName = "tab_map", icon = icon("globe")),
          menuItem("Download", tabName = "tab_download", icon = icon("download"))
          
        )),
        dashboardBody(
        tags$head(
          tags$link(rel = "stylesheet", type = "text/css",
                    href = asset("metaret.css")),
          tags$script(src = asset("metaret.js"))
        ),
        ### Home page
        tabItem("tab_homepage",
                ## The pitch
                fluidRow(
                  column(15,
                    tags$div(
                      class = "metaret-hero",
                      tags$div(class = "metaret-hero-title",
                               includeMarkdown("info_detail.md")),
                      tags$div(class = "metaret-byline",
                               includeMarkdown("info_authors.md")),
                      tags$div(class = "metaret-hero-text",
                               includeMarkdown("info_lead.md"))))),
                fluidRow(
                  column(15,
                      tags$div(
                        class = "ui five column grid metaret-figures",
                        tags$div(class = "column", valueBoxOutput("contributors", width = 16)),
                        tags$div(class = "column", valueBoxOutput("lotteries_num", width = 16)),
                        tags$div(class = "column", valueBoxOutput("quest_num_home", width = 16)),
                        tags$div(class = "column", valueBoxOutput("participants_num", width = 16)),
                        tags$div(class = "column", valueBoxOutput("countries_num", width = 16))),
                      tags$p(class = "metaret-cards-hint",
                             "Click any card to go straight to that section."),
                      tags$div(
                        class = "ui three stackable cards",
                        nav_card("tab_lotteries", "balance scale", "Tasks",
                                 "Every risk elicitation task, encyclopedia-style: what it is, how it behaves, and the papers that used it.",
                                 "red"),
                        nav_card("tab_questionnaires", "question circle", "Questionnaires",
                                 "SOEP, DOSPERT and the sensation-seeking scales, given the same treatment.",
                                 "blue"),
                        nav_card("tab_lotteries_and_questionnaires", "th", "Correlations",
                                 "The heart of the project: does a task predict what people say about themselves?",
                                 "green"),
                        nav_card("demography", "users", "Demographics",
                                 "How elicited risk attitudes differ by gender and by age.",
                                 "violet"),
                        nav_card("tab_map", "globe", "Map",
                                 "Mean risk propensity by country, everywhere the data reaches.",
                                 "orange"),
                        nav_card("tab_download", "download", "Download",
                                 "Inspect the full dataset in the browser, or take it away as a CSV.",
                                 "grey")
                      ))),


                fluidRow(
                  column(15,
                    tags$div(
                      class = "metaret-closing",

                      tags$div(
                        class = "metaret-closing-plans",
                        tags$div(
                          class = "metaret-plans",
                          tags$h2(class = "metaret-plans-title", "Where the project is going"),
                          tags$p(class = "metaret-plans-lead",
                                 "From describing how RETs are designed to understanding what makes them externally valid."),
                          step_sequence(
                            step_card("01", "Characterise RETs",
                                      "Break down each risk elicitation task into its key design features.",
                                      chips = c("Number of choices", "Outcomes",
                                                "Probabilities", "Expected value",
                                                "Losses", "Certainty")),
                            step_card("02", "Document scope and limits",
                                      "Set out exhaustively, task by task, how far the external validity of each RET reaches and where it stops."),
                            step_card("03", "Map external validity",
                                      "Identify which features of a RET are more conducive to consistency and external validity."),
                            step_card("04", "Build a more predictive RET",
                                      "Serve as the basis for a more predictive lottery-based risk elicitation task.",
                                      goal = TRUE)),
    
                          tags$p(class = "metaret-plans-note",
                                 "Along the way the site gains an ",
                                 tags$b("explore"),
                                 " section, where the dataset can be organised by any of these features to test hypotheses about consistency and external validity."))),


                      tags$div(
                        class = "metaret-closing-contribute",
                        tags$div(
                          class = "metaret-footer",
                          tags$h2(class = "metaret-footer-title", "Contribute"),
                          tags$p(class = "metaret-footer-lead",
                                 "METARET collects data of papers that have run:"),
                          tags$div(class = "metaret-footer-criteria",
                                   includeMarkdown("info_contribute.md")),
                          ## The mailto
                          tags$div(
                            class = "metaret-footer-ask",
                            tags$p("Send the paper, the data, and a data description file, and we will add it to the dataset."),
                            tags$a(class = "ui button metaret-footer-action",
                                   href = "mailto:paolo.crosetto@inrae.fr",
                                   tags$i(class = "envelope icon"),
                                   "Send us your paper and data")))))))
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
                     
                      ## Plot with its note 
                      column(12,
                             plotOutput("lotteries"),
                             note("note_task_tab1.md")),

                      ## Select box for the plot
                      column(3, box(selectInput("Tasks", "Tasks:",
                                      mychoices),  width = 3)),
                      
                      ## Information about tasks
                      column(15,
                             tags$div(class = "metaret-info",
                                      tags$h3(class = "metaret-block-title", "Information about tasks"),
                                      infoBoxOutput("info_markdown"))),

                      ## Contributed papers
                      column(15,
                             tags$h3(class = "metaret-block-title", "Contributed papers"),
                             dataTableOutput('table_papers_name')))),
                    
                    ## Second tab of tasks page
                    list(menu = "Across-task, between-subject comparison", content = list(
                      
                      ## Plot on the left, picker on the right. 
                      column(11, h5(),
                             plotOutput("lotteries_comp", width = "100%", height = "700px"),
                             note("infodistributions.md")),
                      column(4,
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
                             h5()
                            ))),
                    
                    ## Third tab for task page

                    list(menu = 'Within-task, across-paper comparison', content = list(
                      column(12,
                             plotOutput("everytask", width = "100%", height = "820px"),
                             note("infotasksevrpaper.md")),
                      column(3, box(selectInput("selectedtask", "Tasks:",
                                                mychoices), width = 16))))
                    ))
                  ),
        
        ## Questionnaires page  
        tabItem("tab_questionnaires",
                fluidRow(
                  valueBoxOutput("paper_num", width = 5),
                  valueBoxOutput("task_num", width = 5),
                  valueBoxOutput("quest_num", width = 5)),

                ## Plot with its note
                column(12,
                       plotOutput("questionnaires"),
                       note("note_quest_tab1.md")),

                ## Select box for the plot
                column(3, box(selectInput("Questionnaires", "Questionnaires:",
                                          questionchoice), width = 3)),

                ## Information about questions 
                column(15,
                       tags$div(class = "metaret-info",
                                tags$h3(class = "metaret-block-title", "Information about questions"),
                                infoBoxOutput("info_markdown_quest"))),

                ## Contributed papers
                column(15,
                       tags$h3(class = "metaret-block-title", "Contributed papers"),
                       dataTableOutput('table_papers_name_quest'))),
        
        ## Correlations page
        tabItem("tab_lotteries_and_questionnaires",
                tabBox(color = "black", width = 16,
                  tabs = list(

                    ## First tab: tasks against questionnaires
                    list(menu = "Task ↔ Questionnaire", content = list(
                    
                      column(10,
                             plotOutput("corr_quest_task", width = "auto", height = "auto"),
                             note("note_taskquest_tab1.md")),

                      column(5,
                             tags$div(
                               class = "metaret-pickers",
                               tags$div(
                                 class = "metaret-picker",
                                 tags$b("Select RET types"),
                                 actionButton("selectalltasks", "Select/Deselect all"),
                                 multiple_checkbox("amongcorrs_1",
                                                   label = NULL,
                                                   choices = names(mychoices),
                                                   choices_value = unname(mychoices),
                                                   position = 'inline',
                                                   selected = c("HL", "EG"))),
                               tags$div(
                                 class = "metaret-picker",
                                 tags$b("Select question types"),
                                 actionButton("selectallquest", "Select/Deselect all"),
                                 multiple_checkbox("amongquest_1",
                                                   label = NULL,
                                                   choices = names(questionchoice_cor),
                                                   choices_value = unname(questionchoice_cor),
                                                   position = 'inline',
                                                   selected = c("soep", "dohealth", 'dogamble')))),
                             ## the figure's download 
                             tags$div(class = "metaret-picker-action",
                                      downloadButton('dl_corr_quest_task', 'Download this figure (PNG)',
                                                     style = "color: #fff; background-color: green; border-color: Black; padding: 5px 14px 5px 14px;margin: 5px 5px 5px 5px; ",
                                                     icon = shiny::icon('download')))))),

                    ## Second tab: tasks against each other
                    list(menu = "Task ↔ Task", content = list(
                      column(11,
                             plotOutput("corr_tasks", width = "auto", height = "auto"),
                             note("infocorrtasks.md")),

                      column(4,
                             tags$div(
                               class = "metaret-pickers",
                               tags$div(
                                 class = "metaret-picker",
                                 tags$b("Choose RETs to display correlations"),
                                 actionButton("selectalltaskcorrs", "Select/Deselect all"),
                                 multiple_checkbox("amongcorrs",
                                                   label = NULL,
                                                   choices = names(mychoices),
                                                   choices_value = unname(mychoices),
                                                   position = 'inline',
                                                   selected = c("HL", "EG", 'BART')))),
                             ## the figure's download
                             tags$div(class = "metaret-picker-action",
                                      downloadButton('dl_corr_tasks', 'Download this figure (PNG)',
                                                     style = "color: #fff; background-color: green; border-color: Black; padding: 5px 14px 5px 14px;margin: 5px 5px 5px 5px; ",
                                                     icon = shiny::icon('download')))))),

                    ## Third tab: the questionnaire baseline
                    list(menu = "Questionnaire ↔ Questionnaire", content = list(
                      column(11,
                             plotOutput("corr_quest", width = "auto", height = "auto"),
                             note("infocorrquest.md")),

                      column(4,
                             tags$div(
                               class = "metaret-pickers",
                               tags$div(
                                 class = "metaret-picker",
                                 tags$b("Choose question types to display correlations"),
                                 actionButton("selectallcorrquest", "Select/Deselect all"),
                                 multiple_checkbox("amongquest",
                                                   label = NULL,
                                                   choices = names(questionchoice_gender),
                                                   choices_value = unname(questionchoice_gender),
                                                   position = 'inline',
                                                   selected = c("soep", "dohealth", 'dogamble')))),
                             ## the figure's download
                             tags$div(class = "metaret-picker-action",
                                      downloadButton('dl_corr_quest', 'Download this figure (PNG)',
                                                     style = "color: #fff; background-color: green; border-color: Black; padding: 5px 14px 5px 14px;margin: 5px 5px 5px 5px; ",
                                                     icon = shiny::icon('download'))))))
                  ))
        ),
        
        tabItem("demography",
                tabBox(color = "black", width = 16,
                       tabs = list(
                         list(menu = "Gender differences by task",  content = list(
                           fluidRow(valueBoxOutput("quant_gend_contr", width = 5),
                                    valueBoxOutput("quant_femmes", width = 5),
                                    valueBoxOutput("quant_hommes", width = 5)),
                           ## Plot with possibility to chose one task
                           column(12,
                                  plotOutput("gender_dist"),
                                  note("demography_gender.md")),

                           ## Select box for the plot
                           column(3, box(selectInput("genderdist", "Tasks:",
                                                     mychoicesgender),  width = 3))
                           )
                       ),
                       list(menu = "Gender differences by questionnaire",  content = list(
                         fluidRow(valueBoxOutput("quant_gend_contr_q", width = 5),
                                  valueBoxOutput("quant_femmes_q", width = 5),
                                  valueBoxOutput("quant_hommes_q", width = 5)),
                         
                         column(12,
                                plotOutput("gender_dist_quest"),
                                note("demography_gender.md")),

                         ## Select box for the plot
                         column(3, box(selectInput("genderdist_quest", "Questions:",
                                                   questionchoice_gender),  width = 3))
                       )),
                       list(menu = "Age gradient by task",  content = list(
                         
                         fluidRow(valueBoxOutput("quant_contr_a", width = 5),
                                  valueBoxOutput("quant_femmes_a", width = 5),
                                  valueBoxOutput("quant_hommes_a", width = 5)),
                         
                         ## Plot with possibility to chose one task
                         column(12, plotOutput("age_dist")),

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
                         column(12, plotOutput("age_dist_quest")),

                         ## Select box for the plot
                         column(3,
                                box(selectInput("agedist_q", "Questions:",
                                                questionchoice_agetab),  width = 3)
                         )
                       )))
                       )),
        
        ## Download page
        tabItem("tab_download",
                tabBox(color = "black", width = 16,
                  tabs = list(
                  
                  ## First tab with tasks 
                  list(menu = "Tasks",  content = list(column(15,
                    tags$div(class = "metaret-intro", includeMarkdown("info_download_task.md")),
                    
                    
                    ## Download button code 
                    h5(), h5(),
                    downloadButton('downloadData', 'Download all task data',  
                                   style="color: #fff; background-color: green; border-color: Black; padding: 5px 14px 5px 14px;margin: 5px 5px 5px 5px; ",
                                   icon = shiny::icon('download')),
                    h5()),
                    
                    ## Table with tasks information
                    column(15, dataTableOutput("page1")))),
                  
                  ## Second tab with tasks 
                  list(menu = "Questionnaires", content = list(column(15,
                  
                    tags$div(class = "metaret-intro", includeMarkdown("info_download_quest.md")),
                    
                    ## Download button code 
                    h5(), h5(),
                    downloadButton('downloadData2', 'Download all questionnaire data',  
                                   style="color: #fff; background-color: green; border-color: Black; padding: 5px 14px 5px 14px;margin: 5px 5px 5px 5px; ",
                                   icon = shiny::icon('download')),
                    h5()),
                    ## Table with questions information
                    column(15, dataTableOutput("page2")))))
                )),

        
        ## Map page

        tabItem("tab_map",
                tabBox(color = "black", width = 16,
                       tabs = list(
                         list(menu = "Risk propensity map",
                              content = leafletOutput("map_crra",
                                              width = "100%",
                                              height = "calc(100vh - 59px)")))
                       ))
        ))
