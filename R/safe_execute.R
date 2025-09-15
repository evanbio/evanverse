#' Safely Execute an Expression
#'
#' Evaluate code with unified error handling (and consistent warning reporting).
#' On error, prints a CLI message (unless `quiet = TRUE`) and returns `NULL`.
#'
#' @param expr Code to evaluate.
#' @param fail_message Message to display if an error occurs. Default: "An error occurred".
#' @param quiet Logical. If `TRUE`, suppress messages. Default: `FALSE`.
#'
#' @return The result of the expression if successful; otherwise `NULL`.
#' @export
#'
#' @examples
#' safe_execute(log(1))
#' safe_execute(log("a"), fail_message = "Failed to compute log")
safe_execute <- function(expr, fail_message = "An error occurred", quiet = FALSE) {
  expr_ <- substitute(expr)

  # Handle warnings consistently (do not interrupt; optionally print)
  w_handler <- function(w) {
    if (!quiet) cli::cli_alert_warning("{conditionMessage(w)}")
    invokeRestart("muffleWarning")
  }

  tryCatch(
    withCallingHandlers(
      eval(expr_, envir = parent.frame()),
      warning = w_handler
    ),
    error = function(e) {
      if (!quiet) cli::cli_alert_danger("{fail_message}: {conditionMessage(e)}")
      NULL
    }
  )
}
