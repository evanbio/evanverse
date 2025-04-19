#' 📄 Convert GMT File to Named List
#'
#' Reads a `.gmt` gene set file and returns a named list,
#' where each list element is a gene set.
#'
#' @param file Path to a `.gmt` file.
#' @param verbose Logical. Whether to print message. Default = TRUE.
#'
#' @return A named list where each element is a character vector of gene symbols.
#' @export
#'
#' @importFrom GSEABase getGmt geneIds
#' @importFrom cli cli_alert_success cli_abort
#'
#' @examples
#' # gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
#' # gene_sets <- gmt2list(gmt_file)
gmt2list <- function(file, verbose = TRUE) {
  # --- Check ---
  if (!file.exists(file)) {
    cli::cli_abort("❌ GMT file not found: {.path {file}}")
  }

  if (!requireNamespace("GSEABase", quietly = TRUE)) {
    cli::cli_abort("Please install {.pkg GSEABase} to use {.fn gmt2list}.")
  }

  # --- Read & Parse ---
  gmt_obj <- GSEABase::getGmt(file)
  gene_sets <- GSEABase::geneIds(gmt_obj)

  if (verbose) {
    cli::cli_alert_success("📄 Parsed {.val {length(gene_sets)}} gene sets from {.file {basename(file)}}.")
  }

  return(gene_sets)
}
