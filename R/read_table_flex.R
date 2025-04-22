#' 📄 read_table_flex(): Flexible and fast table reader using data.table::fread
#'
#' @description
#' A robust and flexible table reader that supports automatic delimiter detection
#' for `.csv`, `.tsv`, `.txt`, `.gz`, and similar tabular files (including compressed).
#' Uses `data.table::fread()` for efficient parsing. Displays helpful CLI messages.
#'
#' @param file_path Character. Path to the file to be read.
#' @param sep Optional. Field delimiter. If `NULL`, auto-detected by file extension.
#' @param encoding Character. File encoding. Default: `"UTF-8"`.
#' @param header Logical. Whether the file contains a header row. Default: `TRUE`.
#' @param verbose Logical. Show progress and details. Default: `FALSE`.
#'
#' @return A `data.table::data.table` object containing the parsed tabular data.
#' @import data.table
#' @importFrom cli cli_h2 cli_text cli_alert_success cli_alert_danger
#' @export
read_table_flex <- function(file_path,
                            sep = NULL,
                            encoding = "UTF-8",
                            header = TRUE,
                            verbose = FALSE) {

  # Check file
  if (!file.exists(file_path)) {
    stop("File not found: ", file_path)
  }

  # Auto-detect separator based on file extension
  if (is.null(sep)) {
    ext <- tolower(file_path)
    if (grepl("\\.csv(\\.gz)?$", ext)) {
      sep <- ","
    } else if (grepl("\\.(tsv|txt)(\\.gz)?$", ext)) {
      sep <- "\t"
    } else {
      sep <- ","  # default fallback
    }
  }

  # CLI feedback
  if (verbose) {
    cli::cli_h2("📄 Reading table file")
    cli::cli_text("📁 Path: {.path {file_path}}")
    cli::cli_text("🔎 Separator: '{sep}' | Encoding: {encoding}")
  }

  # Read file with fread
  tryCatch({
    dt <- data.table::fread(
      file = file_path,
      sep = sep,
      header = header,
      encoding = encoding,
      verbose = verbose,
      showProgress = verbose
    )
    if (verbose) cli::cli_alert_success("✅ File loaded successfully ({nrow(dt)} rows × {ncol(dt)} cols)")
    return(dt)
  }, error = function(e) {
    cli::cli_alert_danger("❌ Failed to read table: {e$message}")
    return(data.table::data.table())
  })
}
