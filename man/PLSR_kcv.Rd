% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ml_PLSR.R
\name{PLSR_kcv}
\alias{PLSR_kcv}
\title{PLSR}
\usage{
PLSR_kcv(XX, YY, kfold = 6, seed = 1, ind_all = NULL, ncomp = 2, ...)
}
\arguments{
\item{...}{others to \code{\link[pls:mvr]{pls::plsr()}}}
}
\description{
PLSR
}
\examples{
PLSR_kcv(XX, YY, kfold = 6, seed = 1)
}
