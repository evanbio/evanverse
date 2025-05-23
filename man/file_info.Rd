% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/file_info.R
\name{file_info}
\alias{file_info}
\title{📄 Summarize File Information (size, time, line count)}
\usage{
file_info(
  paths,
  recursive = FALSE,
  count_line = TRUE,
  preview = TRUE,
  filter_pattern = NULL,
  full_name = TRUE
)
}
\arguments{
\item{paths}{Character vector of file paths or a folder path.}

\item{recursive}{Logical. If a folder is given, whether to search recursively.}

\item{count_line}{Logical. Whether to count lines in each file. Default: TRUE.}

\item{preview}{Logical. Whether to show skipped/missing messages. Default: TRUE.}

\item{filter_pattern}{Optional regex to filter file names (e.g., "\\.R$").}

\item{full_name}{Logical. Whether to return full file paths. Default: TRUE.}
}
\value{
A data.frame with file, size_MB, modified_time, line_count, path.
}
\description{
Given a file or folder path (or vector), returns a data.frame containing
file name, size (in MB), last modified time, optional line count, and path.
}
\examples{
file_info("R")
file_info(c("README.md", "DESCRIPTION"))
file_info("R", filter_pattern = "\\\\.R$", recursive = TRUE)
}
