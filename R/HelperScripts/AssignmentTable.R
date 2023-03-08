createAssignTable <- function(data){
  gs_cols <- names(data)
  assignments <- data.frame(gs_col = gs_cols) %>%
    mutate(students_col = tolower(gs_col), # make all names lowercase
           students_col = str_replace_all(students_col, "[[:punct:]]", ""), # remove all punctuation
           students_col = str_replace_all(students_col, "\\s+", "_"), # replace white space with underscore
           students_col = str_replace_all(students_col, "ps_", "problem_set_"), # standardize names of ps
           students_col = str_replace_all(students_col, "rg_", "rq_"), # standardize names of rq
           students_col = str_replace(students_col, "_max_points", "__max_points"), # differentiate col types
           students_col = str_replace(students_col, "_submission_time", "__submission_time"),
           students_col = str_replace(students_col, "_lateness_hms", "__lateness_hms")) %>%
    mutate(category = case_when(str_detect(students_col, "lab") ~ "lab", # create category variable
                                str_detect(students_col, "problem") ~ "ps",
                                str_detect(students_col, "rq") ~ "rq",
                                str_detect(students_col, "quiz") ~ "quiz",
                                TRUE ~ "other")) %>%
    #organized by type, this should apply to gradescope assignments overall
    mutate(type = case_when(!str_detect(students_col, "name|sections|max|time|late")~ "raw_points",
                            str_detect(students_col, "max") ~ "max_points",
                            str_detect(students_col, "time") ~ "submission_time",
                            str_detect(students_col, "late") ~ "lateness",
                            TRUE ~ "other"))
  return (assignments)
}