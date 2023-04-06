#updates the category table or creates a new one if it's the first row
updateCategoryTable <- function(assign, cat_table, cat_name, weight, num_drops, grading_policy){
  assignments <- ""
  if (!is.null(assign)){
    assignments <- stringr::str_c(assign, collapse = ", ") # creates string of assignments 
  }
  
  if (is.null(cat_table)){
    cat_table <- data.frame(matrix(ncol = 5, nrow = 1)) %>%
      rename(Categories = "X1", Weights = "X2", Assignments_Included = "X3", Drops = "X4", Grading_Policy = "X5") #create dataframe
      cat_table[1,1] <- cat_name #add first row
      cat_table[1,2] <- weight
      cat_table[1,3] <- assignments
      cat_table[1,4] <- num_drops
      cat_table[1,5] <- grading_policy
  } else {
      cat_table <- rbind(cat_table, c(cat_name, weight, assignments, num_drops, grading_policy)) #add new column
  }
  return (cat_table)
}

#create assignment table from input data
createAssignTable <- function(data) {
  gs_cols <- names(data)
  
  assignments <- tibble(colnames = gs_cols) %>%
    #General regex to rename assignments and add a column "category" in table
    mutate(new_colnames = str_replace_all(tolower(colnames), "[\\s:]+", "_"),
      #     category = substr(str_replace_all(tolower(colnames), "[\\s:]+", "_"), 1, regexpr("_", str_replace_all(tolower(colnames), "[\\s:-]+", "_")) - 1),
           type = if_else(!str_detect(new_colnames, "name|sections|max|time|late|email|sid"), "_-_raw_points", "" ),
           new_colnames = paste0(new_colnames, type))%>% # concatenate gs_col and type
    select(new_colnames, colnames) %>%
    mutate(category = "Unassigned")
  return(assignments)
}

#updates assignments in assignment table when they are assigned a category
updateCategory <- function(assignments, assign, cat_name){
  selected <- data.frame(colnames = assign)
  selected <- semi_join(assignments, selected, "colnames") %>% mutate(category = cat_name)
  assignments <- rbind(selected, anti_join(assignments, selected, "colnames"))
  return (assignments)
}

#resets all assignments of a category to "Unassigned"
changeCategory <- function(assignments, cat_table, nrow){
  original_category <- c(cat_table$Categories[nrow])
  selected <- assignments %>%
    filter(category %in% original_category) %>%
    mutate(category = "Unassigned")
  assignments <- rbind(selected, anti_join(assignments, selected, "colnames"))
  return (assignments)
}

getUnassigned <- function(assign_table){
  left <-assign_table %>% 
      filter(category == "Unassigned")
  left$colnames
}