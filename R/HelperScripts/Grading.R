createGradesTable <- function(pivot, cat_table, assign_table, names){
  num_cat <- nrow(cat_table)
  num_students <- length(names)
  table <- data.frame(matrix(ncol = num_cat+2, nrow = num_students)) 
  colnames(table) <- c("Names", cat_table$Categories, "Overall Grade")
  table[,1] <- names
  for (cat in 1:num_cat){
    category <- cat_table$Categories[cat]
    for (stud in 1: num_students){
      student <- names[stud]
      grade <- getCategoryGrade(pivot, student, cat_table, category, assign_table)
      table[stud, cat+1] <- grade
    }
  }
  return (table)
}
#returns all valid assignments from respective category, including drops
getValidAssigns <- function(pivot, student, cat_table, category, assign_table){
  assigns <- getAssignmentsFromCategory(cat_table, category, assign_table)
  #below, it filters by student and all their assignments + scores within given category
  pivot <- pivot%>% filter(names == student)%>%
    select(names, assignments, raw_points, max_points) %>%
    mutate(score = raw_points/max_points) %>%
    filter(assignments %in% assigns)
  num <- which(cat_table$Categories == category)
  pivot <- dropLowest(pivot, cat_table[num, 4])
  return (pivot)
}

#get all assignments within a given category
getAssignmentsFromCategory <- function(cat_table, category, assign_table){
  num <- which(cat_table$Categories == category)  
  assigns <- unlist(strsplit(cat_table$Assignments_Included[num], ", "))
  result <- assign_table %>%
    filter(colnames %in% assigns) %>%
    mutate( new_colnames = str_replace_all(new_colnames, "_-_raw_points", ""))
  return (result$new_colnames)
}

#drops x lowest scores
dropLowest <- function(pivot, x){
  if (x == 0){
    return (pivot)
  }
  pivot <- arrange(pivot, score) 
  len <- nrow(pivot)
  if (x >= len){
    return (pivot[-(1:len-1),]) #return max even if too many drops
  }
  return (pivot[-(1:x),])
}

getCategoryGrade <- function(pivot, student, cat_table, category, assigns_table){
  num <- which(cat_table$Categories == category)  
  grading_policy <-cat_table$Grading_Policy[num]
  assigns <- getValidAssigns(pivot,student, cat_table, category, assigns_table)
  if (grading_policy == "Equally Weighted"){
    #average scores
    return (assigns %>% summarize(grade = mean(score)) %>% pull(grade))
  } 
  return (assigns %>% summarize(grade = sum(raw_points)/sum(max_points)) %>% pull(grade))
}

getOverallGrade <- function(table){
  
}

# Functions to Write:
#   clobber at end
#   multiply by weights
#   lateness penalty