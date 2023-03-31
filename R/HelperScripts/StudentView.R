studentview <- function(new_data) {
  
  if (length(unique(new_data$sid)) < nrow(new_data)) { #if length of unique sid is less than the length of the data
    data_uniquesids <- new_data %>%
      filter(!is.na(sid)) %>% #filter out all rows with NA in SID column
      group_by(sid) %>%
      summarize(across(
        everything(),
        ~ if (inherits(., "Period")) { #keeps the "period" type which is the scientific type
                                       #for date in order to merge the 2 data frames below
          last(na.omit(.)) #keep the last
        } else if (is.numeric(.)) { #if value is numeric, take the max
          max(., na.rm = TRUE)
        } else {
          if (all(is.na(.))) { #if both values are NA, put NA
            NA
          } else {
            last(na.omit(.)) #keep last value
          }
        }
      )) %>%
      ungroup()
    
    # For rows with NA values in sid column
    na_sid_rows <- new_data %>% filter(is.na(sid))
    
    # Combine both dataframes
    data_combined <- bind_rows(data_uniquesids, na_sid_rows)
    
    return(data_combined)
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
