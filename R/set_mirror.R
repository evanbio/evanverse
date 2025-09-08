#' 🔄 set_mirror: Set CRAN/Bioconductor Mirrors
#'
#' Switch CRAN and/or Bioconductor mirrors for faster package installation.
#'
#' @param repo   Character. "cran", "bioc", or "all".
#' @param mirror Character. Predefined mirror name or custom URL.
#' @examples
#' set_mirror("cran", "westlake")
#' set_mirror("bioc", "bioc_tuna")
#' set_mirror("all", "ustc")
set_mirror <- function(repo = c("cran", "bioc", "all"),
                       mirror = "cran") {
  cli::cli_h1("🔄 Setting Mirror")

  repo <- match.arg(repo)

  mirrors <- list(
    cran        = "https://cloud.r-project.org",
    rstudio     = "https://cran.rstudio.com",
    tuna        = "https://mirrors.tuna.tsinghua.edu.cn/CRAN",
    ustc        = "https://mirrors.ustc.edu.cn/CRAN",
    aliyun      = "https://mirrors.aliyun.com/CRAN",
    sjtu        = "https://mirror.sjtu.edu.cn/CRAN",
    pku         = "https://mirrors.pku.edu.cn/CRAN",
    hku         = "https://mirror.hku.hk/CRAN",
    westlake    = "https://mirrors.westlake.edu.cn/CRAN",

    # Bioconductor mirrors
    bioc_tuna     = "https://mirrors.tuna.tsinghua.edu.cn/bioconductor",
    bioc_ustc     = "https://mirrors.ustc.edu.cn/bioconductor",
    bioc_westlake = "https://mirrors.westlake.edu.cn/bioconductor"
  )

  # Detect custom URL
  url <- ifelse(mirror %in% names(mirrors), mirrors[[mirror]], mirror)

  # Set mirror
  if (repo %in% c("cran", "all")) options(repos = c(CRAN = url))
  if (repo %in% c("bioc", "all")) options(BioC_mirror = url)

  # ✅ CLI styled output
  cli::cli_alert_success("Successfully switched {.field {repo}} mirror to: {.url {url}}")

  available <- switch(repo,
    cran = names(mirrors)[!grepl("^bioc_", names(mirrors))],
    bioc = names(mirrors)[grepl("^bioc_", names(mirrors))],
    all  = names(mirrors)
  )

  cli::cli_alert_info(
    "Available mirrors for {.field {repo}}: {paste(available, collapse = ', ')}"
  )
}
