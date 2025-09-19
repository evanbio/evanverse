#' file_tree: Print and Log Directory Tree Structure
#'
#' Print the directory structure of a given path in a tree-like format.
#' Optionally, save the result to a log file for record keeping or debugging.
#'
#' @param path Character. The target root directory path to print. Default is ".".
#' @param max_depth Integer. Maximum depth of recursion into subdirectories. Default is 2.
#' @param log Logical. Whether to save the tree output as a log file. Default is FALSE.
#' @param log_path Character. Directory path to save the log file if log = TRUE. Default is "logs/tree".
#' @param file_name Character. Custom file name for the log file. If NULL, a name like "file_tree_YYYYMMDD_HHMMSS.log" will be used.
#' @param append Logical. If TRUE, appends to an existing file (if present). If FALSE, overwrites the file. Default is FALSE.
#'
#' @return Invisibly returns a character vector containing each line of the file tree.
#'
#' @examples
#' file_tree()
#' \dontrun{
#' file_tree("data", max_depth = 3, log = TRUE)
#' }
#'
#' @export
file_tree <- function(path = ".",
                      max_depth = 2,
                      log = FALSE,
                      log_path = "logs/tree",
                      file_name = NULL,
                      append = FALSE) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  if (!dir.exists(path)) {
    cli::cli_alert_danger("Directory does not exist: {normalizePath(path, mustWork = FALSE)}")
    return(invisible(NULL))
  }

  # ===========================================================================
  # Tree Generation Phase
  # ===========================================================================

  lines <- character()

  traverse <- function(p, depth = 0, prefix = "") {
    if (depth >= max_depth) return()
    
    files <- list.files(p, full.names = TRUE)
    
    for (i in seq_along(files)) {
      f <- files[i]
      name <- basename(f)
      connector <- if (i == length(files)) "\\u2514\\u2500\\u2500 " else "\\u251c\\u2500\\u2500 "
      line <- paste0(prefix, connector, name)
      lines <<- c(lines, line)
      
      if (dir.exists(f)) {
        new_prefix <- paste0(prefix, if (i == length(files)) "    " else "\\u2502   ")
        traverse(f, depth + 1, new_prefix)
      }
    }
  }

  # ===========================================================================
  # Display Phase
  # ===========================================================================

  cli::cli_h1("Directory Tree: {normalizePath(path)}")
  traverse(path)
  
  for (line in lines) {
    cat(line, "\n")
  }

  # ===========================================================================
  # Logging Phase
  # ===========================================================================

  if (isTRUE(log)) {
    # Create log directory if needed
    if (!dir.exists(log_path)) {
      dir.create(log_path, recursive = TRUE)
    }
    
    # Generate filename if not provided
    if (is.null(file_name)) {
      timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
      file_name <- paste0("file_tree_", timestamp, ".log")
    }
    
    full_path <- file.path(log_path, file_name)

    # Construct log content
    log_header <- c(
      "FILE TREE REPORT",
      strrep("-", 40),
      paste0("Timestamp : ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
      paste0("Directory : ", normalizePath(path)),
      paste0("Max Depth : ", max_depth),
      "",
      "Tree Structure:"
    )

    log_footer <- c(
      "",
      strrep("-", 40),
      "End of Report"
    )

    log_content <- c(log_header, lines, log_footer)

    # Write log file
    cat(paste(log_content, collapse = "\n"),
        file = full_path,
        append = append,
        sep = "\n")

    cli::cli_alert_success("File tree log saved to: {normalizePath(full_path)}")
  }

  # ===========================================================================
  # Return Results
  # ===========================================================================

  invisible(lines)
}
