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
  
  # Resample the data set once, getting the indexes of the rows
  resampleVector <- sample(1:numberOfRows, numberOfRows * nBoot, replace = T)
  
  for(i in 1:nBoot) {
    # select the ith resampled data using the indexes calculated earlier
    bootData <- bindedData[resampleVector[(((i - 1) * numberOfRows) + 1):(i*numberOfRows)], ]
    
    # Selecting the explanatory and response columns
    Xmat <- bootData[, c(1, xIndex + 1)]
    Ymat <- bootData[, yIndex + 1]
    
    # Get the linear model coefficients using by solving the Y = BX matrix
    # B = (X'X)^-1 * X'Y
    beta <- solve(t(Xmat)%*%Xmat)%*%t(Xmat)%*%Ymat
    bootResults[i, ] <- beta
<<<<<<< HEAD
=======
    
    
    
>>>>>>> 76106e991a9f31715b79be484cff0cbb3f8bc99a
  } # end of for loop
  
  colnames(bootResults) <- c('intercept', colnames(inputData)[xIndex])
  return(bootResults)
}