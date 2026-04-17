# =============================================================================
# utils_toy.R — Internal helpers for toy data generation
# =============================================================================

#' @keywords internal
#' @noRd
.toy_gene_ref_data <- function(species, n) {
  if (species == "human") {
    base <- data.frame(
      symbol = c(
        "TP53", "BRCA1", "MYC", "EGFR", "PTEN", "CDK2", "MDM2", "RB1",
        "CDKN2A", "AKT1", "MTOR", "PIK3CA", "KRAS", "BRAF", "NRAS",
        "VEGFA", "HIF1A", "STAT3", "JAK2", "BCL2"
      ),
      ensembl_id = c(
        "ENSG00000141510", "ENSG00000012048", "ENSG00000136997",
        "ENSG00000146648", "ENSG00000171862", "ENSG00000123374",
        "ENSG00000135679", "ENSG00000139687", "ENSG00000147889",
        "ENSG00000142208", "ENSG00000198793", "ENSG00000121879",
        "ENSG00000133703", "ENSG00000157764", "ENSG00000213281",
        "ENSG00000112715", "ENSG00000100644", "ENSG00000168610",
        "ENSG00000096968", "ENSG00000171791"
      ),
      entrez_id = c(
        7157L, 672L, 4609L, 1956L, 5728L, 1017L, 4193L, 5925L, 1029L,
        207L, 2475L, 5290L, 3845L, 673L, 4893L, 7422L, 3091L, 6774L,
        3717L, 596L
      ),
      stringsAsFactors = FALSE
    )
    filler_prefix <- "EVANH"
    ensembl_prefix <- "ENSG900000"
    entrez_start <- 90000001L
  } else {
    base <- data.frame(
      symbol = c(
        "Trp53", "Brca1", "Myc", "Egfr", "Pten", "Cdk2", "Mdm2", "Rb1",
        "Cdkn2a", "Akt1", "Mtor", "Pik3ca", "Kras", "Braf", "Nras",
        "Vegfa", "Hif1a", "Stat3", "Jak2", "Bcl2"
      ),
      ensembl_id = c(
        "ENSMUSG00000059552", "ENSMUSG00000017146", "ENSMUSG00000022346",
        "ENSMUSG00000020122", "ENSMUSG00000013663", "ENSMUSG00000025358",
        "ENSMUSG00000020184", "ENSMUSG00000022105", "ENSMUSG00000044303",
        "ENSMUSG00000001729", "ENSMUSG00000028991", "ENSMUSG00000027665",
        "ENSMUSG00000030265", "ENSMUSG00000002413", "ENSMUSG00000027852",
        "ENSMUSG00000023951", "ENSMUSG00000021109", "ENSMUSG00000004040",
        "ENSMUSG00000024789", "ENSMUSG00000057329"
      ),
      entrez_id = c(
        22059L, 12189L, 17869L, 13649L, 19211L, 12566L, 17246L, 19645L,
        12578L, 11651L, 56717L, 18706L, 16653L, 109880L, 18176L, 22339L,
        15251L, 20848L, 16452L, 12043L
      ),
      stringsAsFactors = FALSE
    )
    filler_prefix <- "Evanm"
    ensembl_prefix <- "ENSMUSG900000"
    entrez_start <- 91000001L
  }

  filler_n <- 80L
  filler <- data.frame(
    symbol = sprintf("%s%03d", filler_prefix, seq_len(filler_n)),
    ensembl_id = sprintf("%s%05d", ensembl_prefix, seq_len(filler_n)),
    entrez_id = seq.int(entrez_start, length.out = filler_n),
    stringsAsFactors = FALSE
  )

  genes <- rbind(base, filler)
  genes$gene_type <- rep(
    c("protein_coding", "lncRNA", "pseudogene", "miRNA"),
    length.out = nrow(genes)
  )
  genes$species <- species
  genes$ensembl_version <- "113"
  genes$download_date <- as.Date("2025-04-23")
  genes <- genes[, c(
    "symbol", "ensembl_id", "entrez_id", "gene_type", "species",
    "ensembl_version", "download_date"
  )]

  genes[seq_len(min(n, nrow(genes))), ]
}


#' @keywords internal
#' @noRd
.write_tmp_gmt <- function(n = 5L) {
  sets  <- .gmt_data(n)
  lines <- vapply(sets, function(x) {
    paste(c(x$term, x$description, x$genes), collapse = "\t")
  }, character(1))
  path <- tempfile(fileext = ".gmt")
  writeLines(lines, path)
  path
}


#' @keywords internal
#' @noRd
.gmt_data <- function(n) {
  genes <- c(
    "TP53", "BRCA1", "MYC", "EGFR", "PTEN", "CDK2", "MDM2", "RB1",
    "CDKN2A", "AKT1", "MTOR", "PIK3CA", "KRAS", "BRAF", "NRAS",
    "VEGFA", "HIF1A", "STAT3", "JAK2", "BCL2"
  )
  sets <- list(
    list(term = "HALLMARK_P53_PATHWAY",
         description = "Genes regulated by p53",
         genes = genes[1:10]),
    list(term = "HALLMARK_MTORC1_SIGNALING",
         description = "Genes upregulated by mTORC1",
         genes = genes[5:14]),
    list(term = "HALLMARK_HYPOXIA",
         description = "Genes upregulated under hypoxia",
         genes = genes[11:20]),
    list(term = "HALLMARK_APOPTOSIS",
         description = "Genes involved in apoptosis",
         genes = genes[c(1, 3, 5, 7, 9, 11, 13, 15, 17, 19)]),
    list(term = "HALLMARK_PI3K_AKT_MTOR",
         description = "PI3K/AKT/mTOR signaling",
         genes = genes[10:16])
  )
  sets[seq_len(min(n, length(sets)))]
}
