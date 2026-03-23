# =============================================================================
# utils_biopackage.R — Internal helpers for the package management module
# =============================================================================


#' Return CRAN mirror URL lookup table
#'
#' @return Named list mapping mirror names to URLs.
#'
#' @keywords internal
#' @noRd
.cran_mirrors <- function() {
  list(
    official = "https://cloud.r-project.org",
    rstudio  = "https://cran.rstudio.com",
    tuna     = "https://mirrors.tuna.tsinghua.edu.cn/CRAN",
    ustc     = "https://mirrors.ustc.edu.cn/CRAN",
    aliyun   = "https://mirrors.aliyun.com/CRAN",
    sjtu     = "https://mirror.sjtu.edu.cn/CRAN",
    pku      = "https://mirrors.pku.edu.cn/CRAN",
    hku      = "https://mirror.hku.hk/CRAN",
    westlake = "https://mirrors.westlake.edu.cn/CRAN",
    nju      = "https://mirrors.nju.edu.cn/CRAN",
    sustech  = "https://mirrors.sustech.edu.cn/CRAN"
  )
}


#' Return Bioconductor mirror URL lookup table
#'
#' @return Named list mapping mirror names to URLs.
#'
#' @keywords internal
#' @noRd
.bioc_mirrors <- function() {
  list(
    official = "https://bioconductor.org",
    tuna     = "https://mirrors.tuna.tsinghua.edu.cn/bioconductor",
    ustc     = "https://mirrors.ustc.edu.cn/bioconductor",
    westlake = "https://mirrors.westlake.edu.cn/bioconductor",
    nju      = "https://mirrors.nju.edu.cn/bioconductor"
  )
}


#' Ensure BiocManager is installed
#'
#' @return NULL invisibly.
#'
#' @keywords internal
#' @noRd
.ensure_biocmanager <- function() {
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    cli::cli_alert_info("Installing BiocManager...")
    utils::install.packages("BiocManager")
  }
  invisible(NULL)
}


#' Ensure devtools is installed
#'
#' @return NULL invisibly.
#'
#' @keywords internal
#' @noRd
.ensure_devtools <- function() {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cli::cli_alert_info("Installing devtools...")
    utils::install.packages("devtools")
  }
  invisible(NULL)
}


#' Install packages from CRAN
#' @keywords internal
#' @noRd
.install_from_cran <- function(pkg, ...) {
  cli::cli_alert_info("Installing from CRAN: {.pkg {pkg}}")
  # Reason: R automatically uses getOption("repos"), respecting user's mirror settings
  utils::install.packages(pkg, ...)
}


#' Install packages from GitHub
#' @keywords internal
#' @noRd
.install_from_github <- function(pkg, ...) {
  cli::cli_alert_info("Installing from GitHub: {.pkg {pkg}}")
  .ensure_devtools()
  # Reason: devtools::install_github is vectorized, no need for loop
  devtools::install_github(pkg, ...)
}


#' Install packages from Bioconductor
#' @keywords internal
#' @noRd
.install_from_bioc <- function(pkg, ...) {
  cli::cli_alert_info("Installing from Bioconductor: {.pkg {pkg}}")
  .ensure_biocmanager()
  # Reason: BiocManager automatically uses getOption("BioC_mirror")
  BiocManager::install(pkg, ...)
}


#' Install a package from a local file
#' @keywords internal
#' @noRd
.install_from_local <- function(path, ...) {
  cli::cli_alert_info("Installing from local path: {.file {path}}")
  utils::install.packages(path, repos = NULL, type = "source", ...)
}


#' Scan installed package info from DESCRIPTION files
#'
#' For each package name, reads Version, LibPath, and Package from its
#' DESCRIPTION file. Returns a named list keyed by lowercased package name.
#' Missing or unreadable packages are silently skipped.
#'
#' @param pkg Character vector. Package names to scan.
#' @return Named list; each element has `Version`, `LibPath`, `Package`.
#'
#' @keywords internal
#' @noRd
.installed_pkg_info <- function(pkg) {
  # Reason: find.package is faster than installed.packages for specific packages
  result <- list()
  for (p in pkg) {
    pkg_path <- tryCatch(find.package(p, quiet = TRUE), error = function(e) NULL)
    if (is.null(pkg_path) || length(pkg_path) == 0) next

    desc_path <- file.path(pkg_path, "DESCRIPTION")
    if (!file.exists(desc_path)) next

    desc <- tryCatch(read.dcf(desc_path), error = function(e) NULL)
    if (is.null(desc) || !"Version" %in% colnames(desc)) next

    result[[tolower(p)]] <- list(
      Version = desc[, "Version"],
      LibPath = dirname(pkg_path),
      Package = p
    )
  }
  result
}


#' Fetch latest package versions from CRAN
#'
#' @return Named character vector: version strings keyed by lowercased package name.
#'
#' @keywords internal
#' @noRd
.cran_latest_versions <- function() {
  db <- tryCatch(
    tools::CRAN_package_db(),
    error = function(e) cli::cli_abort("Failed to fetch CRAN database: {e$message}")
  )
  stats::setNames(db$Version, tolower(db$Package))
}


#' Fetch latest package versions from Bioconductor
#'
#' Returns an empty named vector (with a warning) if BiocManager is unavailable
#' or the fetch fails, so callers can degrade gracefully.
#'
#' @return Named character vector: version strings keyed by lowercased package name.
#'
#' @keywords internal
#' @noRd
.bioc_latest_versions <- function() {
  tryCatch({
    .ensure_biocmanager()
    bioc_repo <- BiocManager::repositories()["BioCsoft"]
    db        <- utils::available.packages(repos = bioc_repo)
    stats::setNames(db[, "Version"], tolower(db[, "Package"]))
  }, error = function(e) {
    cli::cli_alert_warning("Bioconductor database unavailable: {e$message}")
    stats::setNames(character(0), character(0))
  })
}


#' Filter out already-installed packages
#'
#' Checks each package in `pkg` and returns only those not yet installed.
#' Prints a skip message for each already-installed package.
#' Returns NULL (with a success message) if all packages are already installed.
#'
#' @param pkg Character vector. Package names or GitHub `"user/repo"` strings.
#' @param source Character. One of `"CRAN"`, `"GitHub"`, `"Bioconductor"`.
#' @return Character vector of packages to install, or NULL if none needed.
#'
#' @keywords internal
#' @noRd
.filter_installed_packages <- function(pkg, source) {
  # Reason: GitHub repos are "user/repo" — extract just the package name for namespace check
  pkg_names  <- if (source == "GitHub") basename(pkg) else pkg
  to_install <- character(0)

  for (i in seq_along(pkg)) {
    if (requireNamespace(pkg_names[i], quietly = TRUE)) {
      cli::cli_alert_info("Package {.pkg {pkg_names[i]}} is already installed. Skipped.")
    } else {
      to_install <- c(to_install, pkg[i])
    }
  }

  if (length(to_install) == 0) {
    cli::cli_alert_success("All packages already installed.")
    return(NULL)
  }

  to_install
}


#' Validate GitHub package name format (user/repo)
#'
#' @param pkg Character vector of GitHub package names.
#' @return NULL invisibly. Aborts on invalid format.
#'
#' @keywords internal
#' @noRd
.validate_github_format <- function(pkg) {
  invalid <- !grepl("^[^/]+/[^/]+$", pkg)
  if (any(invalid)) {
    cli::cli_abort(
      c(
        "GitHub packages must be in {.val user/repo} format.",
        "x" = "Invalid: {.val {pkg[invalid]}}",
        "i" = "Example: {.val hadley/ggplot2}"
      )
    )
  }
  invisible(NULL)
}
