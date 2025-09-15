#' Set CRAN/Bioconductor Mirrors
#'
#' Switch CRAN and/or Bioconductor mirrors for faster package installation.
#'
#' @param repo Character. Repository type: "cran", "bioc", or "all" (default: "all").
#' @param mirror Character. Predefined mirror name (default: "tuna").
#' 
#' @return Previous mirror settings (invisibly)
#' @export
#'
#' @examples
#' \dontrun{
#' set_mirror()  # Use default: all repos with tuna mirror
#' set_mirror("cran", "westlake")
#' set_mirror("bioc", "ustc")
#' }
set_mirror <- function(repo = c("all", "cran", "bioc"),
                       mirror = "tuna") {
  
  # ========== 1. Parameter Validation ==========
  repo <- match.arg(repo)
  
  # ========== 2. Save Current Settings ==========
  old_settings <- list(
    repos = getOption("repos"),
    BioC_mirror = getOption("BioC_mirror")
  )
  
  # ========== 3. Mirror Repository ==========
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
  
  # ========== 4. Validate Mirror Name ==========
  cli::cli_h2("Setting {.field {repo}} mirror")
  
  if (repo %in% c("cran", "all")) {
    if (!mirror %in% names(cran_mirrors)) {
      cli::cli_abort(
        "Unknown CRAN mirror: {.val {mirror}}. Available: {.val {names(cran_mirrors)}}"
      )
    }
  }
  
  if (repo %in% c("bioc", "all")) {
    if (!mirror %in% names(bioc_mirrors)) {
      cli::cli_abort(
        "Unknown Bioconductor mirror: {.val {mirror}}. Available: {.val {names(bioc_mirrors)}}"
      )
    }
  }
  
  # ========== 5. Apply Mirror Settings ==========
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
  
  # ========== 6. Display Available Options ==========
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
  
  # ========== 7. Return Previous Settings ==========
  invisible(old_settings)
}
