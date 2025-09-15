#' Flexible and fast table reader using data.table::fread
#'
#' @description
#' Robust table reader with auto delimiter detection for `.csv`, `.tsv`, `.txt`,
#' and their `.gz` variants. Uses `data.table::fread()` and prints CLI messages.
#'
#' @param file_path Character. Path to the file to be read.
#' @param sep Optional. Field delimiter. If `NULL`, auto-detected by file extension.
#' @param encoding Character. File encoding accepted by fread: "unknown", "UTF-8", or "Latin-1".
#' @param header Logical. Whether the file contains a header row. Default: `TRUE`.
#' @param verbose Logical. Show progress and details. Default: `FALSE`.
#'
#' @return A `data.table::data.table` with the parsed data.
#' @export
read_table_flex <- function(file_path,
                            sep = NULL,
                            encoding = "UTF-8",
                            header = TRUE,
                            verbose = FALSE) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================
  if (missing(file_path) || !is.character(file_path) || length(file_path) != 1L ||
      is.na(file_path) || nchar(file_path) == 0L) {
    cli::cli_abort("'file_path' must be a non-empty character string.")
  }
  if (!is.character(encoding) || length(encoding) != 1L || is.na(encoding)) {
    cli::cli_abort("'encoding' must be a character string.")
  }
  if (!is.logical(header) || length(header) != 1L || is.na(header)) {
    cli::cli_abort("'header' must be TRUE or FALSE.")
  }
  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    cli::cli_abort("'verbose' must be TRUE or FALSE.")
  }

  # ===========================================================================
  # File existence
  # ===========================================================================
  if (!file.exists(file_path)) {
    cli::cli_abort("File not found: {.file {file_path}}")
  }

  # ===========================================================================
  # Normalize encoding to what fread accepts
  # ===========================================================================
  enc_norm <- tolower(trimws(encoding))
  encoding <- switch(
    enc_norm,
    "utf-8" = "UTF-8",
    "utf8" = "UTF-8",
    "latin-1" = "Latin-1",
    "latin1" = "Latin-1",
    "iso-8859-1" = "Latin-1",
    "unknown" = "unknown",
    encoding
  )
  if (!encoding %in% c("unknown", "UTF-8", "Latin-1")) {
    cli::cli_abort("Argument 'encoding' must be 'unknown', 'UTF-8' or 'Latin-1'.")
  }

  # ===========================================================================
  # Auto-detect separator by extension (inline, no helper)
  # ===========================================================================
  if (is.null(sep)) {
    ext <- tolower(tools::file_ext(file_path))
    if (identical(ext, "gz")) {
      base_name <- sub("\\.gz$", "", basename(file_path))
      ext <- tolower(tools::file_ext(base_name))
    }
    sep <- switch(
      ext,
      "csv" = ",",
      "tsv" = "\t",
      "txt" = "\t",  # assume TSV for .txt
      ","            # fallback
    )
  } else if (!is.character(sep) || length(sep) != 1L) {
    cli::cli_abort("'sep' must be a single character string.")
  }

  # ===========================================================================
  # Quick binary-content sanity check (skip for .gz)
  # ===========================================================================
  ext_check <- tolower(tools::file_ext(file_path))
  if (!identical(ext_check, "gz")) {
    con <- file(file_path, "rb")
    on.exit(try(close(con), silent = TRUE), add = TRUE)
    head_raw <- readBin(con, what = "raw", n = 65536L)
    bad <- head_raw[head_raw < as.raw(32) &
                      !(head_raw %in% as.raw(c(9, 10, 13)))]
    if (length(bad) > 0L) {
      cli::cli_abort("File appears to contain binary control bytes; not a valid text table: {.file {file_path}}")
    }
  }

  # ===========================================================================
  # CLI feedback
  # ===========================================================================
  if (verbose) {
    cli::cli_h2("Reading table file")
    cli::cli_text("Path: {.file {file_path}}")
    cli::cli_text("Separator: {.val {sep}} | Encoding: {.val {encoding}}")
  }

  # ===========================================================================
  # fread
  # ===========================================================================
  tryCatch({
    dt <- data.table::fread(
      file         = file_path,
      sep          = sep,
      header       = header,
      encoding     = encoding,
      verbose      = verbose,
      showProgress = verbose
    )

    if (verbose) {
      cli::cli_alert_success("File loaded successfully ({nrow(dt)} rows × {ncol(dt)} cols)")
    }
    dt

  }, error = function(e) {
    cli::cli_abort("Failed to read table file {.file {file_path}}: {e$message}")
  })
}
