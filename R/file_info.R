#' file_info: Summarise file information
#'
#' Given a file or folder path (or vector), returns a data.frame containing
#' file name, size (MB), last modified time, optional line count, and path.
#'
#' @param paths Character vector of file paths or a folder path.
#' @param recursive Logical. If a folder is given, whether to search recursively. Default: FALSE.
#' @param count_line Logical. Whether to count lines in each file. Default: TRUE.
#' @param preview Logical. Whether to show skipped/missing messages. Default: TRUE.
#' @param filter_pattern Optional regex to filter file names (e.g., "\\.R$"). Default: NULL.
#' @param full_name Logical. Whether to return full file paths. Default: TRUE.
#'
#' @return A data.frame with columns: file, size_MB, modified_time, line_count, path.
#' @export
#' @examples
#' file_info("R")
#' file_info(c("README.md", "DESCRIPTION"))
#' file_info("R", filter_pattern = "\\.R$", recursive = TRUE)
file_info <- function(paths,
                      recursive = FALSE,
                      count_line = TRUE,
                      preview = TRUE,
                      filter_pattern = NULL,
                      full_name = TRUE) {

  # ===========================================================================
  # Resolve input -> files vector
  # ===========================================================================
  if (length(paths) == 1 && dir.exists(paths)) {
    files <- list.files(
      paths,
      pattern = filter_pattern,
      recursive = recursive,
      full.names = TRUE
    )
  } else {
    files <- paths
  }

  files <- unique(files[file.exists(files)])

  if (length(files) == 0) {
    if (isTRUE(preview)) cli::cli_alert_warning("No valid files found.")
    return(data.frame())
  }

  # ===========================================================================
  # Extract file metadata
  # ===========================================================================
  info_list <- lapply(files, function(f) {
    fi <- file.info(f)
    size_mb <- if (!is.na(fi$size)) round(fi$size / 1024^2, 3) else NA_real_
    mtime <- fi$mtime

    line_ct <- NA_integer_
    if (isTRUE(count_line)) {
      line_ct <- tryCatch(
        length(readLines(f, warn = FALSE)),
        error = function(e) NA_integer_
      )
    }

    data.frame(
      file = basename(f),
      size_MB = size_mb,
      modified_time = as.POSIXct(mtime),
      line_count = line_ct,
      path = if (isTRUE(full_name)) normalizePath(f) else f,
      stringsAsFactors = FALSE
    )
  })

  # ===========================================================================
  # Combine and return
  # ===========================================================================
  out <- do.call(rbind, info_list)
  return(out)
}

# ===========================================================================
