# =============================================================================
# data.R — Documentation for package datasets
# =============================================================================

#' Built-in color palettes
#'
#' A compiled list of all built-in color palettes, organized by type.
#' Generated from JSON source files in `inst/extdata/palettes/` via
#' `data-raw/palettes.R`.
#'
#' @format A named list with three elements:
#' \describe{
#'   \item{sequential}{Named list of sequential palettes; each element is a
#'     character vector of HEX color codes.}
#'   \item{diverging}{Named list of diverging palettes; each element is a
#'     character vector of HEX color codes.}
#'   \item{qualitative}{Named list of qualitative palettes; each element is a
#'     character vector of HEX color codes.}
#' }
#'
#' @source \code{data-raw/palettes.R}
#'
#' @examples
#' names(palettes)
#' names(palettes$qualitative)
#' palettes$qualitative$qual_vivid
"palettes"
