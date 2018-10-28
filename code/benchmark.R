library(microbenchmark)
library(boot)
library(profvis)
library(tidyverse)
library(ggplot2)

source('code/lmBoot.r')
source('code/lmBootOptimized.R')
source('code/lmBootParallel.R')

fitness <- read_csv('data/fitness.csv')

x <- fitness$Weight
y <- fitness$Age
nBoot <- 1e3
nCores <- detectCores()


# Functions Timing --------------------------------------------------------

# Comparing the default lmBoot with the optimized version
overallPerformance <- system.time(lmBoot(data.frame(x, y) , nBoot))
overallPerformance.opt <- system.time(lmBootOptimized(
  inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1))
overallDifferences <- overallPerformance[[3]] - overallPerformance.opt[[3]]
cat("Overall code was improved by ", overallDifferences, "s")

# Comparing the optimized version with the parallel version
overallPerformance.opt <- system.time(lmBootOptimized(
  inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1))
overallPerformance.par <- system.time(lmBootParallel(
  inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1))
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
lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
Rprof()
summaryRprof(lmBootOptimizedRprofPath)

# lmBootParallel
lmBootParallelRprofPath <- 'Profiling/lmBootParallelRprof'
Rprof(lmBootParallelRprofPath)
lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
Rprof()
summaryRprof(lmBootParallelRprofPath)

# Microbenchmark ----------------------------------------------------------

# Default with optimised
microbenchmark(
  lmBoot(data.frame(x, y) , nBoot),
  lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1),
  times = 10
)

# optimised with parallel
microbenchmark(
  lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1),
  lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1),
  times = 10
)


# Built in Profiler -------------------------------------------------------

profvis({
  lmBoot(data.frame(x, y) , nBoot)  
}, prof_output = 'Profiling/Profiles/lmBoot.Rprofvis')

profvis({
  lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
}, prof_output = 'Profiling/Profiles/lmBootOpt.Rprofvis')

test.prof <- profvis({
  lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
}, prof_output = 'Profiling/Profiles/lmBootPar.Rprofvis')

bootLM.performance.test <- function() {
  numRows <- nrow(fitness)
  bindedData <- as.matrix(cbind(1, fitness))
  for(i in 1:nBoot){
    bootLM(i, bindedData, numRows, c(2,3,5), 1)
  }
}

profvis({
  bootLM.performance.test()
})

# Time Plots -------------------------------------------------------------------

numOfMeasurements <- 5

# Get the timing of the original lmBoot
lmBootTimings <- matrix(data = NA, nrow = numOfMeasurements, ncol = 3)
colnames(lmBootTimings) <- c("group", "size", "time")
for(i in 1:numOfMeasurements) {
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

ggplot(plotTimings, aes(x = size, y = time, group = group, colour = group)) + 
  geom_point() + 
  geom_line() +
  scale_x_continuous(breaks = 5, 
                     limits = c(0, 1e5))

# test.plot <- plotTimings %>% filter(group == "lmBoot")
# plot(test.plot$size, test.plot$time)
# 
# plot(lmBootParallelTimings[, 1], lmBootParallelTimings[, 2])
# lines(lmBootParallelTimings[, 1], lmBootParallelTimings[, 2])

# Add a plot showing the points of x and y and the line using the retured betas

# R boot benchmark --------------------------------------------------------

linModel <- function(d, w, xIndex, yIndex){
  d <- d[w,  ]
  bindedData <- as.matrix(cbind(1, d))
  Xmat <- bindedData[, c(1, xIndex + 1)]
  Ymat <- bindedData[, yIndex + 1]
  beta <- solve(t(Xmat)%*%Xmat)%*%t(Xmat)%*%Ymat
  return(beta)
}

microbenchmark(
  boot(data = fitness, statistic = linModel, R = nBoot, ncpus = nCores, 
       xIndex = c(2,3,5), yIndex = 1),
  lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1),
  times = 2
)

system.time(boot(data = fitness, statistic = linModel, R = nBoot, ncpus = nCores, 
                 xIndex = c(2,3,5), yIndex = 1))
system.time(lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1))

result.boot <- boot(data = fitness, statistic = linModel, R = nBoot, ncpus = nCores, 
                    xIndex = c(2,3,5), yIndex = 1)
result.boot <- result.boot[["t"]]
colnames(result.boot) <- c('intercept', colnames(fitness)[c(2,3,5)])
result.boot <- as.data.frame(result.boot)

par.boot <- lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
par.boot <- plyr::ldply(par.boot)

plot(result.boot)
plot(par.boot)

# View Results ------------------------------------------------------------

lmBoot.res <- lmBoot(data.frame(x, y) , nBoot)
lmBootOpt.res <- lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
lmBootPar.res <- lmBootParallel(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
lmBootPar.res <- plyr::ldply(lmBootPar.res)

View(lmBoot.res)
View(lmBootOpt.res)
View(lmBootPar.res)


# Estimations Plots -------------------------------------------------------


# Testing -----------------------------------------------------------------

test.val.opt <- lmBootOptimized(inputData = fitness, nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
test.val.par <- lmBootParallel(inputData = fitness , nBoot = nBoot, xIndex = c(2,3,5), yIndex = 1)
test.val.par.neat <- plyr::ldply(test.val.par)

View(test.val.par.neat)
View(test.val.opt)
View(test.val.par)

