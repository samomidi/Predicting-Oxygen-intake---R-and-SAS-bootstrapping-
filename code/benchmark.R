library(microbenchmark)
library(boot)
library(profvis)
library(tidyverse)

source('code/lmBoot.r')
source('code/lmBootOptimized.R')
source('code/lmBootParallel.R')

fitness <- read_csv('data/fitness.csv')

x <- fitness$Age
y <- fitness$Weight
nBoot <- 1e3


# Functions Timing --------------------------------------------------------

# Comparing the default lmBoot with the optimized version
overallPerformance <- system.time(lmBoot(data.frame(x, y) , nBoot))
overallPerformance.opt <- system.time(lmBootOptimized(data.frame(x, y) , nBoot))
overallDifferences <- overallPerformance[[3]] - overallPerformance.opt[[3]]
cat("Overall code was improved by ", overallDifferences, "s")

# Comparing the optimized version with the parallel version
overallPerformance.opt <- system.time(lmBootOptimized(data.frame(x, y) , nBoot))
overallPerformance.par <- system.time(lmBootParallel(data.frame(x, y) , nBoot))
overallDifferences <- overallPerformance.opt[[3]] - overallPerformance.par[[3]]
cat("Overall code was improved by ", overallDifferences, "s")

# Rprof -------------------------------------------------------------------

# lmBoot
lmBootRprofPath  <- 'Profiling/lmBootRprof'
Rprof(lmBootRprofPath)
lmBoot(data.frame(x, y) , nBoot)
Rprof()
summaryRprof(lmBootRprofPath)

# lmBootOptimized
lmBootOptimizedRprofPath <- 'Profiling/lmBootOptimizedRprof'
Rprof(lmBootOptimizedRprofPath)
lmBootOptimized(data.frame(x, y) , nBoot)
Rprof()
summaryRprof(lmBootOptimizedRprofPath)

# lmBootParallel
lmBootParallelRprofPath <- 'Profiling/lmBootParallelRprof'
Rprof(lmBootParallelRprofPath)
lmBootParallel(data.frame(x, y) , nBoot)
Rprof()
summaryRprof(lmBootParallelRprofPath)

# Microbenchmark ----------------------------------------------------------

# Default with optimised
microbenchmark(
  lmBoot(data.frame(x, y) , nBoot),
  lmBootOptimized(data.frame(x, y) , nBoot)
)

# optimised with parallel
microbenchmark(
  lmBootOptimized(data.frame(x, y) , nBoot),
  lmBootParallel(data.frame(x, y) , nBoot),
  times = 10
)


# Built in Profiler -------------------------------------------------------

profvis({
  lmBoot(data.frame(x, y) , nBoot)  
})

profvis({
  lmBootOptimized(data.frame(x, y) , nBoot)
})

profvis({
  View(lmBootParallel(data.frame(x, y) , nBoot))
})

profvis({
  bootLM.performance.test()
})

bootLM.performance.test <- function() {
  numRows <- nrow(data.frame(x, y))
  for(i in 1:nBoot){
    bootLM(i, data.frame(x, y), numRows)
  }
}


# Plots -------------------------------------------------------------------

# Get the timing of the lmBootParallel for 10 data sizes
lmBootParallelTimings <- matrix(data = NA, nrow = 3, ncol = 2)
colnames(lmBootParallelTimings) <- c("size", "time")
for(i in 1:3) {
  size <- 10 ^ i
  time <- system.time(lmBootParallel(data.frame(x, y) , size))[3]
  lmBootParallelTimings[i, ] <- c(size, time)
}

lmBootParallelTimings[, 2] <- lmBootParallelTimings[, 2] / 1000

plot(lmBootParallelTimings[, 1], lmBootParallelTimings[, 2])
lines(lmBootParallelTimings[, 1], lmBootParallelTimings[, 2])

# Add a plot showing the points of x and y and the line using the retured betas

# R boot benchmark --------------------------------------------------------

linModel <- function(d, w){
  d <- d[w,  ]
  r <- cor(x = d$x, y = d$y)
  b <- r * sd(x = d$y) / sd(x = d$x)
  a <- mean(d$y) - (b * mean(d$x))
  return(c(a, b))
}

microbenchmark(
  boot(data = data.frame(x, y), statistic = linModel, R = 1e3, ncpus = 3),
  lmBootParallel(data.frame(x, y) , nBoot),
  times = 2
)

system.time(boot(data = data.frame(x, y), statistic = linModel, R = 1e5, ncpus = 4))
system.time(lmBootParallel(data.frame(x, y) , 1e5))

result.boot <- boot(data = data.frame(x, y), statistic = linModel, R = 1e4, ncpus = 4)
par.boot <- lmBootParallel(data.frame(x, y) , 1e4)

plot(result.boot[["t"]])
plot(par.boot)



# Testing -----------------------------------------------------------------

test.val.opt <- lmBootOptimized(data.frame(x, y) , nBoot)
test.val.par <- lmBootParallel(inputData = fitness , nBoot = 100, xIndex = c(2,3,5), yIndex = 1)
test.val.par.neat <- plyr::ldply(test.val.par)

View(test.val.par.neat)
View(test.val.opt)
View(test.val.par)

