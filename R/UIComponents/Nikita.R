Nikita <- tabPanel("Nikita", titlePanel("Nikita"),
                 sidebarPanel (
                   h4("Nikita"),
                   sliderInput("num_cat", "How Many Categories?", min = 1, max = 15, value = 3)
                 ),
                 mainPanel(
                   h4("HI"),
                   selectizeInput("cat_niki", "Select Category:", 
                                  choices = '', 
                                  multiple = FALSE),
                   
                   selectizeInput("assign_niki", "Select Assignments:",
                                  choices = '',
                                  multiple = TRUE),
                   dataTableOutput("cat_table")
                 )
)
