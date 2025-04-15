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
#' 1:3 %is% 1:3          # TRUE
#' 1:3 %is% c(1, 2, 3)   # FALSE, type mismatch
#' data.frame(x=1) %is% data.frame(y=1)  # FALSE, name mismatch
`%is%` <- function(a, b) {
  if (missing(a) || missing(b)) {
    stop("Both arguments must be provided to %is%")
  }

  # 严格相等，直接返回TRUE
  if (identical(a, b)) return(TRUE)

  cli::cli_rule("❌ Objects are NOT identical")

  # 检查是否为支持的类型
  is_supported_type <- function(x) {
    (is.atomic(x) && !is.list(x)) || is.matrix(x) || is.data.frame(x)
  }

  if (!is_supported_type(a)) {
    cli::cli_alert_danger("Unsupported type for a: {.val {class(a)}}")
    return(FALSE)
  }

  if (!is_supported_type(b)) {
    cli::cli_alert_danger("Unsupported type for b: {.val {class(b)}}")
    return(FALSE)
  }

  # 类型检查
  if (!identical(typeof(a), typeof(b))) {
    cli::cli_alert_danger("Type mismatch: {.val {typeof(a)}} vs {.val {typeof(b)}}")
  }

  # class检查
  if (!identical(class(a), class(b))) {
    cli::cli_alert_danger("Class mismatch: {.val {paste(class(a), collapse = ', ')}} vs {.val {paste(class(b), collapse = ', ')}}")
  }

  # 长度检查（向量）
  if (is.vector(a) && !is.matrix(a) && !identical(length(a), length(b))) {
    cli::cli_alert_danger("Length mismatch: {.val {length(a)}} vs {.val {length(b)}}")
  }

  # 维度检查（矩阵或data.frame）
  if ((is.matrix(a) || is.data.frame(a)) && !identical(dim(a), dim(b))) {
    cli::cli_alert_danger("Dimension mismatch: {.val {paste(dim(a), collapse = 'x')}} vs {.val {paste(dim(b), collapse = 'x')}}")
  }

  # 名称检查
  if (is.data.frame(a)) {
    # data.frame检查列名
    if (!identical(names(a), names(b))) {
      cli::cli_alert_danger("Column names differ: {.val {paste0(names(a), collapse = ', ')}} vs {.val {paste0(names(b), collapse = ', ')}}")
    }
  } else if (is.matrix(a)) {
    # 矩阵检查dimnames
    if (!identical(dimnames(a), dimnames(b))) {
      cli::cli_alert_danger("Dimnames differ: {.val {dimnames(a)}} vs {.val {dimnames(b)}}")
    }
  } else if (is.vector(a) && !is.matrix(a)) {
    # 向量检查names
    if (!identical(names(a), names(b))) {
      cli::cli_alert_danger("Names differ: {.val {paste0(names(a), collapse = ', ')}} vs {.val {paste0(names(b), collapse = ', ')}}")
    }
  }

  # 值检查（更详细）
  if (is.data.frame(a) && identical(names(a), names(b)) && identical(dim(a), dim(b))) {
    # data.frame逐列比较
    for (col in names(a)) {
      if (!identical(a[[col]], b[[col]])) {
        cli::cli_alert_danger("Values differ in column '{col}'")
      }
    }
  } else if (is.matrix(a) && identical(dim(a), dim(b))) {
    # 矩阵逐元素比较
    diff_idx <- tryCatch(which(a != b, arr.ind = TRUE), error = function(e) NULL)
    if (!is.null(diff_idx) && nrow(diff_idx) > 0) {
      cli::cli_alert_danger("Values differ at {nrow(diff_idx)} position(s), e.g., [{diff_idx[1,1]},{diff_idx[1,2]}]: {.val {a[diff_idx[1,1], diff_idx[1,2]]}} vs {.val {b[diff_idx[1,1], diff_idx[1,2]]}}")
    }
  } else if (is.vector(a) && !is.matrix(a) && identical(length(a), length(b))) {
    # 向量逐元素比较
    diff_idx <- which(a != b)
    if (length(diff_idx) > 0) {
      cli::cli_alert_danger("Values differ at {length(diff_idx)} position(s), e.g., index {diff_idx[1]}: {.val {a[diff_idx[1]]}} vs {.val {b[diff_idx[1]]}}")
    }
  } else {
    cli::cli_alert_danger("Values are not identical.")
  }

  return(FALSE)
}
