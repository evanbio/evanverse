#' Download GEO Data Resources
#'
#' Downloads GEO data resources including GSEMatrix, supplemental files, and GPL platform files.
#' Adds support for logging, error handling, metadata recording, timeout control, and retries.
#'
#' @param gse_id GEO accession (e.g., "GSE12345").
#' @param dest_dir Destination directory for downloaded files (default: "data/raw").
#' @param overwrite Logical, whether to overwrite existing files (default: FALSE).
#' @param log Logical, whether to record a log file (default: TRUE).
#' @param log_file Path to log file. If NULL, auto-generate under "logs/geo/".
#' @param retries Number of retry attempts on failure (default: 2).
#' @param timeout Timeout (seconds) for each download attempt (default: 300).
#'
#' @return A list containing:
#' \item{gse_object}{The ExpressionSet object from getGEO.}
#' \item{supplemental_files}{Vector of paths to downloaded supplemental files.}
#' \item{platform_info}{List with platform ID and paths to GPL files.}
#' \item{meta}{Metadata about the download process.}
#'
#' @details
#' This function retrieves GEO series data (GSEMatrix), downloads associated supplementary files,
#' and fetches platform information (GPL files). It supports logging progress, retrying on failure, 
#' and setting download timeouts to enhance robustness.
#'
#' @importFrom GEOquery getGEO getGEOSuppFiles
#' @importFrom Biobase annotation exprs
#' @importFrom cli cli_alert_info cli_alert_success cli_alert_warning cli_alert_danger cli_h1
#' @importFrom withr with_options
#' @importFrom rlang check_installed
#'
#' @examples
#' \dontrun{
#' # Download a GEO dataset and save to temporary directory
#' result <- download_geo_data(
#'   gse_id = "GSE7305",
#'   dest_dir = tempdir(),
#'   overwrite = TRUE,
#'   log = FALSE,
#'   retries = 2,
#'   timeout = 300
#' )
#'
#' # Access the ExpressionSet object
#' exprs_data <- Biobase::exprs(result$gse_object)
#' }
#' @export
download_geo_data <- function(gse_id,
                               dest_dir = "data/raw",
                               overwrite = FALSE,
                               log = TRUE,
                               log_file = NULL,
                               retries = 2,
                               timeout = 300) {
  # Load dependencies
  rlang::check_installed(c("GEOquery", "Biobase", "cli", "withr"))

  # Prepare destination directory
  cli::cli_alert_info("Creating destination directory: {dest_dir}")
  dir.create(dest_dir, showWarnings = FALSE, recursive = TRUE)

  # Prepare log file
  if (log) {
    log_dir <- file.path("logs", "geo")
    dir.create(log_dir, showWarnings = FALSE, recursive = TRUE)
    if (is.null(log_file)) {
      date_tag <- format(Sys.Date(), "%Y%m%d")
      log_file <- file.path(log_dir, paste0(gse_id, "_", date_tag, ".log"))
    }
    cli::cli_alert_info("Log will be recorded at: {log_file}")
  }

  # Internal helper for logging
  write_log <- function(message_text) {
    if (log) {
      cat(format(Sys.time(), "[%Y-%m-%d %H:%M:%S]"), message_text, "\n", file = log_file, append = TRUE)
    }
  }

  # Retry wrapper
  retry_wrapper <- function(expr, retries = 2, timeout = 300, description = "") {
    attempt <- 1
    result <- NULL
    while (attempt <= retries && is.null(result)) {
      cli::cli_alert_info("{description} (Attempt {attempt}/{retries})")
      write_log(paste(description, "(Attempt", attempt, "/", retries, ")"))
      result <- safe_execute(
        withr::with_options(list(timeout = timeout), expr),
        fail_message = paste(description, "- attempt", attempt, "failed")
      )
      attempt <- attempt + 1
    }
    result
  }

  # Fetch GSEMatrix data
  cli::cli_h1("Retrieving GSEMatrix for {gse_id}")
  gset <- retry_wrapper(
    GEOquery::getGEO(gse_id, destdir = dest_dir, GSEMatrix = TRUE, getGPL = FALSE),
    retries = retries,
    timeout = timeout,
    description = paste("Downloading GSEMatrix for", gse_id)
  )
  if (is.null(gset) || length(gset) == 0) {
    cli::cli_alert_danger("❌ Failed to retrieve GSEMatrix for {gse_id}")
    write_log("Failed to retrieve GSEMatrix")
    stop("No GSEMatrix data available for ", gse_id)
  }
  if (length(gset) > 1) {
    cli::cli_alert_warning("Multiple ExpressionSets detected. Using the first: {names(gset)[1]}")
  }
  gset <- gset[[1]]
  cli::cli_alert_success("✅ GSEMatrix retrieved successfully with {ncol(Biobase::exprs(gset))} samples and {nrow(Biobase::exprs(gset))} features.")

  # Download supplemental files
  cli::cli_h1("Downloading supplemental files for {gse_id}")
  supp_result <- retry_wrapper(
    GEOquery::getGEOSuppFiles(gse_id, makeDirectory = FALSE, baseDir = dest_dir, fetch_files = !overwrite),
    retries = retries,
    timeout = timeout,
    description = paste("Downloading supplemental files for", gse_id)
  )
  supplemental_files <- if (!is.null(supp_result)) list.files(dest_dir, full.names = TRUE) else character()
  if (length(supplemental_files) > 0) {
    cli::cli_alert_success("✅ Supplemental files downloaded: {length(supplemental_files)} files.")
  } else {
    cli::cli_alert_warning("⚠️ No supplemental files found.")
  }

  # Fetch platform (GPL) information
  cli::cli_h1("Retrieving platform information for {gse_id}")
  platform_id <- Biobase::annotation(gset)
  gpl_file_path <- file.path(dest_dir, paste0(platform_id, ".soft.gz"))
  platform_info <- list(platform_id = platform_id, gpl_files = character())
  if (nzchar(platform_id)) {
    cli::cli_alert_info("Platform identified: {platform_id}")
    gpl_result <- retry_wrapper(
      GEOquery::getGEO(platform_id, destdir = dest_dir, getGPL = TRUE),
      retries = retries,
      timeout = timeout,
      description = paste("Downloading GPL file for", platform_id)
    )
    if (!is.null(gpl_result) && file.exists(gpl_file_path)) {
      platform_info$gpl_files <- gpl_file_path
      cli::cli_alert_success("✅ GPL file downloaded: {basename(gpl_file_path)}")
    } else {
      cli::cli_alert_warning("⚠️ No GPL file downloaded for {platform_id}")
    }
  } else {
    cli::cli_alert_warning("⚠️ No platform annotation found in GSEMatrix.")
  }

  # Collect metadata
  meta <- list(
    gse_id = gse_id,
    dest_dir = dest_dir,
    downloaded_at = Sys.time(),
    retries = retries,
    timeout = timeout,
    status = "success"
  )

  # Final log
  cli::cli_h1("GEO data download completed for {gse_id}")
  write_log("Download completed successfully.")

  list(
    gse_object = gset,
    supplemental_files = supplemental_files,
    platform_info = platform_info,
    meta = meta
  )
}

  settings <- list(
    bioconductor_mirror = "https://mirrors.westlake.edu.cn/bioconductor",
    http_proxy = "http://127.0.0.1:10809",
    https_proxy = "http://127.0.0.1:10809"
  )

           Sys.setenv(http_proxy = settings$http_proxy,
                      https_proxy = settings$https_proxy)
