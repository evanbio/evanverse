#' 📥 Flexible Excel Reader (Upgraded)
#'
#' An enhanced Excel reader using `readxl::read_excel()` with CLI output,
#' automatic column name cleaning, and optional type control.
#'
#' @param file_path Path to the Excel file (.xlsx or .xls)
#' @param sheet Sheet name or number to read (default: 1)
#' @param skip Number of lines to skip before reading data (default: 0)
#' @param header Whether the first row contains column names (default: TRUE)
#' @param range Cell range to read, e.g., "B2:D100" (default: NULL)
#' @param col_types Optional vector to specify column types
#' @param clean_names Whether to clean column names using janitor (default: TRUE)
#' @param guess_max Max number of rows used for column type guessing
#' @param trim_ws Whether to trim whitespace around text fields
#' @param na Values to interpret as NA
#' @param verbose Whether to show CLI output
#'
#' @return A cleaned data.frame or tibble.
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
  # Load required packages
  if (!requireNamespace("readxl", quietly = TRUE)) stop("Please install the 'readxl' package.")
  if (!requireNamespace("cli", quietly = TRUE)) stop("Please install the 'cli' package.")
  if (clean_names && !requireNamespace("janitor", quietly = TRUE)) stop("Please install the 'janitor' package.")

  # Check if file exists
  if (!file.exists(file_path)) {
    cli::cli_alert_danger("❌ File not found: {.path {file_path}}")
    stop("File not found.")
  }

  # CLI display
  cli::cli_h1("📥 Reading Excel File")
  sheets <- readxl::excel_sheets(file_path)
  cli::cli_alert_info("📄 Sheets in {.path {file_path}}: {paste(sheets, collapse = ', ')}")

  # Read the Excel file
  df <- readxl::read_excel(
    path = file_path,
    sheet = sheet,
    skip = skip,
    col_names = header,
    range = range,
    guess_max = guess_max,
    trim_ws = trim_ws,
    na = na,
    col_types = col_types
  )

  # Clean column names
  if (clean_names) {
    df <- janitor::clean_names(df)
    cli::cli_alert_success("✅ Column names cleaned with janitor::clean_names()")
  }

  cli::cli_alert_success("✅ Successfully read sheet {.val {sheet}} from {.path {file_path}}")
  return(df)
}
