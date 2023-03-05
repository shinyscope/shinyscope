ConfigTab <- tabPanel("Configurations", titlePanel("Configurations"),
sidebarPanel (
  
        h4("Configurations"),
        selectizeInput("vars", "Select Columns:",
                          choices = '',
                          multiple = TRUE)
         )
)

