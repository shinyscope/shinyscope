AllGradesTable <- function(pivotdf, cat_table){
  pivotdf_assigned_assignments <- pivotdf%>%
    filter(category != "Unassigned")
  
  pivotdf_assigned_assignments <- pivotdf_assigned_assignments%>%
    
  
  return(pivotdf_assigned_assignments)
}