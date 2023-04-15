updateBins <- function(bins_table, input_A, input_B, input_C, input_D, input_F){
  bins_table$Lower_Bound[1] <- as.numeric(input_A[1])
  bins_table$Upper_Bound[1] <- as.numeric(input_A[2])
  bins_table$Lower_Bound[2] <- as.numeric(input_B[1])
  bins_table$Upper_Bound[2] <- as.numeric(input_B[2])
  bins_table$Lower_Bound[3] <- as.numeric(input_C[1])
  bins_table$Upper_Bound[3] <- as.numeric(input_C[2])
  bins_table$Lower_Bound[4] <- as.numeric(input_D[1])
  bins_table$Upper_Bound[4] <- as.numeric(input_D[2])
  bins_table$Lower_Bound[5] <- as.numeric(input_F[1])
  bins_table$Upper_Bound[5] <- as.numeric(input_F[2])
  return (bins_table)
}