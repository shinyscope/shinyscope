Matt <- tabPanel("Matt", titlePanel("Matt"),
                   sidebarPanel (
                     
                     h4("Matt"),
                     selectizeInput("vars", "Select Columns:",
                                    choices = '',
                                    multiple = TRUE)
                   )
)
