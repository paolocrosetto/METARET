server <- function(input, output, session) {
  output$Plot1 <- renderPlot({
    top_10_names <- babynames %>%
      filter(sex == input$sex) %>%
      filter(year == input$year) %>%
      top_n(10, prop)
    
    ggplot(top_10_names, aes(x = name, y = prop)) + geom_col()
  })
}

