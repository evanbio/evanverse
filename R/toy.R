# =============================================================================
# toy.R — Toy data generators for examples and tests
# =============================================================================

#' Generate a toy gene reference table
#'
#' Generates a small simulated gene reference table for use in examples and
#' tests. Not intended for real analyses — use \code{\link{download_gene_ref}}
#' for a complete reference.
#'
#' @param species One of \code{"human"} or \code{"mouse"}. Default: \code{"human"}.
#' @param n Integer. Number of genes to return. Maximum 20. Default: \code{20}.
#'
#' @return A data.frame with columns \code{symbol}, \code{ensembl_id}, and
#'   \code{entrez_id}.
#' @export
#'
#' @examples
#' toy_gene_ref()
#' toy_gene_ref("mouse", n = 10)
#' Generate a toy GMT file
#'
#' Writes a small GMT gene set file to a temporary path for use in examples
#' and tests. Not intended for real analyses.
#'
#' @param n Integer. Number of gene sets to write. Maximum 5. Default: \code{5}.
#'
#' @return Path to the temporary \code{.gmt} file.
#' @export
#'
#' @examples
#' tmp <- toy_gmt()
#' gmt2df(tmp)
toy_gmt <- function(n = 5L) {
  .assert_count(n)
  .write_tmp_gmt(n)
}


toy_gene_ref <- function(species = c("human", "mouse"), n = 20L) {
  species <- match.arg(species)
  .assert_count(n)

  if (species == "human") .gene_ref_human(n) else .gene_ref_mouse(n)
}
