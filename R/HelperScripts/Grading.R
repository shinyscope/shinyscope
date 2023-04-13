createGradesTable <- function(names){
  
  table <- data.frame(Students = names) %>% mutate(Overall_Grade = "TBD")
  return (table)
}

updateCatGrade <- function(grades_table, pivot, cat_table, cat_num){
  category <- cat_table[cat_num,1]
  new_col <- data.frame(matrix(ncol = 1, nrow = nrow(grades_table)))
  if (cat_table$Assignments_Included[cat_num] != ""){
    pivot <- getValidAssigns(pivot, cat_table, cat_num)
    grading_policy <-cat_table$Grading_Policy[cat_num]
    drops <- cat_table[cat_num, 4]
    for (stud in 1: nrow(grades_table)){
      student <- grades_table[stud,1]
      baby_pivot <- filter(pivot, names == student)
      grade <- getCategoryGrade(baby_pivot, cat_num, grading_policy, drops)
      new_col[stud, 1] <- round(grade*100,2)
    } 
  }
  if ((cat_num+2) <= ncol(grades_table)){
    grades_table[, cat_num+2] <- new_col
    colnames(grades_table)[cat_num+2] <- cat_table$Categories[cat_num]
    return (grades_table)
  }
  colnames(new_col) <- category
  return (cbind(grades_table, new_col))
}

#returns all valid assignments from respective category, including drops
getValidAssigns <- function(pivot, cat_table, cat_num){
  assigns <- getAssignmentsFromCategory(cat_table, cat_num)
  #below, it filters by student and all their assignments + scores within given category
  pivot <- pivot%>% #filter(names == student)%>%
    select(names, colnames, raw_points, max_points) %>%
    filter(colnames %in% assigns) %>%
    mutate(score = raw_points/max_points)
  #pivot <- dropLowest(pivot, cat_table[cat_num, 4])
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

getCategoryGrade <- function(baby_pivot, cat_num, grading_policy, drops){
  baby_pivot <- dropLowest(baby_pivot, drops)
  #assigns <- getValidAssigns(pivot,student, cat_table, cat_num)
  if (grading_policy == "Equally Weighted"){
    #average scores
    return (baby_pivot %>% summarize(grade = mean(score)) %>% pull(grade))
  } 
  return (baby_pivot %>% summarize(grade = sum(raw_points)/sum(max_points)) %>% pull(grade))
}

getOverallGrade <- function(table, cat_table){
  weights <- as.numeric(cat_table$Weights)
  for (cat in 1:nrow(cat_table)){
    if (cat_table$Assignments_Included[cat] == ""){
      weights[cat] <- 0
    }
  }
  num_cat <- ncol(table)
  for (stud in 1:nrow(table)){
    stud_grades <- table[stud,3:num_cat]
    table[stud, 2] <- round(sum(weights*stud_grades, na.rm = TRUE)/sum(weights),2)
  }
  return (table)
}

deleteCategory <- function(grades_table, category){
  grades_table <- select(grades_table, -c(category))
  return (grades_table)
}

# Functions to Write:
#   clobber at end
#   multiply by weights
#   lateness penalty