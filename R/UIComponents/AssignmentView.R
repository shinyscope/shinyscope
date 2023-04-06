AssignmentView <- tabPanel("Assignment View", titlePanel("Assignment View"),
                 sidebarPanel (
                   
                   h4("Create a Grade Category"),
                   actionButton("edit", "Edit Existing Category"),
                   textInput("cat_name", "Enter Category Name", value = "", width = NULL, placeholder = NULL),
                   sliderInput("weight", "How Much is This Worth?", min = 0, max = 1, value = 0.5),
                   numericInput("num_drops", "How Many Drops:", 0, step = 1),
                   radioButtons("grading_policy", strong("Aggregation Method"),
                                choices = c("Equally Weighted", "Weighted by Points")),
                   selectizeInput("assign", "Select Assignments:",
                                  choices = '',
                                  multiple = TRUE),
                   actionButton("create", "Create Category"),
                  
                 ),
                 mainPanel(
                   h4("Categories Interface"),
                   uiOutput("dynamic_ui"),
                   h4("Unassigned Assignments Below:"),
                   uiOutput("myList"),
                   h4("Grading Syllabus"),
                   dataTableOutput("cat_table")
                 )
)
