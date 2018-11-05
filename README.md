# MT5763-A2-TeamSharks
Assignment 2 for Software for Data Analysis, Group repo

References:<br>
https://onlinecourses.science.psu.edu/stat501/node/382/ <br>
https://www.itl.nist.gov/div898/handbook/pmd/section4/pmd431.htm <br>
http://nitro.biosci.arizona.edu/courses/EEB581-2006/handouts/LinearI.pdf <br>

Report:<br>
This repository contains 2 optimised functions [lmBootParallel.R](https://github.com/MarcNohra/MT5763-A2-TeamSharks/blob/master/code/lmBootParallel.R "lmBootParallel") and [regBootOptimised.sas](https://github.com/MarcNohra/MT5763-A2-TeamSharks/blob/master/code/regBootOptimised.sas). Their purpose is to perform non-parameteric bootstrap resamplings of datasets, estimating the parameters of a linear model fit to each resample. This provides samples from the distribution of values that each parameter can take. From the output, confidence intervals can be calculated as well as indicate the level of uncertainty in the point estimates for the parameters of the model.

The R function lmBootParallel is used by specifying a dataset to perform the bootstrap on, the number of bootstraps to perform, as well as a list containing the indexes of the columns representing covariates and the response variable. This allows for an arbitrary number of covariates to be specified for use in the linear modelling. <br>
The implementation consists of the main function and a helper function. The helper function takes as input all the same arguments as the main function with an extra vector argument containing the indexes to use when resampling the data. It then reformats the data into two matrices. A matrix X of covariates and the bias terms, and a matrix Y for the response variable. The formula for the analytical solution to a linear model is then used on the matrices to directly calculate the model parameters.<br>
The main function serves to make parallelised calls to the helper function. It takes in the data and adds the column of 1s for the biases. All the indexes of rows used to resample the data are computed at once and stored in a matrix. A cpu cluster is set up of size appropriate for the hardware running the function, based on the number of cores available. Each core in the cluster runs the helper function independently, using columns of the previously calculated index matrix as the input resampling vector. Once finished the cluster is terminated. The output of every function call is turned into a matrix before being returned to the user.

As an example analysis, we are given the csv file 'fitness' containing columns for variables Age, Weight, Oxygen, RunTime, RestPulse, RunPulse, and MaxPulse, in that order. We use AIC to find the best model predicting Oxygen without interactions, and decide on parameters for Age, Weight, RunTime, RunPulse, and MaxPulse. To test whether our included covariates ar statistically significant, we use bootstrapping to find the 95% confidence intervals for the coefficients of these parameters from 1000 resamples. We run 'lmBootOptimized(data = fitness, nBoot = 1000, xIndex = c(1,2,4,6,7), yIndex = 3)'. This returns a matrix of intercepts and coefficients for each resample. Getting the 95% quantiles then returns the following table of confidence intervals:

|         | intercept|        Age|     Weight|   RunTime|   RunPulse|   MaxPulse|
|:--------|---------:|----------:|----------:|---------:|----------:|----------:|
|Lower CI |  81.43913| -0.4191007| -0.1603127| -3.285994| -0.5380501| -0.0324474|
|Upper CI | 120.51168| -0.0074428|  0.0473132| -2.144767| -0.0954170|  0.4945007|

![R Bootstrapping Example](/Plots/RBootEx.png)

The interpretation of these results is that Weight and MaxPulse are not statistically significant as the null hypothesis of zero is included within the confidence interval for these parameters. Their removal from the model should be considered.<br> 

While the SAS macro performs the same task, its current implementation is limited to accept only one independent variable. The SAS file included performs a bootstrap of 10000 repetitions on the linear model of Age ~ Weight. It prints to an RTF file in the same folder a table of mean coefficients and their 95% Confidence Intervals, as well as density plots for the coefficients and intercepts. An example SAS output file is provided in the /code directory.


<<<<<<< HEAD
The following plots show the time taken against the log of the number of resamples for each of the R bootstrapping functions. It is clear that in all cases the optimized function is much faster, but also that, at a high enough number of resamples, parallelization can further increase the function's efficiency. While the parallized function is more efficent for a large number of simulations, the optimized function works better for a small number of simulations. :

![R Benchmarking](/Plots/Plot2.png)
![R Benchmarking](/Plots/Plot3.png)
=======
The following plots show the time taken against the log of the number of resamples for each of the R bootstrapping functions. It is clear that in all cases the optimized function is much faster, but also that, at a high enough number of resamples, parallelization can further increase the function's efficiency:
![R Benchmarking](/Plots/Plot1A.png)
![R Benchmarking](/Plots/Plot2A.png)
>>>>>>> e044099dc9af3cf83c62d4611b43ad133bbb6fe7
  (Further measurements for the unoptimized lmboot function were not performed due to the extremely long time they would have taken)
