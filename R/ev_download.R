#' 📥 ev_download(): Download a file from URL (supports FTP/HTTP + unzip)
#'
#' A robust and friendly downloader that supports FTP/HTTP/HTTPS sources.
#' Automatically skips download if file already exists.
#'
#' @param url Character. Full URL to the file (FTP or HTTP).
#' @param dest Character. Path to save the file (default: basename(url)).
#' @param method Character. One of "auto", "curl", "wget", or "internal". Default: "auto".
#' @param overwrite Logical. Overwrite if file exists. Default: FALSE.
#' @param unzip Logical. Whether to unzip after download. Default: FALSE.
#' @param verbose Logical. Show progress messages. Default: TRUE.
#'
#' @return Invisibly returns path(s) to downloaded (and optionally unzipped) file(s).
#' @export
ev_download <- function(url,
                        dest = basename(url),
                        method = "auto",
                        overwrite = FALSE,
                        unzip = FALSE,
                        verbose = TRUE) {
  # --- Validation
  stopifnot(is.character(url), length(url) == 1)
  stopifnot(method %in% c("auto", "curl", "wget", "internal"))

  # --- Skip if exists
  if (file.exists(dest) && !overwrite) {
    if (verbose) cli::cli_alert_info("✔ File already exists at {.path {dest}}, skipping download.")
    return(invisible(dest))
  }

  # --- Download
  if (verbose) {
    cli::cli_h2("📥 Downloading file")
    cli::cli_text("🔗 URL: {.url {url}}")
    cli::cli_text("📁 Destination: {.path {dest}}")
  }

  tryCatch({
    utils::download.file(url = url, destfile = dest, method = method, quiet = !verbose)
    if (verbose) cli::cli_alert_success("✅ Download complete: {.path {dest}}")

    # --- Optional unzip step
    extracted <- dest
    if (unzip) {
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
  }, error = function(e) {
    cli::cli_alert_danger("❌ Download failed: {e$message}")
    invisible(NULL)
  })
}
