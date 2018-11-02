library(microbenchmark)
library(boot)
library(profvis)
library(tidyverse)
library(ggplot2)
library(doParallel)

source('code/lmBoot.r')
source('code/lmBootOptimized.R')
source('code/lmBootParallel.R')

fitness <- read_csv('data/fitness.csv')

x <- fitness$Weight
y <- fitness$Age
nBoot <- 1e5
nCores <- detectCores()

# Profile both the original and optimised code # done # Built in Profiler
# Determine the overall speed increase # done # Functions Timing
# Include profile in repo # done
# Micro benchmark my fun to the the boot func # done # R boot benchmark
# Show the multiple covariates with comparison with the lm # done # Multiple Covariates

# R markdown that explains what the 2 functions do (SAS and R)
# How to use the functions (SAS and R)
# Include a short example analysis with plots and interpretation
# The data in the example should also be in the repo
# Include a figure that shows the increase of speed after every major improvement
# Figure that shows the micro bench between my func and Boot
# Profile file for the R bootsrap (my func)

# Assessed on:
# Your code - readable, logical, tidy, works and version controlled.
# Documentation
# Evidently improved code displayed through timing, profiling, parallelisation and documentation.
# Expansion of R code for general numbers (and types!) of covariates.



# Built in Profiler -------------------------------------------------------

# Profiling the original code Age ~ Weight
profvis({
  lmBoot(data.frame(x, y) , nBoot)  
})

# Profiling the final version code Age ~ Weight
profvis({
  lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = 2, yIndex = 1)
})

# Profiling the intermediate version (not parallel), Age ~ Weight
profvis({
  lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = 2, yIndex = 1)
})

# Profiling the bootLM (from the parallel function) to check for possible optimisations
numRows <- nrow(fitness)
sampleVector <- matrix(sample(1:numRows, numRows * nBoot, replace = T), 
                       nrow = numRows, ncol = nBoot)
bindedData <- as.matrix(cbind(1, fitness))
bootLM.performance.test <- function() {
  for(i in 1:nBoot){
    bootLM(sampleVector[(((i - 1) * numRows) + 1):(i*numRows)], bindedData,
           numRows, c(3,4,5), 2)
  }
}
profvis({
  bootLM.performance.test()
})

# Functions Timing --------------------------------------------------------
speedIncrease <- function(nBoot){
  # Comparing the default lmBoot with the optimized version Age ~ Weight
  overallPerformance.original <- system.time(lmBoot(data.frame(x, y) , nBoot))
  overallPerformance.opt <- system.time(lmBootOptimized(
    inputData = fitness, nBoot = nBoot, xIndex = 2, yIndex = 1))
  overallDifferences <- overallPerformance.original[[3]] - overallPerformance.opt[[3]]
  overallFraction <- overallPerformance.original[[3]] / overallPerformance.opt[[3]]
  cat("\nOriginal vs Optimal:",
      "\nOriginal: ", overallPerformance.original[[3]], "s",
      "\nOptimised: ", overallPerformance.opt[[3]], "s",
      "\nOverall code was improved by ", overallDifferences, "s",
      "\nThe optimised code is ", round(overallFraction), " times faster than the",
      "original for nBoot = ", nBoot, "\n")
  
  # Comparing the optimized version with the parallel version Age ~ Weight
  overallPerformance.par <- system.time(lmBootParallel(
    inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1))
  overallDifferences <- overallPerformance.opt[[3]] - overallPerformance.par[[3]]
  overallFraction <- overallPerformance.opt[[3]] / overallPerformance.par[[3]]
  cat("\nOptimised vs Parallel:",
      "\nOptimised: ", overallPerformance.opt[[3]], "s",
      "\nParallel: ", overallPerformance.par[[3]], "s",
      "\nOverall code was improved by ", overallDifferences, "s",
      "\nThe parallel code is ", round(overallFraction, 3), " times",
      ifelse(overallDifferences > 0, "faster", "slower"),
      "faster than the optimal for nBoot = ", nBoot, "\n")
  
  # Comparing the original version with the parallel version Age ~ Weight
  overallDifferences <- overallPerformance.original[[3]] - overallPerformance.par[[3]]
  overallFraction <- overallPerformance.original[[3]] / overallPerformance.par[[3]]
  cat("\nOriginal vs Parallel",
      "\nOriginal: ", overallPerformance.original[[3]], "s",
      "\nParallel: ", overallPerformance.par[[3]], "s",
      "\nOverall code was improved by ", overallDifferences, "s",
      "\nThe parallel code is ", round(overallFraction, 2), " times",
      ifelse(overallDifferences > 0, "faster", "slower"),
      "faster than the original for nBoot = ", nBoot, "\n")
}

speedIncrease(1e3)
speedIncrease(1e4)
speedIncrease(1e5)

# R boot benchmark --------------------------------------------------------

# Create the function for the boot function
linModel <- function(d, w, xIndex, yIndex){
  d <- d[w,  ]
  bindedData <- as.matrix(cbind(1, d))
  Xmat <- bindedData[, c(1, xIndex + 1)]
  Ymat <- bindedData[, yIndex + 1]
  beta <- solve(t(Xmat)%*%Xmat)%*%t(Xmat)%*%Ymat
  return(beta)
}

# Micro-benchmarking my parallel bootstrap against the bootsrap from 'boot'
bootBench <- microbenchmark(
  boot = boot(data = fitness, statistic = linModel, R = nBoot, ncpus = nCores, 
       xIndex = c(2,3,5), yIndex = 1),
  lmBootParallel = lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1),
  times = 10
)
# Save the benchmark in a file
fileName.bench <- paste('Profiling/Benchmark/bootBench', as.character(nBoot), '.rds', sep = "")
saveRDS(bootBench, file = fileName.bench)
bootBench

# Rprof -------------------------------------------------------------------

# lmBoot
lmBootRprofPath  <- 'Profiling/Rprof/lmBootRprof'
Rprof(lmBootRprofPath)
lmBoot(data.frame(x, y) , nBoot)
Rprof()
summaryRprof(lmBootRprofPath)

# lmBootOptimized
lmBootOptimizedRprofPath <- 'Profiling/Rprof/lmBootOptimizedRprof'
Rprof(lmBootOptimizedRprofPath)
lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
Rprof()
summaryRprof(lmBootOptimizedRprofPath)

# lmBootParallel
lmBootParallelRprofPath <- 'Profiling/Rprof/lmBootParallelRprof'
Rprof(lmBootParallelRprofPath)
lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
Rprof()
summaryRprof(lmBootParallelRprofPath)


# Microbenchmark ----------------------------------------------------------

# Original with optimised
microbenchmark(
  lmBoot = lmBoot(data.frame(x, y) , nBoot),
  lmBootOptimized = lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = 2, yIndex = 1),
  times = 10
)

# optimised with parallel
microbenchmark(
  lmBootOptimized = lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1),
  lmBootParallel = lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1),
  times = 10
)

# Original with parallel
par.micro <- microbenchmark(
  lmBoot = lmBoot(data.frame(x, y) , nBoot),
  lmBootParallel = lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = 2, yIndex = 1),
  times = 10
)

autoplot(par.micro)

# Time Plots -------------------------------------------------------------------

numOfMeasurements <- 7

# Get the timing of the original lmBoot
lmBootTimings <- matrix(data = NA, nrow = 5, ncol = 3)
colnames(lmBootTimings) <- c("group", "size", "time")
for(i in 1:5) {
  size <- 10 ^ i
  time <- system.time(lmBoot(data.frame(x, y) , size))[3]
  lmBootTimings[i, ] <- c("lmBoot", size, time)
}

# Get the timing of the lmBootOptimised
lmBootOptimizedTimings <- matrix(data = NA, nrow = numOfMeasurements, ncol = 3)
colnames(lmBootOptimizedTimings) <- c("group", "size", "time")
for(i in 1:numOfMeasurements) {
  size <- 10 ^ i
  time <- system.time(lmBootOptimized(
    inputData = fitness, nBoot = size, xIndex = c(2,3,5), yIndex = 1))[3]
  lmBootOptimizedTimings[i, ] <- c("lmBootOptimized", size, time)
}

# Get the timing of the lmBootParallel
lmBootParallelTimings <- matrix(data = NA, nrow = numOfMeasurements, ncol = 3)
colnames(lmBootParallelTimings) <- c("group", "size", "time")
for(i in 1:numOfMeasurements) {
  size <- 10 ^ i
  time <- system.time(lmBootParallel(
    inputData = fitness, nBoot = size, xIndex = c(2,3,5), yIndex = 1))[3]
  lmBootParallelTimings[i, ] <- c("lmBootParallel", size, time)
}

plotTimings <- as.data.frame(rbind(lmBootTimings, lmBootOptimizedTimings, lmBootParallelTimings))
plotTimings <- plotTimings %>% mutate_at(vars(-group), function(x) as.numeric(as.character(x)))
plotTimings$time <- round(x = plotTimings$time, digits = 8)

# Save the plotTimings for future uses without running the codes again
saveRDS(plotTimings, file = 'data/plotTimings.rds')

# Plots showing the execution time of the 3 functions for multiple nBoot sizes
# Plotting the log(size) to rescale the x-axis (for diplay reasons)
# The first plot shows all the time values where the other 2 plots show
# respectively the times for size <= 1e4 and size >= 1e4 for display reasons as well
ggplot(plotTimings, aes(x = log(size), y = time, group = group, colour = group)) + 
  geom_point() + 
  geom_line() +
  labs(title = "Execution time for the 3 functions for multiple nBoot size",
       x = "Size", y = "Time")

plotTimings %>% filter(., size <= 1e4) %>%
  ggplot(., aes(x = log(size), y = time, group = group, colour = group)) + 
  geom_point() + 
  geom_line() +
  labs(title = "Execution time for the 3 functions for multiple nBoot size",
       x = "Size", y = "Time")

plotTimings %>% filter(., size >= 1e4) %>%
  ggplot(., aes(x = log(size), y = time, group = group, colour = group)) + 
  geom_point() + 
  geom_line() +
  labs(title = "Execution time for the 3 functions for multiple nBoot size",
       x = "Size", y = "Time")

# Estimations Plots -------------------------------------------------------
# Getting the lm coefficients of the Age ~ Weight
lmBoot.res <- lmBoot(data.frame(x, y) , nBoot)
lmBootOpt.res <- lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = 2, yIndex = 1)
lmBootPar.res <- lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = 2, yIndex = 1)
lm.res <- coef(lm(y ~ x))

# Drawing the distribution of the weight and Age in the plot with
# the regression lines using the lm (blue) and lmBootParallel(red) functions
# To compare the accuracy of lmBootParallel
ggplot() +
  geom_point(data = fitness, aes(x = fitness$Weight, y = fitness$Age)) +
  geom_abline(intercept = lmBootPar.res[10, 1], slope = lmBootPar.res[10, 2], colour = "red") +
  geom_abline(intercept = lm.res[1], slope = lm.res[2], colour = "blue") +
  labs(title = "Comparing lm() with lmBootParallel() for Age ~ Weight",
       x = "Weight", y = "Age")

# Plot showing the generated coefficient lines in proportion to the points Age ~ Weight
plot(x = fitness$Weight, y = fitness$Age, pch = 20, col = 'purple', cex = 3,
     xlab = "Weight", ylab = "Age", main = "Bootsrapped coefficients")
apply(lmBootPar.res, 1, function(q){abline(q[1], q[2], col=alpha('lightgrey', 0.04))})

# Intercept and slopes histograms
hist(lmBoot.res[, 1], main = "Original Intercept Distribution")
hist(lmBoot.res[, 2], main = "Original Weight Slope Distribution")

hist(lmBootOpt.res[, 1], main = "Opt Intercept Distribution")
hist(lmBootOpt.res[, 2], main = "Parallel Weight Slope Distribution")

hist(lmBootPar.res[, 1], main = "Parallel Intercept Distribution")
hist(lmBootPar.res[, 2], main = "Parallel Weight Slope Distribution")

# Get the 95% confidence interval of the lmBootParallel
lmBootPar.res.confidence <- quantile(lmBootPar.res[, 1], probs = c(0.025, 0.975))
lmBootPar.res.filtered <- lmBootPar.res %>% as.data.frame() %>%
  filter(intercept > lmBootPar.res.confidence[1]) %>%
  filter(intercept < lmBootPar.res.confidence[2])

# Means of the bootstraps
lmBoot.mean <- apply(lmBoot.res, 2, mean)
lmBootOpt.mean <- apply(lmBootOpt.res, 2, mean)
lmBootPar.mean <- apply(lmBootPar.res, 2, mean)
lmBootParFiltered.mean <- apply(lmBootPar.res.filtered, 2, mean)

lmBoot.mean
lmBootOpt.mean
lmBootPar.mean
lmBootParFiltered.mean
coef(lm(y ~ x))


# Multiple Covariates -----------------------------------------------------

<<<<<<< HEAD
# Using the final version using multiple covariates and comparing the values to
# the corresponding lm
lmBootPar.cov <- lmBootParallel(fitness, nBoot, c(2, 3, 4), 1)
apply(lmBootPar.cov, 2, mean)
coef(lm(fitness$Age ~ fitness$Weight + fitness$Oxygen + fitness$RunTime))
=======



>>>>>>> 76106e991a9f31715b79be484cff0cbb3f8bc99a
