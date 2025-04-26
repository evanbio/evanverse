# R/safe_execute.R
#-------------------------------------------------------------------------------
# Safely Execute an Expression with Unified Error Handling
#-------------------------------------------------------------------------------
#
# Background:
# Provides a unified wrapper around tryCatch() to catch and handle errors
# gracefully during code execution. This prevents pipeline interruptions and
# ensures consistent warning reporting.
#
# Parameters:
# - expr         : Code expression to be evaluated.
# - fail_message : Message to display if an error occurs (default: "An error occurred").
# - quiet        : Logical, whether to suppress warning messages (default: FALSE).
#
# Returns:
# - Result of the evaluated expression if successful.
# - NULL if evaluation fails.
#-------------------------------------------------------------------------------

#' Safely Execute an Expression
#'
#' Provides a unified error-handling wrapper for evaluating code expressions.
#'
#' @param expr Code to evaluate.
#' @param fail_message Message to display if an error occurs. Default is "An error occurred".
#' @param quiet Logical. If TRUE, suppress warning messages. Default is FALSE.
#'
#' @return The result of the expression if successful; otherwise NULL.
#' @export
#'
#' @examples
#' safe_execute(log(1))
#' safe_execute(log("a"), fail_message = "Failed to compute log")
safe_execute <- function(expr, fail_message = "An error occurred", quiet = FALSE) {
  tryCatch(
    expr,
    error = function(e) {
      if (!quiet) {
        cli::cli_alert_warning("{fail_message}: {e$message}")
      }
      NULL
    }
  )
}
