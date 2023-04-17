Dashboard <- tabPanel("Dashboard",
                      h1("Course Summary Statistics", style = "padding-left: 15px;"),
                      fluidRow(
                        column(8,
                               plotOutput("grade_dist", width = "100%", height = "100%")
                        ),
                        column(4,
                               selectInput("which_cat", "Pick a Category", choices = ''),
                               plotOutput("cat_dist"),
                        ),
                      ),
                      fluidRow(
                        column(4,
                               selectInput("which_assign", "Pick an Assignment", choices = ''),
                               plotOutput("assign_dist"),
                        ),
                        column(2,
                               br(),
                        ),
                        column(4,
                               style='background-color:#ffb6c1;',
                               h5("Course Stats:"),
                               uiOutput("studentStats"),
                               h5("Students with Low Scores:"),
                               uiOutput("studentConcerns"))
                      )
                      #renderUI("dists")
                      #splitLayout(cellWidths = c("50%", "50%"), plotOutput("plotgraph1"), plotOutput("plotgraph2"))

)



# Dashboard <- tabPanel("Dashboard",
#                      conditionalPanel(
#                          condition = "!input.upload",
#                          div(
#                            h1("Welcome to the Gradebook!"),
#                            p("Gradebook allows you to calculate, analyze, and visualize your course grades."),
#                            p("To get started, upload a file with your grade data."),
#                            br()
#                          )
#                        ),
#                        conditionalPanel(
#                          condition = "input.upload",
#                          div(
#                            h1("Great!"),
#                            p("Now go to the next tab 'Policies' to create your syllabus.")
#                          )
#                        ),
#                        conditionalPanel(
#                          condition = "input.upload && input.create",
#                          h1("Course Summary Statistics", style = "padding-left: 15px;"),
#                          fluidRow(
#                            column(8,
#                                   plotOutput("grade_dist", width = "100%", height = "100%")
#                            ),
#                            column(4,
#                                   selectInput("which_cat", "Pick a Category", choices = ''),
#                                   plotOutput("cat_dist"),
#                            ),
#                          ),
#                          fluidRow(
#                            column(4,
#                                   selectInput("which_assign", "Pick an Assignment", choices = ''),
#                                   plotOutput("assign_dist"),
#                            ),
#                            column(2,
#                                   br(),
#                            ),
#                            column(4,
#                                   style='background-color:#ffb6c1;',
#                                   h5("Course Stats:"),
#                                   uiOutput("studentStats"),
#                                   h5("Students with Low Scores:"),
#                                   uiOutput("studentConcerns")
#                            )
#                          ),
#                          fluidRow(
#                            h5("Course Grades", style = "padding-left: 15px;"),
# 
#                          ),
# 
#                            #uiOutput("grades_table2_ui"),
#                            actionButton("grade_all", "Calculate Overall Grade"),
#                            dataTableOutput("grades"),
#                            br(),
#                            downloadButton("download_grades_data", label = "Download")
#                          )
# )