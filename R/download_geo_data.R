#' Download GEO Data Resources
#'
#' Downloads GEO (Gene Expression Omnibus) datasets including expression data,
#' supplemental files, and platform annotations with error handling and logging.
#'
#' @param gse_id Character. GEO Series accession ID (e.g., "GSE12345").
#' @param dest_dir Character. Destination directory for downloaded files.
#' @param overwrite Logical. Whether to overwrite existing files (default: FALSE).
#' @param log Logical. Whether to create log file (default: TRUE).
#' @param log_file Character or NULL. Log file path (auto-generated if NULL).
#' @param retries Numeric. Number of retry attempts (default: 2).
#' @param timeout Numeric. Timeout in seconds (default: 300).
#'
#' @return A list with components:
#' \describe{
#'   \item{gse_object}{ExpressionSet object with expression data and annotations}
#'   \item{supplemental_files}{Paths to downloaded supplemental files}
#'   \item{platform_info}{Platform information (platform_id, gpl_files)}
#'   \item{meta}{Download metadata (timing, file counts, etc.)}
#' }
#'
#' @details
#' Downloads GSEMatrix files, supplemental files, and GPL annotations.
#' Includes retry mechanism, timeout control, and logging.
#' Requires: GEOquery, Biobase, withr, cli.
#'
#' @examples
#' \dontrun{
#' # Download GEO data (requires network connection):
#' result <- download_geo_data("GSE12345", dest_dir = tempdir())
#'
#' # Advanced usage with custom settings:
#' result <- download_geo_data(
#'   gse_id = "GSE7305",
#'   dest_dir = tempdir(),
#'   log = TRUE,
#'   retries = 3,
#'   timeout = 600
#' )
#'
#' # Access downloaded data:
#' expr_data <- Biobase::exprs(result$gse_object)
#' sample_info <- Biobase::pData(result$gse_object)
#' feature_info <- Biobase::fData(result$gse_object)
#' }
#'
#' @references
#' \url{https://www.ncbi.nlm.nih.gov/geo/}
#'
#' Barrett T, Wilhite SE, Ledoux P, Evangelista C, Kim IF, Tomashevsky M,
#' Marshall KA, Phillippy KH, Sherman PM, Holko M, Yefanov A, Lee H,
#' Zhang N, Robertson CL, Serova N, Davis S, Soboleva A. NCBI GEO: archive
#' for functional genomics data sets--update. Nucleic Acids Res. 2013 Jan;
#' 41(Database issue):D991-5.
#'
#' @export
download_geo_data <- function(gse_id,
                               dest_dir,
                               overwrite = FALSE,
                               log = TRUE,
                               log_file = NULL,
                               retries = 2,
                               timeout = 300) {

  # ===========================================================================
  # Dependency and Parameter Validation Phase
  # ===========================================================================

  # Check required dependencies
  if (!requireNamespace("GEOquery", quietly = TRUE)) {
    cli::cli_abort("GEOquery package is required. Please install it with: BiocManager::install('GEOquery')")
  }
  if (!requireNamespace("Biobase", quietly = TRUE)) {
    cli::cli_abort("Biobase package is required. Please install it with: BiocManager::install('Biobase')")
  }
  if (!requireNamespace("withr", quietly = TRUE)) {
    cli::cli_abort("withr package is required. Please install it with: install.packages('withr')")
  }
  if (!requireNamespace("cli", quietly = TRUE)) {
    cli::cli_abort("cli package is required. Please install it with: install.packages('cli')")
  }

  # Validate GSE ID format
  if (!is.character(gse_id) || length(gse_id) != 1 || is.na(gse_id)) {
    cli::cli_abort("gse_id must be a single non-missing character string")
  }
  if (!grepl("^GSE\\d{3,}$", gse_id)) {
    cli::cli_abort("gse_id must be a valid GEO accession (e.g., 'GSE12345')")
  }

  # Validate destination directory
  if (!is.character(dest_dir) || length(dest_dir) != 1 || is.na(dest_dir)) {
    cli::cli_abort("dest_dir must be a single character string")
  }

  # Validate other parameters
  if (!is.logical(overwrite) || length(overwrite) != 1 || is.na(overwrite)) {
    cli::cli_abort("overwrite must be a single logical value")
  }
  if (!is.logical(log) || length(log) != 1 || is.na(log)) {
    cli::cli_abort("log must be a single logical value")
  }
  if (!is.null(log_file) && (!is.character(log_file) || length(log_file) != 1 || is.na(log_file))) {
    cli::cli_abort("log_file must be a single character string or NULL")
  }
  if (!is.numeric(retries) || length(retries) != 1 || is.na(retries) || retries < 0 || retries != as.integer(retries)) {
    cli::cli_abort("retries must be a non-negative integer")
  }
  if (!is.numeric(timeout) || length(timeout) != 1 || is.na(timeout) || timeout <= 0) {
    cli::cli_abort("timeout must be a positive number")
  }

  cli::cli_h1("Starting GEO Data Download for {gse_id}")

  # ===========================================================================
  # Directory and Logging Setup Phase
  # ===========================================================================

  # Prepare destination directory
  cli::cli_alert_info("Preparing destination directory: {.path {dest_dir}}")
  dir.create(dest_dir, showWarnings = FALSE, recursive = TRUE)

  # Prepare log file
  if (log) {
    if (is.null(log_file)) {
      # Default log directory at dest_dir/logs/geo
      log_dir <- file.path(dest_dir, "logs", "geo")
      dir.create(log_dir, showWarnings = FALSE, recursive = TRUE)

      date_tag <- format(Sys.Date(), "%Y%m%d")
      log_file <- file.path(log_dir, paste0(gse_id, "_", date_tag, ".log"))
    } else {
      # User-defined log_file, ensure parent directory exists
      dir.create(dirname(log_file), showWarnings = FALSE, recursive = TRUE)
    }

    cli::cli_alert_info("Log will be recorded at: {.path {log_file}}")
  }

  # Internal helper for logging with levels
  write_log <- function(message_text, level = "INFO") {
    if (log) {
      timestamp <- format(Sys.time(), "[%Y-%m-%d %H:%M:%S]")
      log_entry <- paste(timestamp, "[", level, "]", message_text)
      writeLines(log_entry, con = log_file)
    }
  }

  # Record start time for metadata
  start_time <- Sys.time()
  write_log("Download process started", "INFO")

  # ===========================================================================
  # Retry Mechanism Setup Phase
  # ===========================================================================

  # Retry wrapper with exponential backoff
  retry_wrapper <- function(expr, retries = 2, timeout = 300, description = "") {
    attempt <- 1
    result <- NULL
    while (attempt <= retries + 1 && is.null(result)) {
      if (attempt > 1) {
        backoff_time <- min(2^(attempt - 2), 60)  # Exponential backoff, max 60 seconds
        cli::cli_alert_info("Retrying in {backoff_time} seconds...")
        Sys.sleep(backoff_time)
      }

      cli::cli_alert_info("{description} (Attempt {attempt}/{retries + 1})")
      write_log(paste(description, "(Attempt", attempt, "/", retries + 1, ")"), "INFO")

      result <- safe_execute(
        withr::with_options(list(timeout = timeout), expr),
        fail_message = paste(description, "- attempt", attempt, "failed")
      )

      if (is.null(result) && attempt <= retries + 1) {
        write_log(paste(description, "- attempt", attempt, "failed"), "WARNING")
      }

      attempt <- attempt + 1
    }
    result
  }

  # ===========================================================================
  # GSEMatrix Download Phase
  # ===========================================================================

  cli::cli_h2("Retrieving GSEMatrix for {gse_id}")
  gset <- retry_wrapper(
    GEOquery::getGEO(gse_id, destdir = dest_dir, GSEMatrix = TRUE, getGPL = FALSE),
    retries = retries,
    timeout = timeout,
    description = paste("Downloading GSEMatrix for", gse_id)
  )

  if (is.null(gset) || length(gset) == 0) {
    cli::cli_alert_danger("Failed to retrieve GSEMatrix for {gse_id}")
    write_log("Failed to retrieve GSEMatrix", "ERROR")
    cli::cli_abort("No GSEMatrix data available for {gse_id}. Please check the GEO accession ID.")
  }

  if (length(gset) > 1) {
    cli::cli_alert_warning("Multiple ExpressionSets detected. Using the first: {names(gset)[1]}")
    write_log("Multiple ExpressionSets detected. Using the first.", "WARNING")
  }

  gset <- gset[[1]]
  n_samples <- ncol(Biobase::exprs(gset))
  n_features <- nrow(Biobase::exprs(gset))
  cli::cli_alert_success("GSEMatrix retrieved successfully with {n_samples} samples and {n_features} features.")
  write_log("GSEMatrix retrieved successfully", "SUCCESS")

  # ===========================================================================
  # Supplemental Files Download Phase
  # ===========================================================================

  cli::cli_h2("Downloading supplemental files for {gse_id}")
  supp_result <- retry_wrapper(
    GEOquery::getGEOSuppFiles(gse_id, makeDirectory = FALSE, baseDir = dest_dir, fetch_files = TRUE),
    retries = retries,
    timeout = timeout,
    description = paste("Downloading supplemental files for", gse_id)
  )

  supplemental_files <- if (!is.null(supp_result)) list.files(dest_dir, full.names = TRUE) else character()
  if (length(supplemental_files) > 0) {
    cli::cli_alert_success("Supplemental files downloaded: {length(supplemental_files)} files.")
    write_log(paste("Supplemental files downloaded:", paste(basename(supplemental_files), collapse = ", ")), "SUCCESS")
  } else {
    cli::cli_alert_warning("No supplemental files found.")
    write_log("No supplemental files found.", "WARNING")
  }

  # ===========================================================================
  # Platform Information Download Phase
  # ===========================================================================

  cli::cli_h2("Retrieving platform information for {gse_id}")
  platform_id <- Biobase::annotation(gset)
  gpl_file_path <- file.path(dest_dir, paste0(platform_id, ".soft.gz"))
  platform_info <- list(platform_id = platform_id, gpl_files = character())

  if (nzchar(platform_id)) {
    cli::cli_alert_info("Platform identified: {platform_id}")
    write_log(paste("Platform identified:", platform_id), "INFO")

    gpl_result <- retry_wrapper(
      GEOquery::getGEO(platform_id, destdir = dest_dir, getGPL = TRUE),
      retries = retries,
      timeout = timeout,
      description = paste("Downloading GPL file for", platform_id)
    )

    if (!is.null(gpl_result) && file.exists(gpl_file_path)) {
      platform_info$gpl_files <- gpl_file_path
      cli::cli_alert_success("GPL file downloaded: {basename(gpl_file_path)}")
      write_log(paste("GPL file downloaded:", basename(gpl_file_path)), "SUCCESS")
    } else {
      cli::cli_alert_warning("No GPL file downloaded for {platform_id}")
      write_log("No GPL file downloaded.", "WARNING")
    }
  } else {
    cli::cli_alert_warning("No platform annotation found in GSEMatrix.")
    write_log("No platform annotation found.", "WARNING")
  }

  # ===========================================================================
  # Metadata Collection and Summary Phase
  # ===========================================================================

  # Calculate download duration
  end_time <- Sys.time()
  download_duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

  # Collect comprehensive metadata
  meta <- list(
    gse_id = gse_id,
    dest_dir = dest_dir,
    downloaded_at = start_time,
    completed_at = end_time,
    download_duration = download_duration,
    retries = retries,
    timeout = timeout,
    status = "success",
    gse_samples = n_samples,
    gse_features = n_features,
    supplemental_files_count = length(supplemental_files),
    platform_id = platform_id,
    gpl_files_count = length(platform_info$gpl_files),
    total_files_downloaded = length(supplemental_files) + length(platform_info$gpl_files)
  )

  # Final summary
  cli::cli_h2("Download Summary")
  cli::cli_alert_info("Duration: {round(download_duration, 2)} seconds")
  cli::cli_alert_info("GSEMatrix: {n_samples} samples x {n_features} features")
  cli::cli_alert_info("Supplemental files: {length(supplemental_files)}")
  cli::cli_alert_info("Platform files: {length(platform_info$gpl_files)}")
  cli::cli_alert_info("Total files: {meta$total_files_downloaded}")

  cli::cli_h1("GEO data download completed successfully for {gse_id}")
  write_log("Download completed successfully", "SUCCESS")

  # Return structured result
  list(
    gse_object = gset,
    supplemental_files = supplemental_files,
    platform_info = platform_info,
    meta = meta
  )
}
