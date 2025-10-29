#' check_pkg(): Check if packages are installed and optionally install them
#'
#' A utility to check whether CRAN / GitHub / Bioconductor packages are installed,
#' with optional auto-installation via `inst_pkg()`.
#'
#' @param pkg Character vector of package names or GitHub repos (e.g., "r-lib/devtools").
#' @param source Package source: one of "CRAN", "GitHub", "Bioconductor". Case-insensitive.
#' @param auto_install Logical. If TRUE (default), install missing packages automatically.
#' @param ... Additional arguments passed to `inst_pkg()`.
#'
#' @return A tibble with columns: `package`, `name`, `installed`, `source`.
#' @export
#'
#' @examples
#' check_pkg("ggplot2", source = "CRAN")
#' check_pkg("r-lib/devtools", source = "GitHub", auto_install = FALSE)

check_pkg <- function(pkg = NULL,
                      source = c("CRAN", "GitHub", "Bioconductor"),
                      auto_install = TRUE,
                      ...) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  # Validate and normalize source parameter
  source <- match.arg(tolower(source), c("cran", "github", "bioconductor"))
  source_matched <- switch(source,
                           "cran" = "CRAN",
                           "github" = "GitHub",
                           "bioconductor" = "Bioconductor")

  # Check if pkg is provided
  if (is.null(pkg)) {
    cli::cli_abort("Please provide at least one package name.")
  }

  # ===========================================================================
  # Package Check Phase
  # ===========================================================================

  # Determine actual package names (handle GitHub repos)
  pkg_names <- if (source_matched == "GitHub") basename(pkg) else pkg

  # Vectorized check for installed packages
  installed <- vapply(pkg_names, requireNamespace, logical(1), quietly = TRUE)

  # ===========================================================================
  # Installation and Reporting Phase
  # ===========================================================================

  # Process each package (vectorized where possible)
  for (i in seq_along(pkg)) {
    if (installed[i]) {
      cli::cli_alert_success("Installed: {pkg_names[i]}")
    } else {
      cli::cli_alert_warning("Missing: {pkg_names[i]}")
      if (isTRUE(auto_install)) {
        cli::cli_alert_info("Installing {pkg_names[i]} from {source_matched}...")

        # Wrap installation in tryCatch for error handling
        tryCatch({
          inst_pkg(pkg = pkg[i], source = source_matched, ...)
          cli::cli_alert_success("Successfully installed: {pkg_names[i]}")
        }, error = function(e) {
          cli::cli_alert_danger("Failed to install {pkg_names[i]}: {e$message}")
        })
      }
    }
  }

  # ===========================================================================
  # Return Result
  # ===========================================================================

  # Return result as a tibble
  tibble::tibble(
    package = pkg,
    name = pkg_names,
    installed = installed,
    source = source_matched,
    .name_repair = "minimal"
  )
}
