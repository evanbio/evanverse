#' download_url(): Download File from URL
#'
#' Downloads files from URLs (HTTP/HTTPS/FTP/SFTP) with robust error handling,
#' retry mechanisms, and advanced features like resume, bandwidth limiting, and auto-extraction.
#'
#' @param url Character string. Full URL to the file to download.
#'   Supports HTTP, HTTPS, FTP, and SFTP protocols.
#' @param dest Character string. Destination file path. If not specified,
#'   uses the basename of the URL. Default: basename(url).
#' @param overwrite Logical. Whether to overwrite existing files. Default: FALSE.
#' @param unzip Logical. Whether to automatically extract compressed files
#'   after download. Supports .zip, .gz, .tar.gz formats. Default: FALSE.
#' @param verbose Logical. Whether to show download progress and status messages. Default: TRUE.
#' @param timeout Numeric. Download timeout in seconds. Default: 600 (10 minutes).
#' @param headers Named list. Custom HTTP headers for the request
#'   (e.g., list(Authorization = "Bearer token")). Default: NULL.
#' @param resume Logical. Whether to attempt resuming interrupted downloads
#'   if a partial file exists. Default: FALSE.
#' @param speed_limit Numeric. Bandwidth limit in bytes per second
#'   (e.g., 500000 = 500KB/s). Default: NULL (no limit).
#' @param retries Integer. Number of retry attempts on download failure. Default: 3.
#'
#' @return Invisible character string or vector of file paths:
#' \describe{
#'   \item{If unzip = FALSE}{Path to the downloaded file}
#'   \item{If unzip = TRUE}{Vector of paths to extracted files}
#' }
#'
#' @details
#' This function provides a comprehensive solution for downloading files with:
#'
#' \subsection{Supported Protocols}{
#' Supports HTTP/HTTPS, FTP, and SFTP protocols.
#' }
#'
#' \subsection{Features}{
#' Includes retry mechanism, resume support, bandwidth control, auto-extraction, progress tracking, and custom headers.
#' }
#'
#' \subsection{Compression Support}{
#' Supports .zip, .gz, and .tar.gz formats.
#' }
#'
#' @section Dependencies:
#' Required packages: curl, cli, R.utils (automatically checked at runtime).
#'
#' @examples
#' \dontrun{
#' # Download a CSV file from GitHub:
#' download_url(
#'   url = "https://raw.githubusercontent.com/tidyverse/ggplot2/main/README.md",
#'   dest = file.path(tempdir(), "ggplot2_readme.md"),
#'   timeout = 30
#' )
#'
#' # Download and extract a zip file:
#' download_url(
#'   url = "https://cran.r-project.org/src/contrib/Archive/dplyr/dplyr_0.8.0.tar.gz",
#'   dest = file.path(tempdir(), "dplyr.tar.gz"),
#'   unzip = TRUE,
#'   timeout = 60
#' )
#' }
#'
#' \donttest{
#' # Quick demo with a tiny file:
#' download_url(
#'   url = "https://httpbin.org/robots.txt",
#'   dest = file.path(tempdir(), "robots.txt"),
#'   timeout = 10,
#'   verbose = FALSE
#' )
#' }
#'
#' @export
download_url <- function(url,
                         dest = basename(url),
                         overwrite = FALSE,
                         unzip = FALSE,
                         verbose = TRUE,
                         timeout = 600,
                         headers = NULL,
                         resume = FALSE,
                         speed_limit = NULL,
                         retries = 3) {

  # ===========================================================================
  # Dependency & Parameter Validation Phase
  # ===========================================================================
  if (!requireNamespace("curl", quietly = TRUE)) {
    cli::cli_abort("curl package is required. Please install it with: install.packages('curl')")
  }
  if (!requireNamespace("cli", quietly = TRUE)) {
    cli::cli_abort("cli package is required. Please install it with: install.packages('cli')")
  }
  if (isTRUE(unzip) && !requireNamespace("R.utils", quietly = TRUE)) {
    cli::cli_abort("R.utils package is required for unzip functionality. Please install it with: install.packages('R.utils')")
  }

  if (!is.character(url) || length(url) != 1 || is.na(url) || url == "") {
    cli::cli_abort("url must be a single non-empty character string")
  }
  if (!is.character(dest) || length(dest) != 1 || is.na(dest) || dest == "") {
    cli::cli_abort("dest must be a single non-empty character string")
  }
  if (!is.logical(overwrite) || length(overwrite) != 1) {
    cli::cli_abort("overwrite must be a single logical value")
  }
  if (!is.logical(unzip) || length(unzip) != 1) {
    cli::cli_abort("unzip must be a single logical value")
  }
  if (!is.logical(verbose) || length(verbose) != 1) {
    cli::cli_abort("verbose must be a single logical value")
  }
  if (!is.numeric(timeout) || length(timeout) != 1 || timeout <= 0) {
    cli::cli_abort("timeout must be a positive number")
  }
  if (!is.null(headers) && !is.list(headers)) {
    cli::cli_abort("headers must be a list or NULL")
  }
  if (!is.logical(resume) || length(resume) != 1) {
    cli::cli_abort("resume must be a single logical value")
  }
  if (!is.null(speed_limit) && (!is.numeric(speed_limit) || length(speed_limit) != 1 || speed_limit <= 0)) {
    cli::cli_abort("speed_limit must be a positive number or NULL")
  }
  if (!is.numeric(retries) || length(retries) != 1 || retries < 0 || retries != as.integer(retries)) {
    cli::cli_abort("retries must be a non-negative integer")
  }

  cli::cli_h1("Starting File Download")
  cli::cli_alert_info("URL: {.url {url}}")
  cli::cli_alert_info("Destination: {.path {dest}}")

  # ===========================================================================
  # File Existence Check Phase
  # ===========================================================================
  if (file.exists(dest) && !overwrite) {
    cli::cli_alert_success("File already exists at {.path {dest}}, skipping download")
    return(invisible(dest))
  }

  dest_dir <- dirname(dest)
  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
    if (verbose) cli::cli_alert_info("Created destination directory: {.path {dest_dir}}")
  }

  # ===========================================================================
  # Download Configuration Phase
  # ===========================================================================
  h <- curl::new_handle()
  curl::handle_setopt(h,
                      timeout = timeout,
                      failonerror = TRUE,
                      noprogress = !verbose,
                      followlocation = TRUE)

  if (!is.null(headers) && length(headers) > 0) {
    header_names <- names(headers)
    if (is.null(header_names) || any(header_names == "")) {
      cli::cli_abort("All headers must have non-empty names")
    }
    header_list <- as.list(unlist(headers))
    names(header_list) <- names(headers)
    curl::handle_setheaders(h, .list = header_list)
    if (verbose) cli::cli_alert_info("Added {length(headers)} custom header(s)")
  }

  if (resume && file.exists(dest)) {
    file_size <- file.info(dest)$size
    if (file_size > 0) {
      curl::handle_setopt(h, resume_from = file_size)
      if (verbose) cli::cli_alert_info("Attempting to resume download from {file_size} bytes")
    }
  }

  if (!is.null(speed_limit)) {
    curl::handle_setopt(h, max_recv_speed_large = as.integer(speed_limit))
    if (verbose) {
      speed_limit_mb <- speed_limit / 1000000
      cli::cli_alert_info("Bandwidth limit set to {round(speed_limit_mb, 2)} MB/s")
    }
  }

  # ===========================================================================
  # Timeout Configuration Phase
  # ===========================================================================
  old_timeout <- getOption("timeout")
  if (timeout > old_timeout) {
    options(timeout = timeout)
    on.exit(options(timeout = old_timeout), add = TRUE)
  }

  # ===========================================================================
  # Download with Retry Phase
  # ===========================================================================
  attempt <- 1
  success <- FALSE
  download_error <- NULL

  while (attempt <= retries && !success) {
    if (attempt > 1) {
      backoff_time <- min(2^(attempt - 2), 30)
      if (verbose) cli::cli_alert_info("Retrying in {backoff_time} seconds...")
      Sys.sleep(backoff_time)
    }

    tryCatch({
      cli::cli_h2("Download Attempt {attempt}/{retries}")
      download_start <- Sys.time()

      curl::curl_download(
        url = url,
        destfile = dest,
        handle = h,
        quiet = !verbose
      )

      download_end <- Sys.time()
      download_duration <- as.numeric(difftime(download_end, download_start, units = "secs"))
      success <- TRUE

      file_size_bytes <- file.info(dest)$size
      file_size_mb <- file_size_bytes / 1000000
      cli::cli_alert_success("Download completed successfully")
      cli::cli_alert_info("File size: {round(file_size_mb, 2)} MB")
      cli::cli_alert_info("Download time: {round(download_duration, 2)} seconds")
      if (download_duration > 0) {
        speed_bps <- file_size_bytes / download_duration
        speed_mbps <- speed_bps / 1000000
        if (verbose) cli::cli_alert_info("Average speed: {round(speed_mbps, 2)} MB/s")
      }

    }, error = function(e) {
      download_error <- e$message
      cli::cli_alert_warning("Download attempt {attempt} failed: {e$message}")
      attempt <- attempt + 1
    })
  }

  if (!success) {
    cli::cli_alert_danger("All {retries} download attempts failed")
    cli::cli_alert_danger("Last error: {download_error}")
    cli::cli_abort("Failed to download file from {.url {url}}")
  }

  # ===========================================================================
  # Post-Download Processing Phase
  # ===========================================================================
  result <- dest

  if (unzip) {
    cli::cli_h2("Extracting Files")

    ext <- tools::file_ext(dest)
    extract_dir <- dirname(dest)
    result_files <- dest

    result <- tryCatch({
      if (ext == "zip") {
        utils::unzip(dest, exdir = extract_dir)
        extracted_files <- list.files(extract_dir, full.names = TRUE, recursive = TRUE)
        out <- extracted_files[!extracted_files %in% dest]
        cli::cli_alert_success("Extracted {length(out)} files from ZIP archive")
        out

      } else if (ext %in% c("gz", "gzip") && !grepl("\\.tar\\.gz$", dest, ignore.case = TRUE)) {
        out_path <- sub("\\.gz$", "", dest, ignore.case = TRUE)
        R.utils::gunzip(dest, destname = out_path, overwrite = TRUE, remove = FALSE)
        cli::cli_alert_success("Decompressed GZ file to: {.path {basename(out_path)}}")
        out_path

      } else if (grepl("\\.tar\\.gz$", dest, ignore.case = TRUE) || grepl("\\.tar$", dest, ignore.case = TRUE)) {
        utils::untar(dest, exdir = extract_dir)
        extracted_files <- list.files(extract_dir, full.names = TRUE, recursive = TRUE)
        out <- extracted_files[!grepl(basename(dest), extracted_files, fixed = TRUE)]
        cli::cli_alert_success("Extracted {length(out)} files from TAR archive")
        out

      } else {
        cli::cli_alert_warning("Unsupported file format for extraction: {ext}")
        cli::cli_alert_info("Supported formats: .zip, .gz, .tar.gz, .tar")
        result_files
      }
    }, error = function(e) {
      cli::cli_alert_danger("Failed to extract file: {e$message}")
      cli::cli_abort("Extraction failed for {.path {dest}}")
    })
  }

  # ===========================================================================
  # Completion / Return
  # ===========================================================================
  cli::cli_h1("Download Process Completed")
  if (is.character(result) && length(result) == 1) {
    cli::cli_alert_success("Final file: {.path {result}}")
  } else {
    cli::cli_alert_success("Extracted {length(result)} file(s)")
  }

  invisible(result)
}
