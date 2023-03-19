#This script contains helper Server functions to eliminate clutter in the main Server.R
#This script is not designed for code reusability like other helper but rather cleaner organization

modal_confirm <- modalDialog(
  "Are you sure you want to continue?",
  title = "Deleting files",
  footer = tagList(
    numericInput("nRow", "Enter Category Row:", 1, step = 1),
    textInput("change_name", "Enter Category Name", value = "", width = NULL, placeholder = NULL),
    sliderInput("change_weight", "What Weight?", min = 0, max = 1, value = 0),
    selectizeInput("change_assign", "Select Assignments:",
                   choices = '',
                   multiple = TRUE),
    actionButton("done", "Done")
  )
)

updateRow <- function(cat_table, row, name, weight, assignments){
  assign <- ""
  if (!is.null(cat_table) && row <= nrow(cat_table)){
    for(x in 1: length(assignments)){
      assign <- paste(assign, assignments[x])
    }

    
    cat_table[row, 1] <- name
    cat_table[row, 2] <- weight
    cat_table[row, 3] <- assign
  }
  
  return (cat_table)
}

removeAssigned <- function(unassigned_table, assignments){
  len <- length(assignments)
  for (x in 1: len){
    assign <- assignments[x]
    num <- which(unassigned_table[,1] == assign)
    unassigned_table <- unassigned_table[-num,]
  }
  return (unassigned_table)
}