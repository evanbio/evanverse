#' 🔄 convert_gene_id(): Convert gene identifiers using a reference table
#'
#' @description
#' Converts between Ensembl, Symbol, and Entrez gene IDs using a reference table.
#' Supports both character vectors and data.frame columns. Automatically loads
#' species-specific reference data from `data/`, or downloads if unavailable.
#'
#' @param query Character vector or data.frame to convert.
#' @param from Source ID type (e.g., "symbol", "ensembl_id", "entrez_id").
#' @param to Target ID type(s). Supports multiple.
#' @param species Either `"human"` or `"mouse"`. Default `"human"`.
#' @param query_col If `query` is a data.frame, the column name to convert.
#' @param ref_table Optional reference table.
#' @param keep_na Logical. Whether to keep unmatched rows. Default: `FALSE`.
#' @param preview Logical. Whether to preview output. Default: `TRUE`.
#'
#' @return A `data.frame` containing original and converted columns.
#' @export
convert_gene_id <- function(query,
                            from = "symbol",
                            to = c("ensembl_id", "entrez_id"),
                            species = c("human", "mouse"),
                            query_col = NULL,
                            ref_table = NULL,
                            keep_na = FALSE,
                            preview = TRUE) {
  # --- 1. Standardize field names ---
  standardize_field <- function(x) {
    x <- tolower(x)
    dplyr::case_when(
      x %in% c("ensembl", "ensembl_id", "ensemblgene", "ensembl_gene_id") ~ "ensembl_id",
      x %in% c("symbol", "gene", "gene_symbol", "hgnc_symbol", "mgi_symbol") ~ "symbol",
      x %in% c("entrez", "entrezid", "entrez_id", "entrezgene", "entrezgene_id") ~ "entrez_id",
      TRUE ~ x
    )
  }

  from <- standardize_field(from)
  to <- unique(standardize_field(to))
  species <- match.arg(species)

  stopifnot(length(from) == 1, length(to) >= 1)

  # --- 2. Load reference table if not provided ---
  if (is.null(ref_table)) {
    data_name <- paste0("gene_ref_", species, "_filtered")
    file_path <- file.path("data", paste0(data_name, ".rda"))
    if (file.exists(file_path)) {
      cli::cli_alert_info("📂 Loading reference table from {.file {file_path}}")
      load(file_path, envir = environment())
      ref_table <- get(data_name, envir = environment())
    } else {
      cli::cli_alert_warning("⚠️  Reference table not found locally, downloading...")
      ref_table <- download_gene_ref(species, remove_empty_symbol = TRUE, remove_na_entrez = TRUE)
    }
  }

  all_required <- unique(c(from, to))
  missing_cols <- setdiff(all_required, colnames(ref_table))
  if (length(missing_cols) > 0) {
    stop("Missing column(s) in reference: ", paste(missing_cols, collapse = ", "))
  }

  full_mapping <- ref_table[, all_required]
  full_mapping <- full_mapping[!is.na(full_mapping[[from]]), ]
  full_mapping <- full_mapping[!duplicated(full_mapping[[from]]), ]

  # --- 3. Symbol standardization ---
  if (from == "symbol") {
    if (is.character(query)) {
      if (species == "human") {
        cli::cli_alert_info("🔠 Converting symbols to UPPERCASE (human standard)...")
        query <- toupper(query)
      } else {
        cli::cli_alert_info("🔡 Converting symbols to lowercase (mouse standard)...")
        query <- tolower(query)
      }
    }

    if (is.data.frame(query) && !is.null(query_col)) {
      std_col <- if (species == "human") paste0(query_col, "_upper") else paste0(query_col, "_lower")
      std_fun <- if (species == "human") toupper else tolower
      cli::cli_alert_info("🔤 Creating standardized column: {.field {std_col}}")
      query[[std_col]] <- std_fun(query[[query_col]])
    }
  }

  # --- 4. Handle character input ---
  if (is.character(query)) {
    input_df <- setNames(data.frame(query, stringsAsFactors = FALSE), from)
    result <- dplyr::left_join(input_df, full_mapping, by = from)
    if (!keep_na) result <- dplyr::filter(result, !is.na(result[[to[1]]]))
    if (preview) {
      cli::cli_h2("🔍 Preview of converted IDs")
      print(utils::head(result, 6))
    }
    return(result)
  }

  # --- 5. Handle data.frame input ---
  if (is.data.frame(query)) {
    if (is.null(query_col) || !(query_col %in% colnames(query))) {
      stop("When query is a data.frame, you must specify a valid `query_col`.")
    }

    std_col <- if (from == "symbol") {
      if (species == "human") paste0(query_col, "_upper") else paste0(query_col, "_lower")
    } else {
      query_col
    }

    result <- dplyr::left_join(
      query,
      full_mapping,
      by = setNames(from, std_col)
    )

    if (!keep_na) {
      result <- dplyr::filter(result, !is.na(result[[to[1]]]))
    }

    if (preview) {
      cli::cli_h2("🔍 Preview of converted data.frame")
      print(utils::head(result, 6))
    }

    return(result)
  }

  stop("`query` must be a character vector or a data.frame.")
}
