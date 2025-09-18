#' gmt2df: Convert GMT File to Long-format Data Frame
#'
#' Reads a .gmt gene set file and returns a long-format data frame with
#' one row per gene, including the gene set name and optional description.
#'
#' @param file Character. Path to a .gmt file (supports .gmt or .gmt.gz).
#' @param verbose Logical. Whether to show progress message. Default is TRUE.
#'
#' @return A tibble with columns: term, description, and gene.
#'
#' @examples
#' \dontrun{
#' gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
#' result <- gmt2df(gmt_file)
#' head(result)
#' }
#'
#' @export
gmt2df <- function(file, verbose = TRUE) {

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
    stop("Package 'GSEABase' required. Please install it to use gmt2df().", call. = FALSE)
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

  # Extract gene IDs and descriptions
  gene_ids <- GSEABase::geneIds(gmt_obj)
  descriptions <- vapply(gmt_obj, function(x) x@shortDescription, character(1))

  # Create initial data frame
  df <- tibble::tibble(
    term = names(gene_ids),
    description = descriptions,
    gene = unname(gene_ids)
  ) |>
    tidyr::unnest_longer(gene)

  # ===========================================================================
  # Result Processing Phase
  # ===========================================================================

  # Display success message if requested
  if (isTRUE(verbose)) {
    cli::cli_alert_success(
      "Parsed {nrow(df)} rows from {basename(file)} ({length(unique(df$term))} gene sets)"
    )
  }

  # Return result
  return(df)
}
