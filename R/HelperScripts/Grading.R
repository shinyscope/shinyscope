createGradesTable <- function(names){
  
  table <- data.frame(Students = names)
  return (table)
}

updateGrades <- function(grades_table, pivot, cat_table){
  cat_num <- nrow(cat_table)
  category <- cat_table[cat_num,1]
  new_col <- data.frame(matrix(ncol = 1, nrow = nrow(grades_table)))
  colnames(new_col) <- category
  if (cat_table$Assignments_Included[cat_num] != ""){
    for (stud in 1: nrow(grades_table)){
      student <- grades_table[stud,1]
      grade <- getCategoryGrade(pivot, student, cat_table, cat_num)
      new_col[stud, 1] <- round(grade*100, 2)
    } 
  }
  return (cbind(grades_table, new_col))
}

#returns all valid assignments from respective category, including drops
getValidAssigns <- function(pivot, student, cat_table, cat_num){
  assigns <- getAssignmentsFromCategory(cat_table, cat_num)
  #below, it filters by student and all their assignments + scores within given category
  pivot <- pivot%>% filter(names == student)%>%
    select(names, colnames, raw_points, max_points) %>%
    mutate(score = raw_points/max_points) %>%
    filter(colnames %in% assigns)
  pivot <- dropLowest(pivot, cat_table[cat_num, 4])
  return (pivot)
}

#get all assignments within a given category
getAssignmentsFromCategory <- function(cat_table, cat_num){
  assigns <- unlist(strsplit(cat_table$Assignments_Included[cat_num], ", "))
  return (assigns)
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

getCategoryGrade <- function(pivot, student, cat_table, cat_num){
  grading_policy <-cat_table$Grading_Policy[cat_num]
  assigns <- getValidAssigns(pivot,student, cat_table, cat_num)
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