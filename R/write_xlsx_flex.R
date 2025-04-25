#' 📤 Flexible Excel Writer
#'
#' Write a data frame or named list of data frames to an Excel file with optional styling.
#'
#' @param data A data.frame or a named list of data.frames
#' @param file_path Output path to .xlsx file
#' @param overwrite Whether to overwrite if the file exists (default: TRUE)
#' @param timestamp Whether to append a date suffix to the filename
#' @param with_style Whether to apply header styling (default: TRUE)
#' @param auto_col_width Whether to auto-adjust column widths
#' @param open_after Whether to open the file after writing (platform dependent)
#' @param verbose Whether to print CLI messages
#'
#' @return No return value; writes file to disk.
#' @export
write_xlsx_flex <- function(
  data,
  file_path,
  overwrite = TRUE,
  timestamp = FALSE,
  with_style = TRUE,
  auto_col_width = TRUE,
  open_after = FALSE,
  verbose = TRUE
) {
  if (!requireNamespace("openxlsx", quietly = TRUE)) stop("Please install the 'openxlsx' package.")
  if (!requireNamespace("cli", quietly = TRUE)) stop("Please install the 'cli' package.")
  if (!requireNamespace("fs", quietly = TRUE)) stop("Please install the 'fs' package.")

  if (!endsWith(tolower(file_path), ".xlsx")) {
    cli::cli_alert_danger("❌ File must end with .xlsx: {.path {file_path}}")
    stop("Invalid file extension.")
  }

  if (timestamp) {
    date_str <- format(Sys.Date(), "%Y-%m-%d")
    file_path <- fs::path_ext_remove(file_path)
    file_path <- paste0(file_path, "_", date_str, ".xlsx")
  }

  if (fs::file_exists(file_path)) {
    if (!overwrite) {
      cli::cli_alert_danger("❌ File exists and overwrite is FALSE: {.path {file_path}}")
      stop("File exists.")
    } else {
      cli::cli_alert_warning("⚠️ File already exists and will be overwritten: {.path {file_path}}")
    }
  }

  wb <- openxlsx::createWorkbook()
  if (inherits(data, "data.frame")) {
    data <- list(Sheet1 = data)
  }

  header_style <- openxlsx::createStyle(
    textDecoration = "bold", fgFill = "#D9E1F2",
    halign = "center", valign = "center", border = "Bottom"
  )

  for (sheet_name in names(data)) {
    openxlsx::addWorksheet(wb, sheetName = sheet_name)
    openxlsx::writeData(wb, sheet = sheet_name, x = data[[sheet_name]], withFilter = TRUE)

    if (with_style) {
      ncol <- ncol(data[[sheet_name]])
      if (ncol > 0) {
        openxlsx::addStyle(wb, sheet = sheet_name, style = header_style, rows = 1, cols = 1:ncol, gridExpand = TRUE)
      }
    }

    if (auto_col_width) {
      openxlsx::setColWidths(wb, sheet = sheet_name, cols = 1:ncol(data[[sheet_name]]), widths = "auto")
    }
  }

  openxlsx::saveWorkbook(wb, file = file_path, overwrite = TRUE)
  cli::cli_alert_success("✅ Excel file written to {.path {file_path}}")

  if (open_after) {
    if (.Platform$OS.type == "windows") shell.exec(file_path)
    else system2("open", shQuote(file_path))
  }
}
