Configurations <- tabPanel("Config",
                           fluidRow(
                             column(width = 4,
                                    tags$h1("Configurations"),
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
                                                 dataTableOutput("individ_grades")
                                                # dataTableOutput("grades_table")
                                                 
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
