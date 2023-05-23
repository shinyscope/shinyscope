dynamic_ui_categories <- function(categories_table) {
  button_ids <- reactive({
    paste0("edit_button_", 1:nrow(categories_table))
  })
  
  # Create UI elements for each row in the datatable
  lapply(1:nrow(categories_table), function(i) {
    category <- categories_table[i, 1]
    weight <- categories_table[i, 2]
    assignments <- categories_table[i, 3]
    drops <- categories_table[i, 4]
    grading_policy <- categories_table[i, 5]
    clobber <- categories_table[i, 6]
    late_policy <- categories_table[i, 7]
    late <- unlist(str_split(late_policy, ";"))
    if (length(late) >= 2) {
      late_policy <- paste0("Lateness of ", late[1], " allowed with a deduction of ", late[2])
      if (length(late) == 4) {
        late_policy <- paste0(late_policy, "; Lateness of ", late[1], " allowed with a deduction of ", late[2])
      }
    }
    
    category_html <- paste0(
      '<div class="navbar navbar-expand-lg navbar-light bg-light" style="padding: 10px;">',
      '<span style="font-size: 21px;">', tools::toTitleCase(category),
      '</span>',
      '</div>'
    )
    
    # unique id for each edit_button
    
    edit_button_id <- button_ids()[i]
  
    
    # create an actionButton for each Edit button
    edit_button <- actionButton(edit_button_id, "Edit", icon = icon("edit"))
    
    tagList(
      HTML(category_html),
      
      # edit_button in the UI
      div(edit_button, style = "position: relative; top: 10px; right: 10px;"),
      
      div(
        style = "border-left: 1px solid #ddd; padding-left: 10px; display: flex;",
        div(
          style = "flex: 1; display: flex; flex-direction: column; margin-right: 10px;",
          p(strong("Weight:"), style = "margin-bottom: 5px;"),
          p(strong("Drops:"), style = "margin-bottom: 5px;"),
          p(strong("Grading Policy:"), style = "margin-bottom: 5px;"),
          p(strong("Clobber Policy:"), style = "margin-bottom: 5px;"),
          p(strong("Late Policy:"), style = "margin-bottom: 5px;"),
          br(),
          p(strong("Assignments Included:"), style = "margin-bottom: 5px;")
        ),
        div(
          style = "flex: 1; display: flex; flex-direction: column;",
          p(paste(weight), style = "margin-bottom: 5px;"),
          p(paste(drops), style = "margin-bottom: 5px;"),
          p(paste(grading_policy), style = "margin-bottom: 5px;"),
          p(paste(clobber), style = "margin-bottom: 5px;"),
          p(paste(late_policy), style = "margin-bottom: 5px;"),
          br(),
          p(paste(assignments), style = "margin-bottom: 5px;")
        )
      ),
      
      if (i != nrow(categories_table)) {
        hr(style = "border-top: 1px solid #ddd;")
      }
    )
  })
}
