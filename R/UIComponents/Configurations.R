Configurations <- tabPanel("Config",
                           fluidRow(
                             column(width = 4,
                                    helpText("Classify assignment types, implement grading policies, 
                              determine how to process unusual student records, and set the bins for letter grades.",
                                    br(),
                                    br(),
                                    ""),
                                    br(),
                                    #shinyFilesButton('files', label='File select', title='Please select a file', multiple=FALSE),
                                    # actionButton("save", "Save Config"),
                                    # actionButton("load", "Load Config"),
                                    br(),
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
                                                 fluidRow(column(width = 6, 
                                                                 actionButton("create_category", "Add New Category")),
                                                          column(width = 6,
                                                                 actionButton("edit", "Edit Existing Category"))),
                                                 h4("New Assignments:"),
                                                 uiOutput("myList"),
                                                 h4("Existing Categories"),
                                                 uiOutput("dynamic_ui")
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
                                        ),
                                        tabPanel("Coursewide", 
                                                 sliderInput("A+", "A+", min = 0, max = 100, value = c(97,100), width = "100%"),
                                                 sliderInput("A", "A", min = 0, max = 100, value = c(93,96), width = "100%"),
                                                 sliderInput("A-", "A-", min = 0, max = 100, value = c(90,92), width = "100%"),
                                                 sliderInput("B+", "B+", min = 0, max = 100, value = c(87,89), width = "100%"),
                                                 sliderInput("B", "B", min = 0, max = 100, value = c(83,86), width = "100%"),
                                                 sliderInput("B-", "B-", min = 0, max = 100, value = c(80,82), width = "100%"),
                                                 sliderInput("C+", "C+", min = 0, max = 100, value = c(77,79), width = "100%"),
                                                 sliderInput("C", "C", min = 0, max = 100, value = c(73,76), width = "100%"),
                                                 sliderInput("C-", "C-", min = 0, max = 100, value = c(70,72), width = "100%")
                                                 ),
                                                
                                        tabPanel("Grading Trials",
                                                 selectInput("pick_student", "Pick a student", choices = ''),
                                                 selectInput("pick_cat", "Pick a category", choices = ''),
                                                 dataTableOutput("individ_grades")
                                                 # dataTableOutput("grades_table")
                                                 
                                        )
                                        )
                                      )
                                    )
                              )
                            )

