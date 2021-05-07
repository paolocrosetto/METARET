library(shinydashboard)


ui <- dashboardPage(
    
    dashboardHeader(
        
        title = "METARET EXPLORER"
    ),
    

    dashboardSidebar(
       
         sidebarMenu(
            
             menuItem("HOME", tabName = "home", icon = icon("home")),
           
             menuItem("Tasks", tabName = "tasks", icon = icon("dashboard"),
                    
                        menuSubItem("Holt and Laury", tabName = "HL"),
                    
                        menuSubItem("Binswanger, Eckel and Grossmann", tabName = "BEG"),
                    
                        menuSubItem("Investment Game", tabName = "IG"),
                    
                        menuSubItem("Bomb Risk Elicitation Task", tabName = "bomb"),
                    
                        menuSubItem("Balloon Analog Risk Task", tabName = "balloon"),
                     
                        menuSubItem("Certainty equivalent price list", tabName = "certainty")),
           
              menuItem("Questionnaires", tabName = "questionnaires",
                     icon = icon("dashboard"))
        )
    ),
    
    
    
    dashboardBody()
)