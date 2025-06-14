% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bayou-mcmc-utilities.R
\name{combine.chains}
\alias{combine.chains}
\title{Combine mcmc chains}
\usage{
combine.chains(chain.list, thin = 1, burnin.prop = 0)
}
\arguments{
\item{chain.list}{The first chain to be combined}

\item{thin}{A number or vector specifying the thinning interval to be used. If a single value,
then the same proportion will be applied to all chains.}

\item{burnin.prop}{A number or vector giving the proportion of burnin from each chain to be
discarded. If a single value, then the same proportion will be applied to all chains.}
}
\value{
A combined bayouMCMC chain
}
\description{
Combine mcmc chains
}
