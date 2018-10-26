library(microbenchmark)
library(boot)
library(profvis)
library(tidyverse)

source('code/lmBoot.r')
source('code/lmBootOptimized.R')
source('code/lmBootParallel.R')

fitness <- read_csv('data/fitness.csv')
View(fitness)

x <- fitness$Age
y <- fitness$Weight
nBoot <- 1e5


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
  lmBootParallel(data.frame(x, y) , nBoot)
})
