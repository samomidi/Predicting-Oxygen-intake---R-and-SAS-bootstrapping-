lmBootOptimized <- function(inputData, nBoot, xIndex, yIndex){
  # Purpose:
  #   Optimize the bootstrapping code without clustering
  # Inputs:
  #   inputData - data frame
  #   nBoot - integer - number of resampling
  #   xIndex - list of integers - the indexes of explanatory variables
  #   yIndex - integer - index of the response variable
  # Output:
  #   bootResults - matrix - contains the y-intercept and the slopes of the 
  #   explanatory variables
  
  # Calculating the number of rows
  numberOfRows <- nrow(inputData)
  
  # Initialising the data
  bindedData <- as.matrix(cbind(1, inputData))
  
  # Initializing bootResults
  bootResults <- matrix(data = NA, nrow = nBoot, ncol = (length(xIndex) + 1))
  
  resampleVector <- sample(1:numberOfRows, numberOfRows * nBoot, replace = T)
  
  for(i in 1:nBoot) {
    # resample our data with replacement
    bootData <- bindedData[resampleVector[(((i-1)*numberOfRows)+1):(i*numberOfRows)], ]
    Xmat <- bootData[, c(1, xIndex + 1)]
    Ymat <- bootData[, yIndex + 1]
    
    beta <- solve(t(Xmat)%*%Xmat)%*%t(Xmat)%*%Ymat
    bootResults[i, ] <- beta
    
    
    
  } # end of for loop
  
  colnames(bootResults) <- c('intercept', colnames(inputData)[xIndex])
  return(bootResults)
}