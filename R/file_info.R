#' 📄 Summarize File Information (size, time, line count)
#'
#' Given a file or folder path (or vector), returns a data.frame containing
#' file name, size (in MB), last modified time, optional line count, and path.
#'
#' @param paths Character vector of file paths or a folder path.
#' @param recursive Logical. If a folder is given, whether to search recursively.
#' @param count_line Logical. Whether to count lines in each file. Default: TRUE.
#' @param preview Logical. Whether to show skipped/missing messages. Default: TRUE.
#' @param filter_pattern Optional regex to filter file names (e.g., "\\.R$").
#' @param full_name Logical. Whether to return full file paths. Default: TRUE.
#'
#' @return A data.frame with file, size_MB, modified_time, line_count, path.
#' @export
#'
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

  # -- Resolve files --
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
    if (preview) cli::cli_alert_warning("No valid files found.")
    return(data.frame())
  }

  # -- Extract info --
  info_list <- lapply(files, function(f) {
    size <- round(file.info(f)$size / 1024^2, 3)
    time <- file.info(f)$mtime

    lines <- if (count_line) {
      tryCatch(length(readLines(f, warn = FALSE)), error = function(e) NA)
    } else {
      NA
    }

    data.frame(
      file = basename(f),
      size_MB = size,
      modified_time = as.POSIXct(time),
      line_count = lines,
      path = if (full_name) normalizePath(f) else f,
      stringsAsFactors = FALSE
    )
  })

  # -- Combine result --
  out <- do.call(rbind, info_list)
  return(out)
}
