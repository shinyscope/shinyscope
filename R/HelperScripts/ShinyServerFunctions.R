#This script contains helper Server functions to eliminate clutter in the main Server.R
#This script is not designed for code reusability like other helper but rather cleaner organization
#UI setup for modal pop-up
modal_confirm <- modalDialog(
  "Editing already existing assignment type",
  title = "Edit",
  footer = tagList(
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
    radioButtons("change_late_policy1", strong("Is there a late policy?"),
                 choices = c("Yes", "No"),
                 selected = "No"),
    conditionalPanel(
      condition = "input.change_late_policy1 == 'Yes'",
      numericInput("change_lp1_time", "How late work do you accept?", 0, step = 1),
      selectizeInput("change_lp1_unit", "What is the unit of time:",
                     choices = c("Minutes", "Hours", "Days"),
                     multiple = FALSE),
      numericInput("change_lp1_deduction", "How much deduction?", 0, step = 1),
      radioButtons("change_late_policy2", strong("Is there a second late policy?"),
                   choices = c("Yes", "No"),
                   selected = "No"),
    ),
    conditionalPanel(
      condition = "input.change_late_policy2 == 'Yes'",
      numericInput("change_lp2_time", "How late work do you accept?", 0, step = 1),
      selectizeInput("change_lp2_unit", "What is the unit of time:",
                     choices = c("Minutes", "Hours", "Days"),
                     multiple = FALSE),
      numericInput("change_lp2_deduction", "How much deduction?", 0, step = 1)
    ),
    selectizeInput("change_assign", "Select Assignments:",
                   choices = '',
                   multiple = TRUE,
                   width = "700px"),
    br(),
    div(
      class = "modal-footer",
      actionButton("cancel", "Cancel"),
      actionButton("done", "Done")
    ),
    actionButton("delete", "Delete", style = "position:absolute; top:25px; right:15px;")
  )
)


#update a row in category table
updateRow <- function(cat_table, row, name, weight, assignments, num_drops, grading_policy, clobber, 
                      lp1_time = NULL, lp1_unit = NULL, lp1_deduction = NULL, lp2_time = NULL, lp2_unit = NULL, lp2_deduction = NULL){
  if (!is.null(cat_table) && row <= nrow(cat_table)){
    cat_table[row, 1] <- name
    cat_table[row, 2] <- weight
    cat_table[row, 3] <- stringr::str_c(assignments, collapse = ", ")
    cat_table[row, 4] <- num_drops
    cat_table[row, 5] <- grading_policy
    cat_table[row, 6] <- clobber
    if (!is.null(lp1_time) && !is.null(lp1_unit) && !is.null(lp1_deduction)) {
      cat_table[row, 7] <- lp1_time
      cat_table[row, 8] <- lp1_unit
      cat_table[row, 9] <- lp1_deduction
    } else {
      cat_table[row, 7:9] <- ""
    }
    if (!is.null(lp2_time) && !is.null(lp2_unit) && !is.null(lp2_deduction)) {
      cat_table[row, 10] <- lp2_time
      cat_table[row, 11] <- lp2_unit
      cat_table[row, 12] <- lp2_deduction
    } else {
      cat_table[row, 10:12] <- ""
    }
  }
  
  return (cat_table)
}




add_new_category_modal <- modalDialog(
  "Adding New Assignment Category",
  title = "Add New",
  footer = tagList(
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
    radioButtons("late_policy1", strong("Is there a late policy?"),
                 choices = c("Yes", "No"),
                 selected = "No"),
    conditionalPanel(
      condition = "input.late_policy1 == 'Yes'",
      numericInput("lp1_time", "How late work do you accept?", 0, step = 1),
      selectizeInput("lp1_unit", "What is the unit of time:",
                     choices = c("Minutes", "Hours", "Days"),
                     multiple = FALSE),
      numericInput("lp1_deduction", "How much deduction?", 0, step = 1),
      radioButtons("late_policy2", strong("Is there a second late policy?"),
                   choices = c("Yes", "No"),
                   selected = "No"),
    ),
    conditionalPanel(
      condition = "input.late_policy2 == 'Yes'",
      numericInput("lp2_time", "How late work do you accept?", 0, step = 1),
      selectizeInput("lp2_unit", "What is the unit of time:",
                     choices = c("Minutes", "Hours", "Days"),
                     multiple = FALSE),
      numericInput("lp2_deduction", "How much deduction?", 0, step = 1)
      ),
    selectizeInput("assign", "Select Assignments:",
                   choices = '',
                   multiple = TRUE,
                   width = "700px"),
    br(),
    div(class = "modal-footer",
        actionButton("cancel", "Cancel"),
        actionButton("create", "Save")
    )
    
  ))