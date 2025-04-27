# R/view.R
#-------------------------------------------------------------------------------
# 📄 view(): Quick Interactive Table Viewer
#-------------------------------------------------------------------------------
#
# Description:
#   Quickly view a data.frame or tibble as an interactive table in the Viewer pane.
#   Powered by reactable. Designed for exploration, QC, or light reports.
#
# Parameters:
# - data         : A data.frame or tibble to display.
# - page_size    : Number of rows per page (default = 10).
# - searchable   : Whether to enable keyword search (default = TRUE).
# - filterable   : Whether to enable column filters (default = TRUE).
# - striped      : Whether to use striped rows (default = TRUE).
# - highlight    : Whether to highlight rows on hover (default = TRUE).
# - compact      : Whether to use a compact table style (default = FALSE).
#
# Example:
#   iris |> view()
#   mtcars |> view(page_size = 20)
#-------------------------------------------------------------------------------

#' @title view
#' @description Quick interactive table viewer using reactable.
#' @param data A data.frame or tibble to display.
#' @param page_size Number of rows per page (default = 10).
#' @param searchable Whether to enable search (default = TRUE).
#' @param filterable Whether to enable column filters (default = TRUE).
#' @param striped Whether to show striped rows (default = TRUE).
#' @param highlight Whether to highlight rows on hover (default = TRUE).
#' @param compact Whether to use a compact layout (default = FALSE).
#' @return A reactable widget rendered in the Viewer pane.
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
  # Check dependencies
  if (!requireNamespace("reactable", quietly = TRUE)) {
    stop("Please install the 'reactable' package to use view().", call. = FALSE)
  }

  # Check input validity
  if (!is.data.frame(data)) {
    stop("Input must be a data.frame or tibble.", call. = FALSE)
  }

  # Render interactive table
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
        fontWeight = "bold",           # Bold column headers
        fontSize = "14px",              # Slightly larger header font
        backgroundColor = "#f7f7f8",    # Light gray background for headers
        color = "#333333",              # Darker text color for headers
        borderBottom = "2px solid #dee2e6" # Bottom border under headers
      ),
      cellStyle = list(
        fontSize = "13px",              # Slightly smaller text for cells
        color = "#555555",              # Gray color for cell text
        padding = "8px 12px"            # Cell padding for spacing
      ),
      stripedColor = "#f6f8fa",          # Color for striped rows
      highlightColor = "#e8f4fa",        # Color when hovering over a row
      borderColor = "#dee2e6"            # Border color for the table
    )
  )
}
