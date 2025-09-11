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
#' inst_pkg("dplyr", source = "cran")
#' inst_pkg("hadley/emo", source = "gh")
#' inst_pkg("scRNAseq", source = "bio")
#' inst_pkg(source = "local", path = "mypackage.tar.gz")
inst_pkg <- function(pkg = NULL,
                     source = c("CRAN", "GitHub", "Bioconductor", "Local"),
                     path = NULL, ...) {

  # -- 1. Normalize source argument
  valid_sources <- c("CRAN", "GitHub", "Bioconductor", "Local")
  source_matched <- match(source, valid_sources)
  
  # -- 2. Check package argument
  if (is.null(pkg) && source_matched != "Local") {
    stop("Please provide a package name (or repo) for non-local installation.", call. = FALSE)
  }

  # -- 3. Skip if already installed
  if (!is.null(pkg) && source_matched != "Local") {
    pkg_name <- if (source_matched == "GitHub") basename(pkg) else pkg
    if (requireNamespace(pkg_name, quietly = TRUE)) {
      cli::cli_alert_info(sprintf("Package [%s] is already installed. Skipped.", pkg_name))
      return(invisible(NULL))
    }
  }

  # -- 4. Install based on source
  if (source_matched == "CRAN") {
    cli::cli_alert_info(sprintf("Installing from CRAN: [%s]", paste(pkg, collapse = ", ")))
    install.packages(pkg,
                     repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/",
                     ...
    )

  } else if (source_matched == "GitHub") {
    cli::cli_alert_info(sprintf("Installing from GitHub: [%s]", paste(pkg, collapse = ", ")))
    if (!requireNamespace("devtools", quietly = TRUE)) {
      install.packages("devtools", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
    }
    for (p in pkg) devtools::install_github(p, ...)

  } else if (source_matched == "Bioconductor") {
    cli::cli_alert_info(sprintf("Installing from Bioconductor: [%s]", paste(pkg, collapse = ", ")))
    if (!requireNamespace("BiocManager", quietly = TRUE)) {
      install.packages("BiocManager", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
    }
    old_mirror <- getOption("BioC_mirror")
    options(BioC_mirror = "https://mirrors.westlake.edu.cn/bioconductor/")
    on.exit(options(BioC_mirror = old_mirror), add = TRUE)
    BiocManager::install(pkg, ...)

  } else if (source_matched == "Local") {
    if (is.null(path)) stop("Please provide a local path for installation.", call. = FALSE)
    cli::cli_alert_info(sprintf("Installing from local path: [%s]", path))
    install.packages(path, repos = NULL, type = "source", ...)
  }

  cli::cli_alert_success("Installation complete!")
  invisible(NULL)
}
