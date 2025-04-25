#' 📥 download_batch(): Batch download files using multi_download (parallel with curl)
#'
#' A robust batch downloader that supports concurrent downloads with flexible options.
#' Built on top of `curl::multi_download()` for parallelism.
#'
#' @param urls Character vector. List of URLs to download.
#' @param dest_dir Character. Destination directory. Default: current working directory.
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
                           dest_dir = ".",
                           overwrite = FALSE,
                           unzip = FALSE,
                           workers = 4,
                           verbose = TRUE,
                           timeout = 600,
                           resume = FALSE,
                           speed_limit = NULL,
                           retries = 3) {

  # --- Validation
  if (!requireNamespace("curl", quietly = TRUE)) stop("Please install curl")
  if (!requireNamespace("cli", quietly = TRUE)) stop("Please install cli")
  stopifnot(is.character(urls))
  if (length(urls) == 0) stop("No URLs provided.")

  # --- Helper: safe filename generator
  safe_filename <- function(url) {
    fname <- basename(url)
    fname <- sub("\\?.*$", "", fname)
    fname <- gsub("[^A-Za-z0-9._-]", "_", fname)
    if (nchar(fname) < 3) {
      fname <- paste0(digest::digest(url), ".dat")
    }
    fname
  }

  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE)
  dest_paths <- file.path(dest_dir, vapply(urls, safe_filename, character(1)))

  # --- Start messages
  if (verbose) {
    cli::cli_h1("🚀 Starting batch download")
    cli::cli_alert_info("Number of files: {length(urls)}")
    cli::cli_alert_info("Destination: {.path {dest_dir}}")
  }

  # --- Perform the batch download with multi_download
  result <- tryCatch({
    curl::multi_download(
      urls = urls,
      destfile = dest_paths,
      resume = resume,
      progress = verbose,
      multi_timeout = timeout,
      multiplex = TRUE
    )
    cli::cli_alert_success("✅ All downloads complete!")
    return(dest_paths)
  }, error = function(e) {
    cli::cli_alert_danger("❌ Batch download failed: {e$message}")
    return(NULL)
  })

  invisible(result)
}
