ConfigTab <- tabPanel(
  "Student View",
  titlePanel("Student View"),
  
  # Include Font Awesome library
  tags$head(tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css")),
  
  # Data Summary row
  fluidRow(
    h4("Data Summary", style = "padding-left: 15px;"),
    column(width = 4, htmlOutput("num_assign_msg")),
    column(width = 4, htmlOutput("num_students_msg")),
    column(width = 4, htmlOutput("duplicates_msg"))
  ),
  
  # Main Panel with tabs and data tables
  mainPanel(
    tabsetPanel(
      tabPanel("SID issues", dataTableOutput("duplicate_sids")),
      tabPanel("All Students", dataTableOutput("students"))
    )
  )
)
