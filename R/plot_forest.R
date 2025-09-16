#' Draw a forest plot using forestploter with publication-quality styling
#'
#' @param data Data frame with required columns: estimate, lower, upper, label, and p-value.
#' @param estimate_col Name of column containing point estimates.
#' @param lower_col Name of column containing lower CI.
#' @param upper_col Name of column containing upper CI.
#' @param label_col Name of column for variable labels.
#' @param p_col Name of column for p-values.
#' @param ref_line Reference line value, typically 1 for OR/HR.
#' @param sig_level Threshold to bold significant rows (default 0.05).
#' @param bold_sig Whether to bold significant rows.
#' @param arrow_lab Labels at both ends of the forest axis.
#' @param ticks_at Vector of x-axis tick marks.
#' @param xlim Range of x-axis (e.g., c(0, 3)). If NULL, auto-calculated. Default: c(0, 3).
#' @param footnote Caption text below the plot.
#' @param boxcolor Fill colors for CI boxes, will repeat if too short.
#' @param align_left Integer column indices to left-align.
#' @param align_right Integer column indices to right-align.
#' @param align_center Integer column indices to center-align.
#' @param gap_width Number of spaces in the gap column (default = 30).
#'
#' @return A forestplot object
#' @export
plot_forest <- function(data,
                        estimate_col = "estimate",
                        lower_col = "conf.low",
                        upper_col = "conf.high",
                        label_col = "variable",
                        p_col = "p.value",
                        ref_line = 1,
                        sig_level = 0.05,
                        bold_sig = TRUE,
                        arrow_lab = c("Unfavorable", "Favorable"),
                        ticks_at = c(0.5, 1, 1.5, 2),
                        xlim = c(0, 3),
                        footnote = "P-value < 0.05 was considered statistically significant",
                        boxcolor = c("#E64B35", "#4DBBD5", "#00A087", "#3C5488",
                                     "#F39B7F", "#8491B4", "#91D1C2", "#DC0000", "#7E6148"),
                        align_left = 1,
                        align_right = NULL,
                        align_center = NULL,
                        gap_width = 30) {

  # ---- Dependency checks (no library() calls) ----
  if (!requireNamespace("forestploter", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg forestploter} is required for plot_forest().")
  }
  if (!requireNamespace("grid", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg grid} is required for plot_forest().")
  }

  # ---- Column validation ----
  required_cols <- c(estimate_col, lower_col, upper_col, label_col, p_col)
  missing_cols <- setdiff(required_cols, colnames(data))
  if (length(missing_cols) > 0) {
    cli::cli_abort("Missing required columns: {paste(missing_cols, collapse = ', ')}")
  }

  # ---- Prepare core data ----
  # Prepare core data without attaching dplyr: use base R to avoid NSE issues
  df <- as.data.frame(data, stringsAsFactors = FALSE)
  df$.estimate <- df[[estimate_col]]
  df$.lower <- df[[lower_col]]
  df$.upper <- df[[upper_col]]
  df$.label <- as.character(df[[label_col]])
  df$.pvalue <- df[[p_col]]
  df[["OR (95% CI)"]] <- sprintf("%.3f (%.3f\\u2013%.3f)", df$.estimate, df$.lower, df$.upper)
  df[[" "]] <- rep(paste(rep(" ", gap_width), collapse = ""), nrow(df))

  plot_df <- df[, c(label_col, "OR (95% CI)", " ", p_col)]

  # ---- Expand boxcolor if needed ----
  boxcolor <- rep(boxcolor, length.out = nrow(df))

  # ---- Default forestploter theme ----
  tm <- forestploter::forest_theme(
    base_size = 18,
    ci_pch = 16,
    ci_lty = 1,
    ci_lwd = 1.5,
    ci_col = "black",
    ci_alpha = 0.8,
    ci_fill = "#E64B35",
    ci_Theight = 0.2,
    refline_gp = grid::gpar(lwd = 1, lty = "dashed", col = "grey20"),
    base_family = "sans",
    xaxis_gp = grid::gpar(fontsize = 12, fontfamily = "sans"),
    footnote_gp = grid::gpar(cex = 0.6, fontface = "italic", col = "blue")
  )

  if (length(arrow_lab) != 2) {
    arrow_lab <- c("Left", "Right")
  }

  # ---- Draw base forest plot ----
  fp <- forestploter::forest(plot_df,
               est = df$.estimate,
               lower = df$.lower,
               upper = df$.upper,
               ci_column = 3,
               ref_line = ref_line,
               arrow_lab = arrow_lab,
               xlim = xlim,
               ticks_at = ticks_at,
               footnote = footnote,
               theme = tm)

  # ---- Add box color and bold ----
  for (i in seq_len(nrow(df))) {
    fp <- forestploter::edit_plot(fp, col = 3, row = i, which = "ci",
                    gp = grid::gpar(fill = boxcolor[i]))
    if (bold_sig && !is.na(df$.pvalue[i]) && df$.pvalue[i] < sig_level) {
      fp <- forestploter::edit_plot(fp, col = 2, row = i, which = "text",
                      gp = grid::gpar(fontface = "bold"))
    }
  }

  # ---- Alignment logic ----
  total_cols <- ncol(plot_df)
  all_cols <- seq_len(total_cols)
  align_center <- align_center[align_center %in% all_cols]
  align_left <- align_left[align_left %in% all_cols]
  align_right <- setdiff(all_cols, union(align_left, align_center))

  for (col in align_left) {
    fp <- forestploter::edit_plot(fp, col = col, which = "text", part = "body",
                  hjust = grid::unit(0, "npc"), x = grid::unit(0, "npc"))
    fp <- forestploter::edit_plot(fp, col = col, which = "text", part = "header",
                  hjust = grid::unit(0, "npc"), x = grid::unit(0, "npc"))
  }
  for (col in align_center) {
    fp <- forestploter::edit_plot(fp, col = col, which = "text", part = "body",
                  hjust = grid::unit(0.5, "npc"), x = grid::unit(0.5, "npc"))
    fp <- forestploter::edit_plot(fp, col = col, which = "text", part = "header",
                  hjust = grid::unit(0.5, "npc"), x = grid::unit(0.5, "npc"))
  }
  for (col in align_right) {
    fp <- forestploter::edit_plot(fp, col = col, which = "text", part = "body",
                  hjust = grid::unit(1, "npc"), x = grid::unit(1, "npc"))
    fp <- forestploter::edit_plot(fp, col = col, which = "text", part = "header",
                  hjust = grid::unit(1, "npc"), x = grid::unit(1, "npc"))
  }

  # ---- Return forestplot object ----
  return(fp)
}
