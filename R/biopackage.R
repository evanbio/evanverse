# =============================================================================
# biopackage.R — Package management functions
# =============================================================================

#' Set CRAN/Bioconductor Mirrors
#'
#' Configure CRAN and/or Bioconductor mirrors for faster package installation.
#' All package management functions (`inst_pkg()`, `update_pkg()`, etc.) will
#' respect these settings once set.
#'
#' @param repo Character. One of `"all"`, `"cran"`, `"bioc"`. Default: `"all"`.
#' @param mirror Character. Mirror name. Default: `"tuna"`.
#'   CRAN: `official`, `rstudio`, `tuna`, `ustc`, `aliyun`, `sjtu`, `pku`,
#'   `hku`, `westlake`, `nju`, `sustech`.
#'   Bioc: `official`, `tuna`, `ustc`, `westlake`, `nju`.
#'
#' @return Previous mirror settings (invisibly).
#'
#' @examples
#' \dontrun{
#' set_mirror()                    # all mirrors → tuna
#' set_mirror("cran", "westlake")  # CRAN only
#' set_mirror("bioc", "ustc")      # Bioc only
#' }
#'
#' @export
set_mirror <- function(repo = c("all", "cran", "bioc"),
                       mirror = "tuna") {

  # Validate inputs
  repo <- match.arg(repo)
  .assert_scalar_string(mirror)

  # Save current settings
  old_settings <- list(
    repos = getOption("repos"),
    BioC_mirror = getOption("BioC_mirror")
  )

  cran_mirrors <- .cran_mirrors()
  bioc_mirrors <- .bioc_mirrors()

  # Validate mirror name
  if (repo %in% c("cran", "all")) {
    if (!mirror %in% names(cran_mirrors)) {
      cli::cli_abort(
        c(
          "Unknown CRAN mirror: {.val {mirror}}.",
          "i" = "Available: {.val {names(cran_mirrors)}}"
        ),
        call = NULL
      )
    }
  }

  if (repo %in% c("bioc", "all")) {
    if (!mirror %in% names(bioc_mirrors)) {
      cli::cli_abort(
        c(
          "Unknown Bioconductor mirror: {.val {mirror}}.",
          "i" = "Available: {.val {names(bioc_mirrors)}}"
        ),
        call = NULL
      )
    }
  }

  # Apply mirror settings
  if (repo %in% c("cran", "all")) {
    cran_url <- cran_mirrors[[mirror]]
    # Reason: only update the CRAN key to avoid wiping other repo entries
    # (e.g. BioCsoft, RSPM, custom repos) the user may have set
    current_repos         <- getOption("repos")
    current_repos["CRAN"] <- cran_url
    options(repos = current_repos)
    cli::cli_alert_success("CRAN mirror set to: {.url {cran_url}}")
  }

  if (repo %in% c("bioc", "all")) {
    bioc_url <- bioc_mirrors[[mirror]]
    options(BioC_mirror = bioc_url)
    cli::cli_alert_success("Bioconductor mirror set to: {.url {bioc_url}}")
  }

  invisible(old_settings)
}


#' Install R Packages from Multiple Sources
#'
#' Install R packages from CRAN, GitHub, Bioconductor, or local source.
#' Respects mirror settings from `set_mirror()`.
#'
#' @param pkg Character vector. Package name(s) or GitHub `"user/repo"`.
#'   Not required for `source = "Local"`.
#' @param source Character. One of `"CRAN"`, `"GitHub"`, `"Bioconductor"`, `"Local"`.
#' @param path Character. Path to local package file (required for `source = "Local"`).
#' @param ... Passed to the underlying install function.
#'
#' @return NULL invisibly.
#'
#' @examples
#' \dontrun{
#' inst_pkg("dplyr", source = "CRAN")
#' inst_pkg("hadley/emo", source = "GitHub")
#' inst_pkg("scRNAseq", source = "Bioconductor")
#' inst_pkg(source = "Local", path = "mypackage.tar.gz")
#' }
#'
#' @export
inst_pkg <- function(pkg = NULL,
                     source = c("CRAN", "GitHub", "Bioconductor", "Local"),
                     path = NULL, ...) {

  # Validate inputs
  source <- match.arg(source, c("CRAN", "GitHub", "Bioconductor", "Local"))

  if (source == "Local") {
    if (is.null(path)) cli::cli_abort("Must provide {.arg path} for local installation.", call = NULL)
    .assert_file_exists(path)
  } else if (source == "GitHub") {
    .assert_character_vector(pkg)
    .validate_github_format(pkg)
  } else {
    .assert_character_vector(pkg)
  }

  # Skip already-installed packages
  if (!is.null(pkg) && source != "Local") {
    pkg <- .filter_installed_packages(pkg, source)
    if (is.null(pkg)) return(invisible(NULL))
  }

  # Install
  switch(source,
    CRAN         = .install_from_cran(pkg, ...),
    GitHub       = .install_from_github(pkg, ...),
    Bioconductor = .install_from_bioc(pkg, ...),
    Local        = .install_from_local(path, ...)
  )

  cli::cli_alert_success("Installation complete!")
  invisible(NULL)
}


#' Check Package Installation Status
#'
#' Check whether packages are installed and optionally install missing ones.
#' Calls `inst_pkg()` for auto-installation.
#'
#' @param pkg Character vector. Package names or GitHub `"user/repo"`.
#' @param source Character. One of `"CRAN"`, `"GitHub"`, `"Bioconductor"`.
#' @param auto_install Logical. If `TRUE`, install missing packages automatically. Default: `FALSE`.
#' @param ... Passed to `inst_pkg()`.
#'
#' @return A tibble with columns: `package`, `name`, `installed`, `source`.
#'
#' @examples
#' check_pkg("ggplot2", source = "CRAN")
#' check_pkg("r-lib/devtools", source = "GitHub", auto_install = FALSE)
#'
#' @export
check_pkg <- function(pkg = NULL,
                      source = c("CRAN", "GitHub", "Bioconductor"),
                      auto_install = FALSE,
                      ...) {

  # Validate inputs
  source <- match.arg(source, c("CRAN", "GitHub", "Bioconductor"))
  .assert_character_vector(pkg)
  .assert_flag(auto_install)

  # Check installation status
  # Reason: Extract package names from GitHub repos (user/repo -> repo)
  pkg_names <- if (source == "GitHub") basename(pkg) else pkg
  installed <- vapply(pkg_names, requireNamespace, logical(1), quietly = TRUE)

  # Report and auto-install if needed
  for (i in seq_along(pkg)) {
    if (installed[i]) {
      cli::cli_alert_success("Installed: {.pkg {pkg_names[i]}}")
    } else {
      cli::cli_alert_warning("Missing: {.pkg {pkg_names[i]}}")

      if (auto_install) {
        # Reason: tryCatch so one failure doesn't abort the whole loop
        tryCatch(
          {
            inst_pkg(pkg = pkg[i], source = source, ...)
            cli::cli_alert_success("Successfully installed: {.pkg {pkg_names[i]}}")
            installed[i] <- TRUE
          },
          error = function(e) {
            cli::cli_alert_warning("Failed to install {.pkg {pkg_names[i]}}: {e$message}")
          }
        )
      }
    }
  }

  tibble::tibble(
    package   = pkg,
    name      = pkg_names,
    installed = installed,
    source    = source,
    .name_repair = "minimal"
  )
}


#' Update R Packages
#'
#' Update R packages from CRAN, GitHub, or Bioconductor. Supports full updates,
#' source-specific updates, or targeted package updates.
#'
#' @param pkg Character vector. Package name(s) or GitHub `"user/repo"`.
#'   If NULL, updates all installed packages for the given source.
#' @param source Character. One of `"all"`, `"CRAN"`, `"GitHub"`, `"Bioconductor"`.
#'   Default `"all"` updates all CRAN + Bioconductor packages.
#' @param ... Passed to the underlying update function.
#'
#' @return NULL invisibly.
#'
#' @examples
#' \dontrun{
#' update_pkg()                                    # all CRAN + Bioc
#' update_pkg(source = "CRAN")                     # all CRAN only
#' update_pkg("ggplot2", source = "CRAN")          # specific package
#' update_pkg("hadley/ggplot2", source = "GitHub")
#' }
#'
#' @export
update_pkg <- function(pkg = NULL,
                       source = c("all", "CRAN", "GitHub", "Bioconductor"),
                       ...) {

  # Validate inputs
  source <- match.arg(source)
  if (!is.null(pkg)) .assert_character_vector(pkg)

  if (!is.null(pkg) && source == "all")
    cli::cli_abort("Must specify {.arg source} when providing {.arg pkg}.", call = NULL)
  if (is.null(pkg) && source == "GitHub")
    cli::cli_abort("Must provide {.arg pkg} when updating GitHub packages.", call = NULL)
  if (source == "GitHub")
    .validate_github_format(pkg)

  # Sync BiocManager + full Bioconductor update (covers all Bioc cases)
  # Reason: plan B — this block IS the complete Bioc update;
  # downstream branches must not repeat BiocManager::install()
  if (source %in% c("all", "Bioconductor")) {
    .ensure_biocmanager()
    cli::cli_alert_info("Checking for BiocManager updates...")
    utils::install.packages("BiocManager")
    # Reason: Latest BiocManager knows the correct version for current R
    bioc_ver <- as.character(BiocManager::version())
    cli::cli_alert_info("Upgrading Bioconductor packages to version {bioc_ver}...")
    BiocManager::install(ask = FALSE)
    cli::cli_alert_success("Bioconductor upgraded to version {bioc_ver}.")
  }

  # Handle remaining cases (Bioc already done above)
  if (!is.null(pkg)) {
    # Specific package(s)
    cli::cli_alert_info("Updating {.pkg {pkg}} from {source}...")
    switch(source,
      CRAN         = .install_from_cran(pkg, ...),
      GitHub       = .install_from_github(pkg, ...),
      Bioconductor = .install_from_bioc(pkg, ask = FALSE, ...)
    )
  } else if (source %in% c("all", "CRAN")) {
    # CRAN-wide update (Bioc already done above if source == "all")
    cli::cli_alert_info("Updating all CRAN packages...")
    utils::update.packages(ask = FALSE)
  }
  # source == "Bioconductor" with no pkg: already handled above, nothing left to do

  cli::cli_alert_success("Update complete!")
  invisible(NULL)
}


#' Check Package Versions
#'
#' Check installed and latest available versions of R packages across
#' CRAN, Bioconductor, and GitHub.
#'
#' @param pkg Character vector. Package names to check.
#'
#' @return A data.frame with columns: `package`, `version` (installed version),
#'   `latest` (latest available on CRAN/Bioc; for GitHub packages this reflects
#'   the installed remote SHA, not the actual latest remote commit), `source`.
#'   GitHub info is only available for installed packages with
#'   `RemoteType == "github"` in their DESCRIPTION.
#'
#' @examples
#' \dontrun{
#' pkg_version(c("ggplot2", "dplyr"))
#' }
#'
#' @export
pkg_version <- function(pkg) {

  # Validate inputs
  .assert_character_vector(pkg)

  pkg <- unique(pkg)

  # Collect local and remote info
  installed_list        <- .installed_pkg_info(pkg)
  installed_names_lower <- names(installed_list)
  cran_latest           <- .cran_latest_versions()
  bioc_latest           <- .bioc_latest_versions()

  # Build result table
  result <- data.frame(
    package = pkg,
    version = NA_character_,
    latest  = NA_character_,
    source  = NA_character_,
    stringsAsFactors = FALSE
  )

  # Resolve source and latest version for each package
  for (i in seq_along(pkg)) {
    p       <- pkg[i]
    p_lower <- tolower(p)

    if (p_lower %in% installed_names_lower)
      result$version[i] <- installed_list[[p_lower]]$Version

    if (p_lower %in% names(cran_latest)) {
      result$latest[i] <- cran_latest[p_lower]
      result$source[i] <- "CRAN"
      next
    }

    if (p_lower %in% names(bioc_latest)) {
      result$latest[i] <- bioc_latest[p_lower]
      result$source[i] <- "Bioconductor"
      next
    }

    # Check GitHub via DESCRIPTION (only for installed packages)
    if (p_lower %in% installed_names_lower) {
      pkg_info  <- installed_list[[p_lower]]
      desc_path <- file.path(pkg_info$LibPath, pkg_info$Package, "DESCRIPTION")
      desc      <- tryCatch(read.dcf(desc_path), error = function(e) NULL)

      if (!is.null(desc) &&
          "RemoteType" %in% colnames(desc) &&
          desc[, "RemoteType"] == "github") {
        gh_sha          <- substr(desc[, "RemoteSha"], 1, 7)
        result$latest[i] <- gh_sha
        result$source[i] <- sprintf("GitHub (%s/%s@%s)",
                                    desc[, "RemoteUsername"],
                                    desc[, "RemoteRepo"],
                                    desc[, "RemoteRef"])
        next
      }
    }

    result$source[i] <- "Not Found"
  }

  invisible(result)
}


#' List Package Functions
#'
#' List exported symbols from a package's NAMESPACE, optionally filtered
#' by a case-insensitive keyword. Results are sorted alphabetically.
#'
#' @param pkg Character. Package name.
#' @param key Character. Keyword to filter function names (case-insensitive). Default: NULL.
#'
#' @return Character vector of exported names (invisibly).
#'
#' @examples
#' pkg_functions("evanverse")
#' pkg_functions("evanverse", key = "plot")
#'
#' @export
pkg_functions <- function(pkg, key = NULL) {

  # Validate inputs
  .assert_scalar_string(pkg)
  if (!is.null(key)) .assert_scalar_string(key)

  if (!requireNamespace(pkg, quietly = TRUE)) {
    cli::cli_abort("Package {.pkg {pkg}} is not installed.", call = NULL)
  }

  funcs <- getNamespaceExports(pkg)
  if (!is.null(key)) funcs <- funcs[grepl(key, funcs, ignore.case = TRUE)]

  sort(funcs)
}

