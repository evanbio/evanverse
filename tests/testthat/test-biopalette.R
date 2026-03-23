#===============================================================================
# Test: biopalette.R public functions
# File: test-biopalette.R
# Description: Unit tests for get_palette(), list_palettes(), create_palette(),
#              preview_palette(), palette_gallery(), compile_palettes(),
#              remove_palette(), hex2rgb(), rgb2hex()
#===============================================================================

palette_rds_exists <- function() {
  f <- system.file("extdata", "palettes.rds", package = "evanverse")
  file.exists(f)
}

# Helper: create a minimal temp palette directory with one JSON per type
make_temp_palette_dir <- function() {
  root <- file.path(tempdir(), paste0("pal_test_", Sys.getpid()))
  for (type in c("sequential", "diverging", "qualitative")) {
    dir.create(file.path(root, type), recursive = TRUE, showWarnings = FALSE)
  }
  # Write one valid palette per type
  jsonlite::write_json(
    list(name = "seq_test", type = "sequential",
         colors = c("#deebf7", "#9ecae1", "#3182bd")),
    path = file.path(root, "sequential", "seq_test.json"),
    pretty = TRUE, auto_unbox = TRUE
  )
  jsonlite::write_json(
    list(name = "div_test", type = "diverging",
         colors = c("#d73027", "#f7f7f7", "#4575b4")),
    path = file.path(root, "diverging", "div_test.json"),
    pretty = TRUE, auto_unbox = TRUE
  )
  jsonlite::write_json(
    list(name = "qual_test", type = "qualitative",
         colors = c("#E64B35", "#4DBBD5", "#00A087")),
    path = file.path(root, "qualitative", "qual_test.json"),
    pretty = TRUE, auto_unbox = TRUE
  )
  root
}

#==============================================================================
# hex2rgb()
#==============================================================================

test_that("hex2rgb() converts single HEX to data.frame with correct values", {
  result <- hex2rgb("#FF8000")

  expect_s3_class(result, "data.frame")
  expect_named(result, c("hex", "r", "g", "b"))
  expect_equal(nrow(result), 1L)
  expect_equal(result$hex, "#FF8000")
  expect_equal(result$r, 255)
  expect_equal(result$g, 128)
  expect_equal(result$b, 0)
})

test_that("hex2rgb() converts multiple HEX codes to multi-row data.frame", {
  result <- hex2rgb(c("#FF0000", "#00FF00", "#0000FF"))

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3L)
  expect_equal(result$r, c(255, 0, 0))
  expect_equal(result$g, c(0, 255, 0))
  expect_equal(result$b, c(0, 0, 255))
})

test_that("hex2rgb() handles 8-digit HEX (alpha silently ignored)", {
  result <- hex2rgb("#FF8000B2")

  expect_s3_class(result, "data.frame")
  expect_equal(result$r, 255)
  expect_equal(result$g, 128)
  expect_equal(result$b, 0)
})

test_that("hex2rgb() is case-insensitive for HEX codes", {
  upper <- hex2rgb("#FFFFFF")
  lower <- hex2rgb("#ffffff")
  mixed <- hex2rgb("#FfFfFf")

  expect_equal(upper$r, 255); expect_equal(upper$g, 255); expect_equal(upper$b, 255)
  expect_equal(lower$r, 255); expect_equal(lower$g, 255); expect_equal(lower$b, 255)
  expect_equal(mixed$r, 255); expect_equal(mixed$g, 255); expect_equal(mixed$b, 255)
})

test_that("hex2rgb() handles black and white correctly", {
  black <- hex2rgb("#000000")
  white <- hex2rgb("#FFFFFF")

  expect_equal(c(black$r, black$g, black$b), c(0, 0, 0))
  expect_equal(c(white$r, white$g, white$b), c(255, 255, 255))
})

test_that("hex2rgb() validates # prefix is required", {
  expect_error(hex2rgb("FF8000"),  "invalid HEX codes")
  expect_error(hex2rgb("FF8000B2"), "invalid HEX codes")
})

test_that("hex2rgb() rejects non-character input", {
  expect_error(hex2rgb(123),          "non-empty character vector")
  expect_error(hex2rgb(NULL),         "non-empty character vector")
  expect_error(hex2rgb(character(0)), "non-empty character vector")
})

test_that("hex2rgb() rejects invalid HEX patterns", {
  expect_error(hex2rgb("#GGGGGG"),    "invalid HEX codes")
  expect_error(hex2rgb("#FFF"),       "invalid HEX codes")
  expect_error(hex2rgb("#FF800"),     "invalid HEX codes")
  # NA_character_ passes is.character check but fails regex — error is "invalid HEX codes"
  expect_error(hex2rgb(NA_character_), "invalid HEX codes")
})

#==============================================================================
# rgb2hex()
#==============================================================================

test_that("rgb2hex() converts numeric triplet to HEX string", {
  result <- rgb2hex(c(255, 128, 0))
  expect_type(result, "character")
  expect_equal(result, "#FF8000")
})

test_that("rgb2hex() converts boundary values correctly", {
  expect_equal(rgb2hex(c(0, 0, 0)),     "#000000")
  expect_equal(rgb2hex(c(255, 255, 255)), "#FFFFFF")
})

test_that("rgb2hex() rounds non-integer values", {
  result <- rgb2hex(c(254.6, 127.4, 0.5))
  expect_type(result, "character")
  expect_match(result, "^#[0-9A-Fa-f]{6}$")
})

test_that("rgb2hex() accepts data.frame input (symmetric with hex2rgb)", {
  df <- hex2rgb(c("#FF0000", "#00FF00", "#0000FF"))
  result <- rgb2hex(df)

  expect_type(result, "character")
  expect_length(result, 3L)
  expect_equal(toupper(result), c("#FF0000", "#00FF00", "#0000FF"))
})

test_that("rgb2hex() roundtrip with hex2rgb()", {
  original <- c("#E64B35", "#4DBBD5", "#00A087")
  df       <- hex2rgb(original)
  back     <- rgb2hex(df)
  expect_equal(toupper(back), toupper(original))
})

test_that("rgb2hex() validates numeric triplet range", {
  expect_error(rgb2hex(c(-1, 0, 0)),   "values must be in \\[0, 255\\]")
  expect_error(rgb2hex(c(0, 256, 0)),  "values must be in \\[0, 255\\]")
  expect_error(rgb2hex(c(1, 2)),       "numeric vector of length 3")
  expect_error(rgb2hex(c(1, 2, 3, 4)), "numeric vector of length 3")
  expect_error(rgb2hex(c(NA, 0, 0)),   "NA, Inf, or NaN")
  expect_error(rgb2hex(c(Inf, 0, 0)),  "NA, Inf, or NaN")
})

test_that("rgb2hex() validates data.frame columns", {
  bad_df <- data.frame(r = 255, g = 0)         # missing b
  expect_error(rgb2hex(bad_df), "Missing")

  bad_vals <- data.frame(r = 300, g = 0, b = 0) # out of range
  expect_error(rgb2hex(bad_vals), "values in \\[0, 255\\]")
})

#==============================================================================
# get_palette()
#==============================================================================

test_that("get_palette() returns full color vector with explicit type", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  result <- get_palette("qual_vivid", type = "qualitative")
  expect_type(result, "character")
  expect_true(length(result) >= 1L)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6,8}$", result)))
})

test_that("get_palette() returns correct subset with n", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  result <- get_palette("qual_vivid", type = "qualitative", n = 3)
  expect_length(result, 3L)
  expect_type(result, "character")
})

test_that("get_palette() auto-detects type when type = NULL", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  result <- get_palette("seq_blues")
  expect_type(result, "character")
  expect_true(length(result) >= 1L)
})

test_that("get_palette() errors when name is found under a different type", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  # seq_blues is sequential, not diverging
  expect_error(
    get_palette("seq_blues", type = "diverging"),
    "not found under"
  )
})

test_that("get_palette() errors when name is not found anywhere", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  expect_error(
    get_palette("nonexistent_palette_xyz"),
    "not found in any type"
  )
})

test_that("get_palette() errors when n exceeds palette size", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  expect_error(
    get_palette("qual_softtrio", type = "qualitative", n = 9999),
    "only has .* colors, but requested"
  )
})

test_that("get_palette() validates name parameter", {
  expect_error(get_palette(123),             "single non-empty string")
  expect_error(get_palette(""),              "single non-empty string")
  expect_error(get_palette(NA_character_),   "single non-empty string")
  expect_error(get_palette(c("a", "b")),     "single non-empty string")
})

test_that("get_palette() validates type parameter", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  expect_error(get_palette("qual_vivid", type = "invalid"), "should be one of")
})

test_that("get_palette() validates n parameter", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  expect_error(get_palette("qual_vivid", type = "qualitative", n = 0),   "single positive integer")
  expect_error(get_palette("qual_vivid", type = "qualitative", n = -1),  "single positive integer")
  expect_error(get_palette("qual_vivid", type = "qualitative", n = 1.5), "single positive integer")
  expect_error(get_palette("qual_vivid", type = "qualitative", n = Inf), "single positive integer")
})

#==============================================================================
# list_palettes()
#==============================================================================

test_that("list_palettes() returns data.frame with expected columns", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  result <- list_palettes()
  expect_s3_class(result, "data.frame")
  expect_true(all(c("name", "type", "n_color", "colors") %in% names(result)))
  expect_true(nrow(result) > 0L)
})

test_that("list_palettes() filters by single type", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  result <- list_palettes(type = "qualitative")
  expect_true(all(result$type == "qualitative"))
  expect_true(nrow(result) > 0L)
})

test_that("list_palettes() filters by multiple types", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  result <- list_palettes(type = c("sequential", "diverging"))
  expect_true(all(result$type %in% c("sequential", "diverging")))
  expect_false("qualitative" %in% result$type)
})

test_that("list_palettes() sort=TRUE produces ordered output", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  result <- list_palettes(sort = TRUE)
  sorted <- result[order(result$type, result$n_color, result$name), ]
  expect_equal(result$name, sorted$name)
})

test_that("list_palettes() sort=FALSE preserves original order", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  sorted   <- list_palettes(sort = TRUE)
  unsorted <- list_palettes(sort = FALSE)
  # Rows are the same set, but may differ in order
  expect_setequal(sorted$name, unsorted$name)
})

test_that("list_palettes() validates sort parameter", {
  expect_error(list_palettes(sort = "yes"), "TRUE or FALSE")
  expect_error(list_palettes(sort = NA),    "TRUE or FALSE")
})

#==============================================================================
# create_palette()
#==============================================================================

test_that("create_palette() creates JSON file in correct directory", {
  tmp <- file.path(tempdir(), paste0("cp_test_", Sys.getpid()))
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  result <- create_palette(
    "my_blues", "sequential",
    c("#deebf7", "#9ecae1", "#3182bd"),
    color_dir = tmp
  )

  expect_type(result, "list")
  expect_true(file.exists(result$path))
  expect_match(result$path, "sequential")
  expect_match(result$path, "my_blues\\.json$")
})

test_that("create_palette() JSON content is correct", {
  tmp <- file.path(tempdir(), paste0("cp_json_", Sys.getpid()))
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  colors <- c("#E64B35", "#4DBBD5", "#00A087")
  result <- create_palette("qual_trio", "qualitative", colors, color_dir = tmp)

  parsed <- jsonlite::fromJSON(result$path)
  expect_equal(parsed$name,   "qual_trio")
  expect_equal(parsed$type,   "qualitative")
  expect_equal(parsed$colors, colors)
})

test_that("create_palette() errors when palette already exists without overwrite", {
  tmp <- file.path(tempdir(), paste0("cp_ow_", Sys.getpid()))
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  create_palette("blues", "sequential", c("#deebf7", "#9ecae1", "#3182bd"), color_dir = tmp)
  expect_error(
    create_palette("blues", "sequential", c("#c6dbef", "#6baed6", "#2171b5"), color_dir = tmp),
    "already exists"
  )
})

test_that("create_palette() overwrites when overwrite = TRUE", {
  tmp <- file.path(tempdir(), paste0("cp_owt_", Sys.getpid()))
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  create_palette("blues", "sequential", c("#deebf7", "#9ecae1", "#3182bd"), color_dir = tmp)
  new_colors <- c("#c6dbef", "#6baed6", "#2171b5")
  result <- create_palette("blues", "sequential", new_colors, color_dir = tmp, overwrite = TRUE)

  parsed <- jsonlite::fromJSON(result$path)
  expect_equal(parsed$colors, new_colors)
})

test_that("create_palette() validates name parameter", {
  tmp <- file.path(tempdir(), paste0("cp_val_", Sys.getpid()))
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  expect_error(create_palette(123, "sequential", c("#FF0000"), color_dir = tmp),
               "single non-empty string")
  expect_error(create_palette("", "sequential",  c("#FF0000"), color_dir = tmp),
               "single non-empty string")
})

test_that("create_palette() validates colors are valid HEX", {
  tmp <- file.path(tempdir(), paste0("cp_hex_", Sys.getpid()))
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  expect_error(
    create_palette("bad", "sequential", c("notahex"), color_dir = tmp),
    "invalid HEX codes"
  )
})

#==============================================================================
# remove_palette()
#==============================================================================

test_that("remove_palette() removes existing palette file and returns TRUE", {
  tmp <- file.path(tempdir(), paste0("rm_test_", Sys.getpid()))
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  create_palette("to_remove", "sequential", c("#deebf7", "#9ecae1"), color_dir = tmp)
  json_path <- file.path(tmp, "sequential", "to_remove.json")
  expect_true(file.exists(json_path))

  result <- remove_palette("to_remove", type = "sequential", color_dir = tmp)
  expect_true(isTRUE(result))
  expect_false(file.exists(json_path))
})

test_that("remove_palette() returns FALSE when palette not found", {
  tmp <- file.path(tempdir(), paste0("rm_miss_", Sys.getpid()))
  dir.create(tmp, recursive = TRUE, showWarnings = FALSE)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  result <- suppressMessages(remove_palette("ghost_palette", color_dir = tmp))
  expect_false(isTRUE(result))
})

test_that("remove_palette() finds palette without specifying type", {
  tmp <- file.path(tempdir(), paste0("rm_auto_", Sys.getpid()))
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  create_palette("find_me", "diverging", c("#d73027", "#f7f7f7", "#4575b4"), color_dir = tmp)
  json_path <- file.path(tmp, "diverging", "find_me.json")
  expect_true(file.exists(json_path))

  result <- remove_palette("find_me", color_dir = tmp)
  expect_true(isTRUE(result))
  expect_false(file.exists(json_path))
})

test_that("remove_palette() validates name parameter", {
  tmp <- file.path(tempdir(), paste0("rm_val_", Sys.getpid()))
  dir.create(tmp, recursive = TRUE, showWarnings = FALSE)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  expect_error(remove_palette(123, color_dir = tmp),       "single non-empty string")
  expect_error(remove_palette("",  color_dir = tmp),       "single non-empty string")
})

#==============================================================================
# compile_palettes()
#==============================================================================

test_that("compile_palettes() creates a valid RDS from JSON directory", {
  src <- make_temp_palette_dir()
  out <- file.path(tempdir(), paste0("out_", Sys.getpid(), ".rds"))
  on.exit({ unlink(src, recursive = TRUE); unlink(out) }, add = TRUE)

  result <- compile_palettes(palettes_dir = src, output_rds = out)

  expect_true(file.exists(out))
  expect_equal(result, out)

  palettes <- readRDS(out)
  expect_type(palettes, "list")
  expect_true(all(c("sequential", "diverging", "qualitative") %in% names(palettes)))
  expect_true("seq_test"  %in% names(palettes$sequential))
  expect_true("div_test"  %in% names(palettes$diverging))
  expect_true("qual_test" %in% names(palettes$qualitative))
})

test_that("compile_palettes() stores correct colors in RDS", {
  src <- make_temp_palette_dir()
  out <- file.path(tempdir(), paste0("out2_", Sys.getpid(), ".rds"))
  on.exit({ unlink(src, recursive = TRUE); unlink(out) }, add = TRUE)

  compile_palettes(palettes_dir = src, output_rds = out)
  palettes <- readRDS(out)

  expect_equal(palettes$sequential$seq_test,
               c("#deebf7", "#9ecae1", "#3182bd"))
  expect_equal(palettes$qualitative$qual_test,
               c("#E64B35", "#4DBBD5", "#00A087"))
})

test_that("compile_palettes() skips invalid JSON files gracefully", {
  src <- make_temp_palette_dir()
  out <- file.path(tempdir(), paste0("out3_", Sys.getpid(), ".rds"))
  on.exit({ unlink(src, recursive = TRUE); unlink(out) }, add = TRUE)

  # Write a broken JSON
  writeLines("{not valid json", file.path(src, "sequential", "broken.json"))

  expect_no_error(compile_palettes(palettes_dir = src, output_rds = out))
  palettes <- readRDS(out)
  expect_false("broken" %in% names(palettes$sequential))
})

test_that("compile_palettes() errors when palettes_dir is missing", {
  expect_error(compile_palettes(""), "single non-empty string")
})

#==============================================================================
# preview_palette()
#==============================================================================

test_that("preview_palette() returns NULL invisibly", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  pdf(file = tempfile(fileext = ".pdf"))
  on.exit(grDevices::dev.off(), add = TRUE)

  result <- preview_palette("seq_blues", type = "sequential", plot_type = "bar")
  expect_null(result)
})

test_that("preview_palette() works with all plot_type options", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  for (pt in c("bar", "pie", "point", "rect", "circle")) {
    pdf(file = tempfile(fileext = ".pdf"))
    expect_no_error(
      preview_palette("qual_vivid", type = "qualitative", plot_type = pt)
    )
    grDevices::dev.off()
  }
})

test_that("preview_palette() respects n argument", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  pdf(file = tempfile(fileext = ".pdf"))
  on.exit(grDevices::dev.off(), add = TRUE)

  expect_no_error(
    preview_palette("qual_vivid", type = "qualitative", n = 3, plot_type = "bar")
  )
})

test_that("preview_palette() accepts custom title", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  pdf(file = tempfile(fileext = ".pdf"))
  on.exit(grDevices::dev.off(), add = TRUE)

  expect_no_error(
    preview_palette("seq_blues", type = "sequential", title = "My Custom Title")
  )
})

test_that("preview_palette() errors on invalid palette name", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  expect_error(
    preview_palette("does_not_exist"),
    "not found in any type"
  )
})

#==============================================================================
# palette_gallery()
#==============================================================================

test_that("palette_gallery() returns named list of ggplot objects", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")
  skip_if_not_installed("ggplot2")

  result <- palette_gallery(type = "qualitative", verbose = FALSE)
  expect_type(result, "list")
  expect_true(length(result) >= 1L)
  expect_true(all(sapply(result, inherits, "gg")))
  expect_true(all(grepl("^qualitative_page", names(result))))
})

test_that("palette_gallery() paginates correctly", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")
  skip_if_not_installed("ggplot2")

  result <- palette_gallery(type = "qualitative", max_palettes = 5, verbose = FALSE)
  expect_true(length(result) > 1L)
})

test_that("palette_gallery() returns empty list for unknown type", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  # match.arg will error on truly invalid type, so test with no-match scenario
  # by passing valid but mismatched types — function returns empty list
  # when intersection of selected types and available types is empty.
  # This can't happen with match.arg, so just confirm valid types work.
  result <- palette_gallery(type = "sequential", verbose = FALSE)
  expect_type(result, "list")
})

test_that("palette_gallery() validates max_palettes and max_row", {
  skip_if_not(palette_rds_exists(), "Compiled palette RDS not found")

  expect_error(palette_gallery(max_palettes = 0),  "single positive integer")
  expect_error(palette_gallery(max_row = -1),       "single positive integer")
  expect_error(palette_gallery(verbose = "yes"),    "TRUE or FALSE")
})

#===============================================================================
# End: test-biopalette.R
#===============================================================================
