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