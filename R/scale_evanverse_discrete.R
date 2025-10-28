#' @title Discrete Color and Fill Scales for evanverse Palettes
#' @name scale_evanverse
#'
#' @description
#' Apply evanverse color palettes to ggplot2 discrete scales. These functions
#' provide a seamless integration between evanverse palettes and ggplot2's
#' color/fill aesthetics.
#'
#' @details
#' The \code{scale_color_evanverse()} and \code{scale_fill_evanverse()}
#' functions automatically:
#' \itemize{
#'   \item Infer palette type from the naming convention (seq_, div_, qual_)
#'   \item Handle color interpolation intelligently based on palette type:
#'     \itemize{
#'       \item \strong{Qualitative palettes}: Direct color selection (no interpolation)
#'       \item \strong{Sequential/Diverging palettes}: Smooth interpolation when n < palette size
#'     }
#'   \item Support all standard ggplot2 scale parameters
#'   \item Provide informative error messages and warnings
#' }
#'
#' @param palette Character. Name of the palette (e.g., "qual_vivid", "seq_blues").
#'   Type will be automatically inferred from the prefix if not specified.
#' @param type Character. Palette type: "sequential", "diverging", or "qualitative".
#'   If \code{NULL} (default), the type is automatically inferred from the palette
#'   name prefix.
#' @param n Integer. Number of colors to use. If \code{NULL} (default), all
#'   colors from the palette are used. If \code{n} exceeds the number of colors
#'   in the palette, an error will be raised.
#' @param reverse Logical. Should the color order be reversed? Default is \code{FALSE}.
#' @param na.value Character. Color to use for \code{NA} values. Default is "grey50".
#' @param guide Character or function. Type of legend. Use "legend" for standard
#'   legend or "none" to hide the legend. See \code{\link[ggplot2]{guide_legend}}
#'   for more options.
#' @param ... Additional arguments passed to \code{\link[ggplot2]{scale_color_manual}}
#'   or \code{\link[ggplot2]{scale_fill_manual}}, such as \code{name}, \code{labels},
#'   \code{limits}, etc.
#'
#' @return A ggplot2 scale object that can be added to a ggplot.
#'
#' @seealso
#' \code{\link{get_palette}} for retrieving palette colors,
#' \code{\link{list_palettes}} for available palettes,
#' \code{\link[ggplot2]{scale_color_manual}} for the underlying ggplot2 function.
#'
#' @examples
#' library(ggplot2)
#'
#' # Basic usage with automatic type inference
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point(size = 3, alpha = 0.8) +
#'   scale_color_evanverse("qual_vivid") +
#'   theme_minimal()
#'
#' # Fill scale for boxplots
#' ggplot(iris, aes(x = Species, y = Sepal.Length, fill = Species)) +
#'   geom_boxplot(alpha = 0.7) +
#'   scale_fill_evanverse("qual_vivid") +
#'   theme_minimal()
#'
#' # Reverse color order
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point(size = 3) +
#'   scale_color_evanverse("qual_vivid", reverse = TRUE) +
#'   theme_minimal()
#'
#' # Explicitly specify type
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point(size = 3) +
#'   scale_color_evanverse("qual_vivid", type = "qualitative") +
#'   theme_minimal()
#'
#' # Limit number of colors
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point(size = 3) +
#'   scale_color_evanverse("qual_vivid", n = 3) +
#'   theme_minimal()
#'
#' # Custom legend name and labels
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point(size = 3) +
#'   scale_color_evanverse(
#'     "qual_vivid",
#'     name = "Iris Species",
#'     labels = c("Setosa", "Versicolor", "Virginica")
#'   ) +
#'   theme_minimal()
#'
#' # Bar plot with fill
#' ggplot(mtcars, aes(x = factor(cyl), fill = factor(cyl))) +
#'   geom_bar() +
#'   scale_fill_evanverse("qual_vibrant") +
#'   labs(x = "Cylinders", y = "Count", fill = "Cylinders") +
#'   theme_minimal()
#'
#' @rdname scale_evanverse
#' @export
scale_color_evanverse <- function(palette,
                                  type = NULL,
                                  n = NULL,
                                  reverse = FALSE,
                                  na.value = "grey50",
                                  guide = "legend",
                                  ...) {
  .scale_evanverse_discrete(
    palette = palette,
    type = type,
    n = n,
    reverse = reverse,
    na.value = na.value,
    guide = guide,
    scale_type = "color",
    ...
  )
}


#' @rdname scale_evanverse
#' @export
scale_fill_evanverse <- function(palette,
                                 type = NULL,
                                 n = NULL,
                                 reverse = FALSE,
                                 na.value = "grey50",
                                 guide = "legend",
                                 ...) {
  .scale_evanverse_discrete(
    palette = palette,
    type = type,
    n = n,
    reverse = reverse,
    na.value = na.value,
    guide = guide,
    scale_type = "fill",
    ...
  )
}


#' @rdname scale_evanverse
#' @export
scale_colour_evanverse <- scale_color_evanverse


# =============================================================================
# Internal Implementation
# =============================================================================

#' @title Internal Discrete Scale Implementation
#' @description
#' Internal function that implements the shared logic for both color and fill
#' discrete scales. This function should not be called directly by users.
#'
#' @inheritParams scale_color_evanverse
#' @param scale_type Character. Either "color" or "fill". Used for selecting
#'   the appropriate ggplot2 scale function.
#'
#' @return A ggplot2 scale object.
#'
#' @keywords internal
#' @noRd
.scale_evanverse_discrete <- function(palette,
                                      type = NULL,
                                      n = NULL,
                                      reverse = FALSE,
                                      na.value = "grey50",
                                      guide = "legend",
                                      scale_type = "color",
                                      ...) {

  # ===========================================================================
  # Step 1: Parameter Validation
  # ===========================================================================

  # Validate palette name
  if (missing(palette) || !is.character(palette) || length(palette) != 1 ||
      is.na(palette) || palette == "") {
    cli::cli_abort(
      c(
        "{.arg palette} must be a single non-empty character string.",
        "i" = "Example: {.val qual_vivid}, {.val seq_blues}, {.val div_fireice}"
      )
    )
  }

  # Validate reverse parameter
  if (!is.logical(reverse) || length(reverse) != 1 || is.na(reverse)) {
    cli::cli_abort("{.arg reverse} must be a single logical value (TRUE or FALSE).")
  }

  # Validate n parameter
  if (!is.null(n)) {
    if (!is.numeric(n) || length(n) != 1 || is.na(n) || n <= 0 || n != round(n)) {
      cli::cli_abort(
        c(
          "{.arg n} must be a single positive integer.",
          "i" = "You provided: {.val {n}}"
        )
      )
    }
  }

  # Validate na.value
  if (!is.character(na.value) || length(na.value) != 1 || is.na(na.value)) {
    cli::cli_abort("{.arg na.value} must be a single character string (color).")
  }

  # ===========================================================================
  # Step 2: Type Inference (if not provided)
  # ===========================================================================

  if (is.null(type)) {
    type <- .infer_palette_type(palette)
  } else {
    # Validate provided type
    type <- match.arg(type, choices = c("sequential", "diverging", "qualitative"))
  }

  # ===========================================================================
  # Step 3: Retrieve Palette Colors
  # ===========================================================================

  colors <- tryCatch(
    {
      # Reason: Suppress success message from get_palette using suppressMessages
      suppressMessages(get_palette(name = palette, type = type))
    },
    error = function(e) {
      cli::cli_abort(
        c(
          "Failed to retrieve palette {.val {palette}}.",
          "i" = "Use {.fn list_palettes} to see available palettes.",
          "x" = "Original error: {e$message}"
        )
      )
    }
  )

  n_available <- length(colors)

  # ===========================================================================
  # Step 4: Handle Color Count and Interpolation (n parameter)
  # ===========================================================================

  if (!is.null(n)) {
    # Check if requested number exceeds available colors
    if (n > n_available) {
      cli::cli_abort(
        c(
          "Requested {n} color{?s} but palette {.val {palette}} only has {n_available}.",
          "i" = "Please choose a palette with more colors or reduce {.arg n}.",
          "i" = "Available palettes: {.code list_palettes(type = \"{type}\")}"
        )
      )
    }

    # Apply intelligent color selection based on palette type
    if (type == "qualitative") {
      # Qualitative: Direct selection (no interpolation)
      # Reason: Qualitative colors are distinct categories, interpolation is meaningless
      colors <- colors[seq_len(n)]

    } else {
      # Sequential/Diverging: Use interpolation for better distribution
      # Reason: Sequential/diverging colors form a gradient, interpolation
      # provides better coverage of the color space
      colors <- .interpolate_palette_smart(colors, n = n, type = type)
    }
  }

  # ===========================================================================
  # Step 5: Reverse Color Order (if requested)
  # ===========================================================================

  if (reverse) {
    colors <- rev(colors)
  }

  # ===========================================================================
  # Step 6: Apply ggplot2 Scale
  # ===========================================================================

  # Determine aesthetic automatically based on scale type
  aesthetics <- if (scale_type == "color") "colour" else "fill"

  if (scale_type == "color") {
    ggplot2::scale_color_manual(
      values = colors,
      na.value = na.value,
      guide = guide,
      aesthetics = aesthetics,
      ...
    )
  } else {
    ggplot2::scale_fill_manual(
      values = colors,
      na.value = na.value,
      guide = guide,
      aesthetics = aesthetics,
      ...
    )
  }
}


# =============================================================================
# Helper Functions (Internal)
# =============================================================================

#' @title Infer Palette Type from Name
#' @description
#' Automatically detect palette type based on naming convention.
#' Palette names should follow the pattern: {type}_{name}_{source}
#'
#' @param palette Character. Palette name.
#'
#' @return Character. One of "sequential", "diverging", or "qualitative".
#'
#' @keywords internal
#' @noRd
.infer_palette_type <- function(palette) {

  # Extract prefix (seq_, div_, qual_)
  prefix <- sub("^(seq|div|qual)_.*", "\\1", palette)

  # Mapping from prefix to full type name
  type_map <- c(
    "seq"  = "sequential",
    "div"  = "diverging",
    "qual" = "qualitative"
  )

  # Check if prefix matches known types
  if (prefix %in% names(type_map)) {
    return(unname(type_map[prefix]))
  } else {
    # Cannot infer - provide helpful error message
    cli::cli_abort(
      c(
        "Cannot automatically infer palette type from name {.val {palette}}.",
        "i" = "Palette names should start with {.val seq_}, {.val div_}, or {.val qual_}.",
        "i" = "Examples: {.val seq_blues}, {.val div_fireice}, {.val qual_vivid}",
        "i" = "Alternatively, specify the {.arg type} parameter explicitly."
      )
    )
  }
}


#' @title Smart Palette Interpolation
#' @description
#' Intelligently generate n colors from a base palette using smooth interpolation.
#' This function is designed for sequential and diverging palettes where colors
#' form a gradient, ensuring even distribution across the color space.
#'
#' @param colors Character vector. Base colors in HEX format.
#' @param n Integer. Number of colors to generate (must be <= length(colors)).
#' @param type Character. Palette type ("sequential" or "diverging").
#'
#' @return Character vector of HEX colors.
#'
#' @details
#' For sequential and diverging palettes:
#' - Uses colorRampPalette to create a smooth gradient from all base colors
#' - Generates n colors evenly distributed across the gradient
#' - Preserves the extremes (first and last colors) of the original palette
#'
#' Example: A 9-color blue gradient ["#EFF3FF", ..., "#08306B"]
#' - Requesting 3 colors gives light-medium-dark blues
#' - Rather than just the first 3 (all light blues)
#'
#' For diverging palettes, this approach maintains symmetry.
#' Example: 11-color red-white-blue ["#67001F", ..., "#053061"]
#' - Requesting 5 colors maintains red-center-blue structure
#'
#' @keywords internal
#' @noRd
.interpolate_palette_smart <- function(colors, n, type) {

  # ===========================================================================
  # Input Validation
  # ===========================================================================

  if (length(colors) < 2) {
    cli::cli_abort("Need at least 2 colors for interpolation.")
  }

  if (n < 1) {
    cli::cli_abort("{.arg n} must be at least 1.")
  }

  # Edge case: if n equals the number of colors, return as-is
  if (n == length(colors)) {
    return(colors)
  }

  # Edge case: if n is 1, return the middle color for diverging or first for sequential
  if (n == 1) {
    if (type == "diverging") {
      # Return middle color for diverging palettes
      mid_idx <- ceiling(length(colors) / 2)
      return(colors[mid_idx])
    } else {
      # Return first color for sequential palettes
      return(colors[1])
    }
  }

  # ===========================================================================
  # Interpolation Strategy
  # ===========================================================================

  # Create a smooth color gradient function from all base colors
  # Reason: This ensures the interpolated colors span the entire color range
  # rather than just selecting from the beginning of the palette
  color_ramp <- grDevices::colorRampPalette(colors)

  # Generate n evenly-spaced colors from the gradient
  # Reason: colorRampPalette automatically distributes colors evenly across
  # the gradient, preserving the visual balance of the original palette
  interpolated <- color_ramp(n)

  return(interpolated)
}
