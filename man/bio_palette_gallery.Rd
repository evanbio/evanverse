% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bio_palette_gallery.R
\name{bio_palette_gallery}
\alias{bio_palette_gallery}
\title{🌈 bio_palette_gallery(): Visualize All Palettes in a Gallery View}
\usage{
bio_palette_gallery(
  palette_rds = NULL,
  type = c("sequential", "diverging", "qualitative"),
  max_palettes = 30,
  max_row = 12,
  verbose = TRUE
)
}
\arguments{
\item{palette_rds}{Path to compiled RDS.
Default: internal palettes.rds from \verb{inst/extdata/}.}

\item{type}{Palette types to include: "sequential", "diverging", "qualitative"}

\item{max_palettes}{Number of palettes per page (default: 30)}

\item{max_row}{Max colors per row (default: 12)}

\item{verbose}{Whether to print summary/logs (default: TRUE)}
}
\value{
A named list of ggplot objects (one per page)
}
\description{
Display palettes from a compiled RDS in a paged gallery format.
}
