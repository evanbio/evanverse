#' list_palettes(): List All Color Palettes from RDS
#'
#' Load and list all available color palettes compiled into an RDS file.
#'
#' @param palette_rds Path to the RDS file. Default: `"inst/extdata/palettes.rds"`.
#' @param type Palette type(s) to filter: `"sequential"`, `"diverging"`, `"qualitative"`. Default: all.
#' @param sort Whether to sort by type, n_color, name. Default: TRUE.
#' @param verbose Whether to print listing details to console. Default: TRUE.
#'
#' @return A `data.frame` with columns: `name`, `type`, `n_color`, `colors`.
#' @export
#'
#' @examples
#' list_palettes()
#' list_palettes(type = "qualitative")
#' list_palettes(type = c("sequential", "diverging"))
list_palettes <- function(palette_rds = system.file("extdata", "palettes.rds", package = "evanverse"),
                          type = c("sequential", "diverging", "qualitative"),
                          sort = TRUE,
                          verbose = TRUE) {

  type <- match.arg(type, several.ok = TRUE)

  # ===========================================================================
  # Check file
  # ===========================================================================
  if (!file.exists(palette_rds)) {
    cli::cli_alert_danger("Palette file not found: {.path {palette_rds}}")
    return(invisible(data.frame(
      name = character(),
      type = character(),
      n_color = integer(),
      colors = I(list()),
      stringsAsFactors = FALSE
    )))
  }

  # ===========================================================================
  # Load data
  # ===========================================================================
  palettes <- tryCatch(readRDS(palette_rds), error = function(e) {
    cli::cli_alert_danger("Failed to read RDS: {e$message}")
    stop(e)
  })

  matched_types <- intersect(type, names(palettes))

  if (length(matched_types) == 0) {
    cli::cli_alert_warning("No matching types in RDS. Available: {paste(names(palettes), collapse = ', ')}")
    return(invisible(data.frame(
      name = character(),
      type = character(),
      n_color = integer(),
      colors = I(list()),
      stringsAsFactors = FALSE
    )))
  }

  # ===========================================================================
  # Build palette info list
  # ===========================================================================
  palette_df <- purrr::map_dfr(matched_types, function(t) {
    pset <- palettes[[t]]
    if (length(pset) == 0) return(NULL)

    purrr::map2_dfr(names(pset), pset, function(nm, col) {
      tibble::tibble(
        name = nm,
        type = t,
        n_color = length(col),
        colors = list(col)
      )
    })
  })

  # convert to base data.frame for consistency
  palette_df <- as.data.frame(palette_df, stringsAsFactors = FALSE)

  # ===========================================================================
  # Sort if requested
  # ===========================================================================
  if (sort) {
    palette_df <- palette_df[order(palette_df$type, palette_df$n_color, palette_df$name), ]
  }

  # ===========================================================================
  # Display (optional)
  # ===========================================================================
  if (verbose) {
    cli::cli_h1("Available Color Palettes")
    cli::cli_alert_info("Total palettes: {nrow(palette_df)}")

    type_counts <- table(palette_df$type)
    purrr::walk(names(type_counts), ~{
      cli::cli_alert_info("Type {.strong {.val {.x}}}: {type_counts[.x]} palettes")
    })

    cli::cli_text("")  # 空行分隔
    cli::cli_ul()
    purrr::walk(seq_len(nrow(palette_df)), function(i) {
      cli::cli_li("{.strong {palette_df$name[i]}} ({palette_df$type[i]}) - {palette_df$n_color[i]} colors")
    })
    cli::cli_end()
  }

  return(palette_df)
}
