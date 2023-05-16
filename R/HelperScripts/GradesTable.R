# The idea for All_Grades_table is the following:
# Note: cat_table and pivot are already merged at this point
#
# 1) add columns for each grading policy from syllabus
# 2) add columns accordingly: a grade after lateness is applied <- **NOT IMPLEMENTED YET**
#                             a grade after weight is considered 
#
#
# Create another table GradesPerCategory:
# 3) start merging: 
#                   drop lowest graded assignments per drop policy
#                   group by category and student (still have several rows per student 
#                   but just 1 row per category)
#                   determine percentage grade per category



AllGradesTable <- function(pivotdf, cat_table){
  pivotdf_assigned_assignments <- pivotdf%>%
    filter(category != "Unassigned")
  
  if (!is.null(cat_table)){
    count_df <- cat_table%>%
      # I am splitting the assignments in each cell and calculating the length 
      #(it counts assignments for each category)
      mutate(count_assignments = sapply(strsplit(Assignments_Included, ","), length)) %>%
      select(Categories, count_assignments)
    print(count_df)
  } 
  #calculating lateness
  #not implemented yet - need to fix the UI first
  pivotdf_assigned_assignments <- pivotdf_assigned_assignments%>%
    mutate(raw_pts_after_lateness = raw_points)%>%
    left_join(count_df, by = c("category" = "Categories"))

 #  #count max points per category
 #  count_max_points_per_category <- pivotdf_assigned_assignments%>%
 #    group_by(sid, category) %>%
 #    summarise(total_max_points_per_cat = sum(as.numeric(max_points)))
 # 
 # print(count_max_points_per_category)

  #join total count of points with main pivot table
  # pivotdf_assigned_assignments <- pivotdf_assigned_assignments%>%
  # left_join(count_max_points_per_category, by = "category")
  
  #calculating score based on weights EQUALLY WEIGHTED
  #these need be to averaged
  equally_weighted <- pivotdf_assigned_assignments%>%
    filter(Grading_Policy == "Equally Weighted")%>%
    #this should yield the raw final percentage earned per assignment 
    mutate(grade_after_weight = round(((raw_pts_after_lateness/max_points)/count_assignments), 2))

  #calculating score based on weights WEIGHTED BY POINTS
  #these need to be summed
  weighted_by_points <- pivotdf_assigned_assignments%>%
    filter(Grading_Policy == "Weighted by Points")%>%
    #this should yield the raw final percentage earned per assignment 
    mutate(grade_after_weight = round(((raw_pts_after_lateness/count_assignments) * as.numeric(Weights)), 2))
  
  #merge dataframes - equally weighted and by points
  combined_data <- bind_rows(equally_weighted, weighted_by_points)
  
  return(combined_data)
}


GradesPerCategory <- function(allgradestable){
    grades_per_category <- allgradestable %>%
      group_by(sid, category) %>%
      arrange(raw_pts_after_lateness) %>% #arrange in ascending order based on group_by
      slice(((as.numeric(Drops) + 1):n())) %>% #drop the number of drops and keep the rest assignments
   #   summarise(percentage_grade = round((sum(grade_after_weight) / sum(max_points)), 2))%>%
      mutate(percentage_grade = round((sum(grade_after_weight) / sum(max_points)), 2)) %>%
      select(names, sid, category, Grading_Policy, percentage_grade)
      
    # equally_weighted <- grades_per_category%>%
    #   group_by(sid, category)
  
    
    return(grades_per_category)
}