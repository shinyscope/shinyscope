updateBins <- function(bins_table, input_A, input_B, input_C, input_D, input_F){
  bins_table$CutOff[1] <- as.numeric(input_A)
  bins_table$CutOff[2] <- as.numeric(input_B)
  bins_table$CutOff[3] <- as.numeric(input_C)
  bins_table$CutOff[4] <- as.numeric(input_D)
  bins_table$CutOff[5] <- as.numeric(input_F)
  return (bins_table)
}

getLetterGrade <- function(bins_table, grade){
  if (grade >= bins_table$CutOff[1]){
    return ("A")
  } else if (grade >= bins_table$CutOff[2]){
    return ("B")
  } else if (grade >= bins_table$CutOff[3]){
    return ("C")
  } else if (grade >= bins_table$CutOff[4]){
    return ("D")
  }

    return ("F")
}

getStudentConcerns <- function(grades_table, f){
  save <- grades_table %>% filter(as.integer(Overall_Grade) < f) %>%
    mutate(Concerns = paste0(Students, " (score: ", Overall_Grade, ")"))
  if (!is.null(save)){
    return (save$Concerns)
  }
  return ("No student concerns here")
}
getGradeStats <- function(grades_table){
  mean <- paste0("Mean: ", round(mean(as.numeric(grades_table$Overall_Grade)),2))
  median <- paste0("Median: ", median(as.numeric(grades_table$Overall_Grade)))
  sd <- paste0("Standard Deviation: ", round(sd(grades_table$Overall_Grade),2))
  stats <- c(mean,median, sd)
  for (x in 4:ncol(grades_table)){
    name <- colnames(grades_table)[x]
    values <- as.numeric(grades_table[,x])
    mean <- mean(values, na.rm = TRUE)
    stats <- append(stats, paste0("Category ", tools::toTitleCase(name), " Mean : ", round(mean, 2)))
    
  }
  return (stats)
}
