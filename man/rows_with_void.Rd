% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rows_with_void.R
\name{rows_with_void}
\alias{rows_with_void}
\title{🧭 rows_with_void(): Detect Rows Containing Void Values (NA / NULL / "")}
\usage{
rows_with_void(
  data,
  include_na = TRUE,
  include_null = TRUE,
  include_empty_str = TRUE
)
}
\arguments{
\item{data}{A data.frame or tibble.}

\item{include_na}{Logical. Detect \code{NA} if TRUE. Default: TRUE.}

\item{include_null}{Logical. Detect \code{NULL} if TRUE. Default: TRUE.}

\item{include_empty_str}{Logical. Detect \code{""} if TRUE. Default: TRUE.}
}
\value{
A logical vector indicating if each row contains any void values.
}
\description{
Scan a data.frame or tibble and identify rows that contain any "void" values.
Void values include \code{NA}, \code{NULL}, and empty strings (\code{""}), which can be toggled via parameters.
}
\examples{
df <- data.frame(id = 1:3, name = c("A", "", "C"), score = c(10, NA, 20))
rows_with_void(df)
df[rows_with_void(df), ]
}
