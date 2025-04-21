#===============================================================================
# 🧪 Test: compile_palettes()
# 📁 File: test-compile_palettes.R
# 🔍 Description: Unit tests for compile_palettes() from JSON files
#===============================================================================

test_that("compile_palettes() compiles valid palettes and returns path", {
  # 构造临时目录与 JSON 文件
  tmp_dir <- tempfile("palettes_")
  dir.create(file.path(tmp_dir, "qualitative"), recursive = TRUE)

  json_path <- file.path(tmp_dir, "qualitative", "demo_palette.json")
  jsonlite::write_json(
    list(
      name = "demo_palette",
      type = "qualitative",
      colors = c("#123456", "#654321")
    ),
    path = json_path,
    pretty = TRUE, auto_unbox = TRUE
  )

  # 输出路径
  out_rds <- tempfile(fileext = ".rds")

  # 调用函数
  result <- compile_palettes(
    palettes_dir = tmp_dir,
    output_rds = out_rds,
    log = FALSE
  )

  expect_type(result, "character")
  expect_true(file.exists(result))

  palettes <- readRDS(result)
  expect_true("demo_palette" %in% names(palettes$qualitative))
})
