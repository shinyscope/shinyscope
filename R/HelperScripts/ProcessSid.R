process_sids <- function(new_data) {
  df_filtered <- new_data %>% filter(!is.na(new_data$sid))
  
  duplicated_rows <- df_filtered %>%
    group_by(sid) %>%
    filter(n() > 1) %>%
    ungroup()
  
  duplicates_df <- new_data %>%
    filter(is.na(sid) | (sid %in% duplicated_rows$sid)) %>%
    arrange(sid)
  
  #df with only unique sid
  unique_sids <- new_data[!(new_data$sid %in% duplicates_df$sid), ]
  
  #combined df with unique and na in sid
  unique_and_na_sids <- rbind(unique_sids, filter(duplicates_df, is.na(sid)))
  
  #df with duplicate sid so we can do merging using only this small df
  duplicate_sids_without_na <- filter(duplicates_df, !is.na(sid))
  
  if (nrow(duplicate_sids_without_na) > 0) {
    data_uniquesids <- duplicate_sids_without_na %>%
      group_by(sid) %>%
      summarize(across(
        everything(),
        ~ if (inherits(., "Period")) {
          last(na.omit(.))
        } else if (is.numeric(.)) {
          max(., na.rm = TRUE)
        } else {
          if (all(is.na(.))) {
            NA
          } else {
            last(na.omit(.))
          }
        }
      )) %>%
      ungroup()
    
    #combine dataframes into 1 correct dataframe of students
    result <- rbind(unique_and_na_sids, data_uniquesids)
  } else {
    result <- new_data
  }
  
  return(list(unique_sids = result, duplicates = duplicates_df))
}
