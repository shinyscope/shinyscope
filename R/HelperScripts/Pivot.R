pivot <- function(new_data){
  print(new_data)
  id_cols <- c("name", "sections")

  
  sxa <- new_data %>%
    pivot_longer(!all_of(id_cols), # change the unit of obs to student x assignment
                 names_to = c("assignments", ".value"),
                 names_sep = "_-_") %>%
    replace_na(list(raw_points = 0))
  return(sxa)

# 
#   sxa <- sxa %>%
#     left_join(assignments(), by = "assignment") # add on the type of the assignment (and other stuff)
#   return(sxa)
}


