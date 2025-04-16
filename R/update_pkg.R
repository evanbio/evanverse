#' 🔄 Update R Packages from CRAN, GitHub, or Bioconductor
#'
#' A unified function to update R packages by source. Supports full updates,
#' source-specific updates, or targeted package updates. Automatically sets mirrors
#' (Tsinghua CRAN, Tsinghua Bioconductor) and handles version compatibility checks.
#' Ensures Bioconductor installations specify the correct version to avoid mismatches.
#'
#' @param pkg Character vector. Name(s) of package(s) to update. For GitHub, use `"user/repo"` format.
#'            Only required when `source` is specified.
#' @param source Character. The source of the package(s): `"CRAN"`, `"GitHub"` (or `"gh"`), or `"Bioconductor"` (or `"bio"`).
#'               Optional if updating all installed CRAN and Bioconductor packages.
#'
#' @return Invisible `NULL`. Outputs update progress and logs via `message()`.
#' @export
update_pkg <- function(pkg = NULL, source = NULL) {
  # --- Normalize source argument
  if (!is.null(source)) {
    source_input <- tolower(source[1])
    source_matched <- switch(
      source_input,
      "cran" = "CRAN",
      "gh" = "GitHub", "github" = "GitHub",
      "bio" = "Bioconductor", "bioc" = "Bioconductor", "bioconductor" = "Bioconductor",
      stop("❌ Invalid source: ", source_input,
           ". Valid options: CRAN, GitHub, Bioconductor", call. = FALSE)
    )
  } else {
    source_matched <- NULL
  }

  # --- Check input logic
  if (!is.null(pkg) && is.null(source_matched)) {
    stop("❗ Must provide 'source' if 'pkg' is specified.", call. = FALSE)
  }
  if (is.null(pkg) && identical(source_matched, "GitHub")) {
    stop("❗ Must provide 'pkg' when updating GitHub packages.", call. = FALSE)
  }

  # --- Fetch R and expected Bioconductor version
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
      message("⚠️ Bioconductor version (", bioc_version, ") may not match R ", r_version,
              ". Recommended: ", expected_bioc)
      message("ℹ You can run manually: BiocManager::install(version = '", expected_bioc, "')")
    }
  }

  # --- Set mirrors (and restore after execution)
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

  # --- Update all packages (CRAN + Bioc)
  if (is.null(pkg) && is.null(source_matched)) {
    message("🔄 Updating all CRAN + Bioconductor packages...")

    message("📦 Updating CRAN packages...")
    update.packages(ask = FALSE)

    if (!requireNamespace("BiocManager", quietly = TRUE)) {
      install.packages("BiocManager")
    }

    message("🧬 Updating Bioconductor packages...")
    BiocManager::install(version = bioc_version, ask = FALSE)

  } else if (is.null(pkg)) {
    # --- Source-specific full update
    if (source_matched == "CRAN") {
      message("📦 Updating all CRAN packages...")
      update.packages(ask = FALSE)

    } else if (source_matched == "Bioconductor") {
      if (!requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
        bioc_version <- as.character(BiocManager::version())
      }

      message("🧬 Updating all Bioconductor packages...")
      BiocManager::install(version = bioc_version, ask = FALSE)
    }

  } else {
    # --- Specific package(s) update
    message("📦 Updating package(s): ", paste(pkg, collapse = ", "),
            " (source: ", source_matched, ")")

    if (source_matched == "CRAN") {
      install.packages(pkg, quiet = TRUE)

    } else if (source_matched == "Bioconductor") {
      if (!requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
        bioc_version <- as.character(BiocManager::version())
      }

      BiocManager::install(pkg, ask = FALSE, version = bioc_version)

    } else if (source_matched == "GitHub") {
      if (!requireNamespace("devtools", quietly = TRUE)) {
        install.packages("devtools")
      }
      for (p in pkg) devtools::install_github(p, quiet = TRUE)
    }
  }

  message("✅ Package update complete!")
  invisible(NULL)
}
