lmBootOptimized <- function(inputData, nBoot){
  # Purpose:
  #   Optimize the bootstrapping code
  # Inputs:
  #   inputData - data frame
  #   nBoot - integer
  # Output:
  #   bootResults - matrix
  
  # Calculating the number of rows
  numberOfRows <- nrow(inputData)
  
  # Initializing bootResults
  bootResults <- matrix(data = NA, nrow = nBoot, ncol = 2)
  
  for(i in 1:nBoot){
    # resample our data with replacement
    bootData <- inputData[sample(1:numberOfRows, numberOfRows, replace = T), ]
    
    # fit the model under this alternative reality
    bootLM <- lm(y ~ x, data = bootData)
    
    # store the coefs
    if(i == 1){
      bootResults[i, ] <- matrix(coef(bootLM), ncol = 2)
    } else {
      bootResults[i, ] <- matrix(coef(bootLM), ncol = 2)
    }
  } # end of if loop
  
  # Output the result in a csv file
  write_csv(x = as.data.frame(bootResults), path = 'BootResults/OptBootRes')
}


# Changes done:
# Calculated the numbver of rows once before the loop instead of nBoot times
# Predefining the boothResults to get rid of the rbind
# writing results in a csv file