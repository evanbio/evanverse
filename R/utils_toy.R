# =============================================================================
# utils_toy.R — Internal helpers for toy data generation
# =============================================================================

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
    list(term = "HALLMARK_P53_PATHWAY",      description = "Genes regulated by p53",         genes = genes[1:10]),
    list(term = "HALLMARK_MTORC1_SIGNALING", description = "Genes upregulated by mTORC1",    genes = genes[5:14]),
    list(term = "HALLMARK_HYPOXIA",          description = "Genes upregulated under hypoxia", genes = genes[11:20]),
    list(term = "HALLMARK_APOPTOSIS",        description = "Genes involved in apoptosis",     genes = genes[c(1,3,5,7,9,11,13,15,17,19)]),
    list(term = "HALLMARK_PI3K_AKT_MTOR",   description = "PI3K/AKT/mTOR signaling",        genes = genes[c(10:16)])
  )
  sets[seq_len(min(n, length(sets)))]
}


#' @keywords internal
#' @noRd
.gene_ref_human <- function(n) {
  genes <- structure(list(ensembl_id = c("ENSG00000199396", "ENSG00000295528",
"ENSG00000301748", "ENSG00000253260", "ENSG00000258537", "ENSG00000008196",
"ENSG00000202521", "ENSG00000285726", "ENSG00000284501", "ENSG00000199270",
"ENSG00000294467", "ENSG00000293097", "ENSG00000172845", "ENSG00000270149",
"ENSG00000277660", "ENSG00000292419", "ENSG00000227671", "ENSG00000278499",
"ENSG00000179958", "ENSG00000260659", "ENSG00000266830", "ENSG00000230215",
"ENSG00000303792", "ENSG00000274626", "ENSG00000274917", "ENSG00000259670",
"ENSG00000077800", "ENSG00000110680", "ENSG00000268573", "ENSG00000198804",
"ENSG00000201588", "ENSG00000226461", "ENSG00000182352", "ENSG00000202249",
"ENSG00000258417", "ENSG00000175676", "ENSG00000233136", "ENSG00000225626",
"ENSG00000280984", "ENSG00000294460", "ENSG00000283383", "ENSG00000247570",
"ENSG00000137601", "ENSG00000199396", "ENSG00000263715", "ENSG00000225407",
"ENSG00000100344", "ENSG00000125650", "ENSG00000277117", "ENSG00000231622",
"ENSG00000240435", "ENSG00000263575", "ENSG00000285168", "ENSG00000104881",
"ENSG00000224954", "ENSG00000218565", "ENSG00000213373", "ENSG00000253294",
"ENSG00000115596", "ENSG00000224589", "ENSG00000254833", "ENSG00000305123",
"ENSG00000166492", "ENSG00000156795", "ENSG00000299108", "ENSG00000305549",
"ENSG00000288387", "ENSG00000143013", "ENSG00000281510", "ENSG00000305223",
"ENSG00000264435", "ENSG00000134644", "ENSG00000183439", "ENSG00000255836",
"ENSG00000267827", "ENSG00000268296", "ENSG00000229982", "ENSG00000236077",
"ENSG00000236922", "ENSG00000223168", "ENSG00000147687", "ENSG00000172247",
"ENSG00000239127", "ENSG00000308231", "ENSG00000202521", "ENSG00000229083",
"ENSG00000234079", "ENSG00000254899", "ENSG00000234937", "ENSG00000229661",
"ENSG00000199270", "ENSG00000277718", "ENSG00000303379", "ENSG00000274845",
"ENSG00000229106", "ENSG00000231688", "ENSG00000203560", "ENSG00000291060",
"ENSG00000132589", "ENSG00000301434"),
symbol = c("RNA5S5", "", "", "", "FRMD6-AS2", "TFAP2B", "RNA5S7",
"", "MGAT4B", "RNA5S12", "", "", "SP3", "", "", "", "ZNF731P",
"NPAP1L", "DCTPP1", "", "", "LINC01840", "", "RPS9", "RNA5-8SN5",
"", "FKBP6", "CALCA", "", "MT-CO1", "RNA5S2", "OR10G5P",
"CD300LD-AS1", "RNU5E-5P", "", "GOLGA8DP", "USP17L11", "CFAP95-DT",
"", "", "", "SDCBPP2", "NEK1", "RNA5S5", "LINC02210-CRHR1", "",
"PNPLA3", "PSPN", "", "RPS29P7", "RPS12P27", "MIR4665", "RNA5S3",
"PPP1R13L", "PAIP1P1", "", "LINC00671", "IGHVII-40-1", "WNT6",
"ORC1P1", "", "", "FAM86GP", "NTAQ1", "", "", "RNA5-8SN3", "LMO4",
"", "", "", "PUM1", "TRIM61", "", "", "", "GTF3AP6", "SLC6A14P1",
"LINC01378", "RN7SKP142", "TATDN1", "C1QTNF4", "SNORD125", "",
"RNA5S7", "PSMA6P2", "HCG27", "", "", "BUD31P2", "RNA5S12",
"LINC02255", "", "", "BTBD6P1", "RPL21P43", "OR52J1P", "", "FLOT2", ""),
entrez_id = c(124905431L, NA, NA, NA, 100874185L, 7021L, 124905438L,
NA, 11282L, 124905842L, NA, NA, 6670L, NA, 124906683L, NA, NA,
NA, 79077L, NA, NA, 100874079L, NA, 6203L, 124907146L, NA, 8468L,
796L, NA, 4512L, 124905757L, NA, 146723L, NA, NA, 100132979L,
124906399L, NA, NA, NA, 124900824L, NA, 4750L, 124905768L, 1394L,
NA, 80339L, 5623L, 102723996L, NA, NA, 100616288L, 124905800L,
10848L, NA, NA, NA, NA, 7475L, NA, NA, NA, NA, 55093L, NA, NA,
124907622L, 8543L, NA, NA, NA, 9698L, 391712L, NA, NA, NA, NA,
NA, NA, NA, 83940L, 114900L, 100113380L, NA, 124905793L, NA,
253018L, NA, NA, NA, 124905762L, NA, NA, NA, NA, NA, NA, NA,
2319L, NA),
gene_type = c("rRNA", "lncRNA", "lncRNA", "lncRNA", "lncRNA",
"protein_coding", "rRNA", "lncRNA", "protein_coding", "rRNA",
"lncRNA", "lncRNA", "protein_coding", "protein_coding", "snRNA",
"processed_pseudogene", "transcribed_unprocessed_pseudogene",
"unprocessed_pseudogene", "protein_coding", "lncRNA", "lncRNA",
"lncRNA", "lncRNA", "protein_coding", "rRNA", "lncRNA",
"protein_coding", "protein_coding", "lncRNA", "protein_coding",
"rRNA", "unprocessed_pseudogene", "lncRNA", "snRNA",
"protein_coding", "transcribed_unprocessed_pseudogene",
"protein_coding", "lncRNA", "lncRNA", "lncRNA", "lncRNA",
"processed_pseudogene", "protein_coding", "rRNA", "protein_coding",
"lncRNA", "protein_coding", "protein_coding", "artifact",
"processed_pseudogene", "processed_pseudogene", "miRNA", "rRNA",
"protein_coding", "processed_pseudogene",
"transcribed_processed_pseudogene", "lncRNA", "IG_V_pseudogene",
"protein_coding", "processed_pseudogene", "lncRNA", "lncRNA",
"transcribed_unprocessed_pseudogene", "protein_coding", "lncRNA",
"lncRNA", "rRNA", "protein_coding", "unprocessed_pseudogene",
"lncRNA", "transcribed_processed_pseudogene", "protein_coding",
"protein_coding", "processed_pseudogene", "lncRNA", "lncRNA",
"processed_pseudogene", "unprocessed_pseudogene", "lncRNA",
"misc_RNA", "protein_coding", "protein_coding", "snoRNA", "lncRNA",
"rRNA", "processed_pseudogene", "lncRNA", "protein_coding",
"processed_pseudogene", "processed_pseudogene", "rRNA", "lncRNA",
"lncRNA", "misc_RNA", "processed_pseudogene",
"processed_pseudogene", "unprocessed_pseudogene", "lncRNA",
"protein_coding", "lncRNA"),
species = rep("human", 100L),
ensembl_version = rep("113", 100L),
download_date = structure(rep(20201, 100L), class = "Date")),
row.names = c(NA, -100L), class = "data.frame")

  genes$symbol[genes$symbol == ""] <- NA_character_
  genes[seq_len(min(n, nrow(genes))), ]
}

#' @keywords internal
#' @noRd
.gene_ref_mouse <- function(n) {
  genes <- structure(list(ensembl_id = c("ENSMUSG00000123309", "ENSMUSG00000108739",
"ENSMUSG00000078513", "ENSMUSG00000127289", "ENSMUSG00000112032",
"ENSMUSG00000083239", "ENSMUSG00000088811", "ENSMUSG00000027942",
"ENSMUSG00000109888", "ENSMUSG00000126842", "ENSMUSG00000081796",
"ENSMUSG00000081613", "ENSMUSG00000022763", "ENSMUSG00000021795",
"ENSMUSG00000123219", "ENSMUSG00000141617", "ENSMUSG00000134707",
"ENSMUSG00000027514", "ENSMUSG00000136470", "ENSMUSG00000111720",
"ENSMUSG00000032763", "ENSMUSG00000138720", "ENSMUSG00000099259",
"ENSMUSG00000065727", "ENSMUSG00000120001", "ENSMUSG00000053773",
"ENSMUSG00000104364", "ENSMUSG00000049858", "ENSMUSG00000132192",
"ENSMUSG00000117080", "ENSMUSG00000098024", "ENSMUSG00000057461",
"ENSMUSG00000133588", "ENSMUSG00000035392", "ENSMUSG00000082454",
"ENSMUSG00000142587", "ENSMUSG00000116702", "ENSMUSG00000104686",
"ENSMUSG00000130290", "ENSMUSG00000098329", "ENSMUSG00000140742",
"ENSMUSG00000110897", "ENSMUSG00000131145", "ENSMUSG00000083157",
"ENSMUSG00000115737", "ENSMUSG00000131675", "ENSMUSG00000051557",
"ENSMUSG00002075852", "ENSMUSG00000083263", "ENSMUSG00000139384",
"ENSMUSG00000025878", "ENSMUSG00000109571", "ENSMUSG00000032177",
"ENSMUSG00000135599", "ENSMUSG00000022525", "ENSMUSG00000051029",
"ENSMUSG00000110053", "ENSMUSG00000027908", "ENSMUSG00000107036",
"ENSMUSG00000131865", "ENSMUSG00000136543", "ENSMUSG00000089468",
"ENSMUSG00000040414", "ENSMUSG00000128536", "ENSMUSG00000098774",
"ENSMUSG00000128235", "ENSMUSG00000123028", "ENSMUSG00000020000",
"ENSMUSG00000109202", "ENSMUSG00000111413", "ENSMUSG00000067684",
"ENSMUSG00000073721", "ENSMUSG00000083860", "ENSMUSG00000123263",
"ENSMUSG00002074856", "ENSMUSG00000098290", "ENSMUSG00000134674",
"ENSMUSG00000102268", "ENSMUSG00000029449", "ENSMUSG00000106662",
"ENSMUSG00000129005", "ENSMUSG00000028134", "ENSMUSG00000116180",
"ENSMUSG00000036362", "ENSMUSG00000087964", "ENSMUSG00000040663",
"ENSMUSG00000114684", "ENSMUSG00002075588", "ENSMUSG00000116518",
"ENSMUSG00000124158", "ENSMUSG00000133230", "ENSMUSG00000082262",
"ENSMUSG00000139100", "ENSMUSG00000129514", "ENSMUSG00000083338",
"ENSMUSG00000130285", "ENSMUSG00000045509", "ENSMUSG00000108184",
"ENSMUSG00000113989", "ENSMUSG00000130078"),
symbol = c("", "Gm45096", "Pramel22", "", "Gm48036", "Mup-ps1",
"Gm22381", "4933434E20Rik", "Gm45600", "", "Gm9005", "Gm12109",
"Aifm3", "Sftpd", "", "", "", "Zbp1", "", "Gm39459", "Ilvbl",
"", "Mir6922", "Gm26164", "Gm57192", "Rdh8", "Gm38078", "Suox",
"", "1700063J08Rik", "Gm27003", "Or52s1b", "", "Dennd1a", "Gm12183",
"", "Gm6553", "Gm42815", "", "Mir6966", "", "Gm47085", "",
"Gm13511", "Rpl19-ps3", "", "Pusl1", "Gm56227", "Gm14874", "",
"Uimc1", "Gm44655", "Pde4a", "", "Plaat1", "Serpinb1b", "Gm29682",
"Tchhl1", "Gm7596", "", "", "Rnu7-ps1", "Slc25a28", "", "Mir6930",
"", "", "Moxd1", "Gm21037", "Gm47716", "Obp1a", "Pramel15",
"Gm13313", "", "Gm55752", "Obox4-ps1", "", "Gm8826", "Rhof",
"Gm43034", "", "Ptbp2", "Gm49492", "P2ry13", "Gm25388", "Clcf1",
"Vmn2r-ps105", "Gm54474", "Gm49494", "", "", "Gm14730", "", "",
"Gm12475", "", "Gpr150", "Gm44198", "Gm47013", ""),
entrez_id = c(NA, NA, 277668L, NA, NA, NA, 115487860L, 99650L,
NA, NA, NA, NA, 72168L, 20390L, NA, NA, NA, 58203L, NA, NA,
216136L, NA, 102465556L, 115487020L, NA, 235033L, NA, 211389L,
NA, NA, NA, 258139L, NA, 227801L, NA, NA, NA, NA, 105242740L,
102466776L, NA, NA, NA, NA, NA, 105243895L, 433813L, NA, NA,
NA, 20184L, NA, 18577L, 102639365L, 27281L, 282663L, 546096L,
71325L, NA, NA, NA, NA, 246696L, NA, 102465561L, NA, NA, 59012L,
NA, NA, 18249L, 627009L, NA, NA, NA, NA, NA, NA, 23912L, NA,
NA, 56195L, NA, 74191L, 115489606L, 56708L, NA, NA, NA, NA, NA,
NA, NA, NA, NA, NA, 238725L, NA, NA, NA),
gene_type = c("lncRNA", "lncRNA", "protein_coding", "lncRNA",
"lncRNA", "transcribed_unprocessed_pseudogene", "snRNA",
"protein_coding", "lncRNA", "lncRNA", "processed_pseudogene",
"processed_pseudogene", "protein_coding", "protein_coding",
"lncRNA", "lncRNA", "lncRNA", "protein_coding", "lncRNA", "lncRNA",
"protein_coding", "lncRNA", "miRNA", "snRNA", "lncRNA",
"protein_coding", "processed_pseudogene", "protein_coding",
"lncRNA", "lncRNA", "lncRNA", "protein_coding", "lncRNA",
"protein_coding", "processed_pseudogene", "lncRNA",
"processed_pseudogene", "TEC", "lncRNA", "miRNA", "lncRNA",
"processed_pseudogene", "lncRNA", "processed_pseudogene",
"transcribed_processed_pseudogene", "lncRNA", "protein_coding",
"snRNA", "processed_pseudogene", "lncRNA", "protein_coding",
"unprocessed_pseudogene", "protein_coding", "lncRNA",
"protein_coding", "protein_coding", "lncRNA", "protein_coding",
"lncRNA", "lncRNA", "lncRNA", "snRNA", "protein_coding", "lncRNA",
"miRNA", "lncRNA", "lncRNA", "protein_coding",
"processed_pseudogene", "lncRNA", "protein_coding",
"protein_coding", "transcribed_processed_pseudogene", "lncRNA",
"rRNA", "unprocessed_pseudogene", "lncRNA",
"processed_pseudogene", "protein_coding", "TEC", "lncRNA",
"protein_coding", "lncRNA", "protein_coding", "snoRNA",
"protein_coding", "unprocessed_pseudogene", "rRNA", "lncRNA",
"lncRNA", "lncRNA", "processed_pseudogene", "lncRNA", "lncRNA",
"processed_pseudogene", "lncRNA", "protein_coding", "TEC",
"lncRNA", "lncRNA"),
species = rep("mouse", 100L),
ensembl_version = rep("113", 100L),
download_date = structure(rep(20201, 100L), class = "Date")),
row.names = c(NA, -100L), class = "data.frame")

  genes$symbol[genes$symbol == ""] <- NA_character_
  genes[seq_len(min(n, nrow(genes))), ]
}
