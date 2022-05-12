## packages for the project
source("libraries.R")

# import the bibfile
bibdf <- bib2df("METARET.bib")

## clean names
bibdf <- bibdf %>% 
  janitor::clean_names() %>% 
  rename(bibkey = bibtexkey)

## keep the authors, title, journal, year, DOI
bibs <- bibdf %>% select(bibkey, author, title, year, journal, doi_2)
df <- read.csv("df_mod.csv", sep = ";")
df <- merge(x=df, y=bibs, by="bibkey", all.x=TRUE)

## Server function 
  server <- function(input, output, session){
    
    ## Home page 
    output$contributors_lot <- renderValueBox({ 
      value_box(
        "Number of contributors"
        ,n_distinct(filter(df, task == input$Tasks) %>% select(paper))
        ,color = "green")  
    })
    
    output$participants_num_lot <- renderValueBox({ 
      value_box(
        'Number of participants',
        n_distinct(filter(df, task == input$Tasks) %>% select(subject))
        ,color = "purple")  
    })
    
    output$num_obs<- renderValueBox({ 
      value_box(
        "Number of observations"
        ,filter(df, task == input$Tasks) %>% select('name') %>% nrow()
        ,color = "yellow")  
    })
    
    ## Tasks page 
      ## First tab Tasks page 
    output$contributors <- renderValueBox({ 
      value_box(
        "Number of contributors"
        ,n_distinct(df$paper)
        ,color = "green")  
    })
    
    output$lotteries_num <- renderValueBox({ 
      value_box(
        'Number of tasks',
        n_distinct(df$task)
        ,color = "yellow")  
    })
    
    output$participants_num <- renderValueBox({ 
      value_box(
        'Number of participants',
        n_distinct(df$subject)
        ,color = "purple")  
    })
    
    output$lotteries <- renderPlot({
      data <- df %>%filter(task == input$Tasks)
      source("plot_lotteries.R")
      plotDensity(input$Tasks, data)
    })

    output$table_papers_name <- renderDataTable(
      filter(df, task == input$Tasks) %>% 
        select(bibkey, author, title, year, journal, doi_2) %>% 
        unique() %>% as.data.frame(row.names = 1:nrow(.)))  
    
    output$table_papers_link <- renderDataTable(
      filter(df, task == input$Tasks) %>% 
        select('link') %>% drop_na() %>%
        unique() %>% as.data.frame(row.names = 1:nrow(.)) %>% lapply(as.character))
    
      ## Second tab Tasks page 
    observe({
      updateCheckboxGroupInput(session, "id_selectInput", NULL,choices=mychoices)
    })
    
    output$lotteries_comp <- renderPlot({
      data <- df %>% filter(task == input$id_selectInput)
      source("plot_many_lotteries.R")
      plotDensity1(input$id_selectInput, data)
    }, height = 700, width = 900)
    
    
    ## Third tab tasks page 
    observe({
      updateCheckboxGroupInput(session, "amongcorrs", NULL,choices=mychoices)
    })

    output$corr_tasks <- renderPlot({ 
    data <- df %>% 
        filter(r > -1.5 & r < 2.5) %>% 
        distinct(subject,task, .keep_all= TRUE) %>%
        select(task, r, subject) %>% 
        pivot_wider(subject, names_from = 'task', values_from = "r") %>% 
        select(-c(subject, EG_loss)) %>% 
        select(input$amongcorrs)
      ggcorrm(data = data) +
        lotri(geom_point(alpha = 0.5)) +
        lotri(geom_smooth(method = "lm", size = 0.4, alpha = 0.6)) +
        utri_heatmap() +
        utri_corrtext() +
        dia_names(y_pos = 0.15, size = 4) +
        dia_histogram(lower = 0.3, fill = "grey80", color = 1) +
        scale_fill_corr() +
        theme(text = element_text(size=20),
              axis.text = element_blank(),
              axis.ticks = element_blank(),
              strip.text = element_blank(), 
              legend.key.size = unit(1.5, 'cm')) 
    }, height = 700, width = 900 )
    
    ## Questionnaires page
      ## First tab questionnaires page
    output$task_num <- renderValueBox({ 
      value_box(
        "Number of tasks"
        , n_distinct(df %>% select(subject, task, starts_with('soep'), starts_with('do')) %>% 
                       select(-doi_2) %>%
                       pivot_longer(-c(subject, task), values_to = 'values', names_to = 'name') %>%
                       filter(name == input$Questionnaires) %>% drop_na() %>% select(task))
        ,color = "green")  
    })
    output$paper_num <- renderValueBox({ 
      value_box(
        "Number of contributors"
        , n_distinct(df %>% select(subject, bibkey, starts_with('soep'), starts_with('do')) %>% 
                       select(-doi_2) %>%
                       pivot_longer(-c(subject, bibkey), values_to = 'values', names_to = 'name') %>%
                       filter(name == input$Questionnaires) %>% drop_na() %>% select(bibkey))
        ,color = "green")  
    })
    
    output$quest_num <- renderValueBox({ 
      value_box(
        "Number of participants"
        , n_distinct(df %>% select(subject, task, starts_with('soep'), starts_with('do')) %>% 
                       select(-doi_2) %>%
                       pivot_longer(-c(subject, task), values_to = 'values', names_to = 'name') %>%
                       filter(name == input$Questionnaires) %>% drop_na() %>% select(subject))
        ,color = "green")  
    })

    output$questionnaires <- renderPlot({
      data <- df %>% select(subject, starts_with('soep'), starts_with('do')) %>% 
        select(-doi_2) %>%
        pivot_longer(-subject, values_to = 'values', names_to = 'name') %>%
        filter(name == input$Questionnaires) %>% drop_na()
      source("plot_questionnaires.R")
      plotDensity2(input$Questionnaires, data)
    })
    
    ## Second tab questionnaires page
    
    observe({
      updateCheckboxGroupInput(session, "amongquest", NULL,choices=questionchoice)
    })
    
    
    output$corr_quest <- renderPlot({ 
      data = df %>% 
        select(starts_with('soep'), starts_with('do'), -doi_2) %>%
        filter(df$soep != 'Na') %>% 
        select(input$amongquest)
      
      ggcorrm(data = data) +
        lotri(geom_point(alpha = 0.5)) +
        lotri(geom_smooth(method = "lm", size = 0.4, alpha = 0.6)) +
        utri_heatmap() +
        utri_corrtext() +
        dia_names(y_pos = 0.15, size = 4) +
        dia_histogram(lower = 0.3, fill = "grey80", color = 1) +
        scale_fill_corr() +
        theme(text = element_text(size=20),
              axis.text = element_blank(),
              axis.ticks = element_blank(),
              strip.text = element_blank(), 
              legend.key.size = unit(1.5, 'cm')) 
      }, height = 700, width = 900 )
    
    ## Explore page 
    
      ## First tab explore page
    output$table_papers_name_quest <- renderDataTable(
      df %>% filter(df[input$Questionnaires] != 'Na') %>%
        select(author, title, year, journal, doi_2) %>% 
        unique() %>% as.data.frame(row.names = 1:nrow(.)))  
    
    output$page1 <- DT::renderDataTable({df %>% 
        select('subject', 'paper', 
               'task', "age", "gender",
               "choice", "r")})
    
    data <- df %>% 
      select('subject', 'paper', 
             'task', "age", "gender",
             "choice", "r")
    
    output$downloadData <- downloadHandler(
      filename = function() {
        paste("data-", Sys.Date(), ".csv", sep="")
      },
      content = function(file) {
        write.csv(data, file)
      }
    )
    
    ## Second tab explore page
    output$page2 <- DT::renderDataTable({df %>% 
        select('subject', 'paper', 'task',
               starts_with('soep'), starts_with("do"), -doi_2) %>%
        filter((soep != 'Na') | (dosocial != 'Na') | (dohealth != 'Na')) %>% 
        pivot_longer(-c(subject, paper, task), values_to = 'choice', names_to = 'type of question') %>%
        drop_na()})
    
    data <- df %>% 
      select('subject', 'paper', 'task',
             starts_with('soep'), starts_with("do"), -doi_2) %>%
      filter((soep != 'Na') | (dosocial != 'Na') | (dohealth != 'Na')) %>% 
      pivot_longer(-c(subject, paper, task), values_to = 'choice', names_to = 'type of question') %>%
      drop_na()
    
    output$downloadData2 <- downloadHandler(
      filename = function() {
        paste("data-", Sys.Date(), ".csv", sep="")
      },
      content = function(file) {
        write.csv(data, file)
      }
    )
}