dynamic_ui_categories <- function(categories_table){
  
 
  #Create UI elements for each row in the datatable
  lapply(1:nrow(categories_table), function(i){
    category <- categories_table[,1]
    weight <- categories_table[,2]
    assignments <- categories_table[,3]
    drops <- categories_table[,4]
    grading_policy <- categories_table[,5]

    category_html <- paste0(
      '<div class="alert alert-success" role="alert">',
    #  '<i class="fas fa-exclamation-triangle"></i> ',
      '<strong style="font-size: 18px;">', tools::toTitleCase(category), '</strong>',
      '</div>'
    )
    

    tagList(
      HTML(category_html),

      div(
        style = "border-left: 1px solid #ddd; padding-left: 10px; display: flex;",
        div(
          style = "flex: 1;",
          p(strong("Weight:"), style = "margin-bottom: 10px;"),

          p(strong("Drops:"), style = "margin-bottom: 10px;"),
          p(strong("Grading Policy:")),
          p(strong("Assignments Included:"), style = "margin-bottom: 10px;")
        ),
        div(
          style = "flex: 1;",
          p(paste(weight), style = "margin-bottom: 10px;"),
          p(paste(drops), style = "margin-bottom: 10px;"),
          p(paste(grading_policy)),
          p(paste(assignments), style = "margin-bottom: 10px;")
        )
      ),

      if (i != nrow(categories_table)) {
        hr(style = "border-top: 1px solid #ddd;")
      }
    )
  })

}