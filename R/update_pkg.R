#' Update R Packages from CRAN, GitHub, or Bioconductor
#'
#' A unified function to update R packages by source. Supports full updates,
#' source-specific updates, or targeted package updates. Automatically sets mirrors
#' (Tsinghua CRAN, Tsinghua Bioconductor) and handles version compatibility checks.
#' Ensures Bioconductor installations specify the correct version to avoid mismatches.
#'
#' @param pkg Character vector. Name(s) of package(s) to update. For GitHub, use `"user/repo"` format.
#'            Only required when `source` is specified.
#' @param source Character. The source of the package(s): `"CRAN"`, `"GitHub"`, or `"Bioconductor"`.
#'               Optional if updating all installed CRAN and Bioconductor packages.
#'
#' @return Invisible `NULL`. Outputs update progress and logs via `cli`.
#' @export
update_pkg <- function(pkg = NULL, source = NULL) {
  # ===========================================================================
  # Parameter validation
  # ===========================================================================
  if (!is.null(pkg)) {
    if (!is.character(pkg) || any(is.na(pkg)) || length(pkg) == 0) {
      cli::cli_abort("'pkg' must be a character vector without NA values.")
    }
  }

  # Normalize and validate source argument
  if (!is.null(source)) {
    source <- match.arg(source, c("CRAN", "GitHub", "Bioconductor"))
  }

  # Check input logic
  if (!is.null(pkg) && is.null(source)) {
    cli::cli_abort("Must specify 'source' when providing 'pkg'.")
  }
  if (is.null(pkg) && identical(source, "GitHub")) {
    cli::cli_abort("Must provide 'pkg' when updating GitHub packages.")
  }

  # Validate GitHub package format
  if (!is.null(source) && source == "GitHub") {
    invalid_gh <- !grepl("^[^/]+/[^/]+$", pkg)
    if (any(invalid_gh)) {
      cli::cli_abort("GitHub packages must be in 'user/repo' format. Invalid: {.val {pkg[invalid_gh]}}")
    }
  }

  # ===========================================================================
  # Fetch R and expected Bioconductor version
  # ===========================================================================
  r_version <- paste0(R.version$major, ".", R.version$minor)
  expected_bioc <- switch(
    r_version,
    "4.5" = "3.21",
    "4.4" = "3.19",
    "4.3" = "3.18",
    "4.2" = "3.16",
    NULL
  )

  bioc_version <- NULL
  if (requireNamespace("BiocManager", quietly = TRUE)) {
    bioc_version <- as.character(BiocManager::version())
    if (!is.null(expected_bioc) && bioc_version != expected_bioc) {
      cli::cli_alert_warning("Bioconductor version ({bioc_version}) may not match R {r_version}. Recommended: {expected_bioc}")
      cli::cli_alert_info("You can run manually: BiocManager::install(version = '{expected_bioc}')")
    }
  }

  # ===========================================================================
  # Set mirrors (and restore after execution)
  # ===========================================================================
  old_repos <- getOption("repos")
  old_bioc <- getOption("BioC_mirror")
  options(
    repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"),
    BioC_mirror = "https://mirrors.tuna.tsinghua.edu.cn/bioconductor/"
  )
  on.exit({
    options(repos = old_repos)
    options(BioC_mirror = old_bioc)
  }, add = TRUE)

  # ===========================================================================
  # Update all packages (CRAN + Bioc)
  # ===========================================================================
  if (is.null(pkg) && is.null(source)) {
    cli::cli_alert_info("Updating all CRAN + Bioconductor packages...")

    cli::cli_alert_info("Updating CRAN packages...")
    update.packages(ask = FALSE)

    if (!requireNamespace("BiocManager", quietly = TRUE)) {
      install.packages("BiocManager")
    }

    cli::cli_alert_info("Updating Bioconductor packages...")
    BiocManager::install(version = bioc_version, ask = FALSE)

  } else if (is.null(pkg)) {
    # ===========================================================================
    # Source-specific full update
    # ===========================================================================
    if (source == "CRAN") {
      cli::cli_alert_info("Updating all CRAN packages...")
      update.packages(ask = FALSE)

    } else if (source == "Bioconductor") {
      if (!requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
        bioc_version <- as.character(BiocManager::version())
      }

      cli::cli_alert_info("Updating all Bioconductor packages...")
      BiocManager::install(version = bioc_version, ask = FALSE)
    }

  } else {
    # ===========================================================================
    # Specific package(s) update
    # ===========================================================================
    cli::cli_alert_info("Updating package(s): {.pkg {pkg}} (source: {source})")

    if (source == "CRAN") {
      install.packages(pkg, quiet = TRUE)

    } else if (source == "Bioconductor") {
      if (!requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
        bioc_version <- as.character(BiocManager::version())
      }

      BiocManager::install(pkg, ask = FALSE, version = bioc_version)

    } else if (source == "GitHub") {
      if (!requireNamespace("devtools", quietly = TRUE)) {
        install.packages("devtools")
      }
      for (p in pkg) devtools::install_github(p, quiet = TRUE)
    }
  }

  cli::cli_alert_success("Package update complete!")
  invisible(NULL)
}
