#' Draw Venn Diagrams (2-4 sets, classic or gradient style)
#'
#' A flexible and unified Venn diagram plotting function supporting both `ggvenn`
#' and `ggVennDiagram`. Automatically handles naming, de-duplication, and visualization.
#'
#' @param set1,set2,set3,set4 Input vectors. At least two sets are required.
#' @param category.names Optional vector of set names. If NULL, variable names are used.
#' @param fill Fill colors (for `method = "classic"`).
#' @param label Label type: `"count"`, `"percent"`, `"both"`, or `"none"`.
#' @param label_geom Label geometry for `ggVennDiagram`: `"label"` or `"text"`.
#' @param label_alpha Background transparency for labels (only for `gradient`).
#' @param fill_alpha Transparency for filled regions (only for `classic`).
#' @param label_size Size of region labels.
#' @param label_color Color of region labels.
#' @param set_color Color of set labels and borders.
#' @param set_size Font size for set names.
#' @param edge_lty Line type for borders.
#' @param edge_size Border thickness.
#' @param title Plot title.
#' @param title_size Title font size.
#' @param title_color Title font color.
#' @param legend.position Legend position. Default: `"none"`.
#' @param method Drawing method: `"classic"` (ggvenn) or `"gradient"` (ggVennDiagram).
#' @param digits Decimal places for percentages (classic only).
#' @param label_sep Separator for overlapping elements (classic only).
#' @param show_outside Show outside elements (classic only).
#' @param auto_scale Whether to auto-scale layout (classic only).
#' @param palette Gradient palette name (gradient only).
#' @param direction Palette direction (gradient only).
#' @param preview Whether to print the plot to screen.
#' @param return_sets If TRUE, returns a list of de-duplicated input sets.
#' @param ... Additional arguments passed to the underlying plot function.
#'
#' @return A ggplot object (and optionally a list of processed sets if `return_sets = TRUE`).
#' @export
#'
#' @examples
#' set.seed(123)
#' g1 <- sample(letters, 15)
#' g2 <- sample(letters, 10)
#' g3 <- sample(letters, 12)
#'
#' # Classic 3-set Venn
#' plot_venn(g1, g2, g3, method = "classic", title = "Classic Venn")
#'
#' # Gradient 2-set Venn
#' plot_venn(g1, g2, method = "gradient", title = "Gradient Venn")
#'
#' # Return sets for downstream use
#' out <- plot_venn(g1, g2, return_sets = TRUE)
#' names(out)
#'
plot_venn <- function(set1, set2, set3 = NULL, set4 = NULL,
                      category.names = NULL,
                      fill = c("skyblue", "pink", "lightgreen", "lightyellow"),
                      label = "count",
                      label_geom = "label",
                      label_alpha = 0,
                      fill_alpha = 0.5,
                      label_size = 4,
                      label_color = "black",
                      set_color = "black",
                      set_size = 5,
                      edge_lty = "solid",
                      edge_size = 0.8,
                      title = "My Venn Diagram",
                      title_size = 14,
                      title_color = "#F06292",
                      legend.position = "none",
                      method = c("classic", "gradient"),
                      digits = 1,
                      label_sep = ",",
                      show_outside = "auto",
                      auto_scale = FALSE,
                      palette = "Spectral",
                      direction = 1,
                      preview = TRUE,
                      return_sets = FALSE,
                      ...) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================

  # Check required packages
  required_pkgs <- c("ggvenn", "ggVennDiagram")
  missing <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing) > 0) {
    cli::cli_abort("Missing required packages: {paste(missing, collapse = ', ')}")
  }

  # Validate required sets
  if (missing(set1) || missing(set2)) {
    cli::cli_abort("At least two sets (set1 and set2) are required.")
  }

  # Validate method parameter
  method <- match.arg(method)

  # Validate numeric parameters
  if (!is.numeric(label_size) || length(label_size) != 1 || is.na(label_size) || label_size <= 0) {
    cli::cli_abort("`label_size` must be a single positive numeric value.")
  }
  if (!is.numeric(set_size) || length(set_size) != 1 || is.na(set_size) || set_size <= 0) {
    cli::cli_abort("`set_size` must be a single positive numeric value.")
  }
  if (!is.numeric(edge_size) || length(edge_size) != 1 || is.na(edge_size) || edge_size <= 0) {
    cli::cli_abort("`edge_size` must be a single positive numeric value.")
  }
  if (!is.numeric(title_size) || length(title_size) != 1 || is.na(title_size) || title_size <= 0) {
    cli::cli_abort("`title_size` must be a single positive numeric value.")
  }
  if (!is.numeric(digits) || length(digits) != 1 || is.na(digits) || digits < 0) {
    cli::cli_abort("`digits` must be a single non-negative integer.")
  }
  if (!is.numeric(direction) || length(direction) != 1 || is.na(direction) || abs(direction) != 1) {
    cli::cli_abort("`direction` must be 1 or -1.")
  }

  # Validate character parameters
  if (!is.character(label_color) || length(label_color) != 1 || is.na(label_color)) {
    cli::cli_abort("`label_color` must be a single non-NA character string.")
  }
  if (!is.character(set_color) || length(set_color) != 1 || is.na(set_color)) {
    cli::cli_abort("`set_color` must be a single non-NA character string.")
  }
  if (!is.character(title_color) || length(title_color) != 1 || is.na(title_color)) {
    cli::cli_abort("`title_color` must be a single non-NA character string.")
  }
  if (!is.character(title) || length(title) != 1 || is.na(title)) {
    cli::cli_abort("`title` must be a single non-NA character string.")
  }
  if (!is.character(label_sep) || length(label_sep) != 1 || is.na(label_sep)) {
    cli::cli_abort("`label_sep` must be a single non-NA character string.")
  }
  if (!is.character(palette) || length(palette) != 1 || is.na(palette)) {
    cli::cli_abort("`palette` must be a single non-NA character string.")
  }

  # Validate logical parameters
  if (!is.logical(preview) || length(preview) != 1) {
    cli::cli_abort("`preview` must be a single logical value.")
  }
  if (!is.logical(return_sets) || length(return_sets) != 1) {
    cli::cli_abort("`return_sets` must be a single logical value.")
  }
  if (!is.logical(auto_scale) || length(auto_scale) != 1) {
    cli::cli_abort("`auto_scale` must be a single logical value.")
  }

  # Validate alpha parameters
  if (!is.numeric(label_alpha) || length(label_alpha) != 1 || is.na(label_alpha) || label_alpha < 0 || label_alpha > 1) {
    cli::cli_abort("`label_alpha` must be a numeric value between 0 and 1.")
  }
  if (!is.numeric(fill_alpha) || length(fill_alpha) != 1 || is.na(fill_alpha) || fill_alpha < 0 || fill_alpha > 1) {
    cli::cli_abort("`fill_alpha` must be a numeric value between 0 and 1.")
  }

  # Validate label parameter
  valid_labels <- c("count", "percent", "both", "none")
  if (!is.character(label) || length(label) != 1 || is.na(label) || !(label %in% valid_labels)) {
    cli::cli_abort("`label` must be one of: {paste(valid_labels, collapse = ', ')}")
  }

  # Validate label_geom parameter
  valid_geoms <- c("label", "text")
  if (!is.character(label_geom) || length(label_geom) != 1 || is.na(label_geom) || !(label_geom %in% valid_geoms)) {
    cli::cli_abort("`label_geom` must be one of: {paste(valid_geoms, collapse = ', ')}")
  }

  # Validate show_outside parameter
  if (!is.character(show_outside) && !is.logical(show_outside)) {
    cli::cli_abort("`show_outside` must be a character string or logical value.")
  }

  # -- Extract sets and names
  venn_sets <- list(set1, set2)
  var_names <- c(deparse(substitute(set1)), deparse(substitute(set2)))
  if (!is.null(set3)) {
    venn_sets[[3]] <- set3
    var_names[3] <- deparse(substitute(set3))
  }
  if (!is.null(set4)) {
    venn_sets[[4]] <- set4
    var_names[4] <- deparse(substitute(set4))
  }

  # -- Validate sets
  for (i in seq_along(venn_sets)) {
    x <- venn_sets[[i]]
    if (!is.vector(x)) cli::cli_abort("{var_names[i]} is not a vector.")
    if (length(x) == 0) cli::cli_abort("{var_names[i]} is empty.")
  }

  # -- Warn on type mismatch
  base_type <- typeof(venn_sets[[1]])
  for (i in seq_along(venn_sets)[-1]) {
    if (typeof(venn_sets[[i]]) != base_type) {
      cli::cli_warn("Type mismatch: {var_names[i]} is {typeof(venn_sets[[i]])}, expected {base_type}")
    }
  }

  # -- Deduplicate
  for (i in seq_along(venn_sets)) {
    original <- venn_sets[[i]]
    unique_set <- unique(original)
    if (length(unique_set) < length(original)) {
      cli::cli_alert_info("{var_names[i]} had {length(original) - length(unique_set)} duplicates, now de-duplicated.")
    }
    venn_sets[[i]] <- unique_set
  }

  # -- Set names
  if (is.null(category.names)) {
    category.names <- var_names
  } else if (length(category.names) != length(venn_sets)) {
    cli::cli_warn("Length of category.names doesn't match number of sets. Using default variable names.")
    category.names <- var_names
  }
  names(venn_sets) <- category.names
  fill <- fill[seq_along(venn_sets)]

  # -- Plot (classic style)
  if (method == "classic") {
    show_elements <- (label == "both")
    show_percentage <- (label == "percent")
    if (label == "none") {
      show_elements <- FALSE
      show_percentage <- FALSE
    }

    venn <- ggvenn::ggvenn(
      data = venn_sets,
      columns = names(venn_sets),
      show_elements = show_elements,
      show_percentage = show_percentage,
      digits = digits,
      fill_color = fill,
      fill_alpha = fill_alpha,
      stroke_color = set_color,
      stroke_alpha = 1,
      stroke_size = edge_size,
      stroke_linetype = edge_lty,
      set_name_color = set_color,
      set_name_size = set_size,
      text_color = label_color,
      text_size = label_size,
      label_sep = label_sep,
      show_outside = show_outside,
      auto_scale = auto_scale,
      ...
    ) +
      ggplot2::ggtitle(title) +
      ggplot2::theme_void() +
      ggplot2::theme(
        legend.position = legend.position,
        plot.title = ggplot2::element_text(size = title_size, hjust = 0.5, colour = title_color)
      )

  } else {
    # -- Plot (gradient style)
    venn <- ggVennDiagram::ggVennDiagram(
      x = venn_sets,
      category.names = names(venn_sets),
      label = label,
      label_geom = label_geom,
      label_alpha = label_alpha,
      label_size = label_size,
      label_color = label_color,
      set_color = set_color,
      set_size = set_size,
      edge_lty = edge_lty,
      edge_size = edge_size,
      show_intersect = FALSE,
      ...
    ) +
      ggplot2::scale_fill_distiller(palette = palette, direction = direction) +
      ggplot2::ggtitle(title) +
      ggplot2::theme_void() +
      ggplot2::theme(
        legend.position = legend.position,
        plot.title = ggplot2::element_text(size = title_size, hjust = 0.5, colour = title_color)
      )
  }

  if (preview) print(venn)
  if (return_sets) return(list(plot = venn, sets = venn_sets))
  return(venn)
}
