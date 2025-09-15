#' Human Gene Reference (All Genes)
#'
#' A data frame containing all annotated human genes, including both protein-coding and non-coding types.
#' This dataset is primarily used for gene ID conversion and enrichment analysis.
#'
#' @format A data frame with multiple rows (genes) and columns such as `symbol` and `entrez_id`.
#' @source Downloaded and processed from Ensembl database (via `download_gene_ref()` function).

#' Human Gene Reference (Filtered Genes)
#'
#' A data frame containing a filtered subset of human genes, retaining only entries with valid `symbol` and `entrez_id`.
#' Used for cases requiring higher-quality gene identifiers, such as functional enrichment or ID mapping.
#'
#' @format A data frame with multiple rows (filtered genes) and similar columns as the full set.
#' @source Derived from the full human gene reference dataset after filtering missing or invalid entries.

#' Mouse Gene Reference (All Genes)
#'
#' A data frame containing all annotated mouse genes, used for cross-species gene analysis and mapping.
#' Includes both coding and non-coding genes.
#'
#' @format A data frame with rows representing genes and columns including `symbol` and `entrez_id`.
#' @source Downloaded and processed from Ensembl database (via `download_gene_ref()` function).

#' Mouse Gene Reference (Filtered Genes)
#'
#' A filtered version of the mouse gene reference, keeping only genes with non-missing `symbol` and `entrez_id`.
#' Suitable for downstream analyses that require reliable gene identifiers.
#'
#' @format A data frame with multiple rows (filtered genes) and standard annotation columns.
#' @source Derived from the full mouse gene reference dataset after filtering missing or invalid entries.

#' MSigDB Hallmark Gene Sets (Expanded Format)
#'
#' A long-format tibble representing the MSigDB Hallmark gene sets, where each row corresponds to a single gene-term association.
#' Useful for gene set enrichment analysis and visualization.
#'
#' @format A tibble with three columns:
#' \describe{
#'   \item{term}{Name of the hallmark gene set}
#'   \item{description}{Brief description of the gene set}
#'   \item{gene}{Gene symbol associated with the term}
#' }
#' @source Extracted and parsed from the MSigDB v2024.1 (h.all.v2024.1.Hs.symbols.gmt).
