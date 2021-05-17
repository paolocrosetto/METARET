server <- function(input, output, session) {
  output$trend <- renderPlot({
    ggplot(subset(babynames, name == input$name)) +
      geom_line(aes(x = year, y = prop, color = sex))
  })
}


