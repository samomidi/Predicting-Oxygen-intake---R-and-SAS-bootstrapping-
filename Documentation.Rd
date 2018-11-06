\name{lmBootParallel}
\alias{Bootstrap_lmBootParallel}

\title{
%%  ~~function to do ... ~~
}
\description{
The R function lmBootParallel is used by specifying a dataset to perform the bootstrap on, the number of bootstraps to perform, as well as a list containing the indexes of the columns representing covariates and the response variable. This allows for an arbitrary number of covariates to be specified for use in the linear modelling.
}
\usage{
lmBootParallel(inputData, nBoot, xIndex, yIndex)
}

\arguments{
  \item{inputData}{
      Data Frame, it represents the dataset on which you wish to perform the bootsrapping. inputData can have more covariates than the ones we require (we can have additional unnused covariates)
}
  \item{nBoot}{
      integer - number of resampling
  }
  \item{xIndex}{
      list of integers - the indexes of the explanatory variables
  }
  \item{yIndex}{
      integer - index of the response variable
  }
}
\details{
The implementation consists of the main function and a helper function. The helper function takes as input all the same arguments as the main function with an extra vector argument containing the indexes to use when resampling the data. It then reformats the data into two matrices. A matrix X of covariates and the bias terms, and a matrix Y for the response variable. The formula for the analytical solution to a linear model is then used on the matrices to directly calculate the model parameters.
}
\value{
It returns a matrix containing the intercept and the regression coefficients of the covariates for every bootstrap performed (nBoot rows and length(xIndex) + 1 columns)
}
\references{
Team Mega shark vs Giant Octopus (2018) St andrews
}
\author{
Marc Nohra
}

\examples{
lmBootPar(mtcars, 1e4, c(1,2,4), 3)
}
