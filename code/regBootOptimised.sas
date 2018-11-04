/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*This is a small SAS program to perform nonparametric bootstraps for a regression
/*It is not efficient nor general*/
/*Inputs: 																								*/
/*	- NumberOfLoops: the number of bootstrap iterations
/*	- Dataset: A SAS dataset containing the response and covariate										*/
/*	- XVariable: The covariate for our regression model (gen. continuous numeric)						*/
/*	- YVariable: The response variable for our regression model (gen. continuous numeric)				*/
/*Outputs:																								*/
/*	- ResultHolder: A SAS dataset with NumberOfLoops rows and two columns, RandomIntercept & RandomSlope*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
%macro regBoot(NumberOfLoops, DataSet, XVariable, YVariable);
	/*Number of rows in my dataset*/
	data _null_;
		set &DataSet NOBS=size;
		call symput("NROW", size);
		stop;
	run;

	/*Sample my data with replacement*/
	ods listing close;
	proc surveyselect data = &DataSet out = bootData seed = 23434 method = urs noprint 
			sampsize = &NROW rep = &NumberOfLoops outhits;
	run;

	/*Conduct a regression on this randomised dataset and get parameter estimates*/
	proc reg data = bootData outest = ParameterEstimates noprint;
		Model &YVariable = &XVariable;
		by replicate;
	run;
	ods listing;

	/*Extract just the columns for slope and intercept for storage*/
	data ResultHolder;
		set ParameterEstimates;
		keep Intercept &XVariable;
	run;

	/*Rename the results something nice*/
	data ResultHolder;
		set ResultHolder;
		rename Intercept = RandomIntercept &XVariable = RandomSlope;
	run;
	
%mend;

/* for every sample get the mean of every param done */
/* histogram of the means done*/
/* get 95% of the means  done*/
/* get the mean of the means done*/
/* Add the 95% to the histogram */

/*Calculate the mean of every sample then get the CI of all the means for 2 parameters*/
%macro regBootMeanConfidenceInterval(BootDataSet, XVariable, YVariable);
	/*Calculate the slope's mean of every sample*/
	proc univariate data = &BootDataSet noprint;
		var &XVariable;
		by replicate;
		output out = uniGroupSlopeOut mean = meanGroupSlope;
	run;
	
	/*Calculate the mean of the slope means*/
	proc means data = uniGroupSlopeOut;
		var meanGroupSlope;
		output out = uniSlopeOut mean = meanSlope;
	run;
	
	/*Calculate the Intercept's mean of every sample*/
	proc means data = &BootDataSet noprint;
		var &YVariable;
		by replicate;
		output out = uniGroupInterceptOut mean = meanGroupIntercept
	run;
	
	/*Calculate the mean of the intercept means*/
	proc means data = uniGroupInterceptOut;
		var meanGroupIntercept;
		output out = meanInterceptOut mean = meanIntercept;
	run;
	
	/*Confidence interval for the slope*/
	proc univariate data = uniGroupSlopeOut;
		var meanGroupSlope;
		output out = slopeCI pctlpts = 2.5, 97.5 pctlpre = CI;
	run;
	
	/*Confidence interval for the intercept*/
	proc univariate data = uniGroupInterceptOut;
		var meanGroupIntercept;
		output out = interceptCI pctlpts = 2.5, 97.5 pctlpre = CI;
	run;
	
	/*Histogram of the slope means*/
	proc univariate data = uniGroupSlopeOut;
		var meanGroupSlope;
   		histogram;
	run;
	
	/*Histogram of the intercept means*/
	proc univariate data = uniGroupInterceptOut;
		var meanGroupIntercept;
   		histogram;
	run;

 	proc gchart data = uniGroupInterceptOut; 
 		vbar meanGroupIntercept; 
 	run; 
%mend;


/* get the coeff of lm  done*/
/* hist of the coeff of lm  done*/
/* 95% of the lm coeff  done done*/
/* Add the 95% to the histogram */
/*  */
/* mean for the original data done*/

/*Did the CI before the mean*/
%macro regBootCIMean(DataSet);
	/*Confidence Interval of the Slope*/
	proc univariate data = &DataSet;
		var RandomSlope;
		output out = lmSlopeCI pctlpts=2.5, 97.5 pctlpre=CI;
	run;
	
	/*Confidence Interval of the intercept*/
	proc univariate data = &DataSet;
		var RandomIntercept;
		output out = lmInterceptCI pctlpts=2.5, 97.5 pctlpre=CI;
	run;
	
	/*Histogram of the slopes*/
	proc univariate data = &DataSet;
		var RandomSlope;
   		histogram;
	run;
	
	/*Histogram of the intercepts*/
	proc univariate data = &DataSet;
		var RandomIntercept;
   		histogram;
	run;
	
%mend;

/*Get the mean of a dataset for 2*/
%macro originalDataMean(DataSet, XVariable, YVariable);
	/*Calculate the mean of the XVariable in the original data*/
	proc univariate data = &DataSet;
		var &XVariable;
		output out = XVarMeanOut mean = XVarMean;
	run;
	
	/*Calculate the mean of the YVariable in the original data*/
	proc univariate data = &DataSet;
		var &YVariable;
		output out = YVarMeanOut mean = YVarMean;
	run;
	
%mend;

%macro rtfCIMeans(DataSet);
	proc univariate data = &DataSet;
		output out = rtfData mean = means pctlpre= confint PCTLPTS = 2.5, 97.5;
	run;
	ods rtf file = 'output.rtf';
	proc print data = rtfData;
	run;
	goptions reset = all;
	proc sgplot data = &DataSet;
		density RandomIntercept;
	run;
	proc sgplot data = &DataSet;
		density RandomSlope;
	run;
	ods rtf close;
%mend


options nonotes;
/* Load the data set into RAM */
sasfile Fitness load;

options notes stimer;

/*Run the Bootstrap macro*/
%regBoot(NumberOfLoops = 100000, DataSet = fitness, XVariable = Weight, YVariable = Age);

options nonotes;

%originalDataMean(DataSet = fitness, XVariable = Weight, YVariable = Age);

/*Unload the data set from RAM*/
sasfile Fitness close;



/*Run the Confidence Interval on the mean of the sample data macro*/
%regBootMeanConfidenceInterval(BootDataSet = bootData, XVariable = Weight, YVariable = Age);

/*Run the CI on the regression coefficients*/
%regBootCIMean(DataSet = ResultHolder);


/* Prints to an rtf the 95% ci, mean estimates, and distributions, for each parameter coefficient */
%rtfCIMeans(DataSet = ResultHolder);

/*%let _timer_start = %sysfunc(datetime());*/
/**/
/*data _null_;*/
/*dur = datetime() - &_timer_start;*/
/*put 30*'-' / ' Total duration: ' dur time5. / 30*'-';*/
/*run;*/
/*Get the means of the original data*/
