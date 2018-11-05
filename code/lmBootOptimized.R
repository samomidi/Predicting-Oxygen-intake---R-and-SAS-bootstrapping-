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
  } # end of for loop
  
  colnames(bootResults) <- c('intercept', colnames(inputData)[xIndex])
  return(bootResults)
}

lmBootOptimizedQuantiles <- 
  function(data, yIndex, xIndex, nBoot = 1000, alpha = 0.05) {
    # Purpose:
    #   Run optimized bootstrap code and return quantiles
    # Inputs:
    #   inputData - data frame
    #   xIndex - list of integers - the indexes of explanatory variables
    #   yIndex - integer - index of the response variable
    #   
    #   nBoot - integer - number of resamples, default 1000
    # Output:
    #   A matrix containing the upper and lower confidence intervals
    #   for the y-intercept and the slopes of the explanatory variables
    
    boots <- lmBootOptimized(data, nBoot, xIndex, yIndex)
    cis <- matrix(nrow = 2, ncol = ncol(boots))
    colnames(cis) <- colnames(boots)
    rownames(cis) <- c('Lower CI', 'Upper CI')
    for (i in 1:ncol(cis)) {
      cis[,i] <- quantile(boots[,i], probs = c(alpha/2,(1-alpha/2)))
    }
    return(cis)
  }
