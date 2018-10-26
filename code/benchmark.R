library(microbenchmark)
library(boot)
library(profvis)
library(tidyverse)

source('code/lmBoot.r')
source('code/lmBootOptimized.R')

fitness <- read_csv('data/fitness.csv')
View(fitness)

x <- fitness$Age
y <- fitness$Weight
nBoot <- 1000


# Functions Timing --------------------------------------------------------

overallPerformance <- system.time(lmBoot(data.frame(x, y) , nBoot))
overallPerformance.opt <- system.time(lmBootOptimized(data.frame(x, y) , nBoot))
overallDifferences <- overallPerformance[[3]] - overallPerformance.opt[[3]]
cat("Overall code was improved by ", overallDifferences, "s")


# Rprof -------------------------------------------------------------------

lmBootRprofPath  <- 'Profiling/lmBootRprof'
Rprof(lmBootRprofPath)
lmBoot(data.frame(x, y) , nBoot)
Rprof()
summaryRprof(lmBootRprofPath)

lmBootOptimizedRprofPath <- 'Profiling/lmBootOptimizedRprof'
Rprof(lmBootOptimizedRprofPath)
lmBootOptimized(data.frame(x, y) , nBoot)
Rprof()
summaryRprof(lmBootOptimizedRprofPath)


# Microbenchmark ----------------------------------------------------------

microbenchmark(
  lmBoot(data.frame(x, y) , nBoot),
  lmBootOptimized(data.frame(x, y) , nBoot)
)


# Built in Profiler -------------------------------------------------------

profvis({
  lmBoot(data.frame(x, y) , nBoot)  
})

profvis({
  lmBootOptimized(data.frame(x, y) , nBoot)
})

