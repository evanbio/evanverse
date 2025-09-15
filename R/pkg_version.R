#' 🔍 pkg_version: Check Installed and Latest Versions of R Packages
#'
#' This function checks the installed and latest available versions of
#' R packages across CRAN, Bioconductor, and GitHub.
#' It supports case-insensitive matching and smart console previews.
#'
#' @param pkg Character vector of package names.
#' @param preview Logical. If TRUE, print the result to console.
#'
#' @return A data.frame with columns: package, version (installed),
#'         latest (available), and source.
#' @export
#'
#' @examples
#' pkg_version(c("ggplot2", "limma", "MRPRESSO", "nonexistentpackage123"))
pkg_version <- function(pkg, preview = TRUE) {
  # Parameter validation
  if (!is.character(pkg) || length(pkg) == 0) {
    cli::cli_abort("`pkg` must be a non-empty character vector of package names.")
  }
  if (!is.logical(preview) || length(preview) != 1) {
    cli::cli_abort("`preview` must be a single logical value.")
  }

  pkg <- unique(pkg)

  # Check required packages
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    stop("Package 'BiocManager' is required but not installed.")
  }
  if (!requireNamespace("tools", quietly = TRUE)) {
    stop("Package 'tools' is required but not installed.")
  }

  # Initialize installed package info
  cli::cli_h1("Fetching installed R packages...")
  installed <- tryCatch(
    installed.packages(),
    error = function(e) {
      cli::cli_abort("Failed to fetch installed packages: {e$message}")
    }
  )
  installed_names_lower <- tolower(rownames(installed))

  # Get CRAN package versions
  cli::cli_h1("Fetching CRAN package database...")
  cran_db <- tryCatch(
    tools::CRAN_package_db(),
    error = function(e) {
      cli::cli_abort("Failed to fetch CRAN package database: {e$message}")
    }
  )
  cran_latest <- setNames(cran_db$Version, tolower(cran_db$Package))

  # Get Bioconductor package versions
  cli::cli_h1("Fetching Bioconductor package database...")
  bioc_repo <- tryCatch(
    BiocManager::repositories()["BioCsoft"],
    error = function(e) {
      cli::cli_abort("Failed to fetch Bioconductor repositories: {e$message}")
    }
  )
  bioc_db <- tryCatch(
    available.packages(repos = bioc_repo),
    error = function(e) {
      cli::cli_abort("Failed to fetch Bioconductor package database: {e$message}")
    }
  )
  bioc_latest <- setNames(bioc_db[, "Version"], tolower(bioc_db[, "Package"]))

  # Prepare result table
  result <- data.frame(
    package = pkg,
    version = NA_character_,
    latest  = NA_character_,
    source  = NA_character_,
    stringsAsFactors = FALSE
  )

  # Loop through packages
  for (i in seq_along(pkg)) {
    p <- pkg[i]
    p_lower <- tolower(p)
    cli::cli_h2("Checking package: {.pkg {p}}")

    # Get installed version
    if (p_lower %in% installed_names_lower) {
      idx <- match(p_lower, installed_names_lower)
      result$version[i] <- installed[idx, "Version"]
    }

    # Check CRAN
    if (p_lower %in% names(cran_latest)) {
      result$latest[i] <- cran_latest[p_lower]
      result$source[i] <- "CRAN"
      cli::cli_alert_success("Found on CRAN: {cran_latest[p_lower]}")
      next
    }

    # Check Bioconductor
    if (p_lower %in% names(bioc_latest)) {
      result$latest[i] <- bioc_latest[p_lower]
      result$source[i] <- "Bioconductor"
      cli::cli_alert_success("Found on Bioconductor: {bioc_latest[p_lower]}")
      next
    }

    # Check GitHub (only for installed packages)
    if (p_lower %in% installed_names_lower) {
      idx <- match(p_lower, installed_names_lower)
      desc_path <- file.path(installed[idx, "LibPath"],
                             installed[idx, "Package"],
                             "DESCRIPTION")

      desc <- tryCatch(
        read.dcf(desc_path),
        error = function(e) {
          cli::cli_alert_warning("Could not read DESCRIPTION file for {p}: {e$message}")
          NULL
        }
      )

      if (!is.null(desc) &&
          "RemoteType" %in% colnames(desc) &&
          desc[, "RemoteType"] == "github") {

        gh_user <- desc[, "RemoteUsername"]
        gh_repo <- desc[, "RemoteRepo"]
        gh_ref  <- desc[, "RemoteRef"]
        gh_sha  <- substr(desc[, "RemoteSha"], 1, 7)

        result$latest[i] <- gh_sha
        result$source[i] <- sprintf("GitHub (%s/%s@%s)", gh_user, gh_repo, gh_ref)

        cli::cli_alert_success("Found on GitHub: {result$source[i]} (SHA: {gh_sha})")
        next
      } else {
        cli::cli_alert_warning("Installed but not from GitHub.")
      }
    }

    # Not found anywhere
    result$source[i] <- "Not Found"
    cli::cli_alert_warning("Not found in CRAN, Bioconductor, or GitHub.")
  }

  # Final display
  if (preview) print(result)
  invisible(result)
}
