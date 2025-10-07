#' Install R Packages from Multiple Sources
#'
#' A unified installer for R packages from CRAN, GitHub, Bioconductor, or local source.
#'
#' @param pkg Package name(s) or GitHub repo (e.g., "user/repo"). Not required for `source = "local"`.
#' @param source Source of package: "CRAN", "GitHub", "Bioconductor", "local". Case-insensitive, shorthand allowed.
#' @param path Path to local package file (used when `source = "local"`).
#' @param ... Additional arguments passed to `install.packages()`, `devtools::install_github()`, or `BiocManager::install()`.
#'
#' @return NULL (invisibly)
#' @export
#'
#' @examples
#' \dontrun{
#' # Install from CRAN:
#' inst_pkg("dplyr", source = "CRAN")
#'
#' # Install from GitHub:
#' inst_pkg("hadley/emo", source = "GitHub")
#'
#' # Install from Bioconductor:
#' inst_pkg("scRNAseq", source = "Bioconductor")
#'
#' # Install from local file:
#' inst_pkg(source = "local", path = "mypackage.tar.gz")
#' }
#'
#' \donttest{
#' # Quick demo - try to install a small package (will skip if already installed):
#' try(inst_pkg("praise", source = "CRAN"))
#' }
inst_pkg <- function(pkg = NULL,
                     source = c("CRAN", "GitHub", "Bioconductor", "Local"),
                     path = NULL, ...) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================
  
  # Validate and normalize source argument
  source <- match.arg(source, c("CRAN", "GitHub", "Bioconductor", "Local"))
  
  # Validate pkg parameter
  if (!is.null(pkg)) {
    if (!is.character(pkg) || any(is.na(pkg)) || length(pkg) == 0) {
      cli::cli_abort("'pkg' must be a character vector without NA values.")
    }
  }
  
  # Check package argument logic
  if (is.null(pkg) && source != "Local") {
    cli::cli_abort("Must provide 'pkg' for non-local installation.")
  }
  
  # Validate GitHub package format
  if (source == "GitHub") {
    invalid_gh <- !grepl("^[^/]+/[^/]+$", pkg)
    if (any(invalid_gh)) {
      cli::cli_abort("GitHub packages must be in 'user/repo' format. Invalid: {.val {pkg[invalid_gh]}}")
    }
  }
  
  # Validate local path
  if (source == "Local" && is.null(path)) {
    cli::cli_abort("Must provide 'path' for local installation.")
  }

  # ===========================================================================
  # Skip if already installed
  # ===========================================================================
  if (!is.null(pkg) && source != "Local") {
    pkg_name <- if (source == "GitHub") basename(pkg) else pkg
    if (requireNamespace(pkg_name, quietly = TRUE)) {
      cli::cli_alert_info("Package {.pkg {pkg_name}} is already installed. Skipped.")
      return(invisible(NULL))
    }
  }

  # ===========================================================================
  # Install based on source
  # ===========================================================================
  if (source == "CRAN") {
    cli::cli_alert_info("Installing from CRAN: {.pkg {pkg}}")
    utils::install.packages(pkg,
                     repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/",
                     ...
    )

  } else if (source == "GitHub") {
    cli::cli_alert_info("Installing from GitHub: {.pkg {pkg}}")
    if (!requireNamespace("devtools", quietly = TRUE)) {
      utils::install.packages("devtools", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
    }
    for (p in pkg) devtools::install_github(p, ...)

  } else if (source == "Bioconductor") {
    cli::cli_alert_info("Installing from Bioconductor: {.pkg {pkg}}")
    if (!requireNamespace("BiocManager", quietly = TRUE)) {
      utils::install.packages("BiocManager", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
    }
    old_mirror <- getOption("BioC_mirror")
    options(BioC_mirror = "https://mirrors.tuna.tsinghua.edu.cn/bioconductor/")
    on.exit(options(BioC_mirror = old_mirror), add = TRUE)
    BiocManager::install(pkg, ...)

  } else if (source == "Local") {
    cli::cli_alert_info("Installing from local path: {.file {path}}")
    utils::install.packages(path, repos = NULL, type = "source", ...)
  }

  cli::cli_alert_success("Installation complete!")
  invisible(NULL)
}
