% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_ext.R
\name{get_ext}
\alias{get_ext}
\title{🧾 Get File Extension(s)}
\usage{
get_ext(paths, keep_all = FALSE)
}
\arguments{
\item{paths}{A character vector of file names or paths.}

\item{keep_all}{Logical. If TRUE, returns full suffix after first dot in basename
(e.g., "tar.gz"); otherwise returns only the last extension. Default: FALSE.}
}
\value{
A character vector of extensions (no leading dots).
}
\description{
Extract file extension(s) from a file name or path. Supports vector input and
optionally preserves compound extensions (e.g., \code{.tar.gz}) when \code{keep_all = TRUE}.
}
\examples{
get_ext("data.csv")               # "csv"
get_ext("archive.tar.gz")        # "gz"
get_ext("archive.tar.gz", TRUE)  # "tar.gz"
get_ext(c("a.R", "b.txt", "c"))   # "R" "txt" ""
}
