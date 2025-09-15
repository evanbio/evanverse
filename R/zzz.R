# =============================================================================
# zzz.R — Package startup hook
# -----------------------------------------------------------------------------
# Purpose: Show a friendly startup message on attach.
# Notes:
# - Uses cli::emoji() which automatically falls back when emojis are unsupported.
# - Message only appears in interactive sessions.
# - Can be silenced with suppressPackageStartupMessages(library(evanverse)).
# =============================================================================

.onAttach <- function(libname, pkgname) {
  if (!interactive()) return()
  version <- utils::packageVersion(pkgname)

  # Use cli's emoji() (auto-fallback in environments without emoji support)
  cli::cli_text("Welcome to {pkgname} — your personal R utility toolkit!")
  cli::cli_text("Version: {version}")
  cli::cli_text("Tip: type {cli::col_blue('?evanverse')} to see available functions.")
}

# =============================================================================
# Globals for NSE (silence R CMD check notes)
# =============================================================================
utils::globalVariables(
  c(
    "x", "y", "color", "group", "name", "label_text", "count",
    "symbol", "entrez_id", "gene", "current_release"
  )
)
