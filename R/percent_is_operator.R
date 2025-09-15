#' Strict identity comparison with diagnostics
#'
#' A semantic operator that checks whether two objects are strictly identical,
#' and prints where they differ if not.
#'
#' @param a First object (vector, matrix, or data.frame)
#' @param b Second object (vector, matrix, or data.frame)
#'
#' @return TRUE if identical, FALSE otherwise (with diagnostics)
#' @export
#'
#' @examples
#' 1:3 %is% 1:3                  # TRUE
#' 1:3 %is% c(1, 2, 3)           # FALSE, type mismatch (integer vs double)
#' data.frame(x=1) %is% data.frame(y=1)  # FALSE, column name mismatch
#' m1 <- matrix(1:4, nrow=2)
#' m2 <- matrix(c(1,99,3,4), nrow=2)
#' m1 %is% m2                  # FALSE, value differs at [1,2]
#' c(a=1, b=2) %is% c(b=2, a=1) # FALSE, names differ
`%is%` <- function(a, b) {

  # ===========================================================================
  # Input validation
  # ===========================================================================
  if (missing(a) || missing(b)) {
    cli::cli_abort("Both arguments must be provided to %is%.")
  }

  if (identical(a, b)) return(TRUE)

  is_supported_type <- function(x) {
    (is.atomic(x) && !is.list(x)) || is.matrix(x) || is.data.frame(x)
  }

  if (!is_supported_type(a)) {
    cli::cli_alert_danger("Unsupported type for 'a': {paste(class(a), collapse = ', ')}")
    return(FALSE)
  }
  if (!is_supported_type(b)) {
    cli::cli_alert_danger("Unsupported type for 'b': {paste(class(b), collapse = ', ')}")
    return(FALSE)
  }

  cli::cli_rule("Objects are NOT identical")

  # ===========================================================================
  # Type / structure diagnostics
  # ===========================================================================
  if (!identical(typeof(a), typeof(b))) {
    cli::cli_alert_danger("Type mismatch: {typeof(a)} vs {typeof(b)}")
  }
  if (!identical(class(a), class(b))) {
    cli::cli_alert_danger(
      "Class mismatch: {paste(class(a), collapse = ', ')} vs {paste(class(b), collapse = ', ')}"
    )
  }
  if (is.atomic(a) && !is.matrix(a) && !is.data.frame(a)) {
    if (!identical(length(a), length(b))) {
      cli::cli_alert_danger("Length mismatch: {length(a)} vs {length(b)}")
    }
  }
  if ((is.matrix(a) || is.data.frame(a)) && !identical(dim(a), dim(b))) {
    dims_a <- paste(dim(a), collapse = "x")
    dims_b <- paste(dim(b), collapse = "x")
    cli::cli_alert_danger("Dimension mismatch: {dims_a} vs {dims_b}")
  }

  if (is.data.frame(a)) {
    if (!identical(names(a), names(b))) {
      cli::cli_alert_danger(
        "Column names differ: {paste(names(a), collapse=', ')} vs {paste(names(b), collapse=', ')}"
      )
    }
  } else if (is.matrix(a)) {
    if (!identical(dimnames(a), dimnames(b))) {
      fmt_dn <- function(x) {
        if (is.null(x)) return("<NULL>")
        paste0(
          "(", paste(vapply(x, function(v) if (is.null(v)) "NULL" else paste(v, collapse = "|"),
                      character(1)), collapse = "; "), ")"
        )
      }
      cli::cli_alert_danger("Dimnames differ: {fmt_dn(dimnames(a))} vs {fmt_dn(dimnames(b))}")
    }
  } else if (is.atomic(a) && !is.matrix(a) && !is.data.frame(a)) {
    if (!identical(names(a), names(b))) {
      nma <- if (is.null(names(a))) "<NULL>" else paste(names(a), collapse = ", ")
      nmb <- if (is.null(names(b))) "<NULL>" else paste(names(b), collapse = ", ")
      cli::cli_alert_danger("Names differ: {nma} vs {nmb}")
    }
  }

  # ===========================================================================
  # Value diagnostics (NA-safe)
  # ===========================================================================
  diff_idx_vector <- function(x, y) {
    if (!identical(length(x), length(y))) return(integer(0))
    na_x <- is.na(x); na_y <- is.na(y)
    na_mismatch <- which(xor(na_x, na_y))
    both <- which(!na_x & !na_y)
    val_mismatch <- which(x[both] != y[both])
    c(na_mismatch, both[val_mismatch])
  }

  diff_idx_matrix <- function(x, y) {
    if (!identical(dim(x), dim(y))) return(matrix(numeric(0), ncol = 2))
    na_x <- is.na(x); na_y <- is.na(y)
    na_mismatch <- which(xor(na_x, na_y), arr.ind = TRUE)
    both <- which(!(na_x | na_y), arr.ind = TRUE)
    val_mismatch <- both[x[both] != y[both], , drop = FALSE]
    rbind(na_mismatch, val_mismatch)
  }

  if (is.atomic(a) && !is.matrix(a) && !is.data.frame(a) &&
      identical(length(a), length(b))) {
    idx <- diff_idx_vector(a, b)
    if (length(idx) > 0L) {
      i <- idx[1]
      va <- if (is.na(a[i])) "NA" else as.character(a[i])
      vb <- if (is.na(b[i])) "NA" else as.character(b[i])
      cli::cli_alert_danger(
        "Values differ at {length(idx)} position(s), e.g., index {i}: {va} vs {vb}"
      )
    }
  }

  if (is.matrix(a) && is.matrix(b) && identical(dim(a), dim(b))) {
    midx <- diff_idx_matrix(a, b)
    if (length(midx)) {
      r1 <- midx[1, 1]; c1 <- midx[1, 2]
      va <- if (is.na(a[r1, c1])) "NA" else as.character(a[r1, c1])
      vb <- if (is.na(b[r1, c1])) "NA" else as.character(b[r1, c1])
      cli::cli_alert_danger(
        "Values differ at {nrow(midx)} cell(s), e.g., [{r1},{c1}]: {va} vs {vb}"
      )
    }
  }

  if (is.data.frame(a) && is.data.frame(b) &&
      identical(names(a), names(b)) && identical(dim(a), dim(b))) {
    for (col in names(a)) {
      x <- a[[col]]; y <- b[[col]]
      idx <- diff_idx_vector(x, y)
      if (length(idx) > 0L) {
        i <- idx[1]
        va <- if (is.na(x[i])) "NA" else as.character(x[i])
        vb <- if (is.na(y[i])) "NA" else as.character(y[i])
        cli::cli_alert_danger(
          "Values differ in column '{col}' at {length(idx)} row(s), e.g., row {i}: {va} vs {vb}"
        )
      }
    }
  }

  # ===========================================================================
  # Return
  # ===========================================================================
  return(FALSE)
}
