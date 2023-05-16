Scratchpad <- tabPanel("Scratchpad",
                       sidebarPanel (
                         helpText("This tab shows all reactive objects.")
                       ),
                       mainPanel(
                         tabsetPanel(
                           tabPanel("Original Data",
                                    dataTableOutput("data")),
                           tabPanel("assigns$table",
                                    dataTableOutput("assign")),
                           tabPanel("categories$cat_table",
                                    dataTableOutput("cat_table")),
                           tabPanel("pivotdf()",
                                    dataTableOutput("pivotlonger")),
                           tabPanel("grades$table",
                                    dataTableOutput("grades")),
                           tabPanel("grades$bins",
                                    dataTableOutput("bins")),
                           tabPanel("all_grades_table",
                                    dataTableOutput("all_grades_table")),
                           tabPanel("grades_per_category",
                                    dataTableOutput("grades_per_category"))
                           
                           ))
                       
)
# 
# Scratchpad <- tabPanel("Scratchpad",
#                       sidebarPanel (
#                         helpText("This tab is for testing new features.",
#                                  br(),
#                                  br(),
#                                  "Grading syllabus tab contains the cat_table, which was removed from Configurations.")
#                       ),
#                       mainPanel(
#                         tabsetPanel(
#                           tabPanel(h5("Grading Syllabus"),
#                                    dataTableOutput("cat_table")),
#                           tabPanel(h5("All-Grades Table"),
#                                    actionButton("calculate_grades", label = "Calculate Class Grades"),
#                                    dataTableOutput("all_grades_table")),
# 
#                           tabPanel(h5("Analysis"),
#                           mainPanel(
#                             tabsetPanel(
#                                   tabPanel(h6("Assignments"),
#                                              dataTableOutput("assign")), #displays assignment table
#                                   tabPanel(h6("Pivot Longer Table"),
#                                              dataTableOutput("pivotlonger")), #displays assignment table
#                                   tabPanel(h6("Original Data"),
#                                              dataTableOutput("data")),
#                                   tabPanel(h6("Grades Tables"),
#                                            dataTableOutput("grades"))
#                             
#                           ))
#                         )))
# 
# )