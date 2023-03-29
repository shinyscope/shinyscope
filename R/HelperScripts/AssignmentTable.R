updateCategoryTable <- function(assign, cat_table, cat_name, weight){
  assignments <- stringr::str_c(assign, collapse = ", ") # creates string of assignments
  
  if (is.null(cat_table)){
    cat_table <- data.frame(matrix(ncol = 3, nrow = 1)) %>%
      rename(Categories = "X1", Weights = "X2", Assignments_Included = "X3")
      cat_table[1,1] <- cat_name
      cat_table[1,2] <- weight
      cat_table[1,3] <- assignments
  } else {
      cat_table <- rbind(cat_table, c(cat_name, weight, assignments))
  }
  return (cat_table)
}


createAssignTable <- function(data) {
  gs_cols <- names(data)
  
  assignments <- tibble(colnames = gs_cols) %>%
    #General regex to rename assignments and add a column "category" in table
    mutate(new_colnames = str_replace_all(tolower(colnames), "[\\s:]+", "_"),
           category = substr(str_replace_all(tolower(colnames), "[\\s:]+", "_"), 1, regexpr("_", str_replace_all(tolower(colnames), "[\\s:-]+", "_")) - 1),
           type = if_else(!str_detect(new_colnames, "name|sections|max|time|late|email|sid"), "_-_raw_points", "" ),
    
    #filter(type == "raw_points")%>%
    
           new_colnames = paste0(new_colnames, type))%>% # concatenate gs_col and type
    select(colnames,new_colnames, category)
  return(assignments)
}