#' 🎨 Draw Venn Diagrams (2–4 sets, classic or gradient style)
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
  # -- Check dependencies
  required_pkgs <- c("ggplot2", "ggvenn", "ggVennDiagram", "cli")
  missing_pkgs <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing_pkgs) > 0) {
    cli::cli_abort("Missing required packages: {paste(missing_pkgs, collapse = ', ')}")
  }

  # -- Match method
  method <- match.arg(method)

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
