# MT5763-A2-TeamSharks
Assignment 2 for Software for Data Analysis, Group repo

References:<br>
https://onlinecourses.science.psu.edu/stat501/node/382/ <br>
https://www.itl.nist.gov/div898/handbook/pmd/section4/pmd431.htm <br>
http://nitro.biosci.arizona.edu/courses/EEB581-2006/handouts/LinearI.pdf <br>

Report:<br>
This repository contains 2 optimised functions [lmBootParallel.R](https://github.com/MarcNohra/MT5763-A2-TeamSharks/blob/master/code/lmBootParallel.R "lmBootParallel") and regBootOptimised.sas. Their purpose is to perform non-parameteric bootstrap resamplings of datasets, estimating the parameters of a linear model fit to each resample. This provides samples from the distribution of values that each parameter can take. From the output, confidence intervals can be calculated as well as indicate the level of uncertainty in the point estimates for the parameters of the model.

The R function lmBootParallel is used by specifying a dataset to perform the bootstrap on, the number of bootstraps to perform, as well as a list containing the indexes of the columns representing covariates and the response variable. This allows for an arbitrary number of covariates to be specified for use in the linear modelling. 
The implementation consists of the main function and a helper function. The helper function takes as input a single dataset which includes a column of 1s as its first column for the bias term. It then reformats the data into two matrices. A matrix X of covariates and the bias terms, and a matrix Y for the response variable. The formula for the analytical solution to a linear model is then used on the matrices to directly calculate the model parameters.
The main function serves to make parallelised calls to the helper function. It takes the data as input, adds the column of 1s for the biases and sets up a cluster based on the number of cores available on the machine...

TO DO:<br>
Estimations Plots<br>
Check the parallel function<br>
Save the profiles<br>
Check the Boot library micro<br>
Change the x axis values in the time plots and verify the unit of the y axis<br>
