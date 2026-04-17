# =============================================================================
# pkg.R — Package management functions
# =============================================================================

#' Set CRAN/Bioconductor Mirrors
#'
#' Configure CRAN and/or Bioconductor mirrors for faster package installation.
#' R's native installation functions, \pkg{BiocManager}, and \pkg{pak} can
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
  if (repo == "cran") {
    if (!mirror %in% names(cran_mirrors)) {
      cli::cli_abort(
        c(
          "Unknown CRAN mirror: {.val {mirror}}.",
          "i" = "Available: {.val {names(cran_mirrors)}}"
        ),
        call = NULL
      )
    }
  } else if (repo == "bioc") {
    if (!mirror %in% names(bioc_mirrors)) {
      cli::cli_abort(
        c(
          "Unknown Bioconductor mirror: {.val {mirror}}.",
          "i" = "Available: {.val {names(bioc_mirrors)}}"
        ),
        call = NULL
      )
    }
  } else {
    # repo == "all": mirror must exist in both tables
    shared <- intersect(names(cran_mirrors), names(bioc_mirrors))
    if (!mirror %in% shared) {
      if (mirror %in% names(cran_mirrors)) {
        cli::cli_abort(
          c(
            "Mirror {.val {mirror}} is CRAN-only and cannot be used with {.code repo = \"all\"}.",
            "i" = "Use {.code set_mirror(\"cran\", \"{mirror}\")} instead.",
            "i" = "Shared mirrors: {.val {shared}}"
          ),
          call = NULL
        )
      } else if (mirror %in% names(bioc_mirrors)) {
        cli::cli_abort(
          c(
            "Mirror {.val {mirror}} is Bioconductor-only and cannot be used with {.code repo = \"all\"}.",
            "i" = "Use {.code set_mirror(\"bioc\", \"{mirror}\")} instead.",
            "i" = "Shared mirrors: {.val {shared}}"
          ),
          call = NULL
        )
      } else {
        cli::cli_abort(
          c(
            "Unknown mirror: {.val {mirror}}.",
            "i" = "CRAN mirrors: {.val {names(cran_mirrors)}}",
            "i" = "Bioconductor mirrors: {.val {names(bioc_mirrors)}}"
          ),
          call = NULL
        )
      }
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
    # Reason: strip trailing slash so BiocManager::repositories() doesn't
    # produce double-slash URLs like .../bioconductor//packages/...
    bioc_url <- sub("/$", "", bioc_mirrors[[mirror]])
    options(BioC_mirror = bioc_url)
    cli::cli_alert_success("Bioconductor mirror set to: {.url {bioc_url}}")
  }

  invisible(old_settings)
}


#' List Package Functions
#'
#' List exported symbols from a package's NAMESPACE, optionally filtered
#' by a case-insensitive keyword. Results are sorted alphabetically.
#'
#' @param pkg Character. Package name.
#' @param key Character. Keyword to filter function names (case-insensitive). Default: NULL.
#'
#' @return Character vector of exported names.
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

