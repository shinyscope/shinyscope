Policies <- tabPanel("Policies",
                           fluidRow(
                             column(width = 4,
                                    helpText("Classify assignment types, implement grading policies, 
                              determine how to process unusual student records, and set the bins for letter grades.",
                                    br(),
                                    br(),
                                    ""),
                                    br(),
                                    #shinyFilesButton('files', label='File select', title='Please select a file', multiple=FALSE),
                                    actionButton("save_config", "Save Config"),
                                    actionButton("load_config", "Load Config"),
                                    br(),
                             ),
                             column(width = 8,
                                    mainPanel(
                                      tabsetPanel(
                                        tabPanel("Assignment View",
                                                 br(),
                                                 helpText("Each assignment from Gradescope can be classified in terms of its type",
                                                          "(problem set, lab, quiz, etc). Add assignment types below, classify each",
                                                          "assignment according to its type, and determine the type-specific grading options.",
                                                          "To set or change grade bins, go to the 'Coursewide' tab above."),
                                                 br(),
                                                 br(),
                                                 fluidRow(column(width = 6, 
                                                                 actionButton("create_category", "Add New Category")),
                                                          column(width = 6,
                                                                 actionButton("edit", "Edit Existing Category"))),
                                                 h4("New Assignments:"),
                                                 uiOutput("myList"),
                                                 h4("Existing Categories"),
                                                 uiOutput("dynamic_ui")
                                        ),
                                      
                                        tabPanel("Coursewide", 
                                                 fluidRow(
                                                   plotOutput("letter_dist"),
                                                   helpText("Toggling these values below change the lower-bound cutoff for each letter grade.",
                                                            "Below each is the percentage of students with that respective letter grade."),
                                                   column(2,
                                                          numericInput("F", "F", min = 0, max = 100, value = 0), 
                                                   ),
                                                   column(2,
                                                          numericInput("D", "D", min = 0, max = 100, value = 60),
                                                   ),
                                                   column(2,
                                                          numericInput("C", "C", min = 0, max = 100, value = 70),
                                                          ),
                                                   column(2,
                                                          numericInput("B", "B", min = 0, max = 100, value = 80),
                                                   ),
                                                   column(2,
                                                          numericInput("A", "A", min = 0, max = 100, value = 90), 
                                                   ),
                                                 ),
                                                 uiOutput("grade_bin_percent")
                                        ),
                                        tabPanel("Students",
                                                 # Include Font Awesome library
                                                 tags$head(tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css")),
                                                 # Data Summary row
                                                 fluidRow(
                                                   
                                                   column(width = 12, htmlOutput("num_assign_msg")),
                                                   column(width = 12, htmlOutput("num_students_msg")),
                                                   column(width = 12, htmlOutput("duplicates_msg"))
                                                 ),
                                                 
                                                 # Main Panel with tabs and data tables
                                                 mainPanel(
                                                   tabsetPanel(
                                                     tabPanel("Distributions"),
                                                     tabPanel("SID issues", dataTableOutput("duplicate_sids")),
                                                     tabPanel("All Students", dataTableOutput("students"))
                                                   )
                                                 )
                                        )
                                        )
                                      )
                                    )
                              )
                            )

