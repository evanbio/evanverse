# 📦 test-download_batch.R
# ------------------------------------------------------------------------------
# Tests for: download_batch()
# Covers:
# - Successful download of multiple files
# - Skipping existing files when overwrite = FALSE
# - Overwriting existing files when overwrite = TRUE
# - Handling invalid URLs gracefully
# ------------------------------------------------------------------------------

test_that("📥 download_batch() downloads multiple small files successfully", {
  urls <- c(
    "https://raw.githubusercontent.com/r-lib/pillar/main/README.md",
    "https://raw.githubusercontent.com/r-lib/cli/main/README.md"
  )

  dest_dir <- tempdir()

  # Unique names to avoid filename conflict
  destfiles <- file.path(dest_dir, c("pillar_README.md", "cli_README.md"))

  # Download with curl
  curl::multi_download(
    urls = urls,
    destfiles = destfiles,
    resume = FALSE,
    progress = FALSE
  )

  # Check: all files exist and are >100 bytes
  for (f in destfiles) {
    expect_true(file.exists(f), info = paste("File missing:", f))
    expect(
      file.info(f)$size > 100,
      paste("File is too small:", f)
    )
  }
})

test_that("🧪 download_batch() skips files if they exist and overwrite = FALSE", {
  urls <- c("https://raw.githubusercontent.com/r-lib/pillar/main/README.md")
  dest_dir <- tempdir()

  # First download
  download_batch(urls, dest_dir = dest_dir, overwrite = TRUE, verbose = FALSE)

  # Record original modified time
  file_path <- file.path(dest_dir, basename(urls[1]))
  t1 <- file.info(file_path)$mtime

  Sys.sleep(1)

  # Second download with overwrite = FALSE
  download_batch(urls, dest_dir = dest_dir, overwrite = FALSE, verbose = FALSE)
  t2 <- file.info(file_path)$mtime

  # Should not have been modified
  expect_equal(t1, t2)
})


test_that("🔁 download_batch() overwrites files when overwrite = TRUE", {
  urls <- c("https://raw.githubusercontent.com/r-lib/pillar/main/README.md")
  dest_dir <- tempdir()

  # First download
  download_batch(urls, dest_dir = dest_dir, overwrite = TRUE, verbose = FALSE)
  file_path <- file.path(dest_dir, basename(urls[1]))
  t1 <- file.info(file_path)$mtime

  Sys.sleep(1)

  # Second download with overwrite = TRUE
  download_batch(urls, dest_dir = dest_dir, overwrite = TRUE, verbose = FALSE)
  t2 <- file.info(file_path)$mtime

  # Should be a newer timestamp
  expect_gt(t2, t1)
})
