# Generate a toy gene reference table

Generates a small deterministic gene reference table for examples and
tests. The human reference includes the symbols used by
[`toy_gmt`](https://evanbio.github.io/evanverse/reference/toy_gmt.md) so
offline GMT parsing and gene ID conversion examples compose without
network access. Not intended for real analyses — use
[`download_gene_ref`](https://evanbio.github.io/evanverse/reference/download_gene_ref.md)
for a complete reference.

## Usage

``` r
toy_gene_ref(species = c("human", "mouse"), n = 20L)
```

## Arguments

- species:

  One of `"human"` or `"mouse"`. Default: `"human"`.

- n:

  Integer. Number of genes to return. Capped at the 100 available rows.
  Default: `20`.

## Value

A data.frame with columns `symbol`, `ensembl_id`, `entrez_id`,
`gene_type`, `species`, `ensembl_version`, and `download_date`.

## Examples

``` r
toy_gene_ref()
#>    symbol      ensembl_id entrez_id      gene_type species ensembl_version
#> 1    TP53 ENSG00000141510      7157 protein_coding   human             113
#> 2   BRCA1 ENSG00000012048       672         lncRNA   human             113
#> 3     MYC ENSG00000136997      4609     pseudogene   human             113
#> 4    EGFR ENSG00000146648      1956          miRNA   human             113
#> 5    PTEN ENSG00000171862      5728 protein_coding   human             113
#> 6    CDK2 ENSG00000123374      1017         lncRNA   human             113
#> 7    MDM2 ENSG00000135679      4193     pseudogene   human             113
#> 8     RB1 ENSG00000139687      5925          miRNA   human             113
#> 9  CDKN2A ENSG00000147889      1029 protein_coding   human             113
#> 10   AKT1 ENSG00000142208       207         lncRNA   human             113
#> 11   MTOR ENSG00000198793      2475     pseudogene   human             113
#> 12 PIK3CA ENSG00000121879      5290          miRNA   human             113
#> 13   KRAS ENSG00000133703      3845 protein_coding   human             113
#> 14   BRAF ENSG00000157764       673         lncRNA   human             113
#> 15   NRAS ENSG00000213281      4893     pseudogene   human             113
#> 16  VEGFA ENSG00000112715      7422          miRNA   human             113
#> 17  HIF1A ENSG00000100644      3091 protein_coding   human             113
#> 18  STAT3 ENSG00000168610      6774         lncRNA   human             113
#> 19   JAK2 ENSG00000096968      3717     pseudogene   human             113
#> 20   BCL2 ENSG00000171791       596          miRNA   human             113
#>    download_date
#> 1     2025-04-23
#> 2     2025-04-23
#> 3     2025-04-23
#> 4     2025-04-23
#> 5     2025-04-23
#> 6     2025-04-23
#> 7     2025-04-23
#> 8     2025-04-23
#> 9     2025-04-23
#> 10    2025-04-23
#> 11    2025-04-23
#> 12    2025-04-23
#> 13    2025-04-23
#> 14    2025-04-23
#> 15    2025-04-23
#> 16    2025-04-23
#> 17    2025-04-23
#> 18    2025-04-23
#> 19    2025-04-23
#> 20    2025-04-23
toy_gene_ref("mouse", n = 10)
#>    symbol         ensembl_id entrez_id      gene_type species ensembl_version
#> 1   Trp53 ENSMUSG00000059552     22059 protein_coding   mouse             113
#> 2   Brca1 ENSMUSG00000017146     12189         lncRNA   mouse             113
#> 3     Myc ENSMUSG00000022346     17869     pseudogene   mouse             113
#> 4    Egfr ENSMUSG00000020122     13649          miRNA   mouse             113
#> 5    Pten ENSMUSG00000013663     19211 protein_coding   mouse             113
#> 6    Cdk2 ENSMUSG00000025358     12566         lncRNA   mouse             113
#> 7    Mdm2 ENSMUSG00000020184     17246     pseudogene   mouse             113
#> 8     Rb1 ENSMUSG00000022105     19645          miRNA   mouse             113
#> 9  Cdkn2a ENSMUSG00000044303     12578 protein_coding   mouse             113
#> 10   Akt1 ENSMUSG00000001729     11651         lncRNA   mouse             113
#>    download_date
#> 1     2025-04-23
#> 2     2025-04-23
#> 3     2025-04-23
#> 4     2025-04-23
#> 5     2025-04-23
#> 6     2025-04-23
#> 7     2025-04-23
#> 8     2025-04-23
#> 9     2025-04-23
#> 10    2025-04-23
```
