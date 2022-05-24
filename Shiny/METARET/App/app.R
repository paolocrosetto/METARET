## Libraries

library(shiny)
library(shinyjs)
library(shinydashboard)
library(shinydashboardPlus)
library(semantic.dashboard)
library(shinipsum)
library(babynames)
library(DT)
library(tidyverse)      ## basic data wrangling and plotting libraries
library(broom)          ## apply correlations to whole papers in one go
library(hrbrthemes)     ## cool ggplot theming
source("flat_violin.R") ## used for creating the 'raincloud' plot
library(ggbeeswarm)     ## quasirandom jitter
library(GGally)         ## correlation plot
library(RColorBrewer)   ## colors
library(dplyr)    
library(bib2df) 

# import the bibfile
bibdf <- bib2df("METARET.bib")

## clean the bibfile
## keep the authors, title, journal, year, DOI

# clean names
bibdf <- bibdf %>% 
  janitor::clean_names() %>% 
  rename(bibkey = bibtexkey)

bibs <- bibdf %>% select(bibkey, author, title, year, journal, doi_2)
df <- read.csv("df_mod.csv", sep = ";")
df <- merge(x=df, y=bibs, by="bibkey", all.x=TRUE)

mychoices = c("Holt and Laury" = "HL",
              "Binswanger / Eckel and Grossmann" = "EG",
              "Investment Game" = "IG",
              "Bomb Risk Elicitation Task" = "BRET",
              "Balloon Analog Risk Task" = "BART",
              "Certainty equivalent price list" = "CEPL")

questionchoice <- c("SOEP" = "soep",
                    "SOEP - financial" = "soep_financial",
                    "DOSPERT" = "doall",
                    "DOSPERT - health" = "dohealth",
                    "DOSPERT - social" = "dosocial",
                    "DOSPERT - investment" = "doinvest",
                    "DOSPERT - gamble" = "dogamble",
                    "DOSPERT - ethic" = "doethic",
                    "DOSPERT - recreation" = "dorecre")

ui <- dashboardPage(theme  = "solar", dashboardHeader(title = 'METARET'),
                    dashboardSidebar(    
                      sidebarMenu(
                      menuItem("Home page ", tabName = "tab_homepage", icon = icon("home")),
                      menuItem("Tasks", tabName = "tab_lotteries", icon = icon("trophy")),
                      menuItem("Questionnaires", tabName = "tab_questionnaires", icon = icon("question")),
                      menuItem("Tasks and Questionnaires", tabName = "tab_lotteries_and_questionnaires ", icon = icon("images")),
                      menuItem("Explore", tabName = "tab_explore", icon = icon("compass")),
                      menuItem("About", tabName = "tab_about", icon = icon("info"))
                    )),
                    dashboardBody(
                  tags$head(tags$style(HTML(".small-box {height: 50px}"))),
                        tabItem("tab_homepage", 
                              fluidRow(
                                valueBoxOutput("contributors", width = 5),
                                valueBoxOutput("lotteries_num", width = 5),
                                valueBoxOutput("participants_num", width = 5))),
                        tabItem("tab_lotteries",
                                tabBox( color = "black", width = 16,
                                        tabs = list(
                                          list(menu = "Tasks",  content = list(fluidRow(
                                            valueBoxOutput("contributors_lot", width = 5),
                                            valueBoxOutput("participants_num_lot", width = 5),
                                            valueBoxOutput("num_obs", width = 5)),
                                            
                                            box(plotOutput("lotteries"),
                                                width = 12),
                                            box(selectInput("Tasks", "Tasks:",
                                                            c('HL', 'EG', 'IG', "BRET", 'BART', 'CEPL')), width = 3),
                                            box(title = "Rules for tasks",
                                                ribbon = F, background = "black", 
                                                width = 16,
                                                includeMarkdown("include.md")),
                                           
                                            div(box(title = "Contributed papers",
                                                solidHeader = TRUE,
                                                collapsed = FALSE, collapsible = TRUE,
                                                width = 16,
                                                color = 'black',
                                                status = "success",
                                                dataTableOutput('table_papers_name'))
                                            ))),
                                            list(menu = "Across tasks", content = list(
                                              tabPanel("Correlations among tasks",
                                                       fluidPage( width = 3,
                                                                  h5(),
                                                                  h5("Choose a RET to display density distributions"),
                                                                  hr(),
                                                                  checkboxInput('All', "Select All/None", value = TRUE),
                                                                  h5(),
                                                                  checkboxGroupInput("amongtasks", NULL,
                                                                                     mychoices,
                                                                                     selected = c("HL","EG")
                                                                  ))),
                                              box(plotOutput("lotteries_comp"), width = 15)
              
                                                      )
                                        )))),
                  tabItem("tab_questionnaires", 
                          box(plotOutput("questionnaires"),
                              width = 12),
                          box(selectInput("Questionnaires", "Questionnaires:",
                                          questionchoice), width = 3)),
                      tabItem("tab_explore",
                      
                        tabBox( color = "black", width = 16,
                               tabs = list(
                                 list(menu = "Tasks",  content = dataTableOutput("page1")),
                                 list(menu = "Questionnaires", content = dataTableOutput("page2"))
                     )))
                     ))
                   
# density by task 
plotDensity <- function(task, data) {

  data <- data %>% 
    filter(r > -1.5 & r < 2.5) %>% 
    mutate(m = mean(r, na.rm = T)) %>% 
    mutate(n = n()) 
  
  data %>% 
    ggplot(aes(x = r)) +
    geom_density(color="white", fill="orange", alpha = 0.7, 
                 adjust = 0.8)  + 
    geom_boxplot(fill = 'white',
                 color = 'grey30',
                 width = 0.25,
                 outlier.alpha = 0,
                 alpha = 0) +
    geom_jitter(aes(r,0), height = 0.1, color = 'purple', size = 0.1) +
    geom_vline(xintercept = 1, color = 'red', linetype = 'dashed', show.legend = F) +
    labs(x = "Risk aversion parameter CRRA",
         y = "Density",
         title = paste0("Distribution of ", data$task[[1]], " task")) + 
    theme(
      panel.background = element_rect(fill = "white"), 
      panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                      colour = "grey"), text=element_text(size=20)
    ) 
}

# density by task 
plotDensity1 <- function(tasklist, data) {
  
  data <- df %>% 
    filter(r > -1.5 & r < 2.5) %>% 
    group_by(task) %>% 
    mutate(m = mean(r, na.rm = T),
           sd = sd(r, na.rm = T),
           se = sd/sqrt(n()),
           ci = se * qt(.95/2 + .5, n()-1),
           cih = m+ci,
           cil = m-ci) %>% 
    mutate(n = n()) %>% 
    ungroup() %>% 
    mutate(task = reorder(task,r))
  
  values <- c(rev(brewer.pal(length(levels(data$task)), "Set1")))
  names(values) <- levels(data$task)
  
  plot <- data %>% 
    mutate(task = paste0(task, " (N = ",n,")")) %>% 
    ggplot(aes(task, r, colour = task, fill = task)) +
    geom_flat_violin(position = position_nudge(x = 0.15, y = 0),
                     alpha = 0.7, 
                     adjust = 0.8,
                     scale = "width",
                     color = "white") +
    geom_point(alpha = 0.4,
               position = position_jitter(width = 0.12, height = 0),
               size = 0.8, show.legend = F, 
               shape = 21,
               color = "white") +  
    geom_boxplot(fill = 'white',
                 color = 'grey30',
                 width = 0.25,
                 outlier.alpha = 0,
                 alpha = 0) +
    # geom_errorbar(aes(ymin = cil, ymax = cih), width = 0.05, position = position_nudge(x = -0.2), show.legend = F)+
    # geom_point(aes(y = m), shape = 21, size = 2, position = position_nudge(x = -0.2), show.legend = F)+
    
    geom_hline(yintercept = 1, color = 'red', linetype = 'dashed', show.legend = F)+
    labs(y = "Risk aversion parameter CRRA",
         x = "")+
    theme(legend.title = element_blank(),
          legend.position = "none",
          panel.background = element_rect(fill = "white"), 
          panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                          colour = "grey"), text=element_text(size=20))+
    coord_flip()
  
  plot %+% droplevels(data[data$task %in% tasklist,]) +
    scale_fill_manual(values = values)+
    scale_color_manual(values = values)
}

plotDensity2 <- function(tasklist, data) {
  data %>% 
    ggplot(aes(x = values)) +
    geom_density(color="white", fill="orange", alpha = 0.7, 
                 adjust = 0.8)  + 
    geom_boxplot(fill = 'white',
                 color = 'grey30',
                 width = 0.1,
                 outlier.alpha = 0,
                 alpha = 0) +
    geom_jitter(aes(values,0), height = 0.05, color = 'green', size = 0.05) +
    labs(x = "Choises",
         y = "Density",
         title = paste0("Distribution of answers on ", data$name[1], " questions")) + 
    theme(
      panel.background = element_rect(fill = "white"), 
      panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                      colour = "grey"), text=element_text(size=20)
    ) 
}

if (interactive()) {
server <- function(input, output, session){
  # Create reactive value where we'll assign data
  value <- reactiveValues(data = NULL)
  
  output$contributors_lot <- renderValueBox({ 
    value_box(
      "Number of contributors"
      ,n_distinct(filter(df, task == input$Tasks) %>% select(paper))
      ,icon("stats")
      ,color = "green")  
  })

  
  output$participants_num_lot <- renderValueBox({ 
    value_box(
      'Number of participants',
      n_distinct(filter(df, task == input$Tasks) %>% select(subject))
      ,icon = icon("menu-hamburger",lib='glyphicon')
      ,color = "purple")  
  })
  
  output$num_obs<- renderValueBox({ 
    value_box(
      "Number of observations"
      ,filter(df, task == input$Tasks) %>% select('name') %>% nrow()
      ,icon("stats")
      ,color = "yellow")  
  })
  
  output$lotteries <- renderPlot({
    data <- df %>%filter(task == input$Tasks)
    plotDensity(input$Tasks, data)
  })
  
  output$lotteries_comp <- renderPlot({
    data <- df %>%filter(task == input$amongtasks)
    plotDensity1(input$amongtasks, data)
  })
  
  observe({
      updateCheckboxGroupInput(session, "amongtasks", NULL,choices=mychoices, selected = if(input$All) mychoices)
  })

  output$table_papers_name <- renderDataTable(
      filter(df, task == input$Tasks) %>% 
        select(author, title, year, journal, doi_2) %>% 
        unique() %>% as.data.frame(row.names = 1:nrow(.)))  
  
  output$table_papers_link <- renderDataTable(
    filter(df, task == input$Tasks) %>% 
      select('link') %>% drop_na() %>%
      unique() %>% as.data.frame(row.names = 1:nrow(.)) %>% lapply(as.character))
  
  output$contributors <- renderValueBox({ 
    value_box(
      "Number of contributors"
      ,n_distinct(df$paper)
      ,icon("stats")
      ,color = "green")  
  })
  
  output$lotteries_num <- renderValueBox({ 
    value_box(
      'Number of tasks',
      n_distinct(df$task)
      ,icon = icon("menu-hamburger",lib='glyphicon')
      ,color = "yellow")  
  })
  
  output$participants_num <- renderValueBox({ 
    value_box(
      'Number of participants',
      n_distinct(df$subject)
      ,icon = icon("menu-hamburger",lib='glyphicon')
      ,color = "purple")  
  })
  
  output$questionnaires <- renderPlot({
    data <- df %>% select(subject, starts_with('soep'), starts_with('do')) %>% 
      select(-doi_2) %>%
      pivot_longer(-subject, values_to = 'values', names_to = 'name') %>%
      filter(name == input$Questionnaires) %>% drop_na()
    plotDensity2(input$Questionnaires, data)
  })
  
  output$page1 <- DT::renderDataTable({df %>% 
                                      select('subject', 'paper', 
                                             
                                             'task', "age", "gender",
                                             "choice", "r")})
  output$page2 <- DT::renderDataTable({df %>% 
                                           select('subject', 'paper', 
                                                  
                                                  'soep', starts_with("do"))})
}
}

shinyApp(ui, server)

