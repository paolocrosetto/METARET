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
df <- read.csv("DATA/DATA/df_mod.csv", sep = ",")
df <- merge(x=df, y=bibs, by="bibkey", all.x=TRUE) 

## Function to create links in the table
createLink <- function(val) {
  sprintf('<a href="http://dx.doi.org/%s" target="_blank" class="btn btn-primary">Click</a>',val)
}

## Server function 
  server <- function(input, output, session){
    
    ## Home page 
    output$contributors <- renderValueBox({ 
      value_box(
        "Number of contributors"
        ,n_distinct(df$paper)
        ,color = "green")  
    })
    
    output$lotteries_num <- renderValueBox({ 
      value_box(
        'Number of tasks',
        df %>% filter(task != 'quest_only') %>%
          select(task) %>%
          n_distinct()
        ,color = "yellow")  
    })
    
    output$participants_num <- renderValueBox({ 
      value_box(
        'Number of participants',
        n_distinct(df$subject)
        ,color = "purple")  
    })
    
    ## Tasks page 
      ## First tab Tasks page 
    
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
        ,filter(df, task == input$Tasks) %>% select('subject') %>% nrow()
        ,color = "yellow")  
    })
    
    output$lotteries <- renderPlot({
      data <- df %>%filter(task == input$Tasks)
      source("plot_lotteries.R")
      plotDensity(input$Tasks, data)
    })
    
    output$info_markdown <- renderInfoBox({
      source('description.R')
      df = new_data %>% filter(tasks == input$Tasks) %>% pull(desc) 
      includeMarkdown(df)
    })

    output$table_papers_name <- renderDataTable({
      table = filter(df, task == input$Tasks) %>% 
        group_by(author, title, year, journal, doi_2) %>% 
        summarise(sample=n())
      table$link <- createLink(table$doi_2)
      table = table %>% select(-doi_2)
      return(table)}, escape = FALSE)
    
      ## Second tab Tasks page 
    
    observe({
      if(input$selectalltaskdist == 0) return(NULL) 
      else if (input$selectalltaskdist%%2 == 0)
      {
        updateCheckboxGroupInput(session,"id_selectInput",choices=mychoices, selected = mychoices)
      }
      else
      {
        updateCheckboxGroupInput(session,"id_selectInput",choices=mychoices, selected=list())
      }
    })
    
    observe({
      updateCheckboxGroupInput(session, "id_selectInput", NULL,choices=mychoices)
    })
    
    output$lotteries_comp <- renderPlot({
      data <- df %>% filter(task == input$id_selectInput)
      source("plot_many_lotteries.R")
      plotDensity1(input$id_selectInput, data)
    }, height = 600, width = 900)
    
    
    ## Third tab tasks page 
    
    observe({
      if(input$selectalltaskcorrs == 0) return(NULL) 
      else if (input$selectalltaskcorrs%%2 == 0)
      {
        updateCheckboxGroupInput(session,"amongcorrs",choices=mychoices, selected = mychoices)
      }
      else
      {
        updateCheckboxGroupInput(session,"amongcorrs",choices=mychoices, selected=list())
      }
    })
    
    observe({
      updateCheckboxGroupInput(session, "amongcorrs", NULL,choices=mychoices)
    })

    output$corr_tasks <- renderPlot({ 
    data <- df %>% 
        filter(r > -1.5 & r < 2.5) %>% 
        distinct(subject,task, .keep_all= TRUE) %>%
        select(task, r, subject) %>% 
        pivot_wider(subject, names_from = 'task', values_from = "r") %>% 
        select(-subject) %>% 
        select(input$amongcorrs)
      ggcorrm(data = data) +
        lotri(geom_point(alpha = 0.5)) +
        lotri(geom_smooth(method = "lm", size = 0.4, alpha = 0.6)) +
        utri_heatmap() +
        utri_corrtext(corr_size = FALSE, size = 6) +
        dia_names(y_pos = 0.15, size = 4) +
        dia_histogram(lower = 0.3, fill = "grey80", color = 1) +
        scale_fill_corr() +
        theme(text = element_text(size=20),
              axis.text = element_blank(),
              axis.ticks = element_blank(),
              strip.text = element_blank(), 
              legend.title=element_blank(),
              legend.key.size = unit(1.5, 'cm')) +
        scale_fill_continuous(
          limits = c(min(cor(data, use = 'pairwise.complete.obs'), na.rm = T), 1)) + 
        scale_fill_gradient2(low = "#ea97a3", high = "#36a338", mid = 'white', midpoint = .0,  na.value = NA)
    }, height = 600, width = 900 )
    
    
    ## Fourth tab tasks page 
    output$everytask <- renderPlot({
      data <- df %>% filter(task == input$selectedtask) %>% 
        filter(r > -1.5 & r < 2.5) 
      source("function_each_type_of_task.R")
      task_variability_plot(input$selectedtask, data)
    }, height = 650, width = 800)
    
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
    
    output$info_markdown_quest <- renderInfoBox({
      source('description_quest.R')
      df = new_data %>% filter(quest == input$Questionnaires) %>% pull(desc) 
      includeMarkdown(df)
    })
    
    output$table_papers_name_quest <- renderDataTable({
      table = df %>% filter(df[input$Questionnaires] != 'Na') %>%
      group_by(author, title, year, journal, doi_2) %>% summarise(sample=n())
      table$link <- createLink(table$doi_2)
      table = table %>% select(-doi_2)
      return(table)}, escape = FALSE)
    
    ## Second tab questionnaires page
    
    observe({
      if(input$selectallcorrquest == 0) return(NULL) 
      else if (input$selectallcorrquest%%2 == 0)
      {
        updateCheckboxGroupInput(session,"amongquest",choices=questionchoice, selected = questionchoice)
      }
      else
      {
        updateCheckboxGroupInput(session,"amongquest",choices=questionchoice, selected=list())
      }
    })
    
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
        utri_corrtext(corr_size = FALSE, size = 6) +
        dia_names(y_pos = 0.15, size = 4) +
        dia_histogram(lower = 0.3, fill = "grey80", color = 1) +
        scale_fill_corr() +
        theme(text = element_text(size=20),
              axis.text = element_blank(),
              axis.ticks = element_blank(),
              strip.text = element_blank(), 
              legend.title=element_blank(),
              legend.key.size = unit(1.5, 'cm')) +
        scale_fill_continuous(
          limits = c(min(cor(data, use = 'pairwise.complete.obs'), na.rm = T), 1)) + 
        scale_fill_gradient2(low = "#ea97a3", high = "#36a338", mid = 'white', midpoint = .0, na.value = NA)
      }, height = 600, width = 900 )
    
    ## Tasks and questionnaire page
    
    observe({
      if(input$selectalltasks == 0) return(NULL) 
      else if (input$selectalltasks%%2 == 0)
      {
        updateCheckboxGroupInput(session,"amongcorrs_1",choices=mychoices, selected = mychoices)
      }
      else
      {
        updateCheckboxGroupInput(session,"amongcorrs_1",choices=mychoices, selected=list())
      }
    })
    
      observe({
        if(input$selectallquest == 0) return(NULL) 
        else if (input$selectallquest%%2 == 0)
        {
          updateCheckboxGroupInput(session,"amongquest_1",choices=questionchoice, selected = questionchoice)
        }
        else
        {
          updateCheckboxGroupInput(session,"amongquest_1",choices=questionchoice, selected=list())
        }
      })

    
    output$corr_quest_task <- renderPlot({  
      data <- df %>%
        filter(r > -1.5 & r < 2.5) %>% 
        distinct(subject, task, .keep_all= TRUE) %>%
        select(task, r, subject, input$amongquest_1)  %>% 
        pivot_wider(c(subject, input$amongquest_1), names_from = 'task', values_from = "r") %>% 
        select(-c(subject)) %>% 
        select(input$amongcorrs_1, input$amongquest_1) %>% 
        cor(use = "pairwise.complete.obs") %>% 
        as.data.frame() %>%
        select(input$amongquest_1) %>%
        t %>%
        as.data.frame() %>%
        select(-(input$amongquest_1)) %>%
        t %>%
        t
      
      corrplot(data, method = 'color', 
               col.lim=c(min(data, na.rm = T), 
               max(data, na.rm = T)),
               addCoef.col = 'black',
               tl.col = 'black',  
               col = COL2('PiYG', 20), 
               na.label = "  ", tl.srt = 0, number.cex = 1.6, 
               cl.cex = 1.2, 
               tl.cex = 1.2)
      }, height = 650, width = 900 )
    
    ## Demography page 
    
    ## Gender task tab
    
    output$quant_gend_contr<- renderValueBox({ 
      value_box(
        "Number of contributors"
        ,if (input$genderdist == 'all'){
          n_distinct(df %>% 
                      select(gender,paper) %>% 
                      drop_na() %>% select(paper)) }
        else {n_distinct(filter(df, task == input$genderdist) %>% 
                            select(gender,paper) %>% 
                            drop_na() %>% select(paper))
          } ,color = "blue") 
    })
    
    output$quant_femmes <- renderValueBox({ 
      value_box(
        "Number of women"
        ,if (input$genderdist == 'all'){
          count(filter(df, gender == '1'))}
        else {
          count(filter(df, task == input$genderdist, gender == '1'))
        }
        ,color = "blue")  
    })
    
    output$quant_hommes <- renderValueBox({ 
      value_box(
        "Number of men"
        ,if (input$genderdist == 'all'){
          count(filter(df, gender == '0'))}
        else {
          count(filter(df, task == input$genderdist, gender == '0'))
        }
        ,color = "blue")  
    })
    
    output$gender_dist <- renderPlot({
      if (input$genderdist == 'all'){
      data = df %>% 
        filter(r > -1.5 & r < 2.5)}
      else {
        data = df %>% 
          filter(r > -1.5 & r < 2.5) %>% filter(task == input$genderdist)
      }
      source("plot_gender_distributions.R")
      plotgender(input$genderdist, data)
    })
    
    observe({
      updateCheckboxGroupInput(session, "genderdist", NULL,choices=mychoicesgender)
    })
    
    ## Gender questions tab
    
    output$quant_gend_contr_q<- renderValueBox({ 
      value_box(
        "Number of contributors"
        ,n_distinct(df %>% select(input$genderdist_quest, paper) %>% 
                           drop_na() %>% select(paper))
        ,color = "blue") 
    })
    
    output$quant_femmes_q <- renderValueBox({ 
      value_box(
        "Number of women"
        ,
          count(filter(df, gender == '1') %>% select(input$genderdist_quest)  %>% drop_na())
        ,color = "blue")  
    })
    
    output$quant_hommes_q <- renderValueBox({ 
      value_box(
        "Number of men"
        ,count(filter(df, gender == '0') %>% select(input$genderdist_quest) %>% drop_na())
        ,color = "blue")  
    })
    
    output$gender_dist_quest <- renderPlot({
        data = df %>% 
          filter(r > -1.5 & r < 2.5) %>% select(gender, input$genderdist_quest)
      source("plot_gender_distributions_quest.R")
      plotgender(input$genderdist_quest, data)
    })
    
    observe({
      updateCheckboxGroupInput(session, "genderdist_quest", NULL,choices=questionchoice_gender)
    })
    
    
    ## Age tab
    
    output$age_dist <- renderPlot({
      data = df %>% 
        filter(r > -1.5 & r < 2.5) %>% filter(task == input$agedist)
      source("plot_age_distributions.R")
      plotage(input$agedist, data)
    })
    
    observe({
      if(input$selectallage == 0) return(NULL) 
      else if (input$selectallage%%2 == 0)
      {
        updateCheckboxGroupInput(session,"agedist",choices=mychoices, selected = mychoices)
      }
      else
      {
        updateCheckboxGroupInput(session,"agedist",choices=mychoices, selected=list())
      }
    })
    
    
    observe({
      updateCheckboxGroupInput(session, "agedist", NULL,choices=mychoices)
    })
    
    ## Explore page 
    
      ## First tab explore page
    
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