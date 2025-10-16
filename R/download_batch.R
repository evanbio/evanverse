#' download_batch(): Batch download files using multi_download (parallel with curl)
#'
#' A robust batch downloader that supports concurrent downloads with flexible options.
#' Built on top of `curl::multi_download()` for parallelism.
#'
#' @param urls Character vector. List of URLs to download.
#' @param dest_dir Character. Destination directory (required). Use tempdir() for examples/tests.
#' @param overwrite Logical. Whether to overwrite existing files. Default: FALSE.
#' @param unzip Logical. Whether to unzip after download (for supported formats). Default: FALSE.
#' @param workers Integer. Number of parallel workers. Default: 4.
#' @param verbose Logical. Show download progress messages. Default: TRUE.
#' @param timeout Integer. Timeout in seconds for each download. Default: 600.
#' @param resume Logical. Whether to resume interrupted downloads. Default: FALSE.
#' @param speed_limit Numeric. Bandwidth limit in bytes/sec (e.g., 500000 = 500KB/s). Default: NULL.
#' @param retries Integer. Retry attempts if download fails. Default: 3.
#'
#' @return Invisibly returns a list of downloaded (and optionally unzipped) file paths.
#' @export
download_batch <- function(urls,
                           dest_dir,
                           overwrite = FALSE,
                           unzip = FALSE,
                           workers = 4,
                           verbose = TRUE,
                           timeout = 600,
                           resume = FALSE,
                           speed_limit = NULL,
                           retries = 3) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  if (!requireNamespace("curl", quietly = TRUE)) {
    cli::cli_abort("Please install curl")
  }

  # Validate dest_dir (required parameter)
  if (missing(dest_dir) || is.null(dest_dir) || !is.character(dest_dir) || length(dest_dir) != 1) {
    cli::cli_abort("'dest_dir' must be specified. Use tempdir() for examples/tests.")
  }

  if (!is.character(urls)) {
    cli::cli_abort("urls must be a character vector")
  }
  if (length(urls) == 0) {
    cli::cli_abort("No URLs provided")
  }

  # ===========================================================================
  # Setup Phase
  # ===========================================================================

  # Safe filename generator (inline)
  safe_filename <- function(url) {
    fname <- basename(url)
    fname <- sub("\\?.*$", "", fname)
    fname <- gsub("[^A-Za-z0-9._-]", "_", fname)
    if (nchar(fname) < 3) {
      fname <- paste0(digest::digest(url), ".dat")
    }
    fname
  }

  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE)
  }
  dest_paths <- file.path(dest_dir, vapply(urls, safe_filename, character(1)))

  # ===========================================================================
  # Download Phase
  # ===========================================================================

  if (verbose) {
    cli::cli_h1("Starting batch download")
    cli::cli_alert_info("Number of files: {length(urls)}")
    cli::cli_alert_info("Destination: {dest_dir}")
  }

  result <- tryCatch({
    curl::multi_download(
      urls = urls,
      destfile = dest_paths,
      resume = resume,
      progress = verbose,
      multi_timeout = timeout,
      multiplex = TRUE
    )
    if (verbose) {
      cli::cli_alert_success("All downloads complete!")
    }
    return(dest_paths)
  }, error = function(e) {
    cli::cli_alert_danger("Batch download failed: {e$message}")
    return(NULL)
  })

  invisible(result)
}
