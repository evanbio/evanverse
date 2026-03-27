# =============================================================================
# utils_plot.R — internal helpers for plot_forest()
# =============================================================================


# -----------------------------------------------------------------------------
# Theme
# -----------------------------------------------------------------------------

# Build forest theme. theme must be a recognised preset string or a
# forest_theme object. Unrecognised strings warn and fall back to "default".
.fp_theme <- function(theme, ci_Theight = 0.2) {
  if (inherits(theme, "forest_theme")) return(theme)

  presets <- list(
    default = list(
      base_size    = 12,
      base_family  = "sans",
      ci_pch       = 15,
      ci_lty       = 1,
      ci_lwd       = 3,
      ci_col       = "black",
      ci_alpha     = 1,
      ci_fill      = "black",
      ci_Theight   = ci_Theight,
      refline_gp   = grid::gpar(lwd = 2, lty = "dashed", col = "grey20"),
      xaxis_gp     = grid::gpar(fontsize = 12, fontfamily = "sans"),
      arrow_type   = "open",
      arrow_length = 0.1,
      arrow_gp     = grid::gpar(fontsize = 12, fontfamily = "sans", lwd = 2),
      xlab_adjust  = "center",
      xlab_gp      = grid::gpar(fontsize = 10, fontfamily = "sans", fontface = "plain")
    )
  )

  if (!is.character(theme) || !theme %in% names(presets)) {
    cli::cli_warn(
      c("Unknown theme {.val {theme}}, falling back to {.val {'default'}}.",
        "i" = "Available: {.val {names(presets)}}")
    )
    theme <- "default"
  }

  do.call(forestploter::forest_theme, presets[[theme]])
}


# -----------------------------------------------------------------------------
# Data pre-processing
# -----------------------------------------------------------------------------

# Apply indent, format p_cols, insert gap_ci + OR label at ci_column.
# Returns list(data = final_df, p_col_idxs = integer vector of p col positions
#              in final_df).
.fp_build_data <- function(data, est, lower, upper, indent,
                           p_cols, p_digits, ci_digits, ci_sep, ci_column) {
  n         <- nrow(data)
  ncol_orig <- ncol(data)

  # 1. Indent: prepend non-breaking spaces to item (col 1).
  # Reason: regular spaces are often collapsed by grid text rendering;
  # \u00a0 (non-breaking space) preserves visual indentation reliably.
  data[[1L]] <- paste0(strrep("\u00a0\u00a0", as.integer(indent)), data[[1L]])

  # 2. Format p_cols: numeric → character, cache originals for bold logic
  p_numeric <- list()
  if (!is.null(p_cols)) {
    thresh_str <- formatC(10^(-p_digits), digits = p_digits, format = "f")
    for (col in p_cols) {
      pv             <- as.numeric(data[[col]])
      p_numeric[[col]] <- pv
      data[[col]]    <- ifelse(
        is.na(pv), "",
        ifelse(pv < 10^(-p_digits),
               paste0("<", thresh_str),
               formatC(pv, digits = p_digits, format = "f"))
      )
    }
  }

  # 3. Generate OR (95% CI) label from est/lower/upper
  fmt <- function(x) formatC(x, digits = ci_digits, format = "f")
  ci_label <- ifelse(
    is.na(est), "",
    paste0(fmt(est), " (", fmt(lower), ci_sep, fmt(upper), ")")
  )

  # 4. Build final table: left cols | gap_ci | OR (95% CI) | right cols
  if (ci_column <= 1L)
    cli::cli_abort("{.arg ci_column} must be >= 2.", call = NULL)
  if (ci_column > ncol_orig + 1L)
    cli::cli_abort(
      "{.arg ci_column} ({ci_column}) exceeds ncol(data)+1 ({ncol_orig + 1L}).",
      call = NULL
    )

  gap_df <- data.frame(gap_ci        = strrep(" ", 20L), stringsAsFactors = FALSE)
  lab_df <- data.frame(`OR (95% CI)` = ci_label,         stringsAsFactors = FALSE,
                       check.names   = FALSE)

  left  <- data[, seq_len(ci_column - 1L), drop = FALSE]
  right <- if (ci_column <= ncol_orig)
    data[, seq(ci_column, ncol_orig), drop = FALSE]
  else
    NULL

  data_r <- if (is.null(right)) cbind(left, gap_df, lab_df)
            else                 cbind(left, gap_df, lab_df, right)

  # 5. Map original p_cols indices to final positions (+2 if >= ci_column)
  p_col_idxs <- NULL
  if (!is.null(p_cols)) {
    orig_idxs  <- match(p_cols, names(data))
    p_col_idxs <- ifelse(orig_idxs >= ci_column, orig_idxs + 2L, orig_idxs)
  }

  list(data = data_r, p_col_idxs = p_col_idxs, p_numeric = p_numeric)
}


# -----------------------------------------------------------------------------
# Alignment
# -----------------------------------------------------------------------------

# align: integer vector, length = ncol(final data).
#   -1 = left, 0 = center, 1 = right.
# NULL = auto: col 1 left, everything else center.
.fp_align <- function(p, n_cols, align) {
  if (is.null(align)) align <- c(-1L, rep(0L, n_cols - 1L))

  hjust_map <- c("-1" = 0, "0" = 0.5, "1" = 1)
  x_map     <- c("-1" = 0, "0" = 0.5, "1" = 1)

  for (j in seq_len(n_cols)) {
    key  <- as.character(align[j])
    hj   <- grid::unit(hjust_map[[key]], "npc")
    xpos <- grid::unit(x_map[[key]], "npc")
    for (part in c("body", "header")) {
      p <- forestploter::edit_plot(p, col = j, which = "text", part = part,
                                   hjust = hj, x = xpos)
    }
  }
  p
}


# -----------------------------------------------------------------------------
# Bold label (item column)
# -----------------------------------------------------------------------------

# bold_label: logical vector length n_rows. TRUE rows → bold item column.
.fp_bold_label <- function(p, bold_label) {
  rows <- which(bold_label)
  if (length(rows) == 0L) return(p)
  forestploter::edit_plot(p, row = rows, col = 1L, which = "text",
                          gp = grid::gpar(fontface = "bold"))
}


# -----------------------------------------------------------------------------
# Bold p values
# -----------------------------------------------------------------------------

# p_cols: column names in original data.
# p_col_idxs: their indices in final data_r.
# p_numeric: list of original numeric p vectors (named by p_cols).
# bold_p: TRUE / FALSE / logical vector (length n_rows).
# p_threshold: scalar; only used when bold_p is TRUE.
.fp_bold_p <- function(p, p_cols, p_col_idxs, p_numeric,
                       bold_p, p_threshold, n_rows) {
  if (isFALSE(bold_p)) return(p)

  for (j in seq_along(p_cols)) {
    pv      <- p_numeric[[p_cols[j]]]
    col_idx <- p_col_idxs[j]

    bold_rows <- which(bold_p & !is.na(pv) & pv < p_threshold)

    for (r in bold_rows) {
      p <- forestploter::edit_plot(p, row = r, col = col_idx, which = "text",
                                   gp = grid::gpar(fontface = "bold"))
    }
  }
  p
}


# -----------------------------------------------------------------------------
# CI colours
# -----------------------------------------------------------------------------

# ci_col: scalar or vector (length n_rows). Rows with NA est or NA ci_col skipped.
.fp_ci_colors <- function(p, ci_col, ci_column, est, n_rows) {
  if (length(ci_col) == 1L) ci_col <- rep(ci_col, n_rows)
  for (i in seq_len(n_rows)) {
    if (!is.na(est[i]) && !is.na(ci_col[i])) {
      p <- forestploter::edit_plot(p, row = i, col = ci_column, which = "ci",
                                   gp = grid::gpar(fill = ci_col[i],
                                                   col  = ci_col[i]))
    }
  }
  p
}


# -----------------------------------------------------------------------------
# Background
# -----------------------------------------------------------------------------

# background: "zebra" | "bold_label" | "none"
# bg_col: scalar (used for shaded rows) or vector (length n_rows, overrides all).
.fp_background <- function(p, n_rows, n_cols, background, bold_label, bg_col) {
  if (background == "none") return(p)

  all_cols <- seq_len(n_cols)

  # Determine per-row fill colour
  if (length(bg_col) == n_rows) {
    # User supplied per-row vector: direct override
    fill <- bg_col
  } else if (background == "zebra") {
    fill <- ifelse(seq_len(n_rows) %% 2L == 0L, bg_col, "white")
  } else if (background == "bold_label") {
    fill <- ifelse(bold_label, bg_col, "white")
  } else {
    cli::cli_abort(
      c("Unknown {.arg background} value {.val {background}}.",
        "i" = "Must be one of: {.val {c('zebra', 'bold_label', 'none')}}"),
      call = NULL
    )
  }

  for (i in seq_len(n_rows)) {
    p <- forestploter::edit_plot(p, row = i, col = all_cols,
                                 which = "background",
                                 gp    = grid::gpar(fill = fill[i], col = NA))
  }
  p
}


# -----------------------------------------------------------------------------
# Borders
# -----------------------------------------------------------------------------

# border: "three_line" | "none"
# border_width: scalar (all lines same) or length-3 vector
#   (top-of-header, bottom-of-header, bottom-of-body).
.fp_borders <- function(p, n_rows, border, border_width) {
  if (border == "none") return(p)

  if (length(border_width) == 1L) border_width <- rep(border_width, 3L)

  p <- forestploter::add_border(p, part = "header", row = 1L, where = "top",
                                gp = grid::gpar(lwd = border_width[1L]))
  p <- forestploter::add_border(p, part = "header", row = 1L, where = "bottom",
                                gp = grid::gpar(lwd = border_width[2L]))
  p <- forestploter::add_border(p, part = "body",   row = n_rows, where = "bottom",
                                gp = grid::gpar(lwd = border_width[3L]))
  p
}


# -----------------------------------------------------------------------------
# Layout (heights & widths)
# -----------------------------------------------------------------------------

# row_height / col_width: NULL (auto) | scalar | vector.
#
# Auto height: [1]=8mm top, [2]=12mm header, [3..n-1]=10mm rows, [n]=15mm bottom
# Auto width:  each col → ceiling((w+5)/5)*5  (adjustment in [5,10) mm)
.fp_layout <- function(p, row_height, col_width) {
  # --- heights ---
  nh      <- length(p$heights)
  if (!is.null(row_height)) {
    # scalar or vector supplied by user
    if (length(row_height) == 1L) row_height <- rep(row_height, nh)
    for (i in seq_len(nh))
      p$heights[i] <- grid::unit(row_height[i], "mm")
  } else {
    # auto
    p$heights[1L] <- grid::unit(8,  "mm")
    p$heights[2L] <- grid::unit(12, "mm")
    if (nh > 3L)
      for (i in seq(3L, nh - 1L))
        p$heights[i] <- grid::unit(10, "mm")
    p$heights[nh] <- grid::unit(15, "mm")
  }

  # --- widths ---
  nw        <- length(p$widths)
  default_w <- round(grid::convertWidth(p$widths, "mm", valueOnly = TRUE), 1)

  if (!is.null(col_width)) {
    if (length(col_width) == 1L) col_width <- rep(col_width, nw)
    for (i in seq_len(nw))
      p$widths[i] <- grid::unit(col_width[i], "mm")
  } else {
    # auto: round up so adjustment is in [5, 10) mm
    for (i in seq_len(nw)) {
      w   <- default_w[i]
      new <- ceiling((w + 5) / 5) * 5
      p$widths[i] <- grid::unit(new, "mm")
    }
  }

  p
}


# -----------------------------------------------------------------------------
# Save helper
# -----------------------------------------------------------------------------

# dest: file path (with or without extension; extension stripped and ignored).
# Saves png / pdf / jpg / tiff at 300 dpi, white background, always overwrite.
.fp_save <- function(p, dest, save_width, save_height) {
  base  <- tools::file_path_sans_ext(dest)
  exts  <- c("png", "pdf", "jpg", "tiff")
  w_in  <- save_width  / 2.54
  h_in  <- save_height / 2.54

  for (ext in exts) {
    out <- paste0(base, ".", ext)
    tryCatch({
      if (ext == "pdf") {
        grDevices::pdf(out, width = w_in, height = h_in, bg = "white")
      } else if (ext == "png") {
        grDevices::png(out, width = save_width, height = save_height,
                       units = "cm", res = 300, bg = "white")
      } else if (ext == "jpg") {
        grDevices::jpeg(out, width = save_width, height = save_height,
                        units = "cm", res = 300, bg = "white", quality = 95)
      } else if (ext == "tiff") {
        grDevices::tiff(out, width = save_width, height = save_height,
                        units = "cm", res = 300, bg = "white")
      }
      grid::grid.newpage()
      grid::grid.draw(p)
      grDevices::dev.off()
      cli::cli_alert_success("Saved: {.path {out}}")
    }, error = function(e) {
      try(grDevices::dev.off(), silent = TRUE)
      cli::cli_alert_danger("Failed to save {.path {out}}: {conditionMessage(e)}")
    })
  }
  invisible(NULL)
}
