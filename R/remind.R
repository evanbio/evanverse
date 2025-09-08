#' Show usage tips for common R commands
#'
#' A helper to recall commonly used R functions with examples.
#'
#' @param keyword A keyword like "glimpse" or "read_excel". If NULL, show all examples.
#' @return Printed reminder or keyword list (invisibly)
#' @export
#'
#' @examples
#' remind("glimpse")
#' remind()  # Show all keywords
remind <- function(keyword = NULL) {
  dict <- list(
    glimpse = "`glimpse(df)` from dplyr gives a compact overview.",
    read_excel = "`readxl::read_excel(\"yourfile.xlsx\")` reads Excel files.\nSupports `sheet =`, `range =`, etc.",
    droplevels = "`droplevels(df)` removes unused factor levels from a data frame or factor.",
    modifyList = "`modifyList(x, y)` merges two lists; elements in `y` overwrite those in `x`.",
    do.call = "`do.call(fun, args)` calls a function with arguments in a list: do.call(plot, list(x=1:10)).",
    sprintf = "`sprintf(\"Hello, %s!\", name)` formats strings with placeholders like `%s`, `%d`, etc.",
    scRNAseq = "`scRNAseq` from Bioconductor provides example scRNA-seq datasets, e.g., `ZeiselBrainData()`.",
    basename = "`basename(path)` extracts the filename from a full path string. See also `dirname()`.",
    here = "`here::here(\"data\", \"raw\", \"sample1.rds\")` constructs a path from the project root, eliminating the need for manual setwd().",
    stopifnot = "`topifnot(cond1, cond2, ...)` throws an error if any condition is FALSE.\nUseful for lightweight input validation.",
    object.size = "`object.size(x)` estimates the memory size of an R object. Use `format()` to pretty-print.",
    slice = "`slice(df, 1:3)` selects rows by position. Use `slice_head()`, `slice_tail()`, `slice_max()` for more control.",
    unzip = "Use `unzip(\"file.zip\", exdir = \"dir\")` to extract ZIP archives to a target directory.",
    gunzip = "Use `R.utils::gunzip(\"file.csv.gz\", remove = FALSE)` to decompress .gz files; often used for single compressed files like .csv.gz.",
    untar = "Use `untar(\"file.tar.gz\", exdir = \"dir\")` to extract .tar or .tar.gz archives (supports both .tar and .tar.gz).",
    NoLegend = "`NoLegend()` removes legends from ggplot2/Seurat plots. Useful for cleaner visuals.",
    RotatedAxis = "↪`RotatedAxis()` rotates x-axis text for better readability in dot plots and similar charts.",
    guides = "`guides(fill = \"none\")` customizes or removes legends. Use with `scale_*` in ggplot2.",
    log2 = "`log2(x)` computes base-2 logarithm. Often used for expression fold change and transformation.",
    log = "`log(x, base = exp(1))` is the natural logarithm by default. Use `base = 10` or `2` for others.",
    log10 = "`log10(x)` computes base-10 logarithm. Useful for plotting scales and orders of magnitude.",
    round = "`round(x, digits = 0)` rounds numeric values to the specified number of decimal places.\nUse `signif()` for significant digits instead.",
    floor = "`floor(x)` returns the greatest integer less than or equal to `x`.\nExample: `floor(2.8)` → 2.",
    ceiling = "`ceiling(x)` returns the smallest integer greater than or equal to `x`.\nExample: `ceiling(2.1)` → 3.",
    cut = "`cut(x, breaks)` converts numeric vector into factor bins.\nUse `breaks = 3` (equal-width) or provide custom breakpoints.\nSet `labels = FALSE` to return group indices.",
    cumsum = "`cumsum(x)` computes the cumulative sum of a numeric vector.\nExample: `cumsum(c(1, 2, 3))` → 1 3 6",
    cumprod = "`cumprod(x)` computes the cumulative product of a numeric vector.\nExample: `cumprod(c(2, 3, 4))` → 2 6 24",
    cummin = "`cummin(x)` returns the running minimum of a numeric vector.\nExample: `cummin(c(5, 3, 4))` → 5 3 3",
    cummax = "`cummax(x)` returns the running maximum of a numeric vector.\nExample: `cummax(c(1, 4, 2))` → 1 4 4",
    row_number = "`row_number(x)` returns the ranking (by order) of values in `x`, breaking ties arbitrarily.\nExample: `row_number(c(3, 1, 1, 2))` → 4 1 2 3",
    min_rank = "`min_rank(x)` assigns ranks to values with ties getting the same minimum rank.\nExample: `min_rank(c(3, 1, 1, 2))` → 4 1 1 3",
    dense_rank = "`dense_rank(x)` gives ranks like `min_rank()`, but with no gaps in the ranking.\nExample: `dense_rank(c(3, 1, 1, 2))` → 3 1 1 2",
    percent_rank = "`percent_rank(x)` returns the relative rank in [0, 1], normalized by (n - 1).\nLowest = 0, Highest = 1.\nExample: `percent_rank(c(3, 1, 1, 2))` → 1 0 0 0.5",
    cume_dist = "`cume_dist(x)` returns the cumulative proportion of values ≤ x.\nExample: `cume_dist(c(3, 1, 1, 2))` → 1 0.5 0.5 0.75",
    str_view = "`str_view(string, pattern)` visually highlights regex matches in RStudio Viewer.\nUse `str_view_all()` to show all matches.\nExample: `str_view(\"banana\", \"an\")`",
    str_c = "`str_c(...)` concatenates strings without separator by default.\nUse `str_c(..., sep = \", \")` or `collapse = \" / \"` for joining vectors.\nExample: `str_c(\"a\", 1:3)` → \"a1\" \"a2\" \"a3\"",
    str_glue = "`str_glue(\"Hello, {name}!\")` inserts variables directly in strings using `{}`.\nSupports expressions inside `{}`. Requires `glue` package.\nExample: `str_glue(\"{x} + {y} = {x + y}\")`",
    str_flatten = "`str_flatten(x, collapse = \", \")` joins a character vector into a single string.\nMore readable alternative to `str_c(..., collapse = \",\")`.\nExample: `str_flatten(letters[1:3])` → \"a, b, c\"",
    str_length = "`str_length(x)` returns the number of characters in each string.\nExample: `str_length(c(\"cat\", \"moose\"))` → 3 5",
    str_sub = "str_sub(x, start, end)` extracts or replaces substrings by position.\nSupports negative indexing and assignment.\nExample: `str_sub(\"apple\", 1, 3)` → \"app\"",
    today = "`today()` returns the current date as a Date object (no time).\nExample: `today()` → 2025-04-25",
    now = "`now()` returns the current date-time as a POSIXct object.\nIncludes hours, minutes, seconds.\nExample: `now()` → 2025-04-25 22:40:00",
    Sys.timezone = "`Sys.timezone()` returns the system's default time zone name.\nUseful when working with date-times across systems.\nExample: `Sys.timezone()` → \"Asia/Shanghai\"",
    skimr = "`skimr::skim(df)` from the `skimr` package gives comprehensive and readable data summaries in the console. Handles different data types well. Excellent for EDA.",
    par = "`par(mfrow=c(m,n))` splits the plotting area into m rows and n columns.\nUse it to arrange multiple plots on the same canvas.\nExample: `par(mfrow=c(2,2))` → 2×2 grid for 4 plots.",
    layout = "`layout(matrix, widths, heights)` allows custom arrangement of plots.\nMore flexible than `par()`, supports irregular plot layouts.\nExample: layout(matrix(c(1,1,2,3), nrow=2, byrow=TRUE)) → Big plot + two small plots.",
    datatable = "`DT::datatable(data)` creates an interactive table.\nSupports search, filter, sort, pagination.\nIdeal for quickly exploring large datasets in Viewer.",
    windowsFonts = "`windowsFonts()` registers system fonts for plot text.\nUseful when customizing font families like Arial or SimSun in `gpar()`.\nRun once per session before using fontfamily in base or grid graphics.",
    sign = "`sign(x)` returns -1 for negative values, 0 for zero, and 1 for positive values. Handy for extracting the sign of numbers or entire vectors/matrices. Example: `sign(c(-2, 0, 3))` → -1 0 1",
    reactable = "`reactable(data)` builds a customizable, modern table.\nAllows coloring, filtering, tooltips, mini-charts inside cells.\nRecommended for highly polished interactive tables.",
    trimws = "`trimws(x)` removes leading and trailing whitespace"
  )

  # Show all if no keyword is provided
  if (is.null(keyword)) {
    first_key <- names(dict)[1]
    cli::cli_h1("Usage Examples")
    cli::cli_alert_info('"{first_key}": {dict[[first_key]]}')

    cli::cli_rule("Available Keywords")
    cli::cli_text("{.code {paste(names(dict), collapse = ', ')}}")
    return(invisible(NULL))
  }

  # Match keyword
  matches <- grep(keyword, names(dict), ignore.case = TRUE, value = TRUE)
  if (length(matches) == 0) {
    cli::cli_alert_danger("No match found for keyword: {.val {keyword}}")
    return(invisible(FALSE))
  }

  for (m in matches) {
    cli::cli_h1(paste0("🔎 ", m))
    cat(dict[[m]], "\n\n")
  }

  invisible(TRUE)
}


