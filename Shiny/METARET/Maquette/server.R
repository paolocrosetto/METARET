server <- function(input, output, session) {
  output$random1 <- renderPlot({
    random_ggplot()
  })
  
  output$random2 <- renderPlot({
    random_ggplot()
  })
}


