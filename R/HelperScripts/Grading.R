calculateGrades <- function(students, pivot, cat_table){
  students <- students %>% mutate(Overall_Grade = 0)
  pivot <- pivot %>% mutate(Assignment_Grade = raw_points/max_points)
  x = 1
  for (student in students$names){
   grade <- pivot %>% filter(names == student) %>%
      summarize(average = mean(Assignment_Grade)) %>% pull()
   students[x,2] = round(grade*100, digits = 2)
   x = x+1
  }
  return(students)
}

