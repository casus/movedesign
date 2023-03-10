
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src='https://raw.githubusercontent.com/ecoisilva/movedesign/main/inst/app/www/logo.png' align="left" height="150" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/ecoisilva/movedesign/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ecoisilva/movedesign/actions/workflows/R-CMD-check.yaml)
[![DOI](https://zenodo.org/badge/474098792.svg)](https://zenodo.org/badge/latestdoi/474098792)
<!-- [![Codecov test coverage](https://codecov.io/gh/ecoisilva/movedesign/branch/main/graph/badge.svg)](https://app.codecov.io/gh/ecoisilva/movedesign?branch=main) -->
<!-- badges: end -->

The goal of `movedesign` is to assist researchers in designing movement
ecology studies related to two main research questions: the estimation
of home range and of speed and distance traveled.

Movement ecology studies frequently make use of data collected from
animal tracking projects. Planning a successful animal tracking project
requires careful consideration and clear objectives. It is crucial to
plan ahead and understand how much data is required to accurately answer
your chosen research questions, and choose the optimal tracking regime
or schedule.

To facilitate study design, we refer to the
[ctmm](https://ctmm-initiative.github.io/ctmm/) `R` package. Animal
movement is inherently autocorrelated (locations are similar as a
function of space and time) and the `ctmm` package allows us to model
these data as continuous-time stochastic processes, while dealing with
other known biases (such as small sample sizes, or irregular sampling
schedules).

The app was built using the `golem` framework.

## Installation

You can install the development version of `movedesign` like so:

``` r
install.packages("remotes")
remotes::install_github("ecoisilva/movedesign")
```

If you run with any problems, try the solutions listed in the
[instalation
issues](https://ecoisilva.github.io/movedesign/articles/installation.html)
vignette, and run the tutorial in the ???Home??? tab (see the
[tutorial](https://ecoisilva.github.io/movedesign/articles/tutorial.html)
vignette for how to begin the tour).

## Run the app

To launch the `movedesign` Shiny app, type the following code into the R
console after you have loaded the library:

``` r
library(movedesign)
movedesign::run_app()
```
