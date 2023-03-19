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
