#updates the category table or creates a new one if it's the first row
updateCategoryTable <- function(assign, cat_table, cat_name, weight, num_drops, grading_policy, clobber, 
                                lp1_time = NULL, lp1_unit = NULL, lp1_deduction = NULL,
                                lp2_time = NULL, lp2_unit = NULL, lp2_deduction = NULL){
   assignments <- ""
  if (!is.null(assign)){
    assignments <- stringr::str_c(assign, collapse = ", ") # creates string of assignments 
  }
  
  if (is.null(cat_table)){
    cat_table <- data.frame(matrix(ncol = 12, nrow = 1)) %>%
      rename(Categories = "X1", Weights = "X2", Assignments_Included = "X3", Drops = "X4", Grading_Policy = "X5", Clobber_Policy = "X6", Late_Policy1_Time = "X7", Late_Policy1_Unit = "X8",Late_Policy1_Deduction = "X9", Late_Policy2_Time = "X10", Late_Policy2_Unit = "X11",Late_Policy2_Deduction = "X12"  ) #create dataframe
      cat_table[1,1] <- cat_name #add first row
      cat_table[1,2] <- weight
      cat_table[1,3] <- assignments
      cat_table[1,4] <- num_drops
      cat_table[1,5] <- grading_policy
      cat_table[1,6] <- clobber
      cat_table[1,7] <- lp1_time
      cat_table[1,8] <- lp1_unit
      cat_table[1,9] <- lp1_deduction
      cat_table[1,10] <- lp2_time
      cat_table[1,11] <- lp2_unit
      cat_table[1,12] <- lp2_deduction
      new_row <- c(cat_name, weight, assignments, num_drops, grading_policy, clobber,
                   lp1_time, lp1_unit, lp1_deduction, lp2_time, lp2_unit, lp2_deduction)
  } else {
   
    new_row <- c(cat_name, weight, assignments, num_drops, grading_policy, clobber,
                 lp1_time, lp1_unit, lp1_deduction, lp2_time, lp2_unit, lp2_deduction)
    cat_table <- rbind(cat_table, new_row)
  }
   return(cat_table)
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
  
  # Replace all "," with ":" in the colnames to avoid the issue with selecting these assignments in creating categories.
  assignments$colnames <- str_replace_all(assignments$colnames, ",", ":")
  assignments$new_colnames <- str_replace_all(assignments$new_colnames, ",", ":")
  
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
  if (nrow(left) != 0){
    return (left$colnames) 
  }
  return ("No more new assignments")
}

deleteRow <- function(cat_table, nrow){
  len <- nrow(cat_table)
  if (len == 1){
    cat_table <- NULL
  } else if(nrow == len) {
    cat_table <- rbind(NULL,head(cat_table, len-1))
  } else if (nrow == 1){
    cat_table <- rbind(NULL,tail(cat_table, len-1))
  } else {
    cat_table <- rbind(head(cat_table, nrow-1), tail(cat_table, len-nrow)) 
  }
  if (!is.null(cat_table)){
    row.names(cat_table) <- 1:nrow(cat_table)
  }
  return (cat_table)
}

getClobber<- function(clobber_boolean, clobber_assign){
  if (clobber_boolean == "No"){
    return ("None")
  } else {
    return (paste0("Clobbered with ", clobber_assign))
  }
}