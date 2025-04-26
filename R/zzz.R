.onAttach <- function(libname, pkgname) {
  if (!interactive()) return()
  version <- utils::packageVersion(pkgname)
  cli::cli_text("🎉 Welcome to {pkgname} — your personal R utility toolkit!")
  cli::cli_text("📦 Version: {version}")
  cli::cli_text("💡 Type {cli::col_blue('?evanverse')} to see available functions.")
}

utils::globalVariables(
  c(
    "x", "y", "color", "group", "name", "label_text", "count",
    "symbol", "entrez_id", "gene", "current_release"
  )
)