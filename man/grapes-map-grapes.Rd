% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/percent_map_operator.R
\name{\%map\%}
\alias{\%map\%}
\title{🔁 \%map\%: Case-insensitive mapping returning named vector}
\usage{
x \%map\% table
}
\arguments{
\item{x}{Character vector of input strings.}

\item{table}{Character vector to match against.}
}
\value{
A named character vector. Names come from matched \code{table} values, values from \code{x}.
}
\description{
Performs case-insensitive matching between elements in \code{x} and entries in \code{table},
returning a named character vector: matched \code{table} entries as names, and \code{x} as values.
Unmatched values are assigned a default name ("unknown") but removed before returning.
}
\examples{
c("tp53", "brca1", "egfr") \%map\% c("TP53", "EGFR", "MYC")
# → Named vector with matches: TP53 = "tp53", EGFR = "egfr"
}
