
studentview <- function(new_data) {
  
  if (length(unique(new_data$sid)) < nrow(new_data)) {
    data_uniquesids <- new_data %>%
      group_by(sid) %>%
      summarize(across(
        everything(),
        ~ if (is.numeric(.)) {
          max(., na.rm = TRUE)
        } else {
          if (all(is.na(.))) {
            NA
          } else {
            last(na.omit(.))
          }
        }
      )) %>%
      ungroup()%>%
    
    
    return(data_uniquesids)
  }
}


duplicates <- function(new_data){

# filter SID column for non-missing values
df_filtered <- new_data %>% filter(!is.na(new_data$sid))

# find duplicated rows in df
duplicated_rows <- df_filtered %>%
  group_by(sid) %>%
  filter(n() > 1) %>%
  ungroup()

# include all rows with NA values in duplicates_df
duplicates_df <- new_data %>%
  filter(is.na(sid) | (sid %in% duplicated_rows$sid)) %>%
  arrange(sid)

# output duplicates_df to a data frame
duplicates_df <- as.data.frame(duplicates_df)
  
return(duplicates_df)
}
