# =============================================================================
# base.R — Base utility functions
# =============================================================================

# =============================================================================
# Data frame utilities
# =============================================================================

#' Convert a data frame to a named list by grouping
#'
#' Groups a data frame by one column and collects values from another column
#' into a named list.
#'
#' @param data A data.frame or tibble.
#' @param group_col Character. Column name to use as list names.
#' @param value_col Character. Column name to collect as list values.
#'
#' @return A named list where each element is a vector of values for that group.
#' @export
#'
#' @examples
#' df <- data.frame(
#'   cell_type = c("T_cells", "T_cells", "B_cells", "B_cells"),
#'   marker    = c("CD3D", "CD3E", "CD79A", "MS4A1")
#' )
#' df2list(df, "cell_type", "marker")
df2list <- function(data, group_col, value_col) {
  .assert_data_frame(data)
  .assert_scalar_string(group_col)
  .assert_scalar_string(value_col)
  .assert_has_cols(data, c(group_col, value_col))

  split(data[[value_col]], data[[group_col]])
}


#' Convert a data frame to a named vector
#'
#' Extracts two columns from a data frame and returns a named vector, using
#' one column as names and the other as values. The value column type is
#' preserved as-is.
#'
#' @param data A data.frame or tibble.
#' @param name_col Character. Column to use as vector names. Must not contain
#'   \code{NA}, empty strings, or duplicate entries; all trigger an error.
#' @param value_col Character. Column name whose values become the vector elements.
#'   The original column type is preserved.
#'
#' @return A named vector with the same type as \code{data[[value_col]]}.
#' @export
#'
#' @examples
#' df <- data.frame(
#'   gene  = c("TP53", "BRCA1", "MYC"),
#'   score = c(0.9, 0.7, 0.5)
#' )
#' df2vect(df, "gene", "score")
df2vect <- function(data, name_col, value_col) {
  .assert_data_frame(data)
  .assert_scalar_string(name_col)
  .assert_scalar_string(value_col)
  .assert_has_cols(data, c(name_col, value_col))

  names_vec <- data[[name_col]]
  vals_vec  <- data[[value_col]]

  .assert_no_blank(names_vec)

  .assert_no_dupes(names_vec)

  stats::setNames(vals_vec, names_vec)
}


#' Recode a column in a data frame using a named vector
#'
#' Maps values in a column to new values using a named vector (\code{dict}).
#' Unmatched values are replaced with \code{default}. Matched values are kept
#' as-is, including explicit \code{NA} values in \code{dict}.
#'
#' @param data A data.frame.
#' @param column Character. Column name to recode.
#' @param dict Named vector. Names are original values, values are replacements.
#' @param name Character or \code{NULL}. Name of the output column. If \code{NULL}
#'   (default), the original column is overwritten. Otherwise a new column is created.
#' @param default Scalar default value for unmatched entries. Default: \code{NA}.
#'
#' @return A data.frame with the recoded column.
#' @export
#'
#' @examples
#' df <- data.frame(gene = c("TP53", "BRCA1", "EGFR", "XYZ"))
#' dict <- c("TP53" = "Tumor suppressor", "EGFR" = "Oncogene")
#' recode_column(df, "gene", dict, name = "label")
#' recode_column(df, "gene", dict)
recode_column <- function(data, column, dict, name = NULL, default = NA) {
  .assert_data_frame(data)
  .assert_scalar_string(column)
  .assert_has_cols(data, column)

  .assert_named_vector(dict)
  if (!is.null(name)) .assert_scalar_string(name)
  if (length(default) != 1L) {
    cli::cli_abort("{.arg default} must be a scalar value.", call = NULL)
  }

  key <- as.character(data[[column]])
  idx <- match(key, names(dict))
  matched <- !is.na(idx)

  mapped <- rep(default, length(key))
  mapped[matched] <- unname(dict[idx[matched]])

  out_col <- if (is.null(name)) column else name
  data[[out_col]] <- mapped

  data
}


#' Quick interactive table viewer
#'
#' Displays a data.frame as an interactive table in the Viewer pane
#' using \code{reactable}.
#'
#' @param data A data.frame to display.
#' @param n Integer. Number of rows per page. Default: 10.
#'
#' @return A reactable widget rendered in the Viewer pane.
#' @export
#'
#' @examples
#' if (requireNamespace("reactable", quietly = TRUE)) {
#'   view(iris)
#' }
view <- function(data, n = 10) {
  .assert_data_frame(data)
  .assert_count(n)

  if (!requireNamespace("reactable", quietly = TRUE)) {
    cli::cli_abort("Please install {.pkg reactable} to use {.fn view}.", call = NULL)
  }

  reactable::reactable(
    data,
    searchable      = TRUE,
    filterable      = TRUE,
    striped         = TRUE,
    highlight       = TRUE,
    compact         = FALSE,
    pagination      = TRUE,
    defaultPageSize = n,
    resizable       = TRUE,
    bordered        = TRUE,
    showPageInfo    = TRUE,
    theme = reactable::reactableTheme(
      headerStyle  = list(fontWeight = "bold", fontSize = "14px",
                          backgroundColor = "#f7f7f8", color = "#333333",
                          borderBottom = "2px solid #dee2e6"),
      cellStyle    = list(fontSize = "13px", color = "#555555",
                          padding = "8px 12px"),
      stripedColor   = "#f6f8fa",
      highlightColor = "#e8f4fa",
      borderColor    = "#dee2e6"
    )
  )
}


# =============================================================================
# File system utilities
# =============================================================================

#' List files in a directory with metadata
#'
#' Returns a data.frame with file metadata for all files in a directory.
#'
#' @param dir Character. Directory path.
#' @param recursive Logical. Whether to search recursively. Default: FALSE.
#' @param pattern Optional regex to filter file names (e.g., \code{"\\.R$"}). Default: NULL.
#'
#' @return A data.frame with columns: \code{file}, \code{size_MB}, \code{modified_time}, \code{path}.
#' @export
#'
#' @examples
#' file_ls(tempdir())
#' file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
file_ls <- function(dir, recursive = FALSE, pattern = NULL) {
  .assert_scalar_string(dir)
  .assert_flag(recursive)
  if (!is.null(pattern)) .assert_scalar_string(pattern)

  if (!dir.exists(dir)) {
    cli::cli_abort("{.path {dir}} is not an existing directory.", call = NULL)
  }

  files <- list.files(dir, pattern = pattern, recursive = recursive, full.names = TRUE)

  if (length(files) == 0) {
    return(.empty_file_info())
  }

  do.call(rbind, lapply(files, .file_metadata))
}


#' Get metadata for one or more files
#'
#' Returns a data.frame with file metadata for the given file path(s).
#'
#' @param file Character vector of file paths.
#'
#' @return A data.frame with columns: \code{file}, \code{size_MB}, \code{modified_time}, \code{path}.
#' @export
#'
#' @examples
#' f1 <- tempfile(fileext = ".txt")
#' f2 <- tempfile(fileext = ".csv")
#' writeLines("hello", f1)
#' writeLines("a,b\\n1,2", f2)
#' file_info(c(f1, f2))
file_info <- function(file) {
  .assert_character_vector(file)

  missing <- file[!file.exists(file)]
  if (length(missing) > 0L) {
    cli::cli_abort("File{?s} not found: {.path {missing}}", call = NULL)
  }

  files <- unique(file)

  do.call(rbind, lapply(files, .file_metadata))
}


#' Print directory tree structure
#'
#' Prints the directory structure of a given dir in a tree-like format.
#' Invisibly returns the lines so the result can be captured if needed.
#'
#' @param dir Character. Root directory path. Default: \code{"."}.
#' @param max_depth Integer. Maximum recursion depth. Default: 2.
#'
#' @return Invisibly returns a character vector of tree lines.
#' @export
#'
#' @examples
#' file_tree()
#' file_tree(".", max_depth = 3)
file_tree <- function(dir = ".", max_depth = 2) {
  .assert_dir_exists(dir)
  .assert_count_min(max_depth, min = 0L)

  lines <- normalizePath(dir, mustWork = TRUE)

  traverse <- function(p, depth = 0, prefix = "") {
    if (depth >= max_depth) return()
    files <- sort(list.files(p, full.names = TRUE))
    if (length(files) == 0) return()

    for (i in seq_along(files)) {
      f       <- files[i]
      is_last <- (i == length(files))
      lines   <<- c(lines, paste0(prefix, "+-- ", basename(f)))
      if (dir.exists(f)) {
        traverse(f, depth + 1, paste0(prefix, if (is_last) "    " else "|   "))
      }
    }
  }

  traverse(dir)
  writeLines(lines)

  invisible(lines)
}


# =============================================================================
# Gene ID conversion
# =============================================================================

#' Convert gene symbols to Entrez IDs
#'
#' @param x Character vector of gene symbols.
#' @param ref Data frame with columns \code{symbol} and \code{entrez_id}.
#'   If \code{NULL} (default), a full reference is downloaded via
#'   \code{\link{download_gene_ref}} — this may trigger a network request.
#'   For examples and tests, pass \code{toy_gene_ref()} instead.
#' @param species One of \code{"human"} or \code{"mouse"}. Controls symbol
#'   case normalization before matching. Default: \code{"human"}.
#'
#' @return A data.frame with columns \code{symbol} (original input),
#'   \code{symbol_std} (case-normalized), and \code{entrez_id}.
#'   Unmatched entries have \code{NA} in \code{entrez_id}. If the reference
#'   contains duplicated normalized symbols, the first match is used with a warning.
#' @export
#'
#' @examples
#' ref <- toy_gene_ref(species = "human")
#' gene2entrez(c("tp53", "brca1", "MYC"), ref = ref, species = "human")
#'
#' ref <- toy_gene_ref(species = "mouse")
#' gene2entrez(c("Trp53", "Zbp1"), ref = ref, species = "mouse")
gene2entrez <- function(x, ref = NULL, species = c("human", "mouse")) {
  .assert_character_vector(x)
  species <- match.arg(species)

  if (is.null(ref)) {
    ref <- download_gene_ref(species)
  } else {
    .assert_data_frame(ref)
    .assert_has_cols(ref, c("symbol", "entrez_id"))
  }

  x_norm     <- if (species == "human") toupper(x) else tolower(x)
  ref_symbol <- .normalize_ref_symbols(ref$symbol, species)

  idx <- match(x_norm, ref_symbol)

  data.frame(
    symbol     = x,
    symbol_std = x_norm,
    entrez_id  = ref$entrez_id[idx],
    stringsAsFactors = FALSE
  )
}


#' Convert gene symbols to Ensembl IDs
#'
#' @param x Character vector of gene symbols.
#' @param ref Data frame with columns \code{symbol} and \code{ensembl_id}.
#'   If \code{NULL} (default), a full reference is downloaded via
#'   \code{\link{download_gene_ref}} — this may trigger a network request.
#'   For examples and tests, pass \code{toy_gene_ref()} instead.
#' @param species One of \code{"human"} or \code{"mouse"}. Controls symbol
#'   case normalization before matching. Default: \code{"human"}.
#'
#' @return A data.frame with columns \code{symbol} (original input),
#'   \code{symbol_std} (case-normalized), and \code{ensembl_id}.
#'   Unmatched entries have \code{NA} in \code{ensembl_id}. If the reference
#'   contains duplicated normalized symbols, the first match is used with a warning.
#' @export
#'
#' @examples
#' ref <- toy_gene_ref(species = "human")
#' gene2ensembl(c("tp53", "brca1", "MYC"), ref = ref, species = "human")
#'
#' ref <- toy_gene_ref(species = "mouse")
#' gene2ensembl(c("Zbp1", "Sftpd"), ref = ref, species = "mouse")
gene2ensembl <- function(x, ref = NULL, species = c("human", "mouse")) {
  .assert_character_vector(x)
  species <- match.arg(species)

  if (is.null(ref)) {
    ref <- download_gene_ref(species)
  } else {
    .assert_data_frame(ref)
    .assert_has_cols(ref, c("symbol", "ensembl_id"))
  }

  x_norm     <- if (species == "human") toupper(x) else tolower(x)
  ref_symbol <- .normalize_ref_symbols(ref$symbol, species)

  idx <- match(x_norm, ref_symbol)

  data.frame(
    symbol     = x,
    symbol_std = x_norm,
    ensembl_id = ref$ensembl_id[idx],
    stringsAsFactors = FALSE
  )
}


# =============================================================================
# GMT parsing
# =============================================================================

#' Convert a GMT file to a long-format data frame
#'
#' Reads a \code{.gmt} gene set file and returns a long-format data frame with
#' one row per gene.
#'
#' @param file Character. Path to a \code{.gmt} file.
#'
#' @return A data.frame with columns: \code{term}, \code{description}, \code{gene}.
#' @export
#'
#' @examples
#' tmp <- toy_gmt()
#' gmt2df(tmp)
gmt2df <- function(file) {
  .assert_file_exists(file)

  parsed <- .parse_gmt(file)

  result <- lapply(parsed, function(x) {
    data.frame(term = x$term, description = x$description, gene = x$genes,
               stringsAsFactors = FALSE)
  })

  do.call(rbind, result)
}


#' Convert a GMT file to a named list
#'
#' Reads a \code{.gmt} gene set file and returns a named list where each
#' element is a character vector of gene symbols.
#'
#' @param file Character. Path to a \code{.gmt} file.
#'
#' @return A named list where each element is a character vector of gene symbols.
#' @export
#'
#' @examples
#' tmp <- toy_gmt()
#' gmt2list(tmp)
gmt2list <- function(file) {
  .assert_file_exists(file)

  parsed <- .parse_gmt(file)

  stats::setNames(
    lapply(parsed, function(x) x$genes),
    vapply(parsed, function(x) x$term, character(1))
  )
}


# =============================================================================
# Math utilities
# =============================================================================

#' Number of permutations P(n, k)
#'
#' Calculates the number of ordered arrangements of `k` items from `n` distinct items.
#' P(n, k) = n! / (n - k)!
#'
#' @param n Non-negative integer. Total number of items.
#' @param k Non-negative integer. Number of items to arrange. Must be <= `n`.
#'
#' @return A numeric value. Returns `0` when `k > n`, `1` when `k = 0`.
#' @export
#'
#' @examples
#' perm(8, 4)   # 1680
#' perm(5, 2)   # 20
#' perm(10, 0)  # 1
#' perm(5, 6)   # 0
perm <- function(n, k) {
  # Validate inputs
  n <- .assert_count_min(n, min = 0L)
  k <- .assert_count_min(k, min = 0L)

  # Special cases
  if (k > n) return(0)
  if (k == 0) return(1)

  # Warn if result likely overflows double (log scale check via lgamma)
  if (lgamma(n + 1) - lgamma(n - k + 1) > log(.Machine$double.xmax))
    cli::cli_warn("P({n}, {k}) exceeds double range and will return Inf.", call = NULL)

  # Iterative multiplication: avoids computing full factorials
  result <- 1
  for (i in 0:(k - 1)) result <- result * (n - i)
  result
}


#' Number of combinations C(n, k)
#'
#' Calculates the number of ways to choose `k` items from `n` distinct items (unordered).
#' C(n, k) = n! / (k! * (n - k)!)
#'
#' @param n Non-negative integer. Total number of items.
#' @param k Non-negative integer. Number of items to choose. Must be <= `n`.
#'
#' @return A numeric value. Returns `0` when `k > n`, `1` when `k = 0` or `k = n`.
#' @export
#'
#' @examples
#' comb(8, 4)   # 70
#' comb(5, 2)   # 10
#' comb(10, 0)  # 1
#' comb(5, 6)   # 0
comb <- function(n, k) {
  # Validate inputs
  n <- .assert_count_min(n, min = 0L)
  k <- .assert_count_min(k, min = 0L)

  # Special cases
  if (k > n) return(0)
  if (k == 0 || k == n) return(1)

  # Warn if result likely overflows double (log scale check via lgamma)
  if (lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1) > log(.Machine$double.xmax))
    cli::cli_warn("C({n}, {k}) exceeds double range and will return Inf.", call = NULL)

  # Use symmetry C(n,k) = C(n,n-k) to minimise multiplications
  if (k > n - k) k <- n - k
  prod((n - k + 1):n) / factorial(k)
}
