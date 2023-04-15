Dashboard <- tabPanel("Dashboard",
                       mainPanel(
                          selectInput("which_assign", "Pick a Category", choices = ''),
                          plotOutput("assign_dist"),
                          selectInput("which_cat", "Pick a Category", choices = ''),
                          plotOutput("cat_dist"),
                          plotOutput("grade_dist")
                          #renderUI("dists")
                         #splitLayout(cellWidths = c("50%", "50%"), plotOutput("plotgraph1"), plotOutput("plotgraph2"))
                       )
                       
)