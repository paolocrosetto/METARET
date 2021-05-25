server <- function(input, output, session) {
  output$trend <- renderPlot({
    ggplot(subset(babynames, name == input$name)) + 
      geom_line(aes(x = year, y = prop, color = sex))
  })
  
  output$plot_top_10_names <- renderPlot({
    top_10_names <- babynames %>%
      filter(sex == input$sex) %>%
      filter(year == input$year) %>%
      top_n(10, prop)
    ggplot(top_10_names, aes(x = name, y = prop)) +
      geom_col(fill = "#263e63")
  })
  
  output$table_top_10_names <- DT::renderDT({
    top_10_names <- babynames %>%
      filter(sex == input$sex) %>%
      filter(year == input$year) %>%
      top_n(10, prop)
  })
}

