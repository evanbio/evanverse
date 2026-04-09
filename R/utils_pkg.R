# =============================================================================
# utils_pkg.R — Internal helpers for the package management module
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

