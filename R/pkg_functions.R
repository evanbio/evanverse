#' pkg_functions: List exported functions from a package
#'
#' List exported symbols from a package (via its NAMESPACE). Optionally filter
#' by a case-insensitive keyword. Results are sorted alphabetically.
#'
#' @param pkg Character scalar. Package name.
#' @param key Optional character scalar. Keyword to filter function names (case-insensitive).
#'
#' @return Character vector of exported names (invisibly).
#' @export
#'
#' @examples
#' pkg_functions("evanverse")
#' pkg_functions("evanverse", key = "plot")
pkg_functions <- function(pkg, key = NULL) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================
  if (!is.character(pkg) || length(pkg) != 1L || is.na(pkg) || nzchar(pkg) == FALSE) {
    cli::cli_abort("`pkg` must be a non-empty character scalar.")
  }
  if (!is.null(key) && (!is.character(key) || length(key) != 1L || is.na(key))) {
    cli::cli_abort("`key` must be a single non-NA character string or NULL.")
  }

  # ===========================================================================
  # Package availability
  # ===========================================================================
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cli::cli_abort("Package '{pkg}' is not installed.")
  }

  # ===========================================================================
  # Collect & filter exports
  # ===========================================================================
  funcs <- getNamespaceExports(pkg)

  if (!is.null(key)) {
    funcs <- funcs[grepl(key, funcs, ignore.case = TRUE)]
  }

  funcs <- sort(funcs)

  # ===========================================================================
  # CLI preview
  # ===========================================================================
  cli::cli_h2("Package: {pkg}")
  cli::cli_alert_info("Matched exported names: {length(funcs)}")

  if (length(funcs) > 0L) {
    # Use verbatim to avoid glue evaluation inside code examples/names
    cli::cli_verbatim(paste(funcs, collapse = "\n"))
  } else if (!is.null(key)) {
    cli::cli_alert_warning("No exported names matched keyword: {key}")
  }

  invisible(funcs)
}
