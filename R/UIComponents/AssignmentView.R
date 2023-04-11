AssignmentView <- tabPanel("Configurations",
                           fluidRow(
                             column(width = 4,
                                    tags$h1("Configurations"),
                                    # h4("Create a Grade Category"),
                                    helpText("Classify assignment types, implement grading policies, 
                              determine how to process unusual student records, and set the bins for letter grades.",
                                    br(),
                                    br(),
                                    "Your choices can be saved as a JSON file."),
                                    br(),
                                    # actionButton("save", "Save Config"),
                                    # actionButton("load", "Load Config"),
                                    br(),
                                     actionButton("edit", "Edit Existing Category"),
                                    # 
                                    # textInput("cat_name", "Enter Category Name", value = "", width = NULL, placeholder = NULL),
                                    # sliderInput("weight", "How Much is This Worth?", min = 0, max = 1, value = 0.5),
                                    # numericInput("num_drops", "How Many Drops:", 0, step = 1),
                                    # radioButtons("grading_policy", strong("Aggregation Method"),
                                    #              choices = c("Equally Weighted", "Weighted by Points")),
                                    # selectizeInput("assign", "Select Assignments:",
                                    #                choices = '',
                                    #                multiple = TRUE),
                                    # actionButton("create", "Create Category")
                             ),
                             column(width = 8,
                                    mainPanel(
                                      tabsetPanel(
                                        tabPanel("Assignment View",
                                                 br(),
                                                 helpText("Each assignment from Gradescope can be classified in terms of its type",
                                                          "(problem set, lab, quiz, etc). Add assignment types below, classify each",
                                                          "assignment according to its type, and determine the type-specific grading options."),
                                                 br(),
                                                 br(),
                                                 actionButton("create_category", "Add New Category"),
                                                 h4("New Assignments:"),
                                                 uiOutput("myList"),
                                                 h4("Existing Categories"),
                                                 uiOutput("dynamic_ui")
                                        ),
                                        tabPanel("Grading Trials",
                                                 selectInput("pick_student", "Pick a student", choices = ''),
                                                 selectInput("pick_cat", "Pick a category", choices = ''),
                                                 dataTableOutput("individ_grades"),
                                                 dataTableOutput("grades_table")
                                                 
                                        )
                                      )
                                    )
                             )
                           )
)
