#' 📌 Show usage tips for common R commands
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
    glimpse = "🔍 `glimpse(df)` from dplyr gives a compact overview.",
    read_excel = "📥 `readxl::read_excel(\"yourfile.xlsx\")` reads Excel files.\nSupports `sheet =`, `range =`, etc.",
    droplevels = "🧹 `droplevels(df)` removes unused factor levels from a data frame or factor.",
    modifyList = "🧩 `modifyList(x, y)` merges two lists; elements in `y` overwrite those in `x`.",
    do.call = "🛠️ `do.call(fun, args)` calls a function with arguments in a list: do.call(plot, list(x=1:10)).",
    sprintf = "🧾 `sprintf(\"Hello, %s!\", name)` formats strings with placeholders like `%s`, `%d`, etc.",
    scRNAseq = "🧪 `scRNAseq` from Bioconductor provides example scRNA-seq datasets, e.g., `ZeiselBrainData()`.",
    basename = "🧩 `basename(path)` extracts the filename from a full path string. See also `dirname()`.",
    stopifnot = "⛔ `stopifnot(cond1, cond2, ...)` throws an error if any condition is FALSE.\nUseful for lightweight input validation."
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


