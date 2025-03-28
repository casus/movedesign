% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fct_meta.R
\name{run_meta}
\alias{run_meta}
\title{Running \eqn{\chi^2}-IG hierarchical model meta-analyses}
\usage{
run_meta(
  rv,
  set_target = c("hr", "ctsd"),
  subpop = FALSE,
  trace = FALSE,
  .iter_step = 2,
  .only_max_m = FALSE,
  .lists = NULL
)
}
\arguments{
\item{rv}{A list containing outputs, settings and data objects. Must not be NULL.}

\item{set_target}{Character. Research target: `"hr"` for home range or `"ctsd"` for speed & distance.}

\item{subpop}{Logical. If TRUE, will run meta-analyses with groups. Default is FALSE.}

\item{trace}{Logical. If TRUE, prints progress messages. Default is FALSE.}

\item{.iter_step}{Numeric. The size of each iteration step. Default is 2.}

\item{.only_max_m}{Logical. If TRUE, will only run the maximum number of individuals. Default is FALSE.}

\item{.lists}{A list containing already created meta inputs. Default is NULL.}
}
\value{
The outputs of the `run_meta_permutations` function for a single permutation.
}
\description{
This function wraps around the `run_meta_permutations` function to run meta-analyses once (no permutations) for a quick evaluation.
}
