library(doParallel)

bootLM <- function(index, inputData, numberOfRows) {
  # resample our data with replacement
  bootData <- inputData[sample(1:numberOfRows, numberOfRows, replace = T), ]
  browser()
  Xmat <- bootData[,1:2]
  Ymat <- bootData[,3]
  
  # fit the model under this alternative reality
  # Changed the lm part to matrix form
  # the equation is: Y = X * betas
  # betas = (X'X)^-1 * X'Y
  # solve(t(Xmat)%*%Xmat) will return the inverse of X'X
  beta <- solve(t(Xmat)%*%Xmat)%*%t(Xmat)%*%Ymat
  beta <- t(beta)
  return(beta)
  
  
# Attempts ----------------------------------------------------------------

  
  # Attempt 1 to optimise
  # # Get the correlation coefficient
  # r <- cor(x = bootData$x, y = bootData$y)
  # 
  # # Mean x			
  # mean.x <- sum(bootData$x) / numberOfRows			
  # 
  # # Mean y			
  # mean.y <- sum(bootData$y) / numberOfRows			
  # 
  # # SD of x			
  # sd.x <- sqrt(sum((bootData$x - mean.x) ^ 2) / numberOfRows)			
  # # cat(sd.x, ' ', sd(x = bootData$x), ' ')			
  # 
  # # SD of y			
  # sd.y <- sqrt(sum((bootData$y - mean.y) ^ 2) / numberOfRows)			
  # 
  # # Calculating the slope			
  # b <- r * sd.x / sd.y			
  # 
  # # Calculating the y-intercept			
  # # a <- mean(bootData$y) - (b * mean(bootData$x))			
  # # a <- (sum(bootData$y) - (b * sum(bootData$x))) / numberOfRows			
  # a <- mean.y - (b * mean.x)			
  # 
  # # Return the coefficients			
  # return(c(a, b))
  
  
  # Attempt 2 to optimise
  # # Mean of cols
  # columnMeans <- colMeans(inputData)
  # 
  # # # Sums of squares of cols - means
  # # sumForSD <- colSums(inputData)
  # 
  # # SD of x
  # sd.x <- sqrt(sum((bootData$x - columnMeans[1]) ^ 2) / numberOfRows)
  # # cat(sd.x, ' ', sd(x = bootData$x), ' ')
  # 
  # # SD of y
  # sd.y <- sqrt(sum((bootData$y - columnMeans[2]) ^ 2) / numberOfRows)
  # 
  # # Calculating the slope
  # b <- r * sd.x / sd.y
  # 
  # # Calculating the y-intercept
  # # a <- mean(bootData$y) - (b * mean(bootData$x))
  # # a <- (sum(bootData$y) - (b * sum(bootData$x))) / numberOfRows
  # a <- columnMeans[2] - (b * columnMeans[1])
  # 
  # # Return the coefficients
  # return(c(a, b))
}

lmBootParallel <- function(inputData, nBoot) {
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
                           numberOfRows = numberOfRows)
  
  # Terminate the workers
  stopCluster(myClust)
  
  return(bootResults)
  
  # # Output the result in a csv file
  # bootResults <- plyr::ldply(bootResults)
  # #bootResults <- as.data.frame(bootResults)
  # colnames(bootResults) <- c("Intercept", "Slope")
  # # write_csv(x = bootResults, path = 'BootResults/OptBootRes')
  # return(bootResults)
}

# Changes done:
# Calculated the numbver of rows once before the loop instead of nBoot times
# Predefining the bootResults to get rid of the rbind
# Calculating the beta coefficients using matrices calculation
