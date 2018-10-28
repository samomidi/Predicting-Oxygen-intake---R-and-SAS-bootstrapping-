library(doParallel)

bootLM <- function(index, inputData, numberOfRows, xIndex, yIndex) {
  # resample our data with replacement
  bootData <- inputData[sample(1:numberOfRows, numberOfRows, replace = T), ]
  Xmat <- bootData[, c(1, xIndex)]
  Ymat <- bootData[, yIndex]
  
  # fit the model under this alternative reality
  # Changed the lm part to matrix form
  # betas = (X'X)^-1 * X'Y
  # solve(t(Xmat)%*%Xmat) will return the inverse of X'X
  beta <- solve(t(Xmat)%*%Xmat)%*%t(Xmat)%*%Ymat
  
  # Transpose beta to have the values in 1 row and 2 cols
  beta <- t(beta)
  colnames(beta) <- c('intercept', colnames(inputData)[xIndex])
  return(beta)
}

lmBootParallel <- function(inputData, nBoot, xIndex, yIndex) {
  # Calculating the number of rows
  numberOfRows <- nrow(inputData)
  
  # Initialising the data
  bindedData <- as.matrix(cbind(1, inputData))
  
  # Available cores
  nCores <- detectCores()
  
  # Create a cluster
  myClust <- makeCluster(nCores, type = "PSOCK")
  
  # Register cluster for parallel
  registerDoParallel(myClust)
  
  # Initializing bootResults
  bootResults <- matrix(data = NA, nrow = nBoot, ncol = 2)
  bootResults <- parLapply(myClust, 1:nBoot, bootLM, inputData = as.matrix(bindedData), 
                           numberOfRows = numberOfRows, xIndex = xIndex + 1, yIndex = yIndex + 1)
  
  # Terminate the workers
  stopCluster(myClust)
  
  # bootResults <- plyr::ldply(bootResults)
  
  return(bootResults)
}

# Changes done:
# Calculated the numbver of rows once before the loop instead of nBoot times
# Predefining the bootResults to get rid of the rbind
# Calculating the beta coefficients using matrices calculation
