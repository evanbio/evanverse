#' Comprehensive Forest Plot Dataset
#'
#' A comprehensive dataset for demonstrating advanced forest plot functionality.
#' Contains multiple variable types (continuous, categorical, hierarchical),
#' multi-model comparisons, sample sizes, and color grouping information.
#'
#' @format A data frame with 33 rows and 15 columns:
#' \describe{
#'   \item{variable}{Character vector of variable names and group headers}
#'   \item{est}{Numeric vector of effect estimates (Model 1 or single model)}
#'   \item{lower}{Numeric vector of lower confidence limits (Model 1)}
#'   \item{upper}{Numeric vector of upper confidence limits (Model 1)}
#'   \item{pval}{Numeric vector of p-values (Model 1)}
#'   \item{est_2}{Numeric vector of effect estimates for Model 2 (NA for single-model rows)}
#'   \item{lower_2}{Numeric vector of lower confidence limits for Model 2}
#'   \item{upper_2}{Numeric vector of upper confidence limits for Model 2}
#'   \item{pval_2}{Numeric vector of p-values for Model 2}
#'   \item{est_3}{Numeric vector of effect estimates for Model 3}
#'   \item{lower_3}{Numeric vector of lower confidence limits for Model 3}
#'   \item{upper_3}{Numeric vector of upper confidence limits for Model 3}
#'   \item{pval_3}{Numeric vector of p-values for Model 3}
#'   \item{n_total}{Numeric vector of total sample sizes}
#'   \item{n_event}{Numeric vector of event counts}
#'   \item{event_pct}{Numeric vector of event percentages}
#'   \item{color_id}{Character vector of color group identifiers for visualization}
#'   \item{note}{Character vector of notes and model descriptions}
#' }
#' @details
#' This dataset demonstrates various forest plot scenarios:
#' \itemize{
#'   \item Continuous variables (Age, BMI)
#'   \item Categorical variables with subgroups (Sex, BMI category, Treatment)
#'   \item Multi-level hierarchical structures
#'   \item Multi-model comparisons (Models 1-3 for last 3 rows)
#'   \item Sample size and event information
#'   \item Color grouping for enhanced visualizations
#' }
#'
#' @source Created for testing and demonstration of plot_forest() functionality.
#' @name forest_data
#' @docType data
#' @keywords datasets
NULL

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
#' @name trial
#' @docType data
#' @keywords datasets
NULL
