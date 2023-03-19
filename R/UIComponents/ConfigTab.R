ConfigTab <- tabPanel("Configurations", titlePanel("Student View"),
sidebarPanel (
  
        h4("Data Summary"),
        fluidRow(
          textOutput("num_assign_msg")),
        fluidRow(
          textOutput("num_students_msg")),
        fluidRow(
          textOutput("duplicates_msg"))
         ),
mainPanel(
  tabsetPanel(
    tabPanel("SID issues",
             dataTableOutput("duplicate_sids")),
    tabPanel("All Students",
             dataTableOutput("students"))
    
    
  )
  
)
)

