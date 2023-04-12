Home <- tabPanel(
  "Home",


  
  fluidRow(
    h5("Course Grades", style = "padding-left: 15px;"),
  
  ),
  mainPanel(
  
   
    #uiOutput("grades_table2_ui"),
    dataTableOutput("grades"),
    br(),
    downloadButton("download_grades_data", label = "Download")
  )
)
