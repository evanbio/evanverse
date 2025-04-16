#' ✅ Check if packages are installed and optionally install them
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
  # -- Require cli
  if (!requireNamespace("cli", quietly = TRUE)) {
    install.packages("cli", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
  }

  # -- Normalize source
  source_input <- tolower(source[1])
  source_matched <- switch(source_input,
                           "cran"  = "CRAN",
                           "gh"    = "GitHub", "github" = "GitHub",
                           "bio"   = "Bioconductor", "bioc" = "Bioconductor", "bioconductor" = "Bioconductor",
                           stop("❌ Invalid source: ", source_input,
                                "\n✔ Available sources: CRAN / GitHub / Bioconductor", call. = FALSE)
  )

  if (is.null(pkg)) {
    stop("❗ Please provide at least one package name.", call. = FALSE)
  }

  # -- Determine actual pkg names
  pkg_names <- if (source_matched == "GitHub") basename(pkg) else pkg
  installed <- vapply(pkg_names, requireNamespace, logical(1), quietly = TRUE)

  # -- Report and install if needed
  for (i in seq_along(pkg)) {
    if (installed[i]) {
      cli::cli_alert_success("Installed: {pkg_names[i]}")
    } else {
      cli::cli_alert_warning("Missing: {pkg_names[i]}")
      if (isTRUE(auto_install)) {
        cli::cli_alert_info("Installing {pkg_names[i]} from {source_matched}...")
        inst_pkg(pkg = pkg[i], source = source_matched, ...)
      }
    }
  }

  # -- Return result
  tibble::tibble(
    package   = pkg,
    name      = pkg_names,
    installed = installed,
    source    = source_matched
  )
}
