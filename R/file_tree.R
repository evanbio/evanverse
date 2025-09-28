#' file_tree: Print and Log Directory Tree Structure
#'
#' Print the directory structure of a given path in a tree-like format using
#' ASCII characters for maximum compatibility across different systems.
#' Optionally, save the result to a log file for record keeping or debugging.
#'
#' @param path Character. The target root directory path to print. Default is ".".
#' @param max_depth Integer. Maximum depth of recursion into subdirectories. Default is 2.
#' @param verbose Logical. Whether to print the tree to console. Default is TRUE.
#' @param log Logical. Whether to save the tree output as a log file. Default is FALSE.
#' @param log_path Character. Directory path to save the log file if log = TRUE. Default is tempdir().
#' @param file_name Character. Custom file name for the log file. If NULL, a name like "file_tree_YYYYMMDD_HHMMSS.log" will be used.
#' @param append Logical. If TRUE, appends to an existing file (if present). If FALSE, overwrites the file. Default is FALSE.
#'
#' @return Invisibly returns a character vector containing each line of the file tree.
#'
#' @examples
#' # Basic usage:
#' # file_tree()
#' # file_tree("my_directory", max_depth = 3)
#'
#' \donttest{
#' # Example with temporary directory
#' temp_dir <- tempdir()
#' file_tree(temp_dir, max_depth = 2, log = TRUE)
#' }
#'
#' @export
file_tree <- function(path = ".",
                      max_depth = 2,
                      verbose = TRUE,
                      log = FALSE,
                      log_path = NULL,
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

  # Use simple ASCII characters for maximum compatibility
  # This avoids Unicode encoding issues across different systems
  tree_chars <- list(
    branch = "+-- ",      # Branch connector
    last_branch = "+-- ", # Last branch connector
    pipe = "|   ",        # Vertical line
    space = "    "         # Space for last items
  )

  traverse <- function(p, depth = 0, prefix = "") {
    if (depth >= max_depth) return()

    files <- list.files(p, full.names = TRUE)
    if (length(files) == 0) return()

    for (i in seq_along(files)) {
      f <- files[i]
      name <- basename(f)
      is_last <- (i == length(files))

      # Create the line with appropriate connector
      line <- paste0(prefix, tree_chars$branch, name)
      lines <<- c(lines, line)

      # If it's a directory, recurse into it
      if (dir.exists(f)) {
        new_prefix <- paste0(prefix, if (is_last) tree_chars$space else tree_chars$pipe)
        traverse(f, depth + 1, new_prefix)
      }
    }
  }

  # ===========================================================================
  # Display Phase
  # ===========================================================================

  if (verbose) {
    cli::cli_h1("Directory Tree: {normalizePath(path)}")
  }
  traverse(path)

  if (verbose) {
    for (line in lines) {
      message(line)
    }
  }

  # ===========================================================================
  # Logging Phase
  # ===========================================================================

  if (isTRUE(log)) {
    # Set default log path if not provided
    if (is.null(log_path)) {
      log_path <- file.path(tempdir(), "logs", "tree")
    }
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
    con <- file(full_path, open = if (append) "a" else "w")
    on.exit(close(con), add = TRUE)
    writeLines(log_content, con = con)

    cli::cli_alert_success("File tree log saved to: {normalizePath(full_path)}")
  }

  # ===========================================================================
  # Return Results
  # ===========================================================================

  invisible(lines)
}
