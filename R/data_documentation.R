#' Test Dataset for Forest Plots
#'
#' A sample dataset used for demonstrating and testing forest plot functionality.
#' Contains example effect sizes, confidence intervals, and study information.
#'
#' @format A data frame with 12 rows and 5 columns:
#' \describe{
#'   \item{variable}{Character vector of variable names}
#'   \item{estimate}{Numeric vector of effect estimates}
#'   \item{conf.low}{Numeric vector of lower confidence limits}
#'   \item{conf.high}{Numeric vector of upper confidence limits}
#'   \item{p.value}{Numeric vector of p-values}
#' }
#' @source Created for testing and demonstration purposes.
"df_forest_test"

#' Clinical Trial Dataset
#'
#' A sample clinical trial dataset used for testing and demonstration of data analysis functions.
#' Contains typical clinical trial variables for testing various statistical and visualization functions.
#'
#' @format A data frame with 200 rows and 8 columns:
#' \describe{
#'   \item{trt}{Character vector of treatment assignments}
#'   \item{age}{Numeric vector of patient ages}
#'   \item{marker}{Numeric vector of biomarker levels}
#'   \item{stage}{Factor with tumor stage levels}
#'   \item{grade}{Factor with tumor grade levels}
#'   \item{response}{Integer vector indicating tumor response}
#'   \item{death}{Integer vector indicating patient death}
#'   \item{ttdeath}{Numeric vector of time to death/censoring}
#' }
#' @source Created for testing and demonstration purposes.
"trial"
