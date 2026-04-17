# =============================================================================
# utils_base.R — Internal helpers for base utilities
# =============================================================================

#' Parse a GMT file into a list of gene sets
#'
#' Each element is a list with \code{term}, \code{description}, and \code{genes}.
#' Lines with fewer than 3 tab-separated fields are skipped with a warning.
#'
#' @param file Character. Path to a \code{.gmt} file.
#' @return A list of named lists with \code{term}, \code{description}, \code{genes}.
#' @keywords internal
#' @noRd
.parse_gmt <- function(file) {
  lines <- readLines(file, warn = FALSE)
  lines <- lines[nzchar(lines)]

  if (length(lines) == 0L) {
    cli::cli_abort("GMT file contains no gene sets: {.path {file}}", call = NULL)
  }

  result <- vector("list", length(lines))
  valid  <- logical(length(lines))

  for (i in seq_along(lines)) {
    fields <- strsplit(lines[i], "\t")[[1]]
    if (length(fields) < 3L) {
      cli::cli_warn("Line {i} has fewer than 3 fields, skipping.", call = NULL)
      next
    }
    genes      <- fields[-(1:2)]
    genes      <- genes[nzchar(genes)]
    result[[i]] <- list(term = fields[1L], description = fields[2L], genes = genes)
    valid[i]   <- TRUE
  }

  out <- result[valid]
  if (length(out) == 0L) {
    cli::cli_abort("GMT file contains no valid gene sets: {.path {file}}", call = NULL)
  }

  out
}


#' Warn when a gene reference contains duplicated symbols after normalization
#'
#' @param symbol Character vector of reference symbols.
#' @param species Character. One of \code{"human"} or \code{"mouse"}.
#' @return Normalized symbols used for matching.
#' @keywords internal
#' @noRd
.normalize_ref_symbols <- function(symbol, species) {
  ref_symbol <- if (species == "human") toupper(symbol) else tolower(symbol)
  duplicated_symbol <- unique(ref_symbol[duplicated(ref_symbol)])

  if (length(duplicated_symbol) > 0L) {
    cli::cli_warn(
      "Reference contains duplicated gene symbol{?s} after case normalization: {.val {duplicated_symbol}}. Using the first match.",
      call = NULL
    )
  }

  ref_symbol
}


#' Return an empty file-info data frame with correct column types
#'
#' @return A zero-row data.frame with columns \code{file}, \code{size_MB},
#'   \code{modified_time}, \code{path}.
#' @keywords internal
#' @noRd
.empty_file_info <- function() {
  data.frame(
    file          = character(),
    size_MB       = numeric(),
    modified_time = as.POSIXct(character()),
    path          = character(),
    stringsAsFactors = FALSE
  )
}


#' Extract file metadata as a single-row data frame
#'
#' @param f Character scalar. File path.
#' @return A one-row data.frame with columns \code{file}, \code{size_MB},
#'   \code{modified_time}, \code{path}.
#' @keywords internal
#' @noRd
.file_metadata <- function(f) {
  fi <- file.info(f)
  data.frame(
    file          = basename(f),
    size_MB       = if (!is.na(fi$size)) round(fi$size / 1024^2, 3) else NA_real_,
    modified_time = as.POSIXct(fi$mtime),
    path          = normalizePath(f, mustWork = FALSE),
    stringsAsFactors = FALSE
  )
}


#' Return biomaRt dataset name and symbol attribute for a species
#'
#' @param species Character. One of \code{"human"} or \code{"mouse"}.
#' @return A list with \code{dataset} and \code{symbol_attr}.
#' @keywords internal
#' @noRd
.gene_ref_config <- function(species) {
  list(
    dataset     = switch(species,
                         human = "hsapiens_gene_ensembl",
                         mouse = "mmusculus_gene_ensembl"),
    symbol_attr = switch(species,
                         human = "hgnc_symbol",
                         mouse = "mgi_symbol")
  )
}
