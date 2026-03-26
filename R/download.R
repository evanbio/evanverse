# =============================================================================
# ops.R — Custom infix operators
# =============================================================================

#' Download gene annotation reference table from Ensembl
#'
#' Downloads a standardized gene annotation table for human or mouse using
#' \code{biomaRt}. Includes Ensembl ID, gene symbol, Entrez ID, gene type,
#' chromosome location, and other metadata.
#'
#' @param species One of \code{"human"} or \code{"mouse"}. Default: \code{"human"}.
#' @param dest Character or \code{NULL}. File path to save the result as
#'   \code{.rds}. If \code{NULL} (default), the result is not saved.
#'
#' @return A \code{data.frame} containing gene annotation.
#' @export
download_gene_ref <- function(species = c("human", "mouse"),
                              dest = NULL) {

  species <- match.arg(species)
  if (!is.null(dest)) {
    .assert_scalar_string(dest)
    .assert_dest_path(dest)
  }

  cfg  <- .gene_ref_config(species)
  mart <- biomaRt::useMart("ensembl", dataset = cfg$dataset)

  ensembl_version <- tryCatch({
    archives <- biomaRt::listEnsemblArchives()
    v <- archives$version[archives$current_release == "*"]
    if (length(v) == 1L) v else "unknown"
  }, error = function(e) "unknown")

  cli::cli_alert_info("Downloading {species} gene annotation (Ensembl {ensembl_version})...")

  annotation <- biomaRt::getBM(
    attributes = c("ensembl_gene_id", cfg$symbol_attr, "entrezgene_id",
                   "gene_biotype", "chromosome_name", "start_position",
                   "end_position", "strand", "description"),
    mart = mart
  )

  colnames(annotation) <- c("ensembl_id", "symbol", "entrez_id", "gene_type",
                            "chromosome", "start", "end", "strand", "description")

  annotation$species         <- species
  annotation$ensembl_version <- ensembl_version
  annotation$download_date   <- Sys.Date()

  cli::cli_alert_success("Retrieved {nrow(annotation)} annotated genes.")

  if (!is.null(dest)) {
    if (!grepl("\\.rds$", dest, ignore.case = TRUE)) dest <- paste0(dest, ".rds")
    saveRDS(annotation, file = dest)
    cli::cli_alert_success("Saved to {.file {dest}}")
  }

  annotation
}


#' Download a file from a URL
#'
#' Downloads a file from a URL with retry and resume support.
#'
#' @param url Character string. Full URL to the file to download.
#' @param dest Character string. Destination file path.
#' @param overwrite Logical. Whether to overwrite an existing file. Default: FALSE.
#'   If FALSE and the file exists, download is skipped.
#'   If TRUE and \code{resume = TRUE}, will attempt to resume from an existing non-empty destination file.
#'   If TRUE and \code{resume = FALSE}, the file is downloaded from scratch.
#' @param resume Logical. Whether to resume from an existing non-empty destination
#'   file when \code{overwrite = TRUE}. Default: TRUE.
#' @param timeout Integer. Download timeout in seconds. Default: 600.
#' @param retries Integer. Number of retry attempts after the first failure. Default: 3.
#'
#' @return Invisibly returns the path to the downloaded file.
#'
#' @examples
#' \dontrun{
#' download_url(
#'   url  = "https://raw.githubusercontent.com/tidyverse/ggplot2/main/README.md",
#'   dest = file.path(tempdir(), "ggplot2_readme.md")
#' )
#' }
#'
#' @export
download_url <- function(url,
                         dest,
                         overwrite = FALSE,
                         resume    = TRUE,
                         timeout   = 600,
                         retries   = 3) {

  # Validation
  .assert_scalar_string(url)
  .assert_dest_path(dest)
  .assert_flag(overwrite)
  .assert_flag(resume)
  .assert_count(timeout)
  .assert_count_min(retries, min = 0L)

  # File existence check
  if (file.exists(dest) && !overwrite) {
    cli::cli_alert_info("File already exists, skipping: {.path {dest}}")
    return(invisible(dest))
  }

  # Build curl handle
  h <- curl::new_handle()
  curl::handle_setopt(h,
                      timeout        = timeout,
                      failonerror    = TRUE,
                      noprogress     = TRUE,
                      followlocation = TRUE)

  if (overwrite && resume && file.exists(dest)) {
    file_size <- file.info(dest)$size
    if (file_size > 0) {
      curl::handle_setopt(h, resume_from = file_size)
    }
  }

  old_timeout <- getOption("timeout")
  if (timeout > old_timeout) {
    options(timeout = timeout)
    on.exit(options(timeout = old_timeout), add = TRUE)
  }

  # Download with retry
  download_error <- NULL

  for (attempt in seq_len(retries + 1L)) {
    if (attempt > 1) {
      Sys.sleep(min(2^(attempt - 2), 30))
    }

    result <- tryCatch({
      curl::curl_download(url = url, destfile = dest, handle = h, quiet = TRUE)
      "ok"
    }, error = function(e) e$message)

    if (identical(result, "ok")) {
      return(invisible(dest))
    }

    download_error <- result
  }

  cli::cli_abort("Failed to download {.url {url}}: {download_error}", call = NULL)
}


#' Batch download files in parallel
#'
#' Downloads multiple files concurrently using \code{curl::multi_download()}.
#'
#' @param urls Character vector. URLs to download.
#' @param dest_dir Character. Destination directory.
#' @param overwrite Logical. Whether to overwrite existing files. Default: FALSE.
#' @param resume Logical. Whether to resume from an existing non-empty destination
#'   file when \code{overwrite = TRUE}. Default: TRUE.
#' @param timeout Integer. Timeout in seconds for each download. Default: 600.
#' @param retries Integer. Number of retry attempts after the first failure. Default: 3.
#'
#' @return Invisibly returns a character vector of destination file paths.
#' @export
download_batch <- function(urls,
                           dest_dir,
                           overwrite = FALSE,
                           resume    = TRUE,
                           timeout   = 600,
                           retries   = 3) {

  # Validation
  .assert_character_vector(urls)
  .assert_dir_path(dest_dir)
  .assert_flag(overwrite)
  .assert_flag(resume)
  .assert_count(timeout)
  .assert_count_min(retries, min = 0L)

  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  }

  dest_paths <- file.path(dest_dir, vapply(urls, .safe_filename_from_url, character(1)))

  # Skip existing files if overwrite = FALSE
  skip    <- file.exists(dest_paths) & !overwrite
  to_dl   <- urls[!skip]
  to_dest <- dest_paths[!skip]

  if (length(to_dl) == 0L) {
    cli::cli_alert_info("All files already exist, skipping.")
    return(invisible(dest_paths))
  }

  # Download with retry
  download_error <- NULL

  for (attempt in seq_len(retries + 1L)) {
    if (attempt > 1L) {
      Sys.sleep(min(2^(attempt - 2), 30))
    }

    result <- tryCatch({
      curl::multi_download(
        urls     = to_dl,
        destfile = to_dest,
        resume   = overwrite && resume,
        progress = FALSE,
        multi_timeout = timeout,
        multiplex = TRUE
      )
      "ok"
    }, error = function(e) e$message)

    if (identical(result, "ok")) {
      return(invisible(dest_paths))
    }

    download_error <- result
  }

  cli::cli_abort("Batch download failed: {download_error}", call = NULL)
}


#' Download a GEO series
#'
#' Downloads a GEO series including expression data, supplemental files,
#' and platform annotations.
#'
#' @param gse_id Character. GEO Series accession ID (e.g., "GSE12345").
#' @param dest_dir Character. Destination directory for downloaded files.
#' @param overwrite Logical. Whether to overwrite existing files. Default: FALSE.
#' @param retries Integer. Number of retry attempts after the first failure. Default: 2.
#' @param timeout Integer. Timeout in seconds per request. Default: 300.
#'
#' @return A list with:
#' \describe{
#'   \item{gse_object}{ExpressionSet with expression data and annotations}
#'   \item{supplemental_files}{Character vector of supplemental file paths}
#'   \item{platform_info}{List with \code{platform_id} and \code{gpl_files}}
#' }
#'
#' @examples
#' \dontrun{
#' result <- download_geo("GSE12345", dest_dir = tempdir())
#' expr_data   <- Biobase::exprs(result$gse_object)
#' sample_info <- Biobase::pData(result$gse_object)
#' }
#'
#' @export
download_geo <- function(gse_id,
                               dest_dir,
                               overwrite = FALSE,
                               retries   = 2,
                               timeout   = 300) {

  # Validation
  .assert_scalar_string(gse_id)
  if (!grepl("^GSE\\d{3,}$", gse_id)) {
    cli::cli_abort("{.arg gse_id} must be a valid GEO accession (e.g., 'GSE12345').", call = NULL)
  }
  .assert_dir_path(dest_dir)
  .assert_flag(overwrite)
  .assert_count_min(retries, min = 0L)
  .assert_count(timeout)

  if (!requireNamespace("GEOquery", quietly = TRUE)) {
    cli::cli_abort("Please install {.pkg GEOquery}: BiocManager::install('GEOquery')", call = NULL)
  }

  dir.create(dest_dir, showWarnings = FALSE, recursive = TRUE)

  # Orchestration
  gset              <- .download_geo_gsematrix(gse_id, dest_dir, retries, timeout)
  supplemental_files <- .download_geo_supp_files(gse_id, dest_dir, retries, timeout)
  platform_info     <- .download_geo_platform(gset, dest_dir, retries, timeout)

  list(
    gse_object         = gset,
    supplemental_files = supplemental_files,
    platform_info      = platform_info
  )
}
