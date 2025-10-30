#' @title Package Management
#' @name pkg_management
#'
#' @description
#' A unified interface for R package management across CRAN, GitHub,
#' Bioconductor, and local sources. Provides consistent installation,
#' checking, updating, and querying capabilities.
#'
#' @details
#' The package management functions automatically:
#' \itemize{
#'   \item Respect mirror settings configured via \code{set_mirror()}
#'   \item Handle dependencies for BiocManager and devtools
#'   \item Validate package names and sources
#'   \item Provide informative error messages and progress updates
#' }
#'
#' Recommended workflow:
#' \enumerate{
#'   \item (Optional) Configure mirrors: \code{set_mirror()}
#'   \item Install packages: \code{inst_pkg()}
#'   \item Check status: \code{check_pkg()}
#'   \item Update packages: \code{update_pkg()}
#'   \item Query information: \code{pkg_version()}, \code{pkg_functions()}
#' }
#'
#' @seealso
#' \code{\link[utils]{install.packages}} for base installation,
#' \code{\link[devtools]{install_github}} for GitHub packages,
#' \code{\link[BiocManager]{install}} for Bioconductor packages.
NULL


# ==============================================================================
# Mirror Configuration
# ==============================================================================

#' @title Set CRAN/Bioconductor Mirrors
#'
#' @description
#' Configure CRAN and/or Bioconductor mirrors for faster package installation.
#' Once set, all package management functions (\code{inst_pkg}, \code{update_pkg},
#' etc.) will respect these mirror settings.
#'
#' @param repo Character. Repository type: "cran", "bioc", or "all" (default: "all").
#' @param mirror Character. Predefined mirror name (default: "tuna").
#'
#' @return Previous mirror settings (invisibly).
#'
#' @details
#' Available CRAN mirrors:
#' \itemize{
#'   \item \strong{official}: R Project cloud server
#'   \item \strong{rstudio}: RStudio CRAN mirror
#'   \item \strong{tuna}: Tsinghua University (China)
#'   \item \strong{ustc}: USTC (China)
#'   \item \strong{aliyun}: Alibaba Cloud (China)
#'   \item \strong{sjtu}: Shanghai Jiao Tong University (China)
#'   \item \strong{pku}: Peking University (China)
#'   \item \strong{hku}: Hong Kong University
#'   \item \strong{westlake}: Westlake University (China)
#'   \item \strong{nju}: Nanjing University (China)
#'   \item \strong{sustech}: SUSTech (China)
#' }
#'
#' Available Bioconductor mirrors:
#' \itemize{
#'   \item \strong{official}: Bioconductor official server
#'   \item \strong{tuna}: Tsinghua University (China)
#'   \item \strong{ustc}: USTC (China)
#'   \item \strong{westlake}: Westlake University (China)
#'   \item \strong{nju}: Nanjing University (China)
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Set all mirrors to tuna (default):
#' set_mirror()
#'
#' # Set only CRAN mirror:
#' set_mirror("cran", "westlake")
#'
#' # Set only Bioconductor mirror:
#' set_mirror("bioc", "ustc")
#'
#' # Check current settings:
#' getOption("repos")
#' getOption("BioC_mirror")
#' }
#'
#' @rdname set_mirror
set_mirror <- function(repo = c("all", "cran", "bioc"),
                       mirror = "tuna") {

  # ===========================================================================
  # Step 1: Parameter Validation
  # ===========================================================================

  repo <- match.arg(repo)

  # ===========================================================================
  # Step 2: Save Current Settings
  # ===========================================================================

  old_settings <- list(
    repos = getOption("repos"),
    BioC_mirror = getOption("BioC_mirror")
  )

  # ===========================================================================
  # Step 3: Define Mirror Repository URLs
  # ===========================================================================

  cran_mirrors <- list(
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

  bioc_mirrors <- list(
    official = "https://bioconductor.org",
    tuna     = "https://mirrors.tuna.tsinghua.edu.cn/bioconductor",
    ustc     = "https://mirrors.ustc.edu.cn/bioconductor",
    westlake = "https://mirrors.westlake.edu.cn/bioconductor",
    nju      = "https://mirrors.nju.edu.cn/bioconductor"
  )

  # ===========================================================================
  # Step 4: Validate Mirror Name
  # ===========================================================================

  cli::cli_h2("Configuring {.field {repo}} mirror")

  if (repo %in% c("cran", "all")) {
    if (!mirror %in% names(cran_mirrors)) {
      cli::cli_abort(
        c(
          "Unknown CRAN mirror: {.val {mirror}}.",
          "i" = "Available: {.val {names(cran_mirrors)}}"
        )
      )
    }
  }

  if (repo %in% c("bioc", "all")) {
    if (!mirror %in% names(bioc_mirrors)) {
      cli::cli_abort(
        c(
          "Unknown Bioconductor mirror: {.val {mirror}}.",
          "i" = "Available: {.val {names(bioc_mirrors)}}"
        )
      )
    }
  }

  # ===========================================================================
  # Step 5: Apply Mirror Settings
  # ===========================================================================

  if (repo %in% c("cran", "all")) {
    cran_url <- cran_mirrors[[mirror]]
    options(repos = c(CRAN = cran_url))
    cli::cli_alert_success("CRAN mirror set to: {.url {cran_url}}")
  }

  if (repo %in% c("bioc", "all")) {
    bioc_url <- bioc_mirrors[[mirror]]
    options(BioC_mirror = bioc_url)
    cli::cli_alert_success("Bioconductor mirror set to: {.url {bioc_url}}")
  }

  # ===========================================================================
  # Step 6: Display Available Options
  # ===========================================================================

  if (repo == "cran") {
    cli::cli_alert_info("Available CRAN mirrors: {.val {names(cran_mirrors)}}")
  } else if (repo == "bioc") {
    cli::cli_alert_info("Available Bioc mirrors: {.val {names(bioc_mirrors)}}")
  } else {
    cli::cli_alert_info("Available CRAN mirrors: {.val {names(cran_mirrors)}}")
    cli::cli_alert_info("Available Bioc mirrors: {.val {names(bioc_mirrors)}}")
  }

  cli::cli_alert_info(
    "View current settings: {.code getOption('repos')} & {.code getOption('BioC_mirror')}"
  )

  # ===========================================================================
  # Step 7: Return Previous Settings
  # ===========================================================================

  invisible(old_settings)
}


# ==============================================================================
# Core Installation Functions
# ==============================================================================

#' @title Install R Packages from Multiple Sources
#'
#' @description
#' Install R packages from CRAN, GitHub, Bioconductor, or local source.
#' Automatically respects mirror settings from \code{set_mirror()}.
#'
#' @param pkg Character vector. Package name(s) or GitHub repo (e.g., "user/repo").
#'   Not required for \code{source = "local"}.
#' @param source Character. Package source: "CRAN", "GitHub", "Bioconductor", "Local".
#'   Case-insensitive, first match used.
#' @param path Character. Path to local package file (required when \code{source = "local"}).
#' @param ... Additional arguments passed to \code{\link[utils]{install.packages}},
#'   \code{\link[devtools]{install_github}}, or \code{\link[BiocManager]{install}}.
#'
#' @return NULL (invisibly). Side effect: installs packages.
#'
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
#' inst_pkg(source = "Local", path = "mypackage.tar.gz")
#' }
#'
#' @rdname inst_pkg
inst_pkg <- function(pkg = NULL,
                     source = c("CRAN", "GitHub", "Bioconductor", "Local"),
                     path = NULL, ...) {

  # ===========================================================================
  # Step 1: Parameter Validation
  # ===========================================================================

  source <- match.arg(source, c("CRAN", "GitHub", "Bioconductor", "Local"))

  if (!is.null(pkg)) {
    if (!is.character(pkg) || any(is.na(pkg)) || length(pkg) == 0) {
      cli::cli_abort(
        c(
          "{.arg pkg} must be a character vector without NA values.",
          "i" = "Example: {.val dplyr} or {.val c('dplyr', 'ggplot2')}"
        )
      )
    }
  }

  if (is.null(pkg) && source != "Local") {
    cli::cli_abort("Must provide {.arg pkg} for non-local installation.")
  }

  if (source == "GitHub") {
    .validate_github_format(pkg)
  }

  if (source == "Local" && is.null(path)) {
    cli::cli_abort("Must provide {.arg path} for local installation.")
  }

  # ===========================================================================
  # Step 2: Check if Already Installed (skip if so)
  # ===========================================================================

  if (!is.null(pkg) && source != "Local") {
    # Reason: Extract package names from GitHub repos (user/repo -> repo)
    pkg_names <- if (source == "GitHub") basename(pkg) else pkg

    # Check each package individually
    to_install <- character(0)
    for (i in seq_along(pkg)) {
      if (requireNamespace(pkg_names[i], quietly = TRUE)) {
        cli::cli_alert_info("Package {.pkg {pkg_names[i]}} is already installed. Skipped.")
      } else {
        to_install <- c(to_install, pkg[i])
      }
    }

    # If all packages are already installed, return early
    if (length(to_install) == 0) {
      cli::cli_alert_success("All packages already installed.")
      return(invisible(NULL))
    }

    # Update pkg to only include packages that need installation
    pkg <- to_install
  }

  # ===========================================================================
  # Step 3: Install Based on Source
  # ===========================================================================

  if (source == "CRAN") {
    cli::cli_alert_info("Installing from CRAN: {.pkg {pkg}}")
    # Reason: R automatically uses getOption("repos"), respecting user's mirror settings
    utils::install.packages(pkg, ...)

  } else if (source == "GitHub") {
    cli::cli_alert_info("Installing from GitHub: {.pkg {pkg}}")
    .ensure_devtools()
    # Reason: devtools::install_github is vectorized, no need for loop
    devtools::install_github(pkg, ...)

  } else if (source == "Bioconductor") {
    cli::cli_alert_info("Installing from Bioconductor: {.pkg {pkg}}")
    .ensure_biocmanager()
    # Reason: BiocManager automatically uses getOption("BioC_mirror")
    BiocManager::install(pkg, ...)

  } else if (source == "Local") {
    cli::cli_alert_info("Installing from local path: {.file {path}}")
    utils::install.packages(path, repos = NULL, type = "source", ...)
  }

  cli::cli_alert_success("Installation complete!")
  invisible(NULL)
}


#' @title Check Package Installation Status
#'
#' @description
#' Check whether packages are installed and optionally install missing ones.
#' Internally calls \code{inst_pkg()} for auto-installation.
#'
#' @param pkg Character vector. Package names or GitHub repos (e.g., "user/repo").
#' @param source Character. Package source: "CRAN", "GitHub", or "Bioconductor".
#' @param auto_install Logical. If TRUE (default), install missing packages automatically.
#' @param ... Additional arguments passed to \code{inst_pkg()}.
#'
#' @return A tibble with columns: \code{package}, \code{name}, \code{installed}, \code{source}.
#'
#' @export
#'
#' @examples
#' # Check if ggplot2 is installed (will install if missing):
#' check_pkg("ggplot2", source = "CRAN")
#'
#' # Check without auto-install:
#' check_pkg("r-lib/devtools", source = "GitHub", auto_install = FALSE)
#'
#' @rdname check_pkg
check_pkg <- function(pkg = NULL,
                      source = c("CRAN", "GitHub", "Bioconductor"),
                      auto_install = TRUE,
                      ...) {

  # ===========================================================================
  # Step 1: Parameter Validation
  # ===========================================================================

  source <- match.arg(source, c("CRAN", "GitHub", "Bioconductor"))

  if (is.null(pkg)) {
    cli::cli_abort("Please provide at least one package name in {.arg pkg}.")
  }

  # ===========================================================================
  # Step 2: Check Installation Status
  # ===========================================================================

  # Reason: Extract package names from GitHub repos
  pkg_names <- if (source == "GitHub") basename(pkg) else pkg

  # Vectorized check for installed packages
  installed <- vapply(pkg_names, requireNamespace, logical(1), quietly = TRUE)

  # ===========================================================================
  # Step 3: Report Status and Install if Needed
  # ===========================================================================

  for (i in seq_along(pkg)) {
    if (installed[i]) {
      cli::cli_alert_success("Installed: {.pkg {pkg_names[i]}}")
    } else {
      cli::cli_alert_warning("Missing: {.pkg {pkg_names[i]}}")

      if (isTRUE(auto_install)) {
        cli::cli_alert_info("Installing {.pkg {pkg_names[i]}} from {source}...")

        # Reason: Wrap in tryCatch to handle installation failures gracefully
        tryCatch(
          {
            inst_pkg(pkg = pkg[i], source = source, ...)
            cli::cli_alert_success("Successfully installed: {.pkg {pkg_names[i]}}")
            installed[i] <- TRUE
          },
          error = function(e) {
            cli::cli_alert_danger("Failed to install {.pkg {pkg_names[i]}}: {e$message}")
          }
        )
      }
    }
  }

  # ===========================================================================
  # Step 4: Return Result Table
  # ===========================================================================

  tibble::tibble(
    package = pkg,
    name = pkg_names,
    installed = installed,
    source = source,
    .name_repair = "minimal"
  )
}


# ==============================================================================
# Package Update Functions
# ==============================================================================

#' @title Update R Packages
#'
#' @description
#' Update R packages from CRAN, GitHub, or Bioconductor. Supports full updates,
#' source-specific updates, or targeted package updates. Automatically handles
#' version compatibility checks and respects mirror settings.
#'
#' @param pkg Character vector. Package name(s) to update. For GitHub, use
#'   \code{"user/repo"} format. Only required when \code{source} is specified.
#' @param source Character. Package source: "CRAN", "GitHub", or "Bioconductor".
#'   Optional if updating all installed CRAN and Bioconductor packages.
#' @param ... Additional arguments passed to \code{\link[utils]{install.packages}},
#'   \code{\link[devtools]{install_github}}, or \code{\link[BiocManager]{install}}.
#'
#' @return NULL (invisibly). Side effect: updates packages.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Update all CRAN + Bioconductor packages:
#' update_pkg()
#'
#' # Update all CRAN packages only:
#' update_pkg(source = "CRAN")
#'
#' # Update specific package:
#' update_pkg("ggplot2", source = "CRAN")
#'
#' # Update GitHub package:
#' update_pkg("hadley/ggplot2", source = "GitHub")
#' }
#'
#' @rdname update_pkg
update_pkg <- function(pkg = NULL, source = NULL, ...) {

  # ===========================================================================
  # Step 1: Parameter Validation
  # ===========================================================================

  if (!is.null(pkg)) {
    if (!is.character(pkg) || any(is.na(pkg)) || length(pkg) == 0) {
      cli::cli_abort("{.arg pkg} must be a character vector without NA values.")
    }
  }

  if (!is.null(source)) {
    source <- match.arg(source, c("CRAN", "GitHub", "Bioconductor"))
  }

  # Check input logic
  if (!is.null(pkg) && is.null(source)) {
    cli::cli_abort("Must specify {.arg source} when providing {.arg pkg}.")
  }
  if (is.null(pkg) && identical(source, "GitHub")) {
    cli::cli_abort("Must provide {.arg pkg} when updating GitHub packages.")
  }

  # Validate GitHub package format
  if (!is.null(source) && source == "GitHub") {
    .validate_github_format(pkg)
  }

  # ===========================================================================
  # Step 2: Update BiocManager and Upgrade Bioconductor
  # ===========================================================================

  # Only check for Bioconductor-related operations
  if (is.null(source) || source == "Bioconductor") {
    .ensure_biocmanager()

    # Step 1: Update BiocManager package itself (CRAN package)
    cli::cli_alert_info("Checking for BiocManager package updates from CRAN...")
    utils::update.packages("BiocManager", ask = FALSE)

    # Step 2: Get expected Bioconductor version from updated BiocManager
    # Reason: Latest BiocManager knows the correct version for current R
    bioc_expected_version <- as.character(BiocManager::version())

    # Step 3: Upgrade Bioconductor packages to the expected version
    cli::cli_alert_info("Upgrading Bioconductor packages to version {bioc_expected_version}...")
    BiocManager::install(ask = FALSE)

    cli::cli_alert_success(
      "Bioconductor packages upgraded to version {bioc_expected_version}."
    )
  }

  # ===========================================================================
  # Step 3: Execute Update Based on Arguments
  # ===========================================================================

  # Case 1: Update all packages (CRAN + Bioconductor)
  if (is.null(pkg) && is.null(source)) {
    cli::cli_alert_info("Updating all CRAN + Bioconductor packages...")

    cli::cli_alert_info("Updating CRAN packages...")
    utils::update.packages(ask = FALSE)

    cli::cli_alert_info("Updating Bioconductor packages...")
    BiocManager::install(ask = FALSE)

  # Case 2: Source-specific full update
  } else if (is.null(pkg)) {
    if (source == "CRAN") {
      cli::cli_alert_info("Updating all CRAN packages...")
      utils::update.packages(ask = FALSE)

    } else if (source == "Bioconductor") {
      cli::cli_alert_info("Updating all Bioconductor packages...")
      BiocManager::install(ask = FALSE)
    }

  # Case 3: Specific package(s) update
  } else {
    cli::cli_alert_info("Updating package(s): {.pkg {pkg}} (source: {source})")

    if (source == "CRAN") {
      utils::install.packages(pkg, ...)

    } else if (source == "Bioconductor") {
      BiocManager::install(pkg, ask = FALSE, ...)

    } else if (source == "GitHub") {
      .ensure_devtools()
      devtools::install_github(pkg, ...)
    }
  }

  cli::cli_alert_success("Package update complete!")
  invisible(NULL)
}


# ==============================================================================
# Package Query Functions
# ==============================================================================

#' @title Check Package Versions
#'
#' @description
#' Check installed and latest available versions of R packages across
#' CRAN, Bioconductor, and GitHub. Supports case-insensitive matching.
#'
#' @param pkg Character vector. Package names to check.
#' @param preview Logical. If TRUE (default), print result to console.
#'
#' @return A data.frame with columns: \code{package}, \code{version} (installed),
#'   \code{latest} (available), and \code{source}.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Check versions of multiple packages:
#' pkg_version(c("ggplot2", "dplyr"))
#'
#' # Check without console preview:
#' result <- pkg_version(c("ggplot2", "limma"), preview = FALSE)
#' }
#'
#' @rdname pkg_version
pkg_version <- function(pkg, preview = TRUE) {

  # ===========================================================================
  # Step 1: Parameter Validation
  # ===========================================================================

  if (!is.character(pkg) || length(pkg) == 0) {
    cli::cli_abort("{.arg pkg} must be a non-empty character vector.")
  }
  if (!is.logical(preview) || length(preview) != 1) {
    cli::cli_abort("{.arg preview} must be a single logical value.")
  }

  pkg <- unique(pkg)

  # Ensure BiocManager is available (in Suggests)
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg BiocManager} is required but not installed.")
  }

  # ===========================================================================
  # Step 2: Check Installed Package Versions
  # ===========================================================================

  cli::cli_h1("Checking installed packages...")

  # Reason: Use find.package for specific packages (faster than installed.packages)
  installed_list <- list()
  for (p in pkg) {
    pkg_path <- tryCatch(find.package(p, quiet = TRUE), error = function(e) NULL)
    if (!is.null(pkg_path) && length(pkg_path) > 0) {
      desc_path <- file.path(pkg_path, "DESCRIPTION")
      if (file.exists(desc_path)) {
        desc <- tryCatch(read.dcf(desc_path), error = function(e) NULL)
        if (!is.null(desc) && "Version" %in% colnames(desc)) {
          installed_list[[tolower(p)]] <- list(
            Version = desc[, "Version"],
            LibPath = dirname(pkg_path),
            Package = p
          )
        }
      }
    }
  }

  installed_names_lower <- names(installed_list)

  # ===========================================================================
  # Step 3: Fetch CRAN Package Database
  # ===========================================================================

  cli::cli_h1("Fetching CRAN package database...")

  cran_db <- tryCatch(
    tools::CRAN_package_db(),
    error = function(e) {
      cli::cli_abort("Failed to fetch CRAN package database: {e$message}")
    }
  )
  cran_latest <- stats::setNames(cran_db$Version, tolower(cran_db$Package))

  # ===========================================================================
  # Step 4: Fetch Bioconductor Package Database
  # ===========================================================================

  cli::cli_h1("Fetching Bioconductor package database...")

  bioc_repo <- tryCatch(
    BiocManager::repositories()["BioCsoft"],
    error = function(e) {
      cli::cli_abort("Failed to fetch Bioconductor repositories: {e$message}")
    }
  )
  bioc_db <- tryCatch(
    utils::available.packages(repos = bioc_repo),
    error = function(e) {
      cli::cli_abort("Failed to fetch Bioconductor package database: {e$message}")
    }
  )
  bioc_latest <- stats::setNames(bioc_db[, "Version"], tolower(bioc_db[, "Package"]))

  # ===========================================================================
  # Step 5: Build Result Table
  # ===========================================================================

  result <- data.frame(
    package = pkg,
    version = NA_character_,
    latest  = NA_character_,
    source  = NA_character_,
    stringsAsFactors = FALSE
  )

  # Loop through packages and check each source
  for (i in seq_along(pkg)) {
    p <- pkg[i]
    p_lower <- tolower(p)
    cli::cli_h2("Checking package: {.pkg {p}}")

    # Get installed version
    if (p_lower %in% installed_names_lower) {
      result$version[i] <- installed_list[[p_lower]]$Version
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
      pkg_info <- installed_list[[p_lower]]
      desc_path <- file.path(pkg_info$LibPath, pkg_info$Package, "DESCRIPTION")

      desc <- tryCatch(read.dcf(desc_path), error = function(e) NULL)

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

  # ===========================================================================
  # Step 6: Display and Return Result
  # ===========================================================================

  if (preview) print(result)
  invisible(result)
}


#' @title List Package Functions
#'
#' @description
#' List exported symbols from a package's NAMESPACE. Optionally filter
#' by a case-insensitive keyword. Results are sorted alphabetically.
#'
#' @param pkg Character. Package name.
#' @param key Character. Optional keyword to filter function names (case-insensitive).
#'
#' @return Character vector of exported names (invisibly).
#'
#' @export
#'
#' @examples
#' # List all functions in evanverse:
#' pkg_functions("evanverse")
#'
#' # Filter by keyword:
#' pkg_functions("evanverse", key = "plot")
#'
#' @rdname pkg_functions
pkg_functions <- function(pkg, key = NULL) {

  # ===========================================================================
  # Step 1: Parameter Validation
  # ===========================================================================

  if (!is.character(pkg) || length(pkg) != 1L || is.na(pkg) || nzchar(pkg) == FALSE) {
    cli::cli_abort("{.arg pkg} must be a non-empty character scalar.")
  }
  if (!is.null(key) && (!is.character(key) || length(key) != 1L || is.na(key))) {
    cli::cli_abort("{.arg key} must be a single non-NA character string or NULL.")
  }

  # ===========================================================================
  # Step 2: Check Package Availability
  # ===========================================================================

  if (!requireNamespace(pkg, quietly = TRUE)) {
    cli::cli_abort("Package {.pkg {pkg}} is not installed.")
  }

  # ===========================================================================
  # Step 3: Collect and Filter Exports
  # ===========================================================================

  funcs <- getNamespaceExports(pkg)

  if (!is.null(key)) {
    funcs <- funcs[grepl(key, funcs, ignore.case = TRUE)]
  }

  funcs <- sort(funcs)

  # ===========================================================================
  # Step 4: Display Results
  # ===========================================================================

  cli::cli_h2("Package: {.pkg {pkg}}")
  cli::cli_alert_info("Matched exported names: {length(funcs)}")

  if (length(funcs) > 0L) {
    # Reason: Use verbatim to avoid glue evaluation
    cli::cli_verbatim(paste(funcs, collapse = "\n"))
  } else if (!is.null(key)) {
    cli::cli_alert_warning("No exported names matched keyword: {.val {key}}")
  }

  invisible(funcs)
}


# ==============================================================================
# Internal Helper Functions
# ==============================================================================

#' @title Ensure BiocManager is Installed
#' @description
#' Internal function to check and install BiocManager if needed.
#' R automatically uses getOption("repos") for mirror settings.
#'
#' @return NULL (invisibly). Side effect: installs BiocManager if missing.
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


#' @title Ensure devtools is Installed
#' @description
#' Internal function to check and install devtools if needed.
#' R automatically uses getOption("repos") for mirror settings.
#'
#' @return NULL (invisibly). Side effect: installs devtools if missing.
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


#' @title Validate GitHub Package Format
#' @description
#' Internal function to validate GitHub package names follow user/repo format.
#'
#' @param pkg Character vector. GitHub package names to validate.
#'
#' @return NULL (invisibly). Aborts if validation fails.
#'
#' @keywords internal
#' @noRd
.validate_github_format <- function(pkg) {
  invalid <- !grepl("^[^/]+/[^/]+$", pkg)
  if (any(invalid)) {
    cli::cli_abort(
      c(
        "GitHub packages must be in 'user/repo' format.",
        "x" = "Invalid: {.val {pkg[invalid]}}",
        "i" = "Example: {.val hadley/ggplot2}"
      )
    )
  }
  invisible(NULL)
}
