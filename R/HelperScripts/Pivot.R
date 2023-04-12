pivot <- function(new_data, assignments_dataframe){
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
  return(add_categories_to_pivot)

}


