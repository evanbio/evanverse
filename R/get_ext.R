#' 🧾 Get File Extension(s)
#'
#' Extract file extension(s) from a file name or path. Supports vector input and
#' optionally preserves compound extensions (e.g., `.tar.gz`) when `keep_all = TRUE`.
#'
#' @param paths A character vector of file names or paths.
#' @param keep_all Logical. If TRUE, returns full suffix after first dot in basename
#'                 (e.g., "tar.gz"); otherwise returns only the last extension. Default: FALSE.
#'
#' @return A character vector of extensions (no leading dots).
#' @export
#'
#' @examples
#' get_ext("data.csv")               # "csv"
#' get_ext("archive.tar.gz")        # "gz"
#' get_ext("archive.tar.gz", TRUE)  # "tar.gz"
#' get_ext(c("a.R", "b.txt", "c"))   # "R" "txt" ""
get_ext <- function(paths, keep_all = FALSE) {
  stopifnot(is.character(paths))

  base <- basename(paths)
  ext <- if (keep_all) {
    sub("^[^.]*\\.", "", base)
  } else {
    sub(".*\\.", "", base)
  }

  # For no-extension files, fix to ""
  ext[!grepl("\\.", base)] <- ""

  return(ext)
}
