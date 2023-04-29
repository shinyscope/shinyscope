#This script contains helper Server functions to eliminate clutter in the main Server.R
#This script is not designed for code reusability like other helper but rather cleaner organization
#UI setup for modal pop-up
modal_confirm <- modalDialog(
  title = "Edit Existing Assignment Type",
  footer = NULL,
    numericInput("nRow", "Enter Category Row:", 1, min = 1, step = 1),
    textInput("change_name", "Enter Category Name", value = "", width = NULL, placeholder = NULL),
    numericInput("change_weight", "What Weight?", min = 0, max = 1, value = 0, step = 0.05),
    numericInput("change_drops", "How Many Drops:", 0, step = 1),
    radioButtons("change_policy", strong("Aggregation Method"),
                 choices = c("Equally Weighted", "Weighted by Points")),
    radioButtons("change_clobber_boolean", strong("Is there a clobber policy?"),
                 choices = c("Yes", "No"),
                 selected = "No"),
    conditionalPanel(
      condition = "input.change_clobber_boolean == 'Yes'",
      selectInput("change_clobber", "Clobber with the Following Assignment",
                  choices = '')),
    radioButtons("change_late_boolean", strong("Is there a lateness policy?"),
                 choices = c("Yes", "No"),
                 selected = "No"),
    conditionalPanel(
      condition = "input.change_late_boolean == 'Yes'",
      shinyTime::timeInput("change_late_a", "How late can this assignment be? (hours:minutes:seconds)"),
      numericInput("change_late_p", "What is the deduction? (i.e. 0.2 is a 20% deduction)", 1, step = 0.05),
      radioButtons("change_late_boolean2", strong("Is there another lateness policy?"),
                   choices = c("Yes", "No"),
                   selected = "No"),
      conditionalPanel(
        condition = "input.change_late_boolean2 == 'Yes'",
        shinyTime::timeInput("change_late_a2", "How late can this assignment be? (hours:minutes:seconds)"),
        numericInput("change_late_p2", "What is the deduction? (i.e. 0.2 is a 20% deduction)", 1, step = 0.05),
      )
    ),
    selectizeInput("change_assign", "Select Assignments:",
                   choices = '',
                   multiple = TRUE,
                   width = "700px"
                  ),
    br(),
    div(
      actionButton("done", "Done"),
      actionButton("cancel", "Cancel")

    ),
    actionButton("delete", "Delete", style = "position:absolute; top:-65px; right:15px;")
  )




#update a row in category table
updateRow <- function(cat_table, row, name, weight, assignments, num_drops, grading_policy, clobber, 
                      late){
  
  if (!is.null(cat_table) && row <= nrow(cat_table)){
    cat_table[row, 1] <- name
    cat_table[row, 2] <- weight
    cat_table[row, 3] <- stringr::str_c(assignments, collapse = ", ")
    cat_table[row, 4] <- num_drops
    cat_table[row, 5] <- grading_policy
    cat_table[row, 6] <- clobber
    cat_table[row, 7] <- late
  }
  
  return (cat_table)
}




add_new_category_modal <- modalDialog(
  title = "Add New Assignment Type",
  footer = NULL,
    textInput("cat_name", "Enter Category Name", value = "", width = NULL, placeholder = NULL),
    numericInput("weight", "How Much is This Worth?", min = 0, max = 1, value = 0.5, step = 0.05),
    numericInput("num_drops", "How Many Drops:", 0, step = 1),
    radioButtons("grading_policy", strong("Aggregation Method"),
                 choices = c("Equally Weighted", "Weighted by Points")),
    radioButtons("clobber_boolean", strong("Is there a clobber policy?"),
                 choices = c("Yes", "No"),
                 selected = "No"),
    conditionalPanel(
      condition = "input.clobber_boolean == 'Yes'",
      selectInput("clobber_with", "Clobber with the Following Assignment",
                  choices = '')),
    radioButtons("late_boolean", strong("Is there a lateness policy?"),
                 choices = c("Yes", "No"),
                 selected = "No"),
    conditionalPanel(
      condition = "input.late_boolean == 'Yes'",
      shinyTime::timeInput("late_allowed", "How late can this assignment be? (hours:minutes:seconds)"),
      numericInput("late_penalty", "What is the deduction? (i.e. 0.2 is a 20% deduction)", 1, step = 0.05),
      radioButtons("late_boolean2", strong("Is there another lateness policy?"),
                   choices = c("Yes", "No"),
                   selected = "No"),
      conditionalPanel(
        condition = "input.late_boolean2 == 'Yes'",
        shinyTime::timeInput("late_allowed2", "How late can this assignment be? (hours:minutes:seconds)"),
        numericInput("late_penalty2", "What is the deduction? (i.e. 0.2 is a 20% deduction)", 1, step = 0.05),
      )
      ),
    selectizeInput("assign", "Select Assignments:",
                   choices = '',
                   multiple = TRUE,
                   width = "700px"
                 ),
    br(),
    div(
        actionButton("create", "Save"),
        actionButton("cancel", "Cancel")
    
  )
  )