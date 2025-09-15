#' Flexible Excel writer
#'
#' Write a data frame or a **named** list of data frames to an Excel file with optional styling.
#'
#' @param data A data.frame, or a **named** list of data.frames.
#' @param file_path Output path to a `.xlsx` file.
#' @param overwrite Whether to overwrite if the file exists. Default: TRUE.
#' @param timestamp Whether to append a date suffix (`YYYY-MM-DD`) to the filename. Default: FALSE.
#' @param with_style Whether to apply a simple header style (bold, fill, centered). Default: TRUE.
#' @param auto_col_width Whether to auto-adjust column widths. Default: TRUE.
#' @param open_after Whether to open the file after writing (platform-dependent). Default: FALSE.
#' @param verbose Whether to print CLI messages (info/warn/success). Errors are always shown. Default: TRUE.
#'
#' @return No return value; writes a file to disk.
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
  # ===========================================================================
  # Dependency checks
  # ===========================================================================
  if (!requireNamespace("openxlsx", quietly = TRUE)) cli::cli_abort("Please install 'openxlsx'.")
  if (!requireNamespace("fs", quietly = TRUE))        cli::cli_abort("Please install 'fs'.")

  # ===========================================================================
  # Path & extension handling
  # ===========================================================================
  if (!endsWith(tolower(file_path), ".xlsx")) {
    cli::cli_abort("File must end with .xlsx: {.path {file_path}}")
  }

  if (isTRUE(timestamp)) {
    date_str <- format(Sys.Date(), "%Y-%m-%d")
    file_path <- fs::path_ext_remove(file_path)
    file_path <- paste0(file_path, "_", date_str, ".xlsx")
  }

  if (fs::file_exists(file_path)) {
    if (!isTRUE(overwrite)) {
      cli::cli_abort("File exists and overwrite = FALSE: {.path {file_path}}")
    } else if (isTRUE(verbose)) {
      cli::cli_alert_warning("File already exists and will be overwritten: {.path {file_path}}")
    }
  }

  # ===========================================================================
  # Normalize input data
  # ===========================================================================
  if (inherits(data, "data.frame")) {
    data <- list(Sheet1 = data)
  } else if (is.list(data)) {
    if (is.null(names(data)) || any(!nzchar(names(data)))) {
      cli::cli_abort("'data' must be a named list of data.frames.")
    }
  } else {
    cli::cli_abort("'data' must be a data.frame or a named list of data.frames.")
  }

  # Coerce tibbles etc. to data.frame, validate each element
  for (nm in names(data)) {
    if (!inherits(data[[nm]], "data.frame")) {
      cli::cli_abort("Element '{nm}' in 'data' is not a data.frame.")
    }
    # ensure plain data.frame (no tibble printing surprises)
    data[[nm]] <- as.data.frame(data[[nm]], stringsAsFactors = FALSE)
  }

  # ===========================================================================
  # Workbook creation
  # ===========================================================================
  wb <- openxlsx::createWorkbook()

  header_style <- openxlsx::createStyle(
    textDecoration = "bold", fgFill = "#D9E1F2",
    halign = "center", valign = "center", border = "Bottom"
  )

  for (sheet_name in names(data)) {
    openxlsx::addWorksheet(wb, sheetName = sheet_name)
    openxlsx::writeData(wb, sheet = sheet_name, x = data[[sheet_name]], withFilter = TRUE)

    if (isTRUE(with_style)) {
      ncol_cur <- ncol(data[[sheet_name]])
      if (ncol_cur > 0) {
        openxlsx::addStyle(
          wb, sheet = sheet_name, style = header_style,
          rows = 1, cols = 1:ncol_cur, gridExpand = TRUE
        )
      }
    }

    if (isTRUE(auto_col_width)) {
      openxlsx::setColWidths(
        wb, sheet = sheet_name, cols = 1:ncol(data[[sheet_name]]), widths = "auto"
      )
    }
  }

  # ===========================================================================
  # Save and (optionally) open
  # ===========================================================================
  openxlsx::saveWorkbook(wb, file = file_path, overwrite = TRUE)
  if (isTRUE(verbose)) {
    cli::cli_alert_success("Excel file written to {.path {file_path}}")
  }

  if (isTRUE(open_after)) {
    # Windows
    if (.Platform$OS.type == "windows") {
      shell.exec(file_path)
    } else {
      # macOS (open) or Linux (xdg-open); suppress errors if neither exists
      opener <- if (Sys.info()[["sysname"]] == "Darwin") "open" else "xdg-open"
      suppressWarnings(try(system2(opener, shQuote(file_path), stdout = NULL, stderr = NULL), silent = TRUE))
    }
  }

  invisible(NULL)
}
