#' compile_palettes(): Compile JSON palettes into RDS
#'
#' Read JSON files under `palettes_dir/`, validate content, and compile into a structured RDS file.
#'
#' @param palettes_dir Character. Folder containing subdirs: sequential/, diverging/, qualitative/ (required)
#' @param output_rds Character. Path to save compiled RDS file (required). Use tempdir() for examples/tests.
#' @param log Logical. Whether to log compilation events. Default: TRUE
#'
#' @return Invisibly returns RDS file path (character)
#'
#' @examples
#' \donttest{
#' # Compile palettes using temporary directory:
#' compile_palettes(
#'   palettes_dir = system.file("extdata", "palettes", package = "evanverse"),
#'   output_rds = file.path(tempdir(), "palettes.rds")
#' )
#' }
#'
#' @export
compile_palettes <- function(palettes_dir,
                             output_rds,
                             log = TRUE) {

  # ===========================================================================
  # Dependency and Parameter Validation Phase
  # ===========================================================================

  # Validate palettes_dir (required parameter)
  if (missing(palettes_dir) || is.null(palettes_dir) || !is.character(palettes_dir) || length(palettes_dir) != 1) {
    cli::cli_abort("'palettes_dir' must be specified. Use tempdir() for examples/tests.")
  }

  # Validate output_rds (required parameter)
  if (missing(output_rds) || is.null(output_rds) || !is.character(output_rds) || length(output_rds) != 1) {
    cli::cli_abort("'output_rds' must be specified. Use tempdir() for examples/tests.")
  }

  # Check if palettes_dir exists
  if (!dir.exists(palettes_dir)) {
    cli::cli_abort("Palettes directory does not exist: {.path {palettes_dir}}")
  }

  cli::cli_h1("Compiling Color Palettes (JSON -> RDS)")

  # ===========================================================================
  # File Discovery Phase
  # ===========================================================================

  # Locate JSON palette files
  json_files <- unlist(lapply(
    c("sequential", "diverging", "qualitative"),
    function(type) list.files(
      file.path(palettes_dir, type),
      pattern = "\\.json$",
      full.names = TRUE
    )
  ))

  if (length(json_files) == 0) {
    cli::cli_alert_warning("No JSON files found under {.path {palettes_dir}}")
    return(invisible(NULL))
  }

  # ===========================================================================
  # Initialization Phase
  # ===========================================================================

  # Initialize empty palette container
  palettes <- list(
    sequential = list(),
    diverging = list(),
    qualitative = list()
  )

  # Prepare logging
  log_path <- file.path(tempdir(), "logs", "palettes", "compile_palettes.log")
  if (log) dir.create(dirname(log_path), recursive = TRUE, showWarnings = FALSE)
  log_lines <- c(sprintf("\n=== [%s] Compilation started ===", Sys.time()))

  # ===========================================================================
  # JSON Parsing and Validation Phase
  # ===========================================================================

  # Loop through each JSON palette
  for (json_file in json_files) {
    palette_info <- tryCatch(
      jsonlite::fromJSON(json_file),
      error = function(e) NULL
    )

    if (is.null(palette_info)) {
      msg <- sprintf("Failed to parse JSON: %s", json_file)
      cli::cli_alert_warning(msg)
      if (log) log_lines <- c(log_lines, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    # Check for required fields
    required <- c("name", "type", "colors")
    missing <- setdiff(required, names(palette_info))
    if (length(missing) > 0) {
      msg <- sprintf("Missing fields (%s) in: %s",
                     paste(missing, collapse = ", "), json_file)
      cli::cli_alert_warning(msg)
      if (log) log_lines <- c(log_lines, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    type   <- palette_info$type
    name   <- palette_info$name
    colors <- palette_info$colors

    # Check type validity
    if (!type %in% names(palettes)) {
      msg <- sprintf("Unknown type '%s', skipping: %s", type, json_file)
      cli::cli_alert_warning(msg)
      if (log) log_lines <- c(log_lines, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    # HEX validation
    if (!all(grepl("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", colors))) {
      msg <- sprintf("Invalid HEX codes in: %s", json_file)
      cli::cli_alert_warning(msg)
      if (log) log_lines <- c(log_lines, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    # Duplicate handling
    if (name %in% names(palettes[[type]])) {
      cli::cli_alert_warning("Duplicate palette '{name}' in '{type}', will overwrite.")
      log_lines <- c(log_lines,
                     sprintf("[%s] Warning: Duplicate palette '%s' in '%s'", Sys.time(), name, type))
    }

    palettes[[type]][[name]] <- colors

    msg <- sprintf("Added '%s' (Type: %s, %d colors)", name, type, length(colors))
    cli::cli_alert_success(msg)
    log_lines <- c(log_lines, sprintf("[%s] Success: %s", Sys.time(), msg))
  }

  # ===========================================================================
  # Save to RDS Phase
  # ===========================================================================

  dir.create(dirname(output_rds), recursive = TRUE, showWarnings = FALSE)

  tryCatch({
    saveRDS(palettes, file = output_rds)
    msg <- sprintf("Saved RDS: %s", output_rds)
    cli::cli_alert_success(msg)
    log_lines <- c(log_lines, sprintf("[%s] Completed: %s", Sys.time(), msg))
  }, error = function(e) {
    msg <- sprintf("Failed to save RDS: %s", e$message)
    cli::cli_abort(msg)
  })

  # ===========================================================================
  # Summary and Logging Phase
  # ===========================================================================

  cli::cli_h2("Compilation Summary")
  cli::cli_alert_info("Sequential:   {length(palettes$sequential)}")
  cli::cli_alert_info("Diverging:    {length(palettes$diverging)}")
  cli::cli_alert_info("Qualitative:  {length(palettes$qualitative)}")

  # Write log file
  if (log) {
    writeLines(log_lines, con = log_path)
    cli::cli_alert_info("Log written to: {log_path}")
  }

  cli::cli_alert_success("All palettes compiled successfully!")

  invisible(output_rds)
}
