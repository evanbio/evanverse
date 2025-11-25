# ==============================================================================
# plot_forest.R - Forest plot function (Refactored)
# ==============================================================================


# ==============================================================================
# Main function: plot_forest()
# ==============================================================================

#' @title Forest Plot with Advanced Customization
#' @name plot_forest
#'
#' @description
#' Create publication-ready forest plots with extensive customization for
#' confidence intervals, themes, colors, borders, and layout. Designed for
#' meta-analysis and comparative study visualizations.
#'
#' @param data Data frame containing the plot data (both text and numeric columns).
#' @param est List of numeric vectors containing effect estimates. Use \code{list()}
#'   even for single group. Example: \code{list(data$estimate)} or
#'   \code{list(data$estimate_1, data$estimate_2)}.
#' @param lower List of numeric vectors containing lower CI bounds.
#' @param upper List of numeric vectors containing upper CI bounds.
#' @param ci_column Integer vector specifying which column(s) to draw CI graphics.
#'   Example: \code{c(3)} for single group, \code{c(3, 7)} for two groups.
#' @param ref_line Numeric. Reference line position (e.g., 1 for OR, 0 for
#'   mean difference). Default: 1.
#' @param xlim Numeric vector of length 2. X-axis limits. Default: \code{NULL} (auto-calculate).
#' @param ticks_at Numeric vector. X-axis tick positions. Default: \code{NULL} (auto-calculate).
#' @param arrow_lab Character vector of length 2. Labels for left and right arrows.
#'   Example: \code{c("Favors A", "Favors B")}. Default: \code{NULL}.
#' @param sizes Numeric. Size of CI center points. Can be:
#'   \itemize{
#'     \item Single value: Automatically applied to all rows (e.g., \code{0.6})
#'     \item Vector: Must match the number of data rows. If length is insufficient,
#'       later rows will have no CI displayed. To repeat a pattern, use
#'       \code{rep(c(0.5, 0.4, 0.3), length.out = nrow(data))}.
#'   }
#'   Default: 0.6.
#'
#' @param theme_preset Character. Theme preset name. Default: \code{"default"}.
#'   See \code{.get_forest_theme()} for available presets.
#' @param theme_custom List. Custom theme parameters to override preset. Default: \code{NULL}.
#' @param align_left Integer vector. Columns to left-align. Default: \code{NULL}.
#' @param align_center Integer vector. Columns to center-align. Default: \code{NULL}.
#' @param align_right Integer vector. Columns to right-align. Default: \code{NULL}.
#' @param bold_group Character vector. Group names to bold. Default: \code{NULL}.
#' @param bold_group_col Integer. Column containing group names. Default: 1.
#' @param bold_pvalue_cols Integer vector. P-value columns to bold if significant. Default: \code{NULL}.
#' @param p_threshold Numeric. P-value threshold for bolding. Default: 0.05.
#' @param bold_custom List of custom bold specifications. Default: \code{NULL}.
#' @param background_style Character. Background style: \code{"none"}, \code{"zebra"},
#'   \code{"group"}, \code{"block"}. Default: \code{"none"}.
#' @param background_group_rows Integer vector. Row indices of group headers (for
#'   \code{"group"} and \code{"block"} styles). Default: \code{NULL}.
#' @param background_colors Named list of colors (primary, secondary, alternate). Default: \code{NULL}.
#' @param ci_colors Color specification for CI boxes. Can be single color, vector,
#'   or named list with mapping. Default: \code{NULL}.
#' @param ci_group_ids Optional vector of group IDs for color mapping. Default: \code{NULL}.
#' @param add_borders Logical. Add simple borders. Default: \code{TRUE}.
#' @param border_width Numeric. Border line width (mm). Default: 3.
#' @param group_headers List of group header specifications for multi-group plots. Default: \code{NULL}.
#' @param group_border_width Numeric. Border width for group mode (mm). Default: 6.
#' @param custom_borders List of custom border specifications. Default: \code{NULL}.
#' @param nudge_y Numeric. Vertical nudge for multi-group CI positioning. Default: 0.2.
#' @param height_top Numeric. Top margin height (mm). Default: 8.
#' @param height_header Numeric. Header row height (mm). Default: 12.
#' @param height_main Numeric. Data row height (mm). Default: 10.
#' @param height_bottom Numeric. Bottom margin height (mm). Default: 8.
#' @param width_left Numeric. Left margin width (mm). Default: 10.
#' @param width_right Numeric. Right margin width (mm). Default: 10.
#' @param width_adjust Numeric. Width adjustment for data columns (mm). Default: 5.
#' @param height_custom Named list for manual height override. Default: \code{NULL}.
#' @param width_custom Named list for manual width override. Default: \code{NULL}.
#' @param layout_verbose Logical. Print layout adjustment info. Default: \code{TRUE}.
#' @param save_plot Logical. Save plot to file(s). Default: \code{FALSE}.
#' @param filename Character. Base filename (without extension). Default: \code{"forest_plot"}.
#' @param save_path Character. Directory path for saving. Default: \code{"."}.
#' @param save_formats Character vector. File formats to save. Default: \code{c("png", "pdf")}.
#' @param save_width Numeric. Plot width. Default: 35.
#' @param save_height Numeric. Plot height. Default: 42.
#' @param save_units Character. Units for width/height. Default: \code{"cm"}.
#' @param save_dpi Numeric. Resolution for raster formats. Default: 300.
#' @param save_bg Character. Background color. Default: \code{"white"}.
#' @param save_overwrite Logical. Overwrite existing files. Default: \code{TRUE}.
#' @param save_verbose Logical. Print save messages. Default: \code{TRUE}.
#'
#' @return A forest plot object (gtable). Can be displayed with \code{print()} or
#'   \code{grid.draw()}. The object contains the complete plot structure and can
#'   be saved using the built-in save functionality or standard ggplot2 methods.
#'
#' @details
#' \strong{Core Workflow:}
#'
#' The function creates a base forest plot using the \pkg{forestploter} package,
#' then applies a series of customizations:
#' \enumerate{
#'   \item Theme application (presets or custom)
#'   \item Text alignment adjustments
#'   \item Bold formatting for groups and significant p-values
#'   \item Background colors (zebra, group, or block patterns)
#'   \item CI box colors (single, vector, or mapped)
#'   \item Border additions (simple, group, or custom)
#'   \item Layout adjustments (widths and heights)
#'   \item Optional file saving
#' }
#'
#' \strong{CI Color Mapping:}
#'
#' The \code{ci_colors} parameter accepts three formats:
#' \itemize{
#'   \item \strong{Single color}: Applied to all rows (e.g., \code{"#E64B35"})
#'   \item \strong{Color vector}: Must match the number of rows
#'   \item \strong{Named list with mapping}: Maps group IDs to colors
#' }
#'
#' Example of named mapping:
#' \preformatted{
#' ci_colors = list(
#'   mapping = c("Q1" = "#DC0000", "Q2" = "#8491B4", "Q3" = "#F39B7F"),
#'   default = "#999999"
#' )
#' }
#'
#' @section Important Notes:
#' \itemize{
#'   \item \strong{Data preparation}: The \code{data} parameter should contain all
#'     display columns including pre-formatted text
#'   \item \strong{CI graphics}: Use \code{strrep(" ", n)} to create space columns
#'     where CI graphics will be drawn
#'   \item \strong{Layout tuning}: Use \code{height_custom} and \code{width_custom}
#'     after inspecting verbose output for fine-grained control
#' }
#'
#' @examples
#' \dontrun{
#' # Example 1: Using built-in forest_data
#' library(dplyr)
#' library(evanverse)
#'
#' # Load example data
#' data("forest_data")
#'
#' # Filter to single-model data (rows without est_2)
#' df <- forest_data %>%
#'   filter(is.na(est_2)) %>%
#'   filter(!is.na(est))  # Remove header rows
#'
#' # Prepare display data
#' plot_data <- df %>%
#'   mutate(
#'     ` ` = strrep(" ", 20),
#'     `OR (95% CI)` = sprintf("%.2f (%.2f-%.2f)", est, lower, upper),
#'     `P` = ifelse(pval < 0.001, "<0.001", sprintf("%.3f", pval))
#'   ) %>%
#'   select(Variable = variable, ` `, `OR (95% CI)`, `P`)
#'
#' # Create plot
#' p <- plot_forest(
#'   data = plot_data,
#'   est = list(df$est),
#'   lower = list(df$lower),
#'   upper = list(df$upper),
#'   ci_column = 2,
#'   ref_line = 1
#' )
#' print(p)
#'
#' # Example 2: Multi-model comparison
#' df_multi <- forest_data %>%
#'   filter(!is.na(est_2))  # Multi-model rows
#'
#' plot_data_multi <- df_multi %>%
#'   mutate(
#'     ` ` = strrep(" ", 20),
#'     `Model 1` = sprintf("%.2f (%.2f-%.2f)", est, lower, upper),
#'     `Model 2` = sprintf("%.2f (%.2f-%.2f)", est_2, lower_2, upper_2),
#'     `Model 3` = sprintf("%.2f (%.2f-%.2f)", est_3, lower_3, upper_3)
#'   ) %>%
#'   select(Variable = variable, ` `, `Model 1`, `Model 2`, `Model 3`)
#'
#' p <- plot_forest(
#'   data = plot_data_multi,
#'   est = list(df_multi$est, df_multi$est_2, df_multi$est_3),
#'   lower = list(df_multi$lower, df_multi$lower_2, df_multi$lower_3),
#'   upper = list(df_multi$upper, df_multi$upper_2, df_multi$upper_3),
#'   ci_column = 2,
#'   ref_line = 1
#' )
#'
#' # Example 3: Customized styling
#' p <- plot_forest(
#'   data = plot_data,
#'   est = list(df$est),
#'   lower = list(df$lower),
#'   upper = list(df$upper),
#'   ci_column = 2,
#'   xlim = c(0.5, 3),
#'   arrow_lab = c("Lower Risk", "Higher Risk"),
#'   align_left = 1,
#'   align_center = c(2, 3, 4),
#'   bold_pvalue_cols = 4,
#'   background_style = "zebra"
#' )
#'
#' # Example 4: Save to files
#' plot_forest(
#'   data = plot_data,
#'   est = list(df$est),
#'   lower = list(df$lower),
#'   upper = list(df$upper),
#'   ci_column = 2,
#'   save_plot = TRUE,
#'   filename = "forest_plot",
#'   save_formats = c("png", "pdf")
#' )
#' }
#'
#' @seealso
#' \code{\link[forestploter]{forest}} for the underlying plotting function,
#' \code{\link[forestploter]{forest_theme}} for theme customization.
#'
#' @importFrom utils modifyList
#' @export
plot_forest <- function(
  # Core forest plot parameters
  data,
  est,
  lower,
  upper,
  ci_column,
  ref_line = 1,
  xlim = NULL,
  ticks_at = NULL,
  arrow_lab = NULL,
  sizes = 0.6,
  nudge_y = 0.2,

  # Theme parameters
  theme_preset = "default",
  theme_custom = NULL,

  # Alignment parameters
  align_left = NULL,
  align_center = NULL,
  align_right = NULL,

  # Bold formatting parameters
  bold_group = NULL,
  bold_group_col = 1,
  bold_pvalue_cols = NULL,
  p_threshold = 0.05,
  bold_custom = NULL,

  # Background parameters
  background_style = "none",
  background_group_rows = NULL,
  background_colors = NULL,

  # CI color parameters
  ci_colors = NULL,
  ci_group_ids = NULL,

  # Border parameters
  add_borders = TRUE,
  border_width = 3,
  group_headers = NULL,
  group_border_width = 6,
  custom_borders = NULL,

  # Layout adjustment parameters
  height_top = 8,
  height_header = 12,
  height_main = 10,
  height_bottom = 8,
  width_left = 10,
  width_right = 10,
  width_adjust = 5,
  height_custom = NULL,
  width_custom = NULL,
  layout_verbose = TRUE,

  # Save parameters
  save_plot = FALSE,
  filename = "forest_plot",
  save_path = ".",
  save_formats = c("png", "pdf"),
  save_width = 35,
  save_height = 42,
  save_units = "cm",
  save_dpi = 300,
  save_bg = "white",
  save_overwrite = TRUE,
  save_verbose = TRUE
) {

  # ===========================================================================
  # Step 1: Theme Configuration
  # ===========================================================================

  # Reason: Apply theme first to establish base styling for all plot elements
  # before building the forest plot structure
  if (!is.null(theme_custom)) {
    theme <- do.call(.get_forest_theme, c(list(preset = theme_preset), theme_custom))
  } else {
    theme <- .get_forest_theme(preset = theme_preset)
  }

  # ===========================================================================
  # Step 2: Create Base Forest Plot
  # ===========================================================================

  # Auto-generate ticks_at if only xlim is provided
  # Reason: Prevent forestploter from only showing integer ticks
  if (!is.null(xlim) && is.null(ticks_at)) {
    # Generate 5 evenly spaced ticks between xlim boundaries
    ticks_at <- seq(xlim[1], xlim[2], length.out = 5)
  }

  p <- forestploter::forest(
    data = data,
    est = est,
    lower = lower,
    upper = upper,
    ci_column = ci_column,
    ref_line = ref_line,
    xlim = xlim,
    ticks_at = ticks_at,
    arrow_lab = arrow_lab,
    sizes = sizes,
    nudge_y = nudge_y,
    theme = theme
  )

  # ===========================================================================
  # Step 3: Text Alignment
  # ===========================================================================

  if (!is.null(align_left) || !is.null(align_center) || !is.null(align_right)) {
    p <- .apply_alignment(
      plot = p,
      align_left = align_left,
      align_center = align_center,
      align_right = align_right
    )
  }

  # ===========================================================================
  # Step 4: Bold Formatting
  # ===========================================================================

  if (!is.null(bold_group) || !is.null(bold_pvalue_cols) || !is.null(bold_custom)) {
    p <- .apply_bold(
      plot = p,
      data = data,
      bold_group = bold_group,
      bold_group_col = bold_group_col,
      bold_pvalue_cols = bold_pvalue_cols,
      p_threshold = p_threshold,
      bold_custom = bold_custom
    )
  }

  # ===========================================================================
  # Step 5: Background Colors
  # ===========================================================================

  if (background_style != "none") {
    p <- .apply_background(
      plot = p,
      n_rows = nrow(data),
      n_cols = ncol(data),
      style = background_style,
      group_rows = background_group_rows,
      colors = background_colors
    )
  }

  # ===========================================================================
  # Step 6: CI Colors
  # ===========================================================================

  if (!is.null(ci_colors)) {
    # Reason: Apply colors to each CI column separately to support multi-group
    # forest plots where different groups need different color schemes
    for (col_idx in ci_column) {
      p <- .apply_ci_colors(
        plot = p,
        colors = ci_colors,
        ci_column = col_idx,
        n_rows = nrow(data),
        group_ids = ci_group_ids
      )
    }
  }

  # ===========================================================================
  # Step 7: Borders
  # ===========================================================================

  p <- .apply_borders(
    plot = p,
    n_rows = nrow(data),
    add_borders = add_borders,
    border_width = border_width,
    group_headers = group_headers,
    group_border_width = group_border_width,
    custom_borders = custom_borders
  )

  # ===========================================================================
  # Step 8: Layout Adjustments
  # ===========================================================================

  p <- .adjust_layout(
    plot = p,
    height_top = height_top,
    height_header = height_header,
    height_main = height_main,
    height_bottom = height_bottom,
    width_left = width_left,
    width_right = width_right,
    width_adjust = width_adjust,
    height_custom = height_custom,
    width_custom = width_custom,
    verbose = layout_verbose
  )

  # ===========================================================================
  # Step 9: Save Plot (Optional)
  # ===========================================================================

  if (save_plot) {
    .save_forest(
      plot = p,
      filename = filename,
      path = save_path,
      formats = save_formats,
      width = save_width,
      height = save_height,
      units = save_units,
      dpi = save_dpi,
      bg = save_bg,
      overwrite = save_overwrite,
      verbose = save_verbose
    )
  }

  return(p)
}


# ==============================================================================
# Internal Helper Functions
# ==============================================================================

#' Get Forest Plot Theme
#'
#' Internal function to retrieve or customize forest plot themes.
#'
#' @param preset Character. Theme preset name ("default").
#' @param ... Additional parameters to override theme defaults.
#'
#' @return A forest_theme object.
#'
#' @keywords internal
#' @noRd
.get_forest_theme <- function(preset = "default", ...) {

  # ===========================================================================
  # Theme Definitions
  # ===========================================================================

  themes <- list(

    # Default theme: balanced for general use
    default = list(
      base_size    = 12,
      base_family  = "sans",
      ci_pch       = 15,
      ci_lty       = 1,
      ci_lwd       = 3,
      ci_col       = "black",
      ci_alpha     = 1,
      ci_fill      = "black",
      ci_Theight   = 0.1,
      refline_gp   = grid::gpar(lwd = 2, lty = "dashed", col = "grey20"),
      xaxis_gp     = grid::gpar(fontsize = 12, fontfamily = "sans"),
      arrow_type   = "open",
      arrow_length = 0.1,
      arrow_gp     = grid::gpar(fontsize = 12, fontfamily = "sans", lwd = 2),
      xlab_adjust  = "center",
      xlab_gp      = grid::gpar(fontsize = 10, fontfamily = "sans", cex = 1, fontface = "plain")
    )

    # Additional themes will be added here
    # publication = list(...),
    # presentation = list(...),
    # poster = list(...),
    # compact = list(...)
  )

  # ===========================================================================
  # Validation and Theme Application
  # ===========================================================================

  # Validate preset exists
  if (!preset %in% names(themes)) {
    available <- paste(names(themes), collapse = ", ")
    cli::cli_abort(
      c(
        "Unknown theme preset: {.val {preset}}.",
        "i" = "Available presets: {available}"
      )
    )
  }

  # Get base theme parameters
  theme_params <- themes[[preset]]

  # Merge with custom parameters if provided
  custom_params <- list(...)
  if (length(custom_params) > 0) {
    # Reason: modifyList safely merges lists, allowing custom params to
    # override preset values while preserving unspecified defaults
    theme_params <- modifyList(theme_params, custom_params)
  }

  # Create forest_theme object
  do.call(forestploter::forest_theme, theme_params)
}


#' Apply Text Alignment
#'
#' Internal function to apply text alignment to forest plot columns.
#'
#' @param plot Forest plot object.
#' @param align_left Integer vector of column indices to left-align.
#' @param align_center Integer vector of column indices to center-align.
#' @param align_right Integer vector of column indices to right-align.
#'
#' @return Modified forest plot object.
#'
#' @keywords internal
#' @noRd
.apply_alignment <- function(plot,
                            align_left = NULL,
                            align_center = NULL,
                            align_right = NULL) {

  # Left alignment
  if (!is.null(align_left)) {
    for (col in align_left) {
      plot <- forestploter::edit_plot(
        plot, col = col, which = "text", part = "body",
        hjust = grid::unit(0, "npc"), x = grid::unit(0, "npc")
      )
      plot <- forestploter::edit_plot(
        plot, col = col, which = "text", part = "header",
        hjust = grid::unit(0, "npc"), x = grid::unit(0, "npc")
      )
    }
  }

  # Center alignment
  if (!is.null(align_center)) {
    for (col in align_center) {
      plot <- forestploter::edit_plot(
        plot, col = col, which = "text", part = "body",
        hjust = grid::unit(0.5, "npc"), x = grid::unit(0.5, "npc")
      )
      plot <- forestploter::edit_plot(
        plot, col = col, which = "text", part = "header",
        hjust = grid::unit(0.5, "npc"), x = grid::unit(0.5, "npc")
      )
    }
  }

  # Right alignment
  if (!is.null(align_right)) {
    for (col in align_right) {
      plot <- forestploter::edit_plot(
        plot, col = col, which = "text", part = "body",
        hjust = grid::unit(1, "npc"), x = grid::unit(1, "npc")
      )
      plot <- forestploter::edit_plot(
        plot, col = col, which = "text", part = "header",
        hjust = grid::unit(1, "npc"), x = grid::unit(1, "npc")
      )
    }
  }

  return(plot)
}


#' Apply Bold Formatting
#'
#' Internal function to apply bold formatting to forest plot text.
#'
#' @param plot Forest plot object.
#' @param data Plot data frame.
#' @param bold_group Character vector of group names to bold.
#' @param bold_group_col Column index for group names.
#' @param bold_pvalue_cols Column indices of P-value columns.
#' @param p_threshold P-value threshold for bolding.
#' @param bold_custom List of custom bold specifications.
#'
#' @return Modified forest plot object.
#'
#' @keywords internal
#' @noRd
.apply_bold <- function(plot,
                       data,
                       bold_group = NULL,
                       bold_group_col = 1,
                       bold_pvalue_cols = NULL,
                       p_threshold = 0.05,
                       bold_custom = NULL) {

  # 1. Bold group header rows
  if (!is.null(bold_group)) {
    group_rows <- which(data[[bold_group_col]] %in% bold_group)
    if (length(group_rows) > 0) {
      plot <- forestploter::edit_plot(
        plot,
        row = group_rows,
        col = bold_group_col,
        which = "text",
        gp = grid::gpar(fontface = "bold")
      )
    }
  }

  # 2. Bold significant P-values
  if (!is.null(bold_pvalue_cols)) {
    for (col_idx in bold_pvalue_cols) {
      # Get column data
      p_values <- data[[col_idx]]

      # Convert to numeric vector
      if (is.numeric(p_values)) {
        # Already numeric, use directly
        p_numeric <- p_values
      } else {
        # Character format, parse (e.g., "<0.001")
        p_numeric <- .parse_pvalue(p_values)
      }

      # Find significant rows (P < threshold)
      sig_rows <- which(!is.na(p_numeric) & p_numeric < p_threshold)

      # Bold these rows
      if (length(sig_rows) > 0) {
        for (row in sig_rows) {
          plot <- forestploter::edit_plot(
            plot,
            row = row,
            col = col_idx,
            which = "text",
            gp = grid::gpar(fontface = "bold")
          )
        }
      }
    }
  }

  # 3. Custom bold specifications
  if (!is.null(bold_custom)) {
    for (spec in bold_custom) {
      for (row in spec$rows) {
        for (col in spec$cols) {
          plot <- forestploter::edit_plot(
            plot,
            row = row,
            col = col,
            which = "text",
            gp = grid::gpar(fontface = "bold")
          )
        }
      }
    }
  }

  return(plot)
}


#' Parse P-value Strings
#'
#' Internal helper to parse P-value strings into numeric values.
#'
#' @param p_strings Character vector of P-value strings.
#' @return Numeric vector.
#'
#' @keywords internal
#' @noRd
.parse_pvalue <- function(p_strings) {
  p_numeric <- numeric(length(p_strings))

  for (i in seq_along(p_strings)) {
    str <- trimws(p_strings[i])

    if (is.na(str) || str == "") {
      p_numeric[i] <- NA
    } else {
      # Remove "<" or ">" symbols and extract numeric value
      # "<0.001" -> "0.001"
      # "0.023" -> "0.023"
      num_str <- gsub("^[<>]\\s*", "", str)
      p_numeric[i] <- suppressWarnings(as.numeric(num_str))
    }
  }

  return(p_numeric)
}


#' Apply Background Colors
#'
#' Internal function to apply background colors to forest plot.
#'
#' @param plot Forest plot object.
#' @param n_rows Number of data rows.
#' @param n_cols Number of columns.
#' @param style Background style ("none", "zebra", "group", "block").
#' @param group_rows Row indices of group headers.
#' @param colors Named list of colors (primary, secondary, alternate).
#'
#' @return Modified forest plot object.
#'
#' @keywords internal
#' @noRd
.apply_background <- function(plot,
                              n_rows,
                              n_cols,
                              style = "none",
                              group_rows = NULL,
                              colors = list(
                                primary = "#EAF3FA",
                                secondary = "white",
                                alternate = "#FCF5E4"
                              )) {

  # Validate style parameter
  valid_styles <- c("none", "zebra", "group", "block")
  if (!style %in% valid_styles) {
    cli::cli_abort(
      c(
        "Invalid background style: {.val {style}}.",
        "i" = "Must be one of: {.val {valid_styles}}"
      )
    )
  }

  # If no background, return as-is
  if (style == "none") {
    return(plot)
  }

  # Set default colors if not provided
  if (is.null(colors$primary)) colors$primary <- "#EAF3FA"
  if (is.null(colors$secondary)) colors$secondary <- "white"
  if (is.null(colors$alternate)) colors$alternate <- "#FCF5E4"

  # Get all row and column indices
  all_rows <- seq_len(n_rows)
  all_cols <- seq_len(n_cols)

  # Apply style
  if (style == "zebra") {
    # Zebra stripes: alternating rows
    odd_rows <- all_rows[all_rows %% 2 == 1]
    even_rows <- all_rows[all_rows %% 2 == 0]

    plot <- forestploter::edit_plot(
      plot,
      row = odd_rows,
      col = all_cols,
      which = "background",
      gp = grid::gpar(fill = colors$secondary, col = NA)
    )
    plot <- forestploter::edit_plot(
      plot,
      row = even_rows,
      col = all_cols,
      which = "background",
      gp = grid::gpar(fill = colors$alternate, col = NA)
    )

  } else if (style == "group") {
    # Group style: different colors for headers vs body
    if (is.null(group_rows) || length(group_rows) == 0) {
      cli::cli_warn("Style 'group' requires {.arg group_rows}. No background applied.")
      return(plot)
    }

    # Identify body rows (non-group rows)
    body_rows <- setdiff(all_rows, group_rows)

    # Apply colors
    if (length(body_rows) > 0) {
      plot <- forestploter::edit_plot(
        plot,
        row = body_rows,
        col = all_cols,
        which = "background",
        gp = grid::gpar(fill = colors$secondary, col = NA)
      )
    }

    if (length(group_rows) > 0) {
      plot <- forestploter::edit_plot(
        plot,
        row = group_rows,
        col = all_cols,
        which = "background",
        gp = grid::gpar(fill = colors$primary, col = NA)
      )
    }

  } else if (style == "block") {
    # Block style: alternating colors by group blocks
    if (is.null(group_rows) || length(group_rows) == 0) {
      cli::cli_warn("Style 'block' requires {.arg group_rows}. No background applied.")
      return(plot)
    }

    # Calculate block ID for each row
    # Each group header starts a new block
    block_id <- cumsum(all_rows %in% group_rows)

    # Apply colors by block
    for (b in unique(block_id)) {
      rows_in_block <- all_rows[block_id == b]
      fill_color <- if (b %% 2 == 1) colors$primary else colors$secondary

      plot <- forestploter::edit_plot(
        plot,
        row = rows_in_block,
        col = all_cols,
        which = "background",
        gp = grid::gpar(fill = fill_color, col = NA)
      )
    }
  }

  return(plot)
}


#' Apply CI Colors
#'
#' Internal function to apply colors to confidence interval boxes.
#'
#' @param plot Forest plot object.
#' @param colors Color specification (single color, vector, or named list with mapping).
#' @param ci_column Column index where CI is drawn.
#' @param n_rows Number of rows.
#' @param group_ids Optional group IDs for color mapping.
#'
#' @return Modified forest plot object.
#'
#' @keywords internal
#' @noRd
.apply_ci_colors <- function(plot,
                             colors,
                             ci_column = 2,
                             n_rows,
                             group_ids = NULL) {

  # Case 1: Single color - replicate for all rows
  if (is.character(colors) && length(colors) == 1) {
    colors <- rep(colors, n_rows)
  }

  # Case 2: Color vector - validate length
  if (is.character(colors) && length(colors) > 1) {
    if (length(colors) != n_rows) {
      cli::cli_abort(
        "Length of {.arg colors} ({length(colors)}) must match number of rows ({n_rows})"
      )
    }
  }

  # Case 3: Named list with mapping
  if (is.list(colors)) {
    if (is.null(colors$mapping)) {
      cli::cli_abort("{.arg colors} list must contain 'mapping' element")
    }
    if (is.null(group_ids)) {
      cli::cli_abort("{.arg group_ids} is required when using color mapping")
    }
    if (length(group_ids) != n_rows) {
      cli::cli_abort(
        "Length of {.arg group_ids} ({length(group_ids)}) must match number of rows ({n_rows})"
      )
    }

    # Map group IDs to colors
    default_color <- if (!is.null(colors$default)) colors$default else "#999999"
    color_vec <- character(n_rows)

    for (i in seq_len(n_rows)) {
      gid <- as.character(group_ids[i])
      # Try exact match first
      if (gid %in% names(colors$mapping)) {
        color_vec[i] <- colors$mapping[[gid]]
      } else {
        # Try pattern matching (for cases like "str_detect")
        matched <- FALSE
        for (pattern in names(colors$mapping)) {
          if (grepl(pattern, gid, fixed = FALSE)) {
            color_vec[i] <- colors$mapping[[pattern]]
            matched <- TRUE
            break
          }
        }
        if (!matched) {
          color_vec[i] <- default_color
        }
      }
    }
    colors <- color_vec
  }

  # Apply colors to each row
  # Note: forestploter requires row-by-row editing for CI elements
  for (i in seq_len(n_rows)) {
    plot <- forestploter::edit_plot(
      plot,
      col = ci_column,
      row = i,
      which = "ci",
      gp = grid::gpar(fill = colors[i], col = colors[i])
    )
  }

  return(plot)
}


#' Apply Borders
#'
#' Internal function to apply borders to forest plot.
#'
#' @param plot Forest plot object.
#' @param n_rows Number of data rows.
#' @param add_borders Logical. Add simple borders?
#' @param border_width Border line width (mm).
#' @param group_headers List of group header specifications.
#' @param group_border_width Group border line width (mm).
#' @param custom_borders List of custom border specifications.
#'
#' @return Modified forest plot object.
#'
#' @keywords internal
#' @noRd
.apply_borders <- function(plot,
                          n_rows,
                          add_borders = TRUE,
                          border_width = 3,
                          group_headers = NULL,
                          group_border_width = 6,
                          custom_borders = NULL) {

  # Scenario 1: Simple borders (3 lines)
  if (add_borders && is.null(group_headers)) {
    # Top line
    plot <- forestploter::add_border(
      plot, part = "header", row = 1, where = "top",
      gp = grid::gpar(lwd = border_width)
    )
    # Header bottom line
    plot <- forestploter::add_border(
      plot, part = "header", row = 1, where = "bottom",
      gp = grid::gpar(lwd = border_width)
    )
    # Table bottom line
    plot <- forestploter::add_border(
      plot, part = "body", row = n_rows, where = "bottom",
      gp = grid::gpar(lwd = border_width)
    )
  }

  # Scenario 2: Group headers + borders
  if (!is.null(group_headers)) {
    # Get number of columns
    n_cols <- length(plot$widths)

    # Insert empty row at top
    plot <- forestploter::insert_text(
      plot, text = "", col = 1:n_cols, part = "header", before = TRUE
    )

    # Add group header texts
    for (group in group_headers) {
      fontsize <- if (!is.null(group$fontsize)) group$fontsize else 18
      plot <- forestploter::add_text(
        plot,
        text = group$text,
        part = "header",
        row = 1,
        col = group$cols,
        gp = grid::gpar(fontface = "bold", fontsize = fontsize),
        just = "center"
      )
    }

    # Add borders
    # Top line
    plot <- forestploter::add_border(
      plot, part = "header", row = 0, where = "top",
      gp = grid::gpar(lwd = group_border_width)
    )

    # Main header bottom line (row 2 after insertion)
    plot <- forestploter::add_border(
      plot, part = "header", row = 2,
      gp = grid::gpar(lwd = group_border_width)
    )

    # Group header bottom lines
    for (group in group_headers) {
      plot <- forestploter::add_border(
        plot, part = "header", row = 1, col = group$cols,
        gp = grid::gpar(lwd = group_border_width)
      )
    }

    # Table bottom line
    plot <- forestploter::add_border(
      plot, part = "body", row = n_rows + 2, where = "bottom",
      gp = grid::gpar(lwd = group_border_width)
    )
  }

  # Scenario 3: Custom borders
  if (!is.null(custom_borders)) {
    for (border_spec in custom_borders) {
      # Extract parameters
      part <- border_spec$part
      row <- border_spec$row
      col <- border_spec$col  # May be NULL
      where <- border_spec$where  # May be NULL
      lwd <- if (!is.null(border_spec$lwd)) border_spec$lwd else 3

      # Build call based on available parameters
      if (!is.null(col) && !is.null(where)) {
        plot <- forestploter::add_border(
          plot, part = part, row = row, col = col, where = where,
          gp = grid::gpar(lwd = lwd)
        )
      } else if (!is.null(col)) {
        plot <- forestploter::add_border(
          plot, part = part, row = row, col = col,
          gp = grid::gpar(lwd = lwd)
        )
      } else if (!is.null(where)) {
        plot <- forestploter::add_border(
          plot, part = part, row = row, where = where,
          gp = grid::gpar(lwd = lwd)
        )
      } else {
        plot <- forestploter::add_border(
          plot, part = part, row = row,
          gp = grid::gpar(lwd = lwd)
        )
      }
    }
  }

  return(plot)
}


#' Adjust Layout Dimensions
#'
#' Internal function to adjust row heights and column widths.
#'
#' @param plot Forest plot object (gtable).
#' @param height_top Top margin height (mm).
#' @param height_header Header row height (mm).
#' @param height_main Data row height (mm).
#' @param height_bottom Bottom margin height (mm).
#' @param width_left Left margin width (mm).
#' @param width_right Right margin width (mm).
#' @param width_adjust Width adjustment increment (mm).
#' @param height_custom Named list for manual height override.
#' @param width_custom Named list for manual width override.
#' @param verbose Print layout information?
#'
#' @return Modified forest plot object.
#'
#' @keywords internal
#' @noRd
.adjust_layout <- function(plot,
                          height_top = 8,
                          height_header = 12,
                          height_main = 10,
                          height_bottom = 8,
                          width_left = 10,
                          width_right = 10,
                          width_adjust = 5,
                          height_custom = NULL,
                          width_custom = NULL,
                          verbose = TRUE) {

  # 1. Get default dimensions
  default_heights <- grid::convertHeight(plot$heights, "mm", valueOnly = TRUE)
  default_widths <- grid::convertWidth(plot$widths, "mm", valueOnly = TRUE)

  # 2. Adjust column widths
  n_cols <- length(default_widths)

  # First column: left margin
  plot$widths[1] <- grid::unit(width_left, "mm")

  # Middle columns: adjust width with intelligent rounding
  # Reason: Round up to nearest multiple of width_adjust for consistent spacing
  # Example: 78mm + 5mm = 83mm -> ceiling(83/5)*5 = 85mm
  for (i in 2:(n_cols - 1)) {
    adjusted <- ceiling((default_widths[i] + width_adjust) / width_adjust) * width_adjust
    plot$widths[i] <- grid::unit(adjusted, "mm")
  }

  # Last column: right margin
  plot$widths[n_cols] <- grid::unit(width_right, "mm")

  # 3. Adjust row heights
  n_rows <- length(plot$heights)

  if (n_rows >= 3) {
    plot$heights[1] <- grid::unit(height_top, "mm")
    plot$heights[2] <- grid::unit(height_header, "mm")

    # Middle rows (data content)
    if (n_rows > 3) {
      for (i in 3:(n_rows - 1)) {
        plot$heights[i] <- grid::unit(height_main, "mm")
      }
    }

    plot$heights[n_rows] <- grid::unit(height_bottom, "mm")
  }

  # 4. Apply manual overrides
  if (!is.null(height_custom)) {
    for (idx in names(height_custom)) {
      plot$heights[as.numeric(idx)] <- grid::unit(height_custom[[idx]], "mm")
    }
  }
  if (!is.null(width_custom)) {
    for (idx in names(width_custom)) {
      plot$widths[as.numeric(idx)] <- grid::unit(width_custom[[idx]], "mm")
    }
  }

  # 5. Get adjusted dimensions
  adjusted_heights <- grid::convertHeight(plot$heights, "mm", valueOnly = TRUE)
  adjusted_widths <- grid::convertWidth(plot$widths, "mm", valueOnly = TRUE)

  # 6. Print layout information (if verbose)
  if (verbose) {
    cli::cli_h3("Layout Adjustment Summary")

    # Column widths
    cli::cli_alert_info("Column Widths (mm):")
    cli::cli_text("  Default:  {paste(round(default_widths, 1), collapse = ', ')}")
    cli::cli_text("  Adjusted: {paste(round(adjusted_widths, 1), collapse = ', ')}")

    width_code <- paste0("'", seq_len(n_cols), "' = ", round(adjusted_widths, 1))
    cli::cli_code("width_custom = list({paste(width_code, collapse = ', ')})")

    # Row heights
    cli::cli_alert_info("Row Heights (mm):")
    cli::cli_text("  Default:  {paste(round(default_heights, 1), collapse = ', ')}")
    cli::cli_text("  Adjusted: {paste(round(adjusted_heights, 1), collapse = ', ')}")

    height_code <- paste0("'", seq_len(n_rows), "' = ", round(adjusted_heights, 1))
    cli::cli_code("height_custom = list({paste(height_code, collapse = ', ')})")

    cli::cli_alert_success("Tip: Copy and modify the code above for custom dimensions")
  }

  return(plot)
}


#' Save Forest Plot
#'
#' Internal function to save forest plot to files.
#'
#' @param plot Forest plot object.
#' @param filename Base filename without extension.
#' @param path Directory path.
#' @param formats File formats to save.
#' @param width Plot width.
#' @param height Plot height.
#' @param units Units for dimensions.
#' @param dpi Resolution.
#' @param bg Background color.
#' @param overwrite Overwrite existing files?
#' @param verbose Print messages?
#'
#' @return Invisibly returns saved file paths.
#'
#' @keywords internal
#' @noRd
.save_forest <- function(plot,
                         filename = "forest_plot",
                         path = ".",
                         formats = c("png", "pdf"),
                         width = 35,
                         height = 42,
                         units = "cm",
                         dpi = 300,
                         bg = "white",
                         overwrite = TRUE,
                         verbose = TRUE) {

  # ===========================================================================
  # Validation
  # ===========================================================================

  # Validate file formats
  valid_formats <- c("png", "jpg", "jpeg", "tiff", "pdf")
  formats <- tolower(formats)
  invalid <- setdiff(formats, valid_formats)

  if (length(invalid) > 0) {
    cli::cli_abort(
      c(
        "Invalid format(s): {.val {invalid}}",
        "i" = "Valid formats: {.val {valid_formats}}"
      )
    )
  }

  # Normalize jpg/jpeg and remove duplicates
  formats[formats == "jpeg"] <- "jpg"
  formats <- unique(formats)

  # Validate units
  valid_units <- c("in", "cm", "mm", "px")
  if (!units %in% valid_units) {
    cli::cli_abort(
      c(
        "Invalid units: {.val {units}}",
        "i" = "Valid units: {.val {valid_units}}"
      )
    )
  }

  # ===========================================================================
  # Directory Setup
  # ===========================================================================

  # Create output directory if needed
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
    if (verbose) {
      cli::cli_alert_info("Created directory: {.path {path}}")
    }
  }

  # ===========================================================================
  # Save Files
  # ===========================================================================

  saved_files <- character(length(formats))

  for (i in seq_along(formats)) {
    ext <- formats[i]
    full_path <- file.path(path, paste0(filename, ".", ext))

    # Check if file exists and handle overwrite logic
    if (file.exists(full_path) && !overwrite) {
      if (verbose) {
        cli::cli_alert_warning("Skipped (file exists): {.path {full_path}}")
      }
      saved_files[i] <- NA_character_
      next
    }

    # Save file with error handling
    tryCatch({
      ggplot2::ggsave(
        filename = full_path,
        plot = plot,
        width = width,
        height = height,
        units = units,
        dpi = dpi,
        bg = bg,
        device = ext
      )
      saved_files[i] <- full_path

      if (verbose) {
        size_kb <- round(file.info(full_path)$size / 1024, 1)
        cli::cli_alert_success("Saved {.strong {ext}} ({size_kb} KB): {.path {full_path}}")
      }
    }, error = function(e) {
      if (verbose) {
        cli::cli_alert_danger("Failed to save {.val {ext}}: {e$message}")
      }
      saved_files[i] <- NA_character_
    })
  }

  # ===========================================================================
  # Summary
  # ===========================================================================

  if (verbose && length(formats) > 1) {
    n_success <- sum(!is.na(saved_files))
    cli::cli_alert_info("Successfully saved {n_success}/{length(formats)} format(s)")
  }

  invisible(saved_files[!is.na(saved_files)])
}
