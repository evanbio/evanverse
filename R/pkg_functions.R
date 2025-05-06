#' 📦 pkg_functions: List Exported Functions from an R Package
#'
#' List exported functions from a package (via NAMESPACE). Optionally filter by keyword.
#' The results are sorted alphabetically for better readability.
#'
#' @param pkg A character string. Package name.
#' @param key Optional keyword to filter function names (case-insensitive).
#'
#' @return A character vector of exported function names.
#' @export
#'
#' @examples
#' pkg_functions("evanverse")
#' pkg_functions("evanverse", key = "plot")
pkg_functions <- function(pkg, key = NULL) {
  stopifnot(is.character(pkg), length(pkg) == 1)

  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(paste("❌ Package", pkg, "is not installed."))
  }

  funcs <- getNamespaceExports(pkg)

  if (!is.null(key)) {
    funcs <- funcs[grepl(key, funcs, ignore.case = TRUE)]
  }

  funcs <- sort(funcs) 

  cli::cli_h1(sprintf("📦 Package: %s", pkg))
  cli::cli_alert_info("Matched exported functions: {length(funcs)}")

  if (length(funcs) > 0) {
    cat("📄 Function names:\n")
    print(funcs)
  } else {
    cli::cli_alert_warning("No functions matched keyword: {key}")
  }

  invisible(funcs)
}
