#' 🧬 Download gene annotation reference table from Ensembl
#'
#' @description
#' Downloads a standardized gene annotation table for human or mouse using `biomaRt`.
#' Includes Ensembl ID, gene symbol, Entrez ID, gene type, chromosome location, and other metadata.
#'
#' @param species Organism, either `"human"` or `"mouse"`. Default is `"human"`.
#' @param remove_empty_symbol Logical. Remove entries with missing gene symbol. Default: `FALSE`.
#' @param remove_na_entrez Logical. Remove entries with missing Entrez ID. Default: `FALSE`.
#' @param save Logical. Whether to save the result as `.rds`. Default: `FALSE`.
#' @param save_path File path to save (optional). If `NULL`, will use default `gene_ref_<species>_<date>.rds`.
#'
#' @return A `data.frame` containing gene annotation.
#' @export
download_gene_ref <- function(species = c("human", "mouse"),
                              remove_empty_symbol = FALSE,
                              remove_na_entrez = FALSE,
                              save = FALSE,
                              save_path = NULL) {

  # Load namespaces only
  if (!requireNamespace("biomaRt", quietly = TRUE)) {
    stop("Please install 'biomaRt' via BiocManager::install('biomaRt').")
  }
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Please install 'cli' via install.packages('cli').")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Please install 'dplyr' via install.packages('dplyr').")
  }

  library(dplyr)

  species <- match.arg(species)

  dataset <- switch(species,
                    "human" = "hsapiens_gene_ensembl",
                    "mouse" = "mmusculus_gene_ensembl")

  symbol_attr <- switch(species,
                        "human" = "hgnc_symbol",
                        "mouse" = "mgi_symbol")

  mart <- biomaRt::useMart("ensembl", dataset = dataset)

  # Retrieve current Ensembl version
  ensembl_version <- biomaRt::listEnsemblArchives() |>
    dplyr::filter(current_release == "*") |>
    dplyr::pull(version)

  cli::cli_alert_info("[{Sys.time()}] Downloading {species} gene annotation (Ensembl version {ensembl_version})...")

  # Download data
  annotation <- biomaRt::getBM(
    attributes = c("ensembl_gene_id", symbol_attr, "entrezgene_id",
                   "gene_biotype", "chromosome_name", "start_position",
                   "end_position", "strand", "description"),
    mart = mart
  )

  # Rename columns
  colnames(annotation) <- c("ensembl_id", "symbol", "entrez_id", "gene_type",
                            "chromosome", "start", "end", "strand", "description")

  # Add metadata
  annotation <- dplyr::mutate(
    annotation,
    species = species,
    ensembl_version = ensembl_version,
    download_date = Sys.Date()
  )

  # Optional filtering
  if (remove_empty_symbol) {
    annotation <- dplyr::filter(annotation, !is.na(symbol) & symbol != "")
  }
  if (remove_na_entrez) {
    annotation <- dplyr::filter(annotation, !is.na(entrez_id))
  }

  cli::cli_alert_success("[{Sys.time()}] Retrieved {nrow(annotation)} annotated genes.")

  # Save to RDS if requested
  if (save) {
    if (is.null(save_path)) {
      file_name <- paste0("gene_ref_", species, "_", Sys.Date(), ".rds")
      save_path <- file_name
    } else if (!grepl("\\.rds$", save_path, ignore.case = TRUE)) {
      save_path <- paste0(save_path, ".rds")
    }

    saveRDS(annotation, file = save_path)
    cli::cli_alert_info("Saved annotation table to {.file {save_path}}")
  }

  return(annotation)
}
