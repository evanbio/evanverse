#' 📥 download_url(): Professional Downloader based on curl
#'
#' A robust and flexible downloader using curl. Supports timeout, headers, resume, bandwidth limit, and retries.
#'
#' @param url Character. Full URL to the file (FTP/HTTP/HTTPS/SFTP).
#' @param dest Character. Destination file path. Default: basename(url).
#' @param overwrite Logical. Whether to overwrite existing files. Default: FALSE.
#' @param unzip Logical. Whether to unzip after download (supports .zip/.gz/.tar.gz). Default: FALSE.
#' @param verbose Logical. Show download progress. Default: TRUE.
#' @param timeout Integer. Download timeout in seconds. Default: 600.
#' @param headers Named list. Custom HTTP headers (e.g., Authorization). Default: NULL.
#' @param resume Logical. Try to resume interrupted downloads. Default: FALSE.
#' @param speed_limit Numeric. Bandwidth limit in bytes/sec (e.g., 500000 = 500KB/s). Default: NULL (no limit).
#' @param retries Integer. Number of retry attempts if failed. Default: 3.
#'
#' @return Invisibly returns the downloaded (and optionally unzipped) file path.
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
  # --- Validation
  if (!requireNamespace("curl", quietly = TRUE)) stop("Please install the 'curl' package.")
  if (!requireNamespace("cli", quietly = TRUE)) stop("Please install the 'cli' package.")
  stopifnot(is.character(url), length(url) == 1)

  # --- Skip if exists
  if (file.exists(dest) && !overwrite) {
    if (verbose) cli::cli_alert_info("✔ File already exists at {.path {dest}}, skipping download.")
    return(invisible(dest))
  }

  # --- Prepare curl handle
  h <- curl::new_handle()

  curl::handle_setopt(h,
                      timeout = timeout,
                      failonerror = TRUE,    # Fail if HTTP error code
                      noprogress = !verbose  # Show progress bar
  )

  # Add custom headers if needed
  if (!is.null(headers)) {
    stopifnot(is.list(headers))
    header_vec <- paste(names(headers), headers, sep = ": ")
    curl::handle_setheaders(h, .list = headers)
  }

  # Enable resume if requested
  if (resume && file.exists(dest)) {
    curl::handle_setopt(h, resume_from = file.info(dest)$size)
  }

  # Limit speed if requested
  if (!is.null(speed_limit)) {
    stopifnot(is.numeric(speed_limit), speed_limit > 0)
    curl::handle_setopt(h, max_recv_speed_large = as.integer(speed_limit))
  }

  # --- Extend R timeout option safely
  old_timeout <- getOption("timeout")
  options(timeout = max(timeout, old_timeout))
  on.exit(options(timeout = old_timeout), add = TRUE)

  # --- Download with retry
  attempt <- 1
  success <- FALSE

  while (attempt <= retries && !success) {
    tryCatch({
      if (verbose) {
        cli::cli_h2("📥 Downloading file (Attempt {attempt}/{retries})")
        cli::cli_text("🔗 URL: {.url {url}}")
        cli::cli_text("📁 Destination: {.path {dest}}")
      }

      curl::curl_download(
        url = url,
        destfile = dest,
        handle = h,
        quiet = !verbose
      )

      success <- TRUE

      if (verbose) cli::cli_alert_success("✅ Download complete: {.path {dest}}")

    }, error = function(e) {
      cli::cli_alert_warning("⚠️ Download attempt {attempt} failed: {e$message}")
      attempt <<- attempt + 1
      if (attempt > retries) {
        cli::cli_alert_danger("❌ All download attempts failed for {.url {url}}")
        return(invisible(NULL))
      }
    })
  }

  # --- Optional unzip
  extracted <- dest
  if (success && unzip) {
    ext <- tools::file_ext(dest)
    unzip_dir <- dirname(dest)

    if (ext == "zip") {
      utils::unzip(dest, exdir = unzip_dir)
      extracted <- list.files(unzip_dir, full.names = TRUE)
      if (verbose) cli::cli_alert_success("📂 Unzipped .zip to: {.path {unzip_dir}}")
    } else if (ext %in% c("gz", "gzip") && !grepl("\\.tar\\.gz$", dest)) {
      out <- sub("\\.gz$", "", dest)
      R.utils::gunzip(dest, destname = out, overwrite = TRUE, remove = FALSE)
      extracted <- out
      if (verbose) cli::cli_alert_success("📂 Unzipped .gz to: {.path {out}}")
    } else if (grepl("\\.tar\\.gz$", dest)) {
      utils::untar(dest, exdir = unzip_dir)
      extracted <- list.files(unzip_dir, full.names = TRUE)
      if (verbose) cli::cli_alert_success("📂 Extracted .tar.gz to: {.path {unzip_dir}}")
    } else {
      cli::cli_alert_warning("❗ File format not supported for unzip.")
    }
  }

  invisible(extracted)
}
