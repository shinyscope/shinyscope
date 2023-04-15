pivot <- function(new_data, assignments_dataframe, cat_table){
  id_cols <- c("names", "sections","email", "sid")
  
  new_data <- as.data.frame(new_data)
  
  sxa <- new_data %>%
    pivot_longer(!all_of(id_cols), # change the unit of obs to student x assignment
                 names_to = c("assignments", ".value"),
                 names_sep = "_-_") %>%
    replace_na(list(raw_points = 0))
  
  
  assignments_dataframe$new_colnames <- str_replace_all(assignments_dataframe$new_colnames, "_-_raw_points", "")
  
  add_categories_to_pivot <- sxa %>%
      left_join(assignments_dataframe %>% select(new_colnames, colnames, category), by = c("assignments" = "new_colnames"))
  print(cat_table)
  print(add_categories_to_pivot)
  if (!is.null(cat_table)){
  add_cat_table_to_pivot <- add_categories_to_pivot %>%
    left_join(cat_table %>% select(Categories, Weights, Drops, Grading_Policy), by = c("category"="Categories"))
    return(add_cat_table_to_pivot)
  }
  else{
    return(add_categories_to_pivot)
  }

}




