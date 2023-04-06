Nikita <- tabPanel("Nikita", titlePanel("Assignment View"),
                   sidebarPanel (),
                   mainPanel(
                     h4("Here are your students' grades"),
                     dataTableOutput("grades")
                   )
)