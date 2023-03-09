createAssignTable <- function(data){
  gs_cols <- names(data)
  assignments <- tibble(gs_col = gs_cols) %>%
    #General regex to rename assignments and add a column "category" in table
     mutate(gs_col = str_replace_all(tolower(gs_col), "[\\s:-]+", "_"),
            category = substr(str_replace_all(tolower(gs_col), "[\\s:-]+", "_"), 1, regexpr("_", str_replace_all(tolower(gs_col), "[\\s:-]+", "_")) - 1))%>%
     #This allows to filter 1 column per assignment in "Assignments Tab"
     mutate(type = case_when(!str_detect(gs_col, "name|sections|max|time|late")~ "raw_points"))
 
   return (assignments)
}