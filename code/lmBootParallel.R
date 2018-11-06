library(doParallel)
library(foreach)

# Changes made:
# Calculated the number of rows once before the loop instead of nBoot times
# Predefining the bootResults to get rid of the rbind
# Calculating the beta coefficients using matrices calculation in a parallel way
# Generting the matrix sample once instead of resampling nBoot times

bootLM <- function(sampleVector, inputData, numberOfRows, xIndex, yIndex) {
  # Purpose:
  #   Calculte the lm coefficients for a sample using the matrix form
  # Inputs:
  #   SampleVector - matrix - the index of the sample to take from the inputData
  #   inputData - data frame - the data
  #   numberOfRows - integer - the number of rows of the inputData
  #   xIndex - vector - the covariates indexes
  #   yIndex - vector - the response indexes
  # Output:
  #   beta - the coefficents of the linear model
  
  # resample our data with replacement
  bootData <- inputData[sampleVector, ]
  Xmat <- bootData[, c(1, xIndex)] # Always take the 1 column to get beta 0
  Ymat <- bootData[, yIndex]
  
  # fit the model under this alternative reality
  # Changed the lm part to matrix form
  # betas = (X'X)^-1 * X'Y
  # solve(t(Xmat)%*%Xmat) will return the inverse of X'X
  beta <- solve(t(Xmat)%*%Xmat)%*%t(Xmat)%*%Ymat
  return(beta)
}
head(fitness)

lmBootParallel <- function(inputData, nBoot, xIndex, yIndex) {
  # Purpose:
  #   Optimize the bootstrapping code using parallel programming
  # Inputs:
  #   inputData - data frame
  #   nBoot - integer - number of resampling
  #   xIndex - list of integers - the indexes of the explanatory variables
  #   yIndex - integer - index of the response variable
  # Output:
  #   bootResults - matrix - contains the y-intercept and the slopes of the 
  #   explanatory variables
  
  # Input checks
  if(!is.data.frame(inputData) || nBoot < 0 || !is.numeric(nBoot) || 
    any(xIndex > ncol(inputData)) || any(yIndex > ncol(inputData)) ||
    any(xIndex < 0) || length(yIndex != 1)){
    stop("Invalid arguments")
  }
  
  # Calculating the number of rows
  numberOfRows <- nrow(inputData)
  
  # Initialising the data, we add a column of 1 which will be the first column
  # of the X matrix so that we can calculate beta 0
  bindedData <- as.matrix(cbind(1, inputData))
  
  # Available cores
  nCores <- detectCores()
  
  # Create a cluster
  myClust <- makeCluster(nCores - 1, type = "PSOCK")
  
  # Register cluster for parallel
  registerDoParallel(myClust)
  
  # Resample the data set once, getting the indexes of the rows
  sampleVector <- matrix(sample(1:numberOfRows, numberOfRows * nBoot, replace = T), 
                         nrow = numberOfRows, ncol = nBoot)
  
  # Initializing bootResults
  bootResults <- matrix(data = NA, nrow = nBoot, ncol = (length(xIndex) + 1))
  
  # Using the parallel code to calculate the regression coefficients
  bootResults <- matrix(parApply(myClust, sampleVector, 2, bootLM,
                                 inputData = as.matrix(bindedData),
                                 numberOfRows = numberOfRows,
                                 xIndex = xIndex + 1, yIndex = yIndex + 1), 
                        nrow = nBoot, ncol = (length(xIndex) + 1), byrow = TRUE)
  
  # Terminate the workers
  stopCluster(myClust)
  
  colnames(bootResults) <- c("intercept", colnames(inputData)[xIndex])
  return(bootResults)
}
