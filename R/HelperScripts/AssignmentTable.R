createAssignTable <- function(data) {
  gs_cols <- names(data)
  
  assignments <- tibble(colnames = gs_cols) %>%
    #General regex to rename assignments and add a column "category" in table
    mutate(new_colnames = str_replace_all(tolower(colnames), "[\\s:]+", "_"),
           category = substr(str_replace_all(tolower(colnames), "[\\s:]+", "_"), 1, regexpr("_", str_replace_all(tolower(colnames), "[\\s:-]+", "_")) - 1),
           type = if_else(!str_detect(new_colnames, "name|sections|max|time|late"), "_-_raw_points", "" ),
    
    #filter(type == "raw_points")%>%
    
           new_colnames = paste0(new_colnames, type))%>% # concatenate gs_col and type
    select(colnames,new_colnames, category)
  return(assignments)
}

updateCategories <- function(cat_table, category, assignments, weight){
  row <- as.numeric(parse_number(category))
  cat_table[row, 3] <- ""
  for(x in 1: length(assignments)){
    cat_table[row,3] <- paste(cat_table[row, 3],assignments[x])
  }
  cat_table[row, 2] <- as.numeric(weight)
  return(cat_table)
}