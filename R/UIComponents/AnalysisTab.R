AnalysisTab <- tabPanel("Analysis", titlePanel("Analyzing Grades"),
sidebarPanel (
  
                #upload
                h4("Upload File"),
                fileInput("upload", "Upload a csv file", accept = c(".csv")),
                #selecting columns for calculation
                selectizeInput("cols", "Select Columns:",
                               choices = '',
                               multiple = TRUE),
                #calculate button
                actionButton("calculate", "Calculate Mean"),
              #-----------------Download file-----------------
                br(),
                br(),
                uiOutput("downloadBtn")
),
  

mainPanel(
  tabsetPanel(
                #dataTableOutput("table")
                tabPanel("Original Data",
                         dataTableOutput("data")),
                #
                tabPanel("Data Manipulation",
                         dataTableOutput("table")),
                tabPanel("Assignments",
                         dataTableOutput("assignments"))
                
    )
)
)
