#===============================================================================
# Compile Color Palettes from JSON -> data/palettes.rda
# Input:  inst/extdata/palettes/{sequential,diverging,qualitative}/*.json
# Output: data/palettes.rda  (R package dataset, lazy-loaded)
#
# Run this script whenever palettes are added, removed, or changed:
#   source("data-raw/palettes.R")
#===============================================================================

devtools::load_all()

palettes <- compile_palettes(
  palettes_dir = "inst/extdata/palettes"
)

usethis::use_data(palettes, overwrite = TRUE)
