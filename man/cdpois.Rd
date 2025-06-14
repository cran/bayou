% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/probability.R
\name{cdpois}
\alias{cdpois}
\alias{rdpois}
\title{Conditional Poisson distribution}
\usage{
cdpois(k, lambda, kmax, log = TRUE)

rdpois(n, lambda, kmax, ...)
}
\arguments{
\item{k}{random variable value}

\item{lambda}{rate parameter of the Poisson distribution}

\item{kmax}{maximum value of the conditional Poisson distribution}

\item{log}{log transformed density}

\item{n}{number of samples to draw}

\item{...}{additional parameters passed to \code{dpois} or \code{rpois}}
}
\value{
A numeric value representing the probability (or log-probability) of
observing `k` under the truncated Poisson distribution, or a vector of random
values drawn from a truncated Poisson distribution.
}
\description{
\code{cdpois} calculates the probability density of a value \code{k} from a
Poisson distribution with a maximum \code{kmax}. \code{rdpois} draws random
numbers from a conditional Poisson distribution.
}
\examples{
cdpois(10,1,10)
cdpois(11,1,10)
rdpois(5,10,10)
}
