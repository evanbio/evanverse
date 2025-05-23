% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/list_palettes.R
\name{list_palettes}
\alias{list_palettes}
\title{🎨 list_palettes(): List All Color Palettes from RDS}
\usage{
list_palettes(
  palette_rds = system.file("extdata", "palettes.rds", package = "evanverse"),
  type = c("sequential", "diverging", "qualitative"),
  sort = TRUE,
  verbose = TRUE
)
}
\arguments{
\item{palette_rds}{Path to the RDS file. Default: \code{"inst/extdata/palettes.rds"}.}

\item{type}{Palette type(s) to filter: \code{"sequential"}, \code{"diverging"}, \code{"qualitative"}. Default: all.}

\item{sort}{Whether to sort by type, n_color, name. Default: TRUE.}

\item{verbose}{Whether to print listing details to console. Default: TRUE.}
}
\value{
A \code{data.frame} with columns: \code{name}, \code{type}, \code{n_color}, \code{colors}.
}
\description{
Load and list all available color palettes compiled into an RDS file.
}
\examples{
list_palettes()
list_palettes(type = "qualitative")
list_palettes(type = c("sequential", "diverging"))
}
