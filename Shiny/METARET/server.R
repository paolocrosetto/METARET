shinyServer(function(input, output){
  
  output$markdown <- renderUI({
    
    mdfile <- read_file(paste0("./md/", input$RET, ".md"))
    HTML(markdown::markdownToHTML(text = mdfile))
  })
} 
)
