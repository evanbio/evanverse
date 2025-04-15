#' 📌 Show usage tips for common R commands
#'
#' A helper to recall commonly used R functions with examples.
#'
#' @param keyword A keyword like "glimpse" or "read_excel". If NULL, show all examples.
#' @return Printed reminder or keyword list
#' @export
#'
#' @examples
#' remind("glimpse")
#' remind()  # Show all keywords
remind <- function(keyword = NULL) {
  dict <- list(
    glimpse = "🔍 `glimpse(df)` from dplyr gives a compact overview.",
    read_excel = "📥 `readxl::read_excel(\"yourfile.xlsx\")` reads Excel files.\nSupports `sheet =`, `range =`, etc."
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
