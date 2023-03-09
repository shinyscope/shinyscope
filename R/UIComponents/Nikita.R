Nikita <- tabPanel("Nikita", titlePanel("Nikita"),
                 sidebarPanel (
                   
                   h4("Nikita"),
                   selectizeInput("vars", "Select Columns:",
                                  choices = '',
                                  multiple = TRUE)
                 )
)
