#===============================================================================
# 🎨 Compile Color Palettes from JSON → RDS
# 📁 Input: inst/extdata/palettes/
# 💾 Output: data/palettes.rds
#===============================================================================

# 📦 Load the evanverse package (make sure it's loaded/installed)
devtools::load_all()

# 🚀 Run the compiler
compile_palettes(
  palettes_dir = "inst/extdata/palettes",
  output_rds = "data/palettes.rds",
  log = TRUE
)
