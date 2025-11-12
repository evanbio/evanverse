#' Show usage tips for common R commands
#'
#' A helper to recall commonly used R functions with short examples.
#'
#' @param keyword A keyword like "glimpse" or "read_excel". If `NULL`, show all.
#' @return Invisibly returns the matched keywords (character vector).
#' @export
#'
#' @examples
#' remind("glimpse")
#' remind()  # show all keywords
remind <- function(keyword = NULL) {

  # ===========================================================================
  # Dictionary
  # ===========================================================================
  dict <- list(
    glimpse      = "`glimpse(df)` from dplyr/tibble gives a compact overview.",
    read_excel   = "`readxl::read_excel(\"yourfile.xlsx\")` reads Excel files. Supports `sheet =`, `range =`, etc.",
    droplevels   = "`droplevels(df)` removes unused factor levels from a data frame or factor.",
    modifyList   = "`modifyList(x, y)` merges two lists; elements in `y` overwrite those in `x`.",
    do.call      = "`do.call(fun, args)` calls a function with arguments in a list: `do.call(plot, list(x = 1:10))`.",
    sprintf      = "`sprintf(\"Hello, %s!\", name)` formats strings with `%s`, `%d`, etc.",
    scRNAseq     = "`scRNAseq` (Bioconductor) provides scRNA-seq datasets, e.g., `ZeiselBrainData()`.",
    basename     = "`basename(path)` extracts the filename from a full path. See also `dirname()`.",
    here         = "`here::here(\"data\", \"raw\", \"sample1.rds\")` builds a path from project root.",
    stopifnot    = "`stopifnot(cond1, cond2, ...)` throws if any condition is FALSE.",
    object.size  = "`object.size(x)` estimates memory size; use `format()` to pretty-print.",
    slice        = "`slice(df, 1:3)` selects rows by position; see `slice_head()`, `slice_tail()`, `slice_max()`.",
    unzip        = "`unzip(\"file.zip\", exdir = \"dir\")` extracts ZIP archives.",
    gunzip       = "`R.utils::gunzip(\"file.csv.gz\", remove = FALSE)` decompresses .gz files.",
    untar        = "`untar(\"file.tar.gz\", exdir = \"dir\")` extracts .tar or .tar.gz archives.",
    NoLegend     = "`NoLegend()` removes legends from ggplot2/Seurat plots.",
    RotatedAxis  = "`RotatedAxis()` rotates x-axis text for readability in dot plots.",
    guides       = "`guides(fill = \"none\")` customizes or removes legends (with `scale_*`).",
    log2         = "`log2(x)` base-2 logarithm (often for fold change).",
    log          = "`log(x, base = exp(1))` natural log by default; set `base = 10` or `2` for others.",
    log10        = "`log10(x)` base-10 logarithm (orders of magnitude).",
    round        = "`round(x, digits = 0)` rounds; use `signif()` for significant digits.",
    floor        = "`floor(x)` greatest integer <= x (e.g., `floor(2.8)` -> 2).",
    ceiling      = "`ceiling(x)` smallest integer >= x (e.g., `ceiling(2.1)` -> 3).",
    cut          = "`cut(x, breaks)` bins numeric vector; `breaks = 3` or custom; `labels = FALSE` for group indices.",
    cumsum       = "`cumsum(x)` cumulative sum.",
    cumprod      = "`cumprod(x)` cumulative product.",
    cummin       = "`cummin(x)` running minimum.",
    cummax       = "`cummax(x)` running maximum.",
    row_number   = "`row_number(x)` order rank (ties broken arbitrarily).",
    min_rank     = "`min_rank(x)` ties get the same minimum rank.",
    dense_rank   = "`dense_rank(x)` like `min_rank()` but without gaps.",
    percent_rank = "`percent_rank(x)` relative rank in [0,1], normalized by n-1.",
    cume_dist    = "`cume_dist(x)` cumulative proportion of values <= x.",
    str_view     = "`stringr::str_view(string, pattern)` highlights regex matches; `str_view_all()` for all.",
    str_c        = "`stringr::str_c(...)` concatenates; use `sep`/`collapse` as needed.",
    str_glue     = "`glue::glue(\"Hello, {name}!\")` inline expressions with `{}`.",
    str_flatten  = "`stringr::str_flatten(x, collapse = \", \")` join a character vector.",
    str_length   = "`stringr::str_length(x)` string lengths.",
    str_sub      = "`stringr::str_sub(x, start, end)` extract/replace substrings (supports negative indices).",
    today        = "`lubridate::today()` current Date (no time).",
    now          = "`lubridate::now()` current POSIXct date-time.",
    Sys.timezone = "`Sys.timezone()` system time zone name.",
    skimr        = "`skimr::skim(df)` compact, readable data summaries.",
    par          = "`par(mfrow = c(m, n))` split plotting area (e.g., 2x2).",
    layout       = "`layout(matrix, widths, heights)` flexible plot arrangement.",
    datatable    = "`DT::datatable(data)` interactive table (search/filter/sort/paginate).",
    windowsFonts = "`windowsFonts()` register system fonts (Windows).",
    sign         = "`sign(x)` returns -1/0/1 for negative/zero/positive.",
    reactable    = "`reactable::reactable(data)` modern interactive table.",
    trimws       = "`trimws(x)` removes leading and trailing whitespace.",
    cranlogs     = "`cranlogs::cran_downloads('pkgname', from = 'last-month')` gets CRAN download stats; use `'last-week'`, `'last-day'`, or specific dates.",
    dlstats      = "`dlstats::cran_stats('pkgname')` shows CRAN download trends with plots; supports Bioconductor via `source = 'bioc'`."
  )

  # Validation
  if (!is.null(keyword)) {
    if (!is.character(keyword) || length(keyword) != 1L || is.na(keyword)) {
      cli::cli_abort("`keyword` must be a single non-NA character string or NULL.")
    }
  }

  # Render
  if (is.null(keyword)) {
    cli::cli_h1("Usage Examples")
    for (k in names(dict)) {
      cli::cli_h3(k)
      cli::cli_verbatim(dict[[k]])   # <- no glue evaluation
    }
    cli::cli_rule("Available Keywords")
    cli::cli_text("{.code {paste(names(dict), collapse = ', ')}}")
    return(invisible(names(dict)))
  }

  matches <- grep(keyword, names(dict), ignore.case = TRUE, value = TRUE)
  if (length(matches) == 0L) {
    cli::cli_alert_danger("No match found for keyword: {.val {keyword}}")
    return(invisible(character(0)))
  }

  for (m in matches) {
    cli::cli_h3(m)
    cli::cli_verbatim(dict[[m]])     # <- no glue evaluation
  }
  invisible(matches)
}
