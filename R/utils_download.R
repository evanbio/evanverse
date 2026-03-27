# =============================================================================
# utils_download.R — Internal helpers for download functions
# =============================================================================

#' Derive a safe local filename from a URL
#'
#' @param url A single URL string.
#' @return A single safe filename string.
#' @keywords internal
#' @noRd
.safe_filename_from_url <- function(url) {
  fname <- basename(url)
  fname <- sub("\\?.*$", "", fname)
  fname <- gsub("[^A-Za-z0-9._-]", "_", fname)
  if (nchar(fname) < 3L) {
    fname <- paste0(format(sum(utf8ToInt(url)), scientific = FALSE), ".dat")
  }
  fname
}


#' Retry wrapper with exponential backoff
#'
#' @param expr Expression to evaluate.
#' @param retries Integer. Number of retries after first failure.
#' @param timeout Integer. Timeout in seconds.
#' @param label Character or \code{NULL}. If provided, a warning is emitted
#'   when all attempts are exhausted, identifying the failed operation.
#' @return Result of \code{expr}, or \code{NULL} if all attempts fail.
#' @keywords internal
#' @noRd
.geo_retry <- function(expr, retries = 2, timeout = 300, label = NULL) {
  result     <- NULL
  last_error <- NULL
  for (attempt in seq_len(retries + 1L)) {
    if (attempt > 1L) Sys.sleep(min(2^(attempt - 2), 60))
    result <- tryCatch(
      withr::with_options(list(timeout = timeout), expr),
      error = function(e) { last_error <<- conditionMessage(e); NULL }
    )
    if (!is.null(result)) break
  }
  if (is.null(result)) {
    msg      <- if (!is.null(label)) paste0(label, ": ") else ""
    err_info <- if (!is.null(last_error) && nzchar(last_error)) last_error
                else "(no error message captured)"
    cli::cli_warn(
      "All {retries + 1L} attempt{?s} failed. {msg}{err_info}",
      call = NULL
    )
  }
  result
}


#' Download GSEMatrix for a GEO series
#'
#' @param gse_id Character. GEO Series accession ID.
#' @param dest_dir Character. Destination directory.
#' @param retries Integer. Number of retries after first failure.
#' @param timeout Integer. Timeout in seconds.
#' @return An ExpressionSet object.
#' @keywords internal
#' @noRd
.download_geo_gsematrix <- function(gse_id, dest_dir, retries = 2, timeout = 300) {
  gset <- .geo_retry(
    GEOquery::getGEO(gse_id, destdir = dest_dir, GSEMatrix = TRUE, getGPL = FALSE),
    retries = retries, timeout = timeout
  )

  if (is.null(gset) || length(gset) == 0) {
    cli::cli_abort("No GSEMatrix data available for {gse_id}.", call = NULL)
  }
  if (length(gset) > 1) {
    cli::cli_alert_warning("Multiple ExpressionSets found, using the first: {names(gset)[1]}")
  }

  gset[[1]]
}


#' Download supplemental files for a GEO series
#'
#' @param gse_id Character. GEO Series accession ID.
#' @param dest_dir Character. Destination directory.
#' @param retries Integer. Number of retries after first failure.
#' @param timeout Integer. Timeout in seconds.
#' @return Character vector of downloaded file paths, or \code{character(0)} if none.
#' @keywords internal
#' @noRd
.download_geo_supp_files <- function(gse_id, dest_dir, retries = 2, timeout = 300) {
  # getGEOSuppFiles() returns a data.frame whose rownames are the file paths.
  # Reason: using rownames avoids listing unrelated pre-existing files in dest_dir.
  result <- .geo_retry(
    GEOquery::getGEOSuppFiles(gse_id, makeDirectory = FALSE, baseDir = dest_dir, fetch_files = TRUE),
    retries = retries, timeout = timeout,
    label   = paste0(gse_id, " supplemental files")
  )
  if (!is.null(result)) rownames(result) else character()
}


#' Download platform annotation for a GEO ExpressionSet
#'
#' @param gset An ExpressionSet object.
#' @param dest_dir Character. Destination directory.
#' @param retries Integer. Number of retries after first failure.
#' @param timeout Integer. Timeout in seconds.
#' @return A list with \code{platform_id} and \code{gpl_files}.
#' @keywords internal
#' @noRd
.download_geo_platform <- function(gset, dest_dir, retries = 2, timeout = 300) {
  platform_id   <- gset@annotation
  gpl_file_path <- file.path(dest_dir, paste0(platform_id, ".soft.gz"))
  gpl_files     <- character()

  if (nzchar(platform_id)) {
    result <- .geo_retry(
      GEOquery::getGEO(platform_id, destdir = dest_dir, getGPL = TRUE),
      retries = retries, timeout = timeout,
      label   = paste0("GPL annotation for ", platform_id)
    )
    if (!is.null(result) && file.exists(gpl_file_path)) {
      gpl_files <- gpl_file_path
    }
  }

  list(platform_id = platform_id, gpl_files = gpl_files)
}
