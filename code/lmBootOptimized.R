library(parallel)


lmBootOptimized <- function(inputData, nBoot){
  # Purpose:
  #   Optimize the bootstrapping code
  # Inputs:
  #   inputData - data frame
  #   nBoot - integer
  # Output:
  #   bootResults - matrix
  
  # # Available cores
  # nCores <- detectCores()
  # 
  # # Create a cluster
  # myClust <- makeCluster(nCores - 1, type = "PSOCK") 
  
  # Calculating the number of rows
  numberOfRows <- nrow(inputData)
  
  # Initializing bootResults
  bootResults <- matrix(data = NA, nrow = nBoot, ncol = 2)
  
  for(i in 1:nBoot){
    # resample our data with replacement
    bootData <- inputData[sample(1:numberOfRows, numberOfRows, replace = T), ]
    
    # Get the correlation coefficient
    r <- cor(x = bootData$x, y = bootData$y)
    
    # Calculating the slope
    b <- r * sd(x = bootData$y) / sd(x = bootData$x)
    
    # Calculating the y-intercept
    a <- mean(bootData$y) - (b * mean(bootData$x))
    
    # store the coefs
    bootResults[i, ] <- c(a, b)
    
  } # end of if loop
  
  # Output the result in a csv file
  write_csv(x = as.data.frame(bootResults), path = 'BootResults/OptBootRes')
  
  
  # stopCluster(myClust)
}


# Changes done:
# Calculated the numbver of rows once before the loop instead of nBoot times
# Predefining the boothResults to get rid of the rbind
# Writing results in a csv file
# Manually calculate the coefficients