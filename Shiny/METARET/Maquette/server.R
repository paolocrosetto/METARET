server <- function(input, output, session) {
  output$random1 <- renderPlot({
    random_ggplot()
  })
}


