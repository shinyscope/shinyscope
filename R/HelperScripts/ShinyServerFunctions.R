#This script contains helper Server functions to eliminate clutter in the main Server.R
#This script is not designed for code reusability like other helper but rather cleaner organization
#UI setup for modal pop-up
modal_confirm <- modalDialog(
  "Editing already existing assignment type",
  title = "Edit",
  footer = tagList(
    numericInput("nRow", "Enter Category Row:", 1, min = 1, step = 1),
    textInput("change_name", "Enter Category Name", value = "", width = NULL, placeholder = NULL),
    sliderInput("change_weight", "What Weight?", min = 0, max = 1, value = 0),
    numericInput("change_drops", "How Many Drops:", 0, step = 1),
    radioButtons("change_policy", strong("Aggregation Method"),
                 choices = c("Equally Weighted", "Weighted by Points")),
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
updateRow <- function(cat_table, row, name, weight, assignments,num_drops, grading_policy){
  if (!is.null(cat_table) && row <= nrow(cat_table)){
    cat_table[row, 1] <- name
    cat_table[row, 2] <- weight
    cat_table[row, 3] <- stringr::str_c(assignments, collapse = ", ")
    cat_table[row, 4] <- num_drops
    cat_table[row, 5] <- grading_policy
  }
  
  return (cat_table)
}


add_new_category_modal <- modalDialog(
  "Adding New Assignment Category",
  title = "Add New",
  footer = tagList(
    textInput("cat_name", "Enter Category Name", value = "", width = NULL, placeholder = NULL),
    sliderInput("weight", "How Much is This Worth?", min = 0, max = 1, value = 0.5),
    numericInput("num_drops", "How Many Drops:", 0, step = 1),
    radioButtons("grading_policy", strong("Aggregation Method"),
                 choices = c("Equally Weighted", "Weighted by Points")),
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