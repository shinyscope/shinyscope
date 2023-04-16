dynamic_ui_categories <- function(categories_table){
  
  #Create UI elements for each row in the datatable
  lapply(1:nrow(categories_table), function(i){
    category <- categories_table[i,1]
    weight <- categories_table[i,2]
    assignments <- categories_table[i,3]
    drops <- categories_table[i,4]
    grading_policy <- categories_table[i,5]
    clobber <- categories_table[i,6]
    
    category_html <- paste0(
      '<div class="navbar navbar-expand-lg navbar-light bg-light" style="padding: 10px;">',
      '<span style="font-size: 21px;">', tools::toTitleCase(category),
      '</span>',
      '</div>'
    )
    
    # late_policy1_text <- if (late_policy1_time > 0) {
    #   paste(late_policy1_time, late_policy1_unit, "after deadline", late_policy1_deduction, "% deduction")
    # } else {
    #   "No late policies listed."
    # }
    # 
    # late_policy2_text <- if (late_policy2_time > 0) {
    #   paste(late_policy2_time, late_policy2_unit, "after deadline", late_policy2_deduction, "% deduction")
    # } else {
    #   NULL
    # }
    
    tagList(
      HTML(category_html),
      
      div(
        style = "border-left: 1px solid #ddd; padding-left: 10px; display: flex;",
        div(
          style = "flex: 1; display: flex; flex-direction: column; margin-right: 10px;",
          p(strong("Weight:"), style = "margin-bottom: 5px;"),
          p(strong("Drops:"), style = "margin-bottom: 5px;"),
          p(strong("Grading Policy:"), style = "margin-bottom: 5px;"),
          p(strong("Clobber Policy:"), style = "margin-bottom: 5px;"),
         # p(strong("Late Policy:"), style = "margin-bottom: 5px;"),
          p(strong("Assignments Included:"), style = "margin-bottom: 5px;")
        ),
        div(
          style = "flex: 1; display: flex; flex-direction: column;",
          p(paste(weight), style = "margin-bottom: 5px;"),
          p(paste(drops), style = "margin-bottom: 5px;"),
          p(paste(grading_policy), style = "margin-bottom: 5px;"),
          p(paste(clobber), style = "margin-bottom: 5px;"),
          # p(paste(late_policy1_text), style = "margin-bottom: 5px;"),
          # if (!is.null(late_policy2_text)) {
          #   p(paste(late_policy2_text), style = "margin-bottom: 5px;")
          # },
          # p(paste(assignments), style = "margin-bottom: 5px;")
        )
      ),
      
      if (i != nrow(categories_table)) {
        hr(style = "border-top: 1px solid #ddd;")
      }
    )
  })
}
