% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bayou-plotting.R
\name{plotShiftSummaries}
\alias{plotShiftSummaries}
\title{A function to plot a list produced by \code{shiftSummaries}}
\usage{
plotShiftSummaries(
  summaries,
  pal = rainbow,
  ask = FALSE,
  single.plot = FALSE,
  label.pts = TRUE,
  ...
)
}
\arguments{
\item{summaries}{A list produced by the function \code{shiftSummaries}}

\item{pal}{A color palette function}

\item{ask}{Whether to wait for the user between plotting each shift summary}

\item{single.plot}{A logical indicating whether to summarize all shifts in a single plot.}

\item{label.pts}{A logical indicating whether to label the scatter plot.}

\item{...}{Additional parameters passed to the function par(...)}
}
\value{
**No return value**, called for **side effects**.
The function **generates visualizations** of shift summaries, including:
\itemize{
  \item **Phylogenetic tree with shift locations**
  \item **Scatter plots of phenotype data**
  \item **Density plots for regression coefficients**
}
}
\description{
A function to plot a list produced by \code{shiftSummaries}
}
\details{
For each shift, this function plots the taxa on the phylogeny that are (usually) in this regime (each taxon
is assigned to the specified shifts, thus some descendent taxa may not always be in indicated regime if the shift if
they are sometimes in another tipward shift with low posterior probability). The function then plots the distribution
of phenotypic states and the predicted regression line, as well as density plots for the intercept and any regression
coefficients in the model.
}
