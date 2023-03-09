Monika <- tabPanel("Monika", titlePanel("Monika"),
                      sidebarPanel (
                        
                        h4("Monika"),
                        selectizeInput("vars", "Select Columns:",
                                       choices = '',
                                       multiple = TRUE)
                      )
)
