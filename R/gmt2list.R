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
#' # Basic usage (commented to avoid file I/O):
#' # gmt_file <- "path/to/geneset.gmt"
#' # gene_sets <- gmt2list(gmt_file)
#' # length(gene_sets)
#' # names(gene_sets)[1:3]
#'
#' @export
gmt2list <- function(file, verbose = TRUE) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  # Validate file parameter
  if (!is.character(file) || length(file) != 1 || is.na(file) || file == "") {
    stop("'file' must be a single non-empty character string.", call. = FALSE)
  }

  # Check if file exists
  if (!file.exists(file)) {
    stop("GMT file not found: ", file, call. = FALSE)
  }

  # Validate verbose parameter
  if (!is.logical(verbose) || length(verbose) != 1 || is.na(verbose)) {
    stop("'verbose' must be a single logical value.", call. = FALSE)
  }

  # ===========================================================================
  # Dependency Check Phase
  # ===========================================================================

  # Check required package
  if (!requireNamespace("GSEABase", quietly = TRUE)) {
    stop("Package 'GSEABase' required. Please install it to use gmt2list().", call. = FALSE)
  }

  # ===========================================================================
  # GMT Parsing Phase
  # ===========================================================================

  # Parse GMT file
  gmt_obj <- tryCatch({
    GSEABase::getGmt(file)
  }, error = function(e) {
    stop("Failed to parse GMT file: ", e$message, call. = FALSE)
  })

  # Validate GMT object
  if (length(gmt_obj) == 0) {
    stop("GMT file contains no gene sets.", call. = FALSE)
  }

  # ===========================================================================
  # Data Conversion Phase
  # ===========================================================================

  # Extract gene sets as named list
  gene_sets <- GSEABase::geneIds(gmt_obj)

  # Validate gene sets data
  if (!is.list(gene_sets) || length(gene_sets) == 0) {
    stop("Invalid gene sets data extracted from GMT file.", call. = FALSE)
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
