#' get_ext: Extract File Extension(s)
#'
#' Extract file extension(s) from a file name or path. Supports vector input and
#' optionally preserves compound extensions (e.g., .tar.gz) when keep_all = TRUE.
#'
#' @param paths Character vector of file names or paths.
#' @param keep_all Logical. If TRUE, returns full suffix after first dot in basename.
#'                 If FALSE, returns only the last extension. Default is FALSE.
#' @param include_dot Logical. If TRUE, includes the leading dot in result. Default is FALSE.
#' @param to_lower Logical. If TRUE, converts extensions to lowercase. Default is FALSE.
#'
#' @return Character vector of extensions.
#'
#' @examples
#' get_ext("data.csv")               # "csv"
#' get_ext("archive.tar.gz")         # "gz"
#' get_ext("archive.tar.gz", TRUE)   # "tar.gz"
#' get_ext(c("a.R", "b.txt", "c"))   # "R" "txt" ""
#' get_ext("data.CSV", to_lower = TRUE)  # "csv"
#'
#' @export
get_ext <- function(paths, 
                    keep_all = FALSE, 
                    include_dot = FALSE, 
                    to_lower = FALSE) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  if (!is.character(paths)) {
    stop("'paths' must be a character vector.", call. = FALSE)
  }

  if (length(paths) == 0) {
    return(character(0))
  }

  # ===========================================================================
  # Extension Extraction Phase
  # ===========================================================================

  # Extract basename to work with file names only
  base_names <- basename(paths)
  
  # Initialize result vector
  extensions <- character(length(base_names))
  
  # Find files with extensions (contain at least one dot)
  has_dot <- grepl("\\.", base_names)
  
  if (any(has_dot)) {
    if (isTRUE(keep_all)) {
      # Extract everything after first dot
      extensions[has_dot] <- sub("^[^.]*\\.", "", base_names[has_dot])
    } else {
      # Extract only last extension
      extensions[has_dot] <- sub(".*\\.", "", base_names[has_dot])
    }
  }
  
  # Files without dots get empty string
  extensions[!has_dot] <- ""

  # ===========================================================================
  # Post-processing Phase
  # ===========================================================================

  # Convert to lowercase if requested
  if (isTRUE(to_lower)) {
    extensions <- tolower(extensions)
  }
  
  # Add leading dot if requested
  if (isTRUE(include_dot)) {
    non_empty <- extensions != ""
    extensions[non_empty] <- paste0(".", extensions[non_empty])
  }

  # ===========================================================================
  # Return Results
  # ===========================================================================

  return(extensions)
}
