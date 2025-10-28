# =============================================================================
# Tests for scale_evanverse_discrete.R
# =============================================================================

# =============================================================================
# Basic Functionality Tests
# =============================================================================

test_that("scale_color_evanverse() returns valid ggplot2 scale object", {
  scale <- scale_color_evanverse("qual_vivid")

  expect_s3_class(scale, "ScaleDiscrete")
  expect_s3_class(scale, "Scale")
  expect_s3_class(scale, "ggproto")
})


test_that("scale_fill_evanverse() returns valid ggplot2 scale object", {
  scale <- scale_fill_evanverse("qual_vivid")

  expect_s3_class(scale, "ScaleDiscrete")
  expect_s3_class(scale, "Scale")
  expect_s3_class(scale, "ggproto")
})


test_that("scale_colour_evanverse() alias works correctly", {
  scale1 <- scale_color_evanverse("qual_vivid")
  scale2 <- scale_colour_evanverse("qual_vivid")

  expect_s3_class(scale2, "ScaleDiscrete")
  expect_identical(class(scale1), class(scale2))
})


# =============================================================================
# Type Inference Tests
# =============================================================================

test_that("scale_color_evanverse() infers sequential type correctly", {
  scale <- scale_color_evanverse("seq_blues")

  expect_s3_class(scale, "ScaleDiscrete")
})


test_that("scale_color_evanverse() infers diverging type correctly", {
  scale <- scale_color_evanverse("div_fireice")

  expect_s3_class(scale, "ScaleDiscrete")
})


test_that("scale_color_evanverse() infers qualitative type correctly", {
  scale <- scale_color_evanverse("qual_vivid")

  expect_s3_class(scale, "ScaleDiscrete")
})


test_that("scale_color_evanverse() works with explicit type parameter", {
  scale <- scale_color_evanverse("qual_vivid", type = "qualitative")

  expect_s3_class(scale, "ScaleDiscrete")
})


# =============================================================================
# Reverse Parameter Tests
# =============================================================================

test_that("scale_color_evanverse() works with reverse = FALSE", {
  scale <- scale_color_evanverse("qual_vivid", reverse = FALSE)

  expect_s3_class(scale, "ScaleDiscrete")

  # Get original colors
  colors_normal <- suppressMessages(get_palette("qual_vivid", type = "qualitative"))
  expect_equal(scale$palette(length(colors_normal)), colors_normal)
})


test_that("scale_color_evanverse() works with reverse = TRUE", {
  scale <- scale_color_evanverse("qual_vivid", reverse = TRUE)

  expect_s3_class(scale, "ScaleDiscrete")

  # Get reversed colors
  colors_original <- suppressMessages(get_palette("qual_vivid", type = "qualitative"))
  colors_reversed <- rev(colors_original)
  expect_equal(scale$palette(length(colors_reversed)), colors_reversed)
})


# =============================================================================
# n Parameter Tests - Qualitative Palettes
# =============================================================================

test_that("qualitative palette with n < palette size uses direct selection", {
  # Get original palette
  colors_all <- suppressMessages(get_palette("qual_vivid", type = "qualitative"))
  n_request <- min(3, length(colors_all))

  scale <- scale_color_evanverse("qual_vivid", n = n_request)

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(length(scale$palette(n_request)), n_request)

  # Should be the first n colors (no interpolation)
  expect_equal(scale$palette(n_request), colors_all[seq_len(n_request)])
})


test_that("qualitative palette with n = 1 works correctly", {
  scale <- scale_color_evanverse("qual_vivid", n = 1)

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(length(scale$palette(1)), 1)

  # Should be the first color
  colors_all <- suppressMessages(get_palette("qual_vivid", type = "qualitative"))
  expect_equal(scale$palette(1), colors_all[1])
})


# =============================================================================
# n Parameter Tests - Sequential Palettes
# =============================================================================

test_that("sequential palette with n < palette size uses interpolation", {
  # Get original palette
  colors_all <- suppressMessages(get_palette("seq_blues", type = "sequential"))
  n_request <- min(3, length(colors_all) - 1)

  scale <- scale_color_evanverse("seq_blues", n = n_request)

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(length(scale$palette(n_request)), n_request)

  # Should NOT be just the first n colors (interpolation should be used)
  # Check that first and last colors span the range
  interpolated <- scale$palette(n_request)
  # First color should be close to original first
  # Last color should be close to original last
  expect_true(grepl("^#[0-9A-Fa-f]{6}$", interpolated[1]))
  expect_true(grepl("^#[0-9A-Fa-f]{6}$", interpolated[n_request]))
})


test_that("sequential palette with n = 1 returns first color", {
  scale <- scale_color_evanverse("seq_blues", n = 1)

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(length(scale$palette(1)), 1)
})


# =============================================================================
# n Parameter Tests - Diverging Palettes
# =============================================================================

test_that("diverging palette with n < palette size uses interpolation", {
  # Get original palette
  colors_all <- suppressMessages(get_palette("div_fireice", type = "diverging"))
  n_request <- min(5, length(colors_all) - 1)

  scale <- scale_color_evanverse("div_fireice", n = n_request)

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(length(scale$palette(n_request)), n_request)

  # Should use interpolation to maintain symmetry
  interpolated <- scale$palette(n_request)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", interpolated)))
})


test_that("diverging palette with n = 1 returns middle color", {
  scale <- scale_color_evanverse("div_fireice", n = 1)

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(length(scale$palette(1)), 1)
})


# =============================================================================
# n Parameter Error Tests
# =============================================================================

test_that("scale_color_evanverse() errors when n > palette size", {
  colors_all <- suppressMessages(get_palette("qual_vivid", type = "qualitative"))
  n_available <- length(colors_all)

  expect_error(
    scale_color_evanverse("qual_vivid", n = n_available + 1),
    "Requested .+ color"
  )
})


test_that("scale_fill_evanverse() errors when n > palette size", {
  colors_all <- suppressMessages(get_palette("seq_blues", type = "sequential"))
  n_available <- length(colors_all)

  expect_error(
    scale_fill_evanverse("seq_blues", n = n_available + 1),
    "Requested .+ color"
  )
})


# =============================================================================
# na.value Parameter Tests
# =============================================================================

test_that("scale_color_evanverse() works with custom na.value", {
  scale <- scale_color_evanverse("qual_vivid", na.value = "red")

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(scale$na.value, "red")
})


test_that("scale_fill_evanverse() works with custom na.value", {
  scale <- scale_fill_evanverse("qual_vivid", na.value = "#FF0000")

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(scale$na.value, "#FF0000")
})


# =============================================================================
# guide Parameter Tests
# =============================================================================

test_that("scale_color_evanverse() works with guide = 'legend'", {
  scale <- scale_color_evanverse("qual_vivid", guide = "legend")

  expect_s3_class(scale, "ScaleDiscrete")
})


test_that("scale_color_evanverse() works with guide = 'none'", {
  scale <- scale_color_evanverse("qual_vivid", guide = "none")

  expect_s3_class(scale, "ScaleDiscrete")
})


# =============================================================================
# Additional ggplot2 Parameters Tests
# =============================================================================

test_that("scale_color_evanverse() accepts additional ggplot2 parameters", {
  scale <- scale_color_evanverse(
    "qual_vivid",
    name = "Custom Legend",
    labels = c("A", "B", "C")
  )

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(scale$name, "Custom Legend")
})


test_that("scale_fill_evanverse() accepts additional ggplot2 parameters", {
  scale <- scale_fill_evanverse(
    "qual_vivid",
    name = "Fill Variable",
    breaks = c("A", "B")
  )

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(scale$name, "Fill Variable")
})


# =============================================================================
# Parameter Validation Error Tests
# =============================================================================

test_that("scale_color_evanverse() errors with missing palette", {
  expect_error(
    scale_color_evanverse(),
    "must be a single non-empty character string"
  )
})


test_that("scale_color_evanverse() errors with empty palette name", {
  expect_error(
    scale_color_evanverse(""),
    "must be a single non-empty character string"
  )
})


test_that("scale_color_evanverse() errors with NA palette name", {
  expect_error(
    scale_color_evanverse(NA_character_),
    "must be a single non-empty character string"
  )
})


test_that("scale_color_evanverse() errors with multiple palette names", {
  expect_error(
    scale_color_evanverse(c("qual_vivid", "seq_blues")),
    "must be a single non-empty character string"
  )
})


test_that("scale_color_evanverse() errors with invalid reverse parameter", {
  expect_error(
    scale_color_evanverse("qual_vivid", reverse = "yes"),
    "must be a single logical value"
  )

  expect_error(
    scale_color_evanverse("qual_vivid", reverse = NA),
    "must be a single logical value"
  )

  expect_error(
    scale_color_evanverse("qual_vivid", reverse = c(TRUE, FALSE)),
    "must be a single logical value"
  )
})


test_that("scale_color_evanverse() errors with invalid n parameter", {
  expect_error(
    scale_color_evanverse("qual_vivid", n = -1),
    "must be a single positive integer"
  )

  expect_error(
    scale_color_evanverse("qual_vivid", n = 0),
    "must be a single positive integer"
  )

  expect_error(
    scale_color_evanverse("qual_vivid", n = 3.5),
    "must be a single positive integer"
  )

  expect_error(
    scale_color_evanverse("qual_vivid", n = "three"),
    "must be a single positive integer"
  )

  expect_error(
    scale_color_evanverse("qual_vivid", n = NA),
    "must be a single positive integer"
  )

  expect_error(
    scale_color_evanverse("qual_vivid", n = c(2, 3)),
    "must be a single positive integer"
  )
})


test_that("scale_color_evanverse() errors with invalid na.value parameter", {
  expect_error(
    scale_color_evanverse("qual_vivid", na.value = NA_character_),
    "must be a single character string"
  )

  expect_error(
    scale_color_evanverse("qual_vivid", na.value = c("red", "blue")),
    "must be a single character string"
  )

  expect_error(
    scale_color_evanverse("qual_vivid", na.value = 123),
    "must be a single character string"
  )
})


test_that("scale_color_evanverse() errors with non-existent palette", {
  # Use a palette name with valid prefix but that doesn't exist
  expect_error(
    scale_color_evanverse("qual_nonexistent_xyz123"),
    "Failed to retrieve palette"
  )
})


test_that("scale_color_evanverse() errors with invalid type parameter", {
  expect_error(
    scale_color_evanverse("qual_vivid", type = "invalid_type"),
    "'arg' should be one of"
  )
})


test_that("scale_color_evanverse() errors when type cannot be inferred", {
  expect_error(
    scale_color_evanverse("invalid_prefix_palette"),
    "Cannot automatically infer palette type"
  )
})


# =============================================================================
# Integration Tests with ggplot2
# =============================================================================

test_that("scale_color_evanverse() integrates with ggplot - scatter plot", {
  skip_if_not_installed("ggplot2")

  p <- ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width, color = Species)) +
    ggplot2::geom_point() +
    scale_color_evanverse("qual_vivid")

  expect_s3_class(p, "ggplot")

  # Build plot to ensure no errors
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})


test_that("scale_fill_evanverse() integrates with ggplot - boxplot", {
  skip_if_not_installed("ggplot2")

  p <- ggplot2::ggplot(iris, ggplot2::aes(x = Species, y = Sepal.Length, fill = Species)) +
    ggplot2::geom_boxplot() +
    scale_fill_evanverse("qual_vivid")

  expect_s3_class(p, "ggplot")

  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})


test_that("scale_fill_evanverse() integrates with ggplot - bar plot", {
  skip_if_not_installed("ggplot2")

  p <- ggplot2::ggplot(mtcars, ggplot2::aes(x = factor(cyl), fill = factor(cyl))) +
    ggplot2::geom_bar() +
    scale_fill_evanverse("qual_vibrant")

  expect_s3_class(p, "ggplot")

  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})


test_that("scale_color_evanverse() handles NA values in data", {
  skip_if_not_installed("ggplot2")

  df <- data.frame(
    x = 1:4,
    y = 1:4,
    group = c("A", "B", "C", NA)
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, color = group)) +
    ggplot2::geom_point() +
    scale_color_evanverse("qual_vivid", na.value = "grey50")

  expect_s3_class(p, "ggplot")

  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})


test_that("scale_color_evanverse() with reversed colors integrates correctly", {
  skip_if_not_installed("ggplot2")

  p <- ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width, color = Species)) +
    ggplot2::geom_point() +
    scale_color_evanverse("qual_vivid", reverse = TRUE)

  expect_s3_class(p, "ggplot")

  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})


test_that("scale_color_evanverse() with n parameter integrates correctly", {
  skip_if_not_installed("ggplot2")

  p <- ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width, color = Species)) +
    ggplot2::geom_point() +
    scale_color_evanverse("qual_vivid", n = 3)

  expect_s3_class(p, "ggplot")

  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})


# =============================================================================
# Internal Helper Function Tests
# =============================================================================

test_that(".infer_palette_type() infers 'sequential' from seq_ prefix", {
  type <- evanverse:::.infer_palette_type("seq_blues")
  expect_equal(type, "sequential")

  type <- evanverse:::.infer_palette_type("seq_anything")
  expect_equal(type, "sequential")
})


test_that(".infer_palette_type() infers 'diverging' from div_ prefix", {
  type <- evanverse:::.infer_palette_type("div_fireice")
  expect_equal(type, "diverging")

  type <- evanverse:::.infer_palette_type("div_anything")
  expect_equal(type, "diverging")
})


test_that(".infer_palette_type() infers 'qualitative' from qual_ prefix", {
  type <- evanverse:::.infer_palette_type("qual_vivid")
  expect_equal(type, "qualitative")

  type <- evanverse:::.infer_palette_type("qual_anything")
  expect_equal(type, "qualitative")
})


test_that(".infer_palette_type() errors with invalid prefix", {
  expect_error(
    evanverse:::.infer_palette_type("invalid_prefix"),
    "Cannot automatically infer palette type"
  )

  expect_error(
    evanverse:::.infer_palette_type("nounderscore"),
    "Cannot automatically infer palette type"
  )
})


test_that(".interpolate_palette_smart() generates correct number of colors", {
  base_colors <- c("#FF0000", "#00FF00", "#0000FF")
  n <- 5

  interpolated <- evanverse:::.interpolate_palette_smart(base_colors, n = n, type = "sequential")

  expect_equal(length(interpolated), n)
  expect_type(interpolated, "character")
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", interpolated)))
})


test_that(".interpolate_palette_smart() returns colors as-is when n equals length", {
  base_colors <- c("#FF0000", "#00FF00", "#0000FF")
  n <- length(base_colors)

  interpolated <- evanverse:::.interpolate_palette_smart(base_colors, n = n, type = "sequential")

  expect_equal(interpolated, base_colors)
})


test_that(".interpolate_palette_smart() handles n = 1 for sequential palettes", {
  base_colors <- c("#FF0000", "#00FF00", "#0000FF")

  interpolated <- evanverse:::.interpolate_palette_smart(base_colors, n = 1, type = "sequential")

  expect_equal(length(interpolated), 1)
  expect_equal(interpolated, base_colors[1])
})


test_that(".interpolate_palette_smart() handles n = 1 for diverging palettes", {
  base_colors <- c("#FF0000", "#FFFFFF", "#0000FF")

  interpolated <- evanverse:::.interpolate_palette_smart(base_colors, n = 1, type = "diverging")

  expect_equal(length(interpolated), 1)
  # Should return middle color
  expect_equal(interpolated, base_colors[2])
})


test_that(".interpolate_palette_smart() errors with insufficient colors", {
  expect_error(
    evanverse:::.interpolate_palette_smart(c("#FF0000"), n = 5, type = "sequential"),
    "Need at least 2 colors for interpolation"
  )
})


test_that(".interpolate_palette_smart() errors with invalid n", {
  base_colors <- c("#FF0000", "#00FF00")

  expect_error(
    evanverse:::.interpolate_palette_smart(base_colors, n = 0, type = "sequential"),
    "must be at least 1"
  )

  expect_error(
    evanverse:::.interpolate_palette_smart(base_colors, n = -1, type = "sequential"),
    "must be at least 1"
  )
})


test_that(".interpolate_palette_smart() preserves edge colors for sequential", {
  base_colors <- c("#FF0000", "#00FF00", "#0000FF")
  n <- 5

  interpolated <- evanverse:::.interpolate_palette_smart(base_colors, n = n, type = "sequential")

  # First and last should be close to original extremes
  # Using colorRampPalette ensures this
  expect_equal(toupper(interpolated[1]), toupper(base_colors[1]))
  expect_equal(toupper(interpolated[n]), toupper(base_colors[length(base_colors)]))
})


test_that(".interpolate_palette_smart() works for diverging palettes", {
  # 11-color red-white-blue palette
  base_colors <- c(
    "#67001F", "#B2182B", "#D6604D", "#F4A582", "#FDDBC7",
    "#FFFFFF",
    "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC", "#053061"
  )
  n <- 5

  interpolated <- evanverse:::.interpolate_palette_smart(base_colors, n = n, type = "diverging")

  expect_equal(length(interpolated), n)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", interpolated)))

  # Extremes should be preserved
  expect_equal(toupper(interpolated[1]), toupper(base_colors[1]))
  expect_equal(toupper(interpolated[n]), toupper(base_colors[length(base_colors)]))
})


# =============================================================================
# Edge Cases and Special Scenarios
# =============================================================================

test_that("scale_color_evanverse() works with all parameters combined", {
  scale <- scale_color_evanverse(
    palette = "qual_vivid",
    type = "qualitative",
    n = 3,
    reverse = TRUE,
    na.value = "black",
    guide = "legend",
    name = "Test Legend"
  )

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(scale$na.value, "black")
  expect_equal(scale$name, "Test Legend")
})


test_that("scale_fill_evanverse() works with all parameters combined", {
  # First check how many colors are available
  colors_available <- suppressMessages(get_palette("seq_blues", type = "sequential"))
  n_colors <- length(colors_available)

  # Request a subset of available colors
  n_request <- max(2, floor(n_colors * 0.6))

  scale <- scale_fill_evanverse(
    palette = "seq_blues",
    type = "sequential",
    n = n_request,
    reverse = FALSE,
    na.value = "grey80",
    guide = "legend",
    name = "Blues"
  )

  expect_s3_class(scale, "ScaleDiscrete")
  expect_equal(scale$na.value, "grey80")
  expect_equal(scale$name, "Blues")
})


test_that("aesthetics are automatically set correctly for color scale", {
  scale <- scale_color_evanverse("qual_vivid")

  # The aesthetics should be "colour" for color scales
  expect_equal(scale$aesthetics, "colour")
})


test_that("aesthetics are automatically set correctly for fill scale", {
  scale <- scale_fill_evanverse("qual_vivid")

  # The aesthetics should be "fill" for fill scales
  expect_equal(scale$aesthetics, "fill")
})
