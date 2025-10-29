#' Flexible Excel reader
#'
#' Read an Excel sheet via `readxl::read_excel()` with optional column-name
#' cleaning (`janitor::clean_names()`), basic type control, and CLI messages.
#'
#' @param file_path Path to the Excel file (.xlsx or .xls).
#' @param sheet Sheet name or index to read (default: 1).
#' @param skip Number of lines to skip before reading data (default: 0).
#' @param header Logical. Whether the first row contains column names (default: TRUE).
#' @param range Optional cell range (e.g., `"B2:D100"`). Default: `NULL`.
#' @param col_types Optional vector specifying column types; passed to `readxl`.
#' @param clean_names Logical. Clean column names with `janitor::clean_names()` (default: TRUE).
#' @param guess_max Max rows to guess column types (default: 1000).
#' @param trim_ws Logical. Trim surrounding whitespace in text fields (default: TRUE).
#' @param na Values to interpret as NA (default: `""`).
#' @param verbose Logical. Show CLI output (default: TRUE).
#'
#' @return A tibble (or data.frame) read from the Excel sheet.
#' @export
read_excel_flex <- function(
  file_path,
  sheet = 1,
  skip = 0,
  header = TRUE,
  range = NULL,
  col_types = NULL,
  clean_names = TRUE,
  guess_max = 1000,
  trim_ws = TRUE,
  na = "",
  verbose = TRUE
) {

  # ===========================================================================
  # Dependency check
  # ===========================================================================
  if (!requireNamespace("readxl", quietly = TRUE)) {
    cli::cli_abort("Please install the {.pkg readxl} package.")
  }
  if (isTRUE(clean_names) && !requireNamespace("janitor", quietly = TRUE)) {
    cli::cli_abort("Please install the {.pkg janitor} package (or set clean_names = FALSE).")
  }

  # ===========================================================================
  # Parameter validation
  # ===========================================================================
  if (!is.character(file_path) || length(file_path) != 1L || is.na(file_path) || nzchar(file_path) == FALSE) {
    cli::cli_abort("'file_path' must be a non-empty character string.")
  }
  if (!file.exists(file_path)) {
    cli::cli_abort("File not found: {.path {file_path}}")
  }
  if (!is.logical(header) || length(header) != 1L || is.na(header)) {
    cli::cli_abort("'header' must be a single logical.")
  }
  if (!is.logical(trim_ws) || length(trim_ws) != 1L || is.na(trim_ws)) {
    cli::cli_abort("'trim_ws' must be a single logical.")
  }
  if (!is.logical(clean_names) || length(clean_names) != 1L || is.na(clean_names)) {
    cli::cli_abort("'clean_names' must be a single logical.")
  }
  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    cli::cli_abort("'verbose' must be a single logical.")
  }
  if (!is.numeric(skip) || length(skip) != 1L || is.na(skip) || skip < 0) {
    cli::cli_abort("'skip' must be a single non-negative number.")
  }
  if (!is.numeric(guess_max) || length(guess_max) != 1L || is.na(guess_max) || guess_max < 1) {
    cli::cli_abort("'guess_max' must be a single positive number.")
  }
  if (!is.null(range) && !(is.character(range) && length(range) == 1L)) {
    cli::cli_abort("'range' must be a single character like \"B2:D100\" or NULL.")
  }

  # ===========================================================================
  # Preflight (optional CLI)
  # ===========================================================================
  if (isTRUE(verbose)) {
    cli::cli_h2("Reading Excel file")
    sh <- readxl::excel_sheets(file_path)
    cli::cli_alert_info("Sheets in {.path {file_path}}: {paste(sh, collapse = ', ')}")
  }

  # ===========================================================================
  # Read phase
  # ===========================================================================
  df <- readxl::read_excel(
    path       = file_path,
    sheet      = sheet,
    skip       = skip,
    col_names  = header,
    range      = range,
    guess_max  = guess_max,
    trim_ws    = trim_ws,
    na         = na,
    col_types  = col_types
  )

  # ===========================================================================
  # Post-process
  # ===========================================================================
  if (isTRUE(clean_names)) {
    df <- janitor::clean_names(df)
    if (isTRUE(verbose)) {
      cli::cli_alert_success("Column names cleaned with janitor::clean_names().")
    }
  }

  if (isTRUE(verbose)) {
    cli::cli_alert_success("Successfully read sheet {.val {sheet}} from {.path {file_path}}.")
  }

  # ===========================================================================
  # Return
  # ===========================================================================
  df
}
