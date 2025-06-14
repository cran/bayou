% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bayou-weight_matrix.R
\name{parmap.W}
\alias{parmap.W}
\title{Calculate the weight matrix of a set of regimes on a phylogeny}
\usage{
parmap.W(tree, pars)
}
\arguments{
\item{tree}{either a tree of class "phylo" or a cache object produced by bayOU's internal
functions. Must include list element 'maps' which is a simmap reconstruction of regime history.}

\item{pars}{a list of the parameters used to calculate the weight matrix. Only pars$alpha is
necessary to calculate the matrix, but others can be present.}
}
\value{
A matrix where rows correspond to branches in the phylogenetic tree, and columns correspond
to the different evolutionary regimes. Each entry in the matrix represents the weight of a given
regime on a given branch.
}
\description{
These functions calculate weight matrices from regimes specified by a bayou formatted parameter list
\code{parmap.W} calculates the weight matrix for a set of regimes from a phylogeny
with a stored regime history. \code{.parmap.W} calculates the same matrix, but without checks and is
generally run internally.
}
\details{
\code{.parmap.W} is more computationally efficient within a mcmc and is used internally.
}
