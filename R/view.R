#' Quick interactive table viewer (reactable)
#'
#' Quickly view a data.frame or tibble as an interactive table in the Viewer pane.
#'
#' @param data A data.frame or tibble to display.
#' @param page_size Number of rows per page (default = 10).
#' @param searchable Whether to enable search (default = TRUE).
#' @param filterable Whether to enable column filters (default = TRUE).
#' @param striped Whether to show striped rows (default = TRUE).
#' @param highlight Whether to highlight rows on hover (default = TRUE).
#' @param compact Whether to use a compact layout (default = FALSE).
#'
#' @return A reactable widget rendered in the Viewer pane.
#' @examples
#' view(iris)
#' view(mtcars, page_size = 20, striped = TRUE, filterable = TRUE)
#'
#' @export
view <- function(
  data,
  page_size = 10,
  searchable = TRUE,
  filterable = TRUE,
  striped = TRUE,
  highlight = TRUE,
  compact = FALSE
) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================
  if (!is.data.frame(data)) {
    cli::cli_abort("Input 'data' must be a data.frame or tibble.")
  }

  if (!is.numeric(page_size) || length(page_size) != 1L || is.na(page_size) || page_size < 1) {
    cli::cli_abort("'page_size' must be a single positive number.")
  }
  page_size <- as.integer(page_size)

  for (nm in c("searchable", "filterable", "striped", "highlight", "compact")) {
    val <- get(nm, inherits = FALSE)
    if (!is.logical(val) || length(val) != 1L || is.na(val)) {
      cli::cli_abort("Parameter '{nm}' must be a single logical value (TRUE/FALSE).")
    }
  }

  # ===========================================================================
  # Dependency check
  # ===========================================================================
  if (!requireNamespace("reactable", quietly = TRUE)) {
    cli::cli_abort("Package 'reactable' is required. Please install it to use view().")
  }

  # ===========================================================================
  # Render
  # ===========================================================================
  reactable::reactable(
    data,
    searchable = searchable,
    filterable = filterable,
    striped = striped,
    highlight = highlight,
    compact = compact,
    pagination = TRUE,
    defaultPageSize = page_size,
    resizable = TRUE,
    bordered = TRUE,
    showPageInfo = TRUE,
    theme = reactable::reactableTheme(
      headerStyle = list(
        fontWeight = "bold",
        fontSize = "14px",
        backgroundColor = "#f7f7f8",
        color = "#333333",
        borderBottom = "2px solid #dee2e6"
      ),
      cellStyle = list(
        fontSize = "13px",
        color = "#555555",
        padding = "8px 12px"
      ),
      stripedColor = "#f6f8fa",
      highlightColor = "#e8f4fa",
      borderColor = "#dee2e6"
    )
  )
}
