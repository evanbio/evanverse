#' 📦 Install R Packages from Multiple Sources
#'
#' A unified installer for R packages from CRAN, GitHub, Bioconductor, or local source.
#'
#' @param pkg Package name(s) or GitHub repo (e.g., `"user/repo"`). Not required for `source = "local"`.
#' @param source Source of package: `"CRAN"`, `"GitHub"`, `"Bioconductor"`, `"local"`. Case-insensitive, shorthand allowed.
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
                     source = c("CRAN", "GitHub", "Bioconductor", "local"),
                     path = NULL, ...) {

  # -- 1. Normalize source argument
  source_input <- tolower(source[1])
  source_matched <- switch(source_input,
                           "cran"  = "CRAN",
                           "gh"    = "GitHub", "github" = "GitHub",
                           "bio"   = "Bioconductor", "bioc" = "Bioconductor", "bioconductor" = "Bioconductor",
                           "local" = "local",
                           stop("❌ Invalid source: ", source_input,
                                "\n✔ Available: CRAN / GitHub / Bioconductor / local", call. = FALSE)
  )

  # -- 2. Check package argument
  if (is.null(pkg) && source_matched != "local") {
    stop("❗ Please provide a package name (or repo) for non-local installation.", call. = FALSE)
  }

  # -- 3. Skip if already installed
  if (!is.null(pkg) && source_matched != "local") {
    pkg_name <- if (source_matched == "GitHub") basename(pkg) else pkg
    if (requireNamespace(pkg_name, quietly = TRUE)) {
      message("✅ Package [", pkg_name, "] is already installed. Skipped.")
      return(invisible(NULL))
    }
  }

  # -- 4. Install based on source
  if (source_matched == "CRAN") {
    message("🔽 Installing from CRAN: [", paste(pkg, collapse = ", "), "]")
    install.packages(pkg,
                     repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/",
                     ...
    )

  } else if (source_matched == "GitHub") {
    message("🔽 Installing from GitHub: [", paste(pkg, collapse = ", "), "]")
    if (!requireNamespace("devtools", quietly = TRUE)) {
      install.packages("devtools", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
    }
    for (p in pkg) devtools::install_github(p, ...)

  } else if (source_matched == "Bioconductor") {
    message("🔽 Installing from Bioconductor: [", paste(pkg, collapse = ", "), "]")
    if (!requireNamespace("BiocManager", quietly = TRUE)) {
      install.packages("BiocManager", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
    }
    old_mirror <- getOption("BioC_mirror")
    options(BioC_mirror = "https://mirrors.tuna.tsinghua.edu.cn/bioconductor/")
    on.exit(options(BioC_mirror = old_mirror), add = TRUE)
    BiocManager::install(pkg, ...)

  } else if (source_matched == "local") {
    if (is.null(path)) stop("❗ Please provide a local path for installation.", call. = FALSE)
    message("📂 Installing from local path: [", path, "]")
    install.packages(path, repos = NULL, type = "source", ...)
  }

  message("🎉 Installation complete!")
  invisible(NULL)
}
