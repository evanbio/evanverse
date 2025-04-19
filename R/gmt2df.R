#' 📄 Convert GMT File to Long-format Data Frame
#'
#' Reads a `.gmt` gene set file and returns a long-format data frame with
#' one row per gene, including the gene set name and optional description.
#'
#' @param file Path to a `.gmt` file (supports .gmt or .gmt.gz).
#' @param verbose Logical. Whether to show progress message. Default = TRUE.
#'
#' @return A tibble with columns: `term`, `description`, and `gene`.
#' @export
#'
#' @importFrom GSEABase getGmt geneIds
#' @importFrom tibble tibble
#' @importFrom tidyr unnest_longer
#' @importFrom cli cli_alert_success cli_abort
#'
#' @examples
#' # gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
#' # gmt2df(gmt_file)
gmt2df <- function(file, verbose = TRUE) {
  # --- Check file path ---
  if (!file.exists(file)) {
    cli::cli_abort("❌ GMT file not found: {.path {file}}")
  }

  # --- Ensure dependency ---
  if (!requireNamespace("GSEABase", quietly = TRUE)) {
    cli::cli_abort("Please install {.pkg GSEABase} to use {.fn gmt2df}.")
  }

  # --- Parse GMT ---
  gmt_obj <- GSEABase::getGmt(file)

  df <- tibble::tibble(
    term = names(GSEABase::geneIds(gmt_obj)),
    description = vapply(gmt_obj, function(x) x@shortDescription, character(1)),
    gene = unname(GSEABase::geneIds(gmt_obj))
  ) |>
    tidyr::unnest_longer(gene)

  # --- Optional message ---
  if (verbose) {
    cli::cli_alert_success(
      "📄 Parsed {.val {nrow(df)}} rows from {.file {basename(file)}} ({.val {length(unique(df$term))}} gene sets)."
    )
  }

  return(df)
}
