# =============================================================================
# zzz.R - Package startup and initialization
# -----------------------------------------------------------------------------
# Purpose:
# - Initialize palette cache on package load (.onLoad)
# - Show friendly startup message on attach (.onAttach)
# =============================================================================

# =============================================================================
# Package Environment for Caching
# =============================================================================

# Package-level environment for caching palette data
# Reason: Avoids repeated file I/O by storing palettes in memory
.evanverse_env <- new.env(parent = emptyenv())


# =============================================================================
# Package Load Hook (.onLoad)
# =============================================================================

#' @title Load Package Hook
#' @description
#' Called automatically when the package is loaded. Initializes the cache
#' environment but does NOT preload palette data (lazy loading).
#'
#' @param libname Library name (automatically provided by R)
#' @param pkgname Package name (automatically provided by R)
#'
#' @keywords internal
#' @noRd
.onLoad <- function(libname, pkgname) {
  # Mark cache as uninitialized (will be loaded on first access)
  # Reason: Lazy loading - avoid slowing down package load time
  assign("cache_initialized", FALSE, envir = .evanverse_env)
}


# =============================================================================
# Package Attach Hook (.onAttach)
# =============================================================================

.onAttach <- function(libname, pkgname) {
  if (!interactive()) return()
  version <- utils::packageVersion(pkgname)

  # Use cli's emoji() (auto-fallback in environments without emoji support)
  cli::cli_text("Welcome to {pkgname} - your personal R utility toolkit!")
  cli::cli_text("Version: {version}")
  cli::cli_text("Tip: type {cli::col_blue('?evanverse')} to see available functions.")
}

# =============================================================================
# Palette Cache Management Functions
# =============================================================================

#' @title Load Palette Data into Cache
#' @description
#' Internal function to load all palette data from RDS file into package
#' environment for fast retrieval. Called automatically on package load.
#'
#' @return Invisible NULL
#'
#' @keywords internal
#' @noRd
.load_palette_cache <- function() {
  # Get path to palette RDS file
  palette_rds <- system.file("extdata", "palettes.rds", package = "evanverse")

  # Only load if file exists
  if (file.exists(palette_rds)) {
    # Load palette data
    palettes <- readRDS(palette_rds)

    # Store in package environment
    assign("palettes", palettes, envir = .evanverse_env)
    assign("cache_initialized", TRUE, envir = .evanverse_env)
    assign("cache_timestamp", Sys.time(), envir = .evanverse_env)
  } else {
    # Mark cache as uninitialized
    assign("cache_initialized", FALSE, envir = .evanverse_env)
  }

  invisible(NULL)
}


#' @title Get Cached Palette Data
#' @description
#' Internal function to retrieve palette data from cache. If cache is not
#' initialized, loads the data first.
#'
#' @return List of palette data by type
#'
#' @keywords internal
#' @noRd
.get_cached_palettes <- function() {
  # Check if cache is initialized
  if (!exists("cache_initialized", envir = .evanverse_env) ||
      !get("cache_initialized", envir = .evanverse_env)) {
    # Cache not initialized, load it now
    .load_palette_cache()
  }

  # Return cached palettes
  if (exists("palettes", envir = .evanverse_env)) {
    return(get("palettes", envir = .evanverse_env))
  } else {
    return(NULL)
  }
}


#' Clear Palette Cache
#'
#' Clear the internal palette cache and force reload on next access.
#' This is useful if you've updated the palette RDS file and want to
#' reload the data.
#'
#' @return Invisible NULL
#'
#' @examples
#' \dontrun{
#' # Clear cache (rarely needed)
#' clear_palette_cache()
#'
#' # Cache will be automatically reloaded on next get_palette() call
#' get_palette("qual_vivid", type = "qualitative")
#' }
#'
#' @export
clear_palette_cache <- function() {
  # Remove cached data
  if (exists("palettes", envir = .evanverse_env)) {
    rm("palettes", envir = .evanverse_env)
  }
  assign("cache_initialized", FALSE, envir = .evanverse_env)

  cli::cli_alert_success("Palette cache cleared")
  invisible(NULL)
}


#' Reload Palette Cache
#'
#' Force reload of palette data from disk. This is useful if you've updated
#' the palette RDS file and want to refresh the cached data without restarting R.
#'
#' @return Invisible NULL
#'
#' @examples
#' \dontrun{
#' # After updating palettes.rds, reload the cache
#' reload_palette_cache()
#' }
#'
#' @export
reload_palette_cache <- function() {
  # Clear existing cache
  clear_palette_cache()

  # Reload palette data
  .load_palette_cache()

  # Verify reload
  if (exists("cache_initialized", envir = .evanverse_env) &&
      get("cache_initialized", envir = .evanverse_env)) {
    palettes <- get("palettes", envir = .evanverse_env)
    n_palettes <- sum(sapply(palettes, length))
    cli::cli_alert_success("Palette cache reloaded: {n_palettes} palette{?s}")
  } else {
    cli::cli_alert_warning("Failed to reload palette cache")
  }

  invisible(NULL)
}


#' Get Palette Cache Information
#'
#' Display information about the current palette cache status, including
#' whether it's initialized, when it was loaded, and how many palettes
#' are cached.
#'
#' @return List with cache information (invisible)
#'
#' @examples
#' \dontrun{
#' # Check cache status
#' palette_cache_info()
#' }
#'
#' @export
palette_cache_info <- function() {
  # Check initialization status
  if (!exists("cache_initialized", envir = .evanverse_env)) {
    cli::cli_alert_info("Palette cache: Not initialized")
    return(invisible(list(initialized = FALSE)))
  }

  is_init <- get("cache_initialized", envir = .evanverse_env)

  if (!is_init) {
    cli::cli_alert_info("Palette cache: Not initialized")
    return(invisible(list(initialized = FALSE)))
  }

  # Get cache details
  timestamp <- get("cache_timestamp", envir = .evanverse_env)
  palettes <- get("palettes", envir = .evanverse_env)

  # Count palettes by type
  palette_counts <- sapply(palettes, length)
  total_palettes <- sum(palette_counts)

  # Display information
  cli::cli_h2("Palette Cache Information")
  cli::cli_alert_success("Status: Initialized")
  cli::cli_alert_info("Loaded: {format(timestamp, '%Y-%m-%d %H:%M:%S')}")
  cli::cli_alert_info("Total palettes: {total_palettes}")

  cli::cli_h3("Palettes by type")
  for (type in names(palette_counts)) {
    cli::cli_li("{type}: {palette_counts[type]} palette{?s}")
  }

  # Return info invisibly
  invisible(list(
    initialized = TRUE,
    timestamp = timestamp,
    total_palettes = total_palettes,
    by_type = palette_counts
  ))
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
