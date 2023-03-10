createAssignTable <- function(data) {
  gs_cols <- names(data)
  
  assignments <- tibble(gs_col = gs_cols) %>%
    #General regex to rename assignments and add a column "category" in table
    mutate(gs_col = str_replace_all(tolower(gs_col), "[\\s:-]+", "_"),
           category = substr(str_replace_all(tolower(gs_col), "[\\s:-]+", "_"), 1, regexpr("_", str_replace_all(tolower(gs_col), "[\\s:-]+", "_")) - 1),
           type = if_else(!str_detect(gs_col, "name|sections|max|time|late"), "raw_points", NA_character_),
           gs_col = paste0(gs_col, "_", type)) # concatenate gs_col and type
  return(assignments)
}
