# The idea is the following:
# Note: cat_table and pivot are already merged at this point
#
# 1) add columns for each grading policy from syllabus
# 2) add columns accordingly: a grade after lateness is applied, 
#                             a grade after weight is considered 
#
#
# Create another table:
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
  
  #calculating score based on weights EQUALLY WEIGHTED
  #these need be to averaged
  equally_weighted <- pivotdf_assigned_assignments%>%
    filter(Grading_Policy == "Equally Weighted")%>%
    mutate(grade_after_weight = round(raw_pts_after_lateness/max_points, 2))

  #calculating score based on weights WEIGHTED BY POINTS
  #these need to be summed
  weighted_by_points <- pivotdf_assigned_assignments%>%
    filter(Grading_Policy == "Weighted by Points")%>%
    mutate(grade_after_weight = round(((raw_pts_after_lateness/max_points) * (as.numeric(Weights) / count_assignments)), 2))
  
  #merge dataframes - equally weighted and by points
  combined_data <- bind_rows(equally_weighted, weighted_by_points)
  
  return(combined_data)
}