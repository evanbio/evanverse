# Wrap a function to measure and display execution time

Wraps a function with CLI-based timing and prints its runtime in
seconds. Useful for benchmarking or logging time-consuming tasks.

## Usage

``` r
with_timer(fn, name = "Task")
```

## Arguments

- fn:

  A function to be wrapped.

- name:

  A short descriptive name of the task (used in log output).

## Value

A function that executes `fn(...)` and prints timing information
(returns invisibly).

## Details

Requires the `tictoc` package (CLI messages are emitted via `cli`).

## Examples

``` r
slow_fn <- function(n) { Sys.sleep(0.01); n^2 }
timed_fn <- with_timer(slow_fn, name = "Square Task")
timed_fn(5)
#> ℹ Square Task started at 2025-11-25 06:07:49
#> ✔ Square Task completed in 0.011 seconds
```
