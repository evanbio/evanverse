#' ⏱️ Wrap a function to measure and display execution time
#'
#' This utility wraps a function with CLI-based timing and displays its runtime in seconds.
#' It is especially useful for benchmarking or logging time-consuming tasks.
#'
#' @param fn A function to be wrapped
#' @param name A short descriptive name of the task (used in log output)
#'
#' @return A new function that executes `fn(...)` and prints timing information
#' @export
#'
#' @details
#' This function requires the `cli` and `tictoc` packages.
#'
#' @examples
#' slow_fn <- function(n) { Sys.sleep(0.2); n^2 }
#' timed_fn <- with_timer(slow_fn, name = "Square Task")
#' timed_fn(5)
with_timer <- function(fn, name = "Task") {
  stopifnot(is.function(fn))

  if (!requireNamespace("cli", quietly = TRUE) || !requireNamespace("tictoc", quietly = TRUE)) {
    stop("Packages 'cli' and 'tictoc' are required for `with_timer()`.")
  }

  function(...) {
    cli::cli_h1("{name} started at {Sys.time()}")
    tictoc::tic()
    result <- fn(...)
    timing <- tictoc::toc(quiet = TRUE)
    elapsed <- as.numeric(timing$toc - timing$tic, units = "secs")
    cli::cli_alert_success("{name} completed in {.val {sprintf('%.3f', elapsed)}} seconds")
    invisible(result)
  }
}
