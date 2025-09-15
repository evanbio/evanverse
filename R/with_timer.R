#' Wrap a function to measure and display execution time
#'
#' Wraps a function with CLI-based timing and prints its runtime in seconds.
#' Useful for benchmarking or logging time-consuming tasks.
#'
#' @param fn A function to be wrapped.
#' @param name A short descriptive name of the task (used in log output).
#'
#' @return A function that executes `fn(...)` and prints timing information (returns invisibly).
#' @details Requires the `tictoc` package (CLI messages are emitted via `cli`).
#' @export
#'
#' @examples
#' slow_fn <- function(n) { Sys.sleep(0.2); n^2 }
#' timed_fn <- with_timer(slow_fn, name = "Square Task")
#' timed_fn(5)
with_timer <- function(fn, name = "Task") {

  # ===========================================================================
  # Input validation
  # ===========================================================================
  if (!is.function(fn)) {
    cli::cli_abort("'fn' must be a function.")
  }
  # Ensure 'tictoc' is available
  if (!requireNamespace("tictoc", quietly = TRUE)) {
    cli::cli_abort("Package 'tictoc' is required for with_timer().")
  }

  # ===========================================================================
  # Wrapper
  # ===========================================================================
  function(...) {
    cli::cli_alert_info("{name} started at {format(Sys.time(), '%Y-%m-%d %H:%M:%S')}")
    tictoc::tic()
    result <- fn(...)
    timing <- tictoc::toc(quiet = TRUE)
    elapsed <- as.numeric(timing$toc - timing$tic, units = "secs")
    cli::cli_alert_success("{name} completed in {sprintf('%.3f', elapsed)} seconds")
    invisible(result)
  }
}
