AssignmentView <- tabPanel("Configurations", titlePanel("Configurations"),
                 sidebarPanel (

                  # h4("Create a Grade Category"),
                   helpText("Classify assignment types, implement grading policies, 
                            determine how to process unusual student records, and set the bins for letter grades.",
                            br(),
                            br(),
                            "Your choices can be saved as a JSON file."),
                   actionButton("create_caretgory", "Add New Category"),
                   
                   
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
                   tabsetPanel(
                     tabPanel("Assignment View",
                              h4("New Assignments:"),
                              uiOutput("myList"),
                              h4("Existing Categories"),
                              uiOutput("dynamic_ui")
                               
                 )
                   )
                 )
)
