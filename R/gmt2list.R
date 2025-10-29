#' gmt2list: Convert GMT File to Named List
#'
#' Reads a .gmt gene set file and returns a named list,
#' where each list element is a gene set.
#'
#' @param file Character. Path to a .gmt file.
#' @param verbose Logical. Whether to print message. Default is TRUE.
#'
#' @return A named list where each element is a character vector of gene symbols.
#'
#' @examples
#' \dontrun{
#' # Requires a GMT file to run:
#' gmt_file <- "path/to/geneset.gmt"
#' gene_sets <- gmt2list(gmt_file)
#' length(gene_sets)
#' names(gene_sets)[1:3]
#' }
#'
#' @export
gmt2list <- function(file, verbose = TRUE) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  # Validate file parameter
  if (!is.character(file) || length(file) != 1 || is.na(file) || file == "") {
    cli::cli_abort("'file' must be a single non-empty character string.")
  }

  # Check if file exists
  if (!file.exists(file)) {
    cli::cli_abort("GMT file not found: {file}")
  }

  # Validate verbose parameter
  if (!is.logical(verbose) || length(verbose) != 1 || is.na(verbose)) {
    cli::cli_abort("'verbose' must be a single logical value.")
  }

  # ===========================================================================
  # Dependency Check Phase
  # ===========================================================================

  # Check required package
  if (!requireNamespace("GSEABase", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg GSEABase} required. Please install it to use gmt2list().")
  }

  # ===========================================================================
  # GMT Parsing Phase
  # ===========================================================================

  # Parse GMT file
  gmt_obj <- tryCatch({
    GSEABase::getGmt(file)
  }, error = function(e) {
    cli::cli_abort("Failed to parse GMT file: {e$message}")
  })

  # Validate GMT object
  if (length(gmt_obj) == 0) {
    cli::cli_abort("GMT file contains no gene sets.")
  }

  # ===========================================================================
  # Data Conversion Phase
  # ===========================================================================

  # Extract gene sets as named list
  gene_sets <- GSEABase::geneIds(gmt_obj)

  # Validate gene sets data
  if (!is.list(gene_sets) || length(gene_sets) == 0) {
    cli::cli_abort("Invalid gene sets data extracted from GMT file.")
  }

  # ===========================================================================
  # Result Processing Phase
  # ===========================================================================

  # Display success message if requested
  if (isTRUE(verbose)) {
    cli::cli_alert_success(
      "Parsed {length(gene_sets)} gene sets from {basename(file)}"
    )
  }

  # Return result
  return(gene_sets)
}
