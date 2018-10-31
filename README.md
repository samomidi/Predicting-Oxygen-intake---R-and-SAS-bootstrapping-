# MT5763-A2-TeamSharks
Assignment 2 for Software for Data Analysis, Group repo

References:<br>
https://onlinecourses.science.psu.edu/stat501/node/382/ <br>
https://www.itl.nist.gov/div898/handbook/pmd/section4/pmd431.htm <br>
http://nitro.biosci.arizona.edu/courses/EEB581-2006/handouts/LinearI.pdf <br>

Report:
This repository contains 2 optimised functions [lmBootParallel.R](https://github.com/MarcNohra/MT5763-A2-TeamSharks/blob/master/code/lmBootParallel.R "lmBootParallel") and regBootOptimised.sas. Their purpose is to perform non-parameteric bootstrap resamplings of datasets, estimating the parameters of a linear model fit to each resample. This provides samples from the distribution of values that each parameter can take. From the output, confidence intervals can be calculated as well as indicate the level of uncertainty in the point estimates for the parameters of the model.

The R function lmBootParallel is used by specifying a dataset to perform the bootstrap on, the number of bootstraps to perform, as well as a list containing the indexes of the columns representing covariates and the response variable. This allows for an arbitrary number of covariates to be specified for use in the linear modelling. 

TO DO:<br>
Estimations Plots<br>
Check the parallel function<br>
Save the profiles<br>
Check the Boot library micro<br>
Change the x axis values in the time plots and verify the unit of the y axis<br>
