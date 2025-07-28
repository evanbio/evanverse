#' Bar plot with optional fill grouping, sorting, and directional layout
#'
#' @param data A data frame containing the input data.
#' @param x Column name for the x-axis (quoted or unquoted).
#' @param y Column name for the y-axis (quoted or unquoted).
#' @param fill Optional. A character string specifying the column name to be mapped to fill (grouping).
#' @param direction Plot direction. Either "vertical" or "horizontal". Default is "vertical".
#' @param sort Logical. Whether to sort the bars based on y values. Default is FALSE.
#' @param sort_by Optional. If `fill` is specified and `sort = TRUE`, this selects which level of `fill` is used for sorting.
#' @param sort_dir Sorting direction. Either "asc" (increasing) or "desc" (decreasing). Default is "asc".
#' @param width Numeric. Width of bars. Default is 0.7.
#' @param ... Additional arguments passed to `geom_bar()`, such as `alpha`, `color`, etc.
#'
#' @return A ggplot object showing a bar chart.
#' @export
plot_bar <- function(data, x, y, fill = NULL,
                     direction = c("vertical", "horizontal"),
                     sort = FALSE,
                     sort_by = NULL,
                     sort_dir = c("asc", "desc"),
                     width = 0.7,
                     ...) {
  # 1. 加载依赖包
  library(ggplot2)
  library(ggpubr)
  library(rlang)

  # 2. 匹配方向和排序方式参数
  direction <- match.arg(direction)    # 垂直还是水平
  sort_dir <- match.arg(sort_dir)      # 升序还是降序

  # 3. 获取x和y的符号及字符串形式
  x_sym <- ensym(x)         # 符号类型，便于aes映射
  y_sym <- ensym(y)
  x_str <- as_string(x_sym) # 列名字符串
  y_str <- as_string(y_sym)

  df <- data  # 复制数据防止修改原始data

  # 4. 检查x有重复但未设置fill的情况，发出警告
  if (anyDuplicated(df[[x_str]]) > 0 && is.null(fill)) {
    warning("⚠️ Multiple rows share the same x value, but `fill` is not set.\nDid you forget to specify `fill = \"...\"`?")
  }

  # 5. 处理fill变量（可选的分组着色）
  fill_sym <- NULL
  fill_levels <- NULL
  if (!is.null(fill)) {
    # 检查fill参数是否合法
    if (!is.character(fill) || length(fill) != 1) {
      stop("`fill` must be a single character string, e.g., fill = \"group_var\"")
    }
    if (!fill %in% colnames(df)) {
      stop(paste0("Column `", fill, "` not found in data."))
    }
    # 转为因子，方便后续分组排序
    if (!is.factor(df[[fill]])) {
      df[[fill]] <- as.factor(df[[fill]])
    }
    fill_levels <- levels(df[[fill]])
    # 如果在...里还额外传递了fill参数，则报错（防止冲突）
    if ("fill" %in% names(list(...))) {
      stop("You cannot specify both `fill` as a mapped variable and also pass `fill = ...` in `...`.")
    }
  }

  # 6. 排序功能
  if (sort) {
    if (!is.null(fill)) {
      # 如果有fill，优先根据sort_by指定的分组层级排序
      selected_level <- sort_by
      if (is.null(selected_level)) {
        selected_level <- fill_levels[1] # 默认第一个分组
        warning(paste0("sort = TRUE but `sort_by` is not set. Using first level: ", selected_level))
      } else if (!selected_level %in% fill_levels) {
        stop(paste0("`sort_by = \"", sort_by, "\"` is not a valid level of `fill = \"", fill, "\"`.\nAvailable levels: ",
                    paste(fill_levels, collapse = ", ")))
      }
      # 只取指定分组的子集，按x分组，计算y的均值用于排序
      df_subset <- df[df[[fill]] == selected_level, ]
      df_summary <- df_subset |>
        dplyr::group_by(.data[[x_str]]) |>
        dplyr::summarise(sort_value = mean(.data[[y_str]], na.rm = TRUE), .groups = "drop")
    } else {
      # 没有fill时，直接用唯一x的y值排序
      df_summary <- df[!duplicated(df[[x_str]]), , drop = FALSE]
      df_summary$sort_value <- df_summary[[y_str]]
    }
    # 根据排序值和方向生成新的x的因子顺序
    ordering <- order(df_summary$sort_value, decreasing = (sort_dir == "desc"))
    levels_sorted <- df_summary[[x_str]][ordering]
    df[[x_str]] <- factor(df[[x_str]], levels = levels_sorted)
  }

  # 7. 设置美学映射
  aes_mapping <- if (!is.null(fill)) {
    aes(x = !!x_sym, y = !!y_sym, fill = !!sym(fill))
  } else {
    aes(x = !!x_sym, y = !!y_sym)
  }
  # 设置柱状排列方式，有分组时为dodge，否则identity
  position <- if (!is.null(fill)) "dodge" else "identity"

  # 8. 构建基础ggplot对象
  p <- ggplot(df, aes_mapping) +
    geom_bar(stat = "identity", position = position, width = width, ...) +  # 必须stat="identity"
    theme_pubr()  # 使用ggpubr美化主题

  # 9. 如果direction是horizontal，添加coord_flip()
  if (direction == "horizontal") {
    p <- p + coord_flip()
  }

  # 10. 返回绘图对象
  return(p)
}
