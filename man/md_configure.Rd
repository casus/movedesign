% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fct_main.R
\name{md_configure}
\alias{md_configure}
\title{Interactively configure movement design setup}
\usage{
md_configure(data, models = NULL)
}
\arguments{
\item{data}{A named list of telemetry objects (from
\code{ctmm::as.telemetry()}) to be used as the empirical basis for the
simulations. Each telemetry object must contain valid metadata
and timestamped locations.}

\item{models}{(Optional) Named list of fitted ctmm models (from
\code{ctmm::ctmm.fit()} or \code{ctmm::ctmm.select()}). If not supplied,
models are fitted automatically.}
}
\value{
An object of class \code{movedesign_input} (and \code{movedesign}). This is
a structured S3 list containing all validated inputs, model fits,
and derived parameters for the study design workflow.
}
\description{
Guides the user to assign each argument required for a movement design
workflow, including species label and key simulation settings. Users
may choose to set a specific population sample size (number of animals
tagged/to be tagged) or optimize the population sample size considering
a specific analytical target.
}
\details{
The argument \code{data} is \strong{required} and must be supplied directly (as
a list of telemetry objects, obtained from \code{ctmm::as.telemetry()}).
The argument \code{models} is optional, and if omitted, models will be
fitted automatically.
}
\examples{
if(interactive()) {
  data(buffalo)
  md_params <- md_configure(data = buffalo)
}

}
\seealso{
\code{\link[=md_prepare]{md_prepare()}}
}
