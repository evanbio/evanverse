# Generate a toy gene reference table

Generates a small simulated gene reference table for use in examples and
tests. Not intended for real analyses — use
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
#>         ensembl_id    symbol entrez_id                          gene_type
#> 1  ENSG00000199396    RNA5S5 124905431                               rRNA
#> 2  ENSG00000295528      <NA>        NA                             lncRNA
#> 3  ENSG00000301748      <NA>        NA                             lncRNA
#> 4  ENSG00000253260      <NA>        NA                             lncRNA
#> 5  ENSG00000258537 FRMD6-AS2 100874185                             lncRNA
#> 6  ENSG00000008196    TFAP2B      7021                     protein_coding
#> 7  ENSG00000202521    RNA5S7 124905438                               rRNA
#> 8  ENSG00000285726      <NA>        NA                             lncRNA
#> 9  ENSG00000284501    MGAT4B     11282                     protein_coding
#> 10 ENSG00000199270   RNA5S12 124905842                               rRNA
#> 11 ENSG00000294467      <NA>        NA                             lncRNA
#> 12 ENSG00000293097      <NA>        NA                             lncRNA
#> 13 ENSG00000172845       SP3      6670                     protein_coding
#> 14 ENSG00000270149      <NA>        NA                     protein_coding
#> 15 ENSG00000277660      <NA> 124906683                              snRNA
#> 16 ENSG00000292419      <NA>        NA               processed_pseudogene
#> 17 ENSG00000227671   ZNF731P        NA transcribed_unprocessed_pseudogene
#> 18 ENSG00000278499    NPAP1L        NA             unprocessed_pseudogene
#> 19 ENSG00000179958    DCTPP1     79077                     protein_coding
#> 20 ENSG00000260659      <NA>        NA                             lncRNA
#>    species ensembl_version download_date
#> 1    human             113    2025-04-23
#> 2    human             113    2025-04-23
#> 3    human             113    2025-04-23
#> 4    human             113    2025-04-23
#> 5    human             113    2025-04-23
#> 6    human             113    2025-04-23
#> 7    human             113    2025-04-23
#> 8    human             113    2025-04-23
#> 9    human             113    2025-04-23
#> 10   human             113    2025-04-23
#> 11   human             113    2025-04-23
#> 12   human             113    2025-04-23
#> 13   human             113    2025-04-23
#> 14   human             113    2025-04-23
#> 15   human             113    2025-04-23
#> 16   human             113    2025-04-23
#> 17   human             113    2025-04-23
#> 18   human             113    2025-04-23
#> 19   human             113    2025-04-23
#> 20   human             113    2025-04-23
toy_gene_ref("mouse", n = 10)
#>            ensembl_id        symbol entrez_id
#> 1  ENSMUSG00000123309          <NA>        NA
#> 2  ENSMUSG00000108739       Gm45096        NA
#> 3  ENSMUSG00000078513      Pramel22    277668
#> 4  ENSMUSG00000127289          <NA>        NA
#> 5  ENSMUSG00000112032       Gm48036        NA
#> 6  ENSMUSG00000083239       Mup-ps1        NA
#> 7  ENSMUSG00000088811       Gm22381 115487860
#> 8  ENSMUSG00000027942 4933434E20Rik     99650
#> 9  ENSMUSG00000109888       Gm45600        NA
#> 10 ENSMUSG00000126842          <NA>        NA
#>                             gene_type species ensembl_version download_date
#> 1                              lncRNA   mouse             113    2025-04-23
#> 2                              lncRNA   mouse             113    2025-04-23
#> 3                      protein_coding   mouse             113    2025-04-23
#> 4                              lncRNA   mouse             113    2025-04-23
#> 5                              lncRNA   mouse             113    2025-04-23
#> 6  transcribed_unprocessed_pseudogene   mouse             113    2025-04-23
#> 7                               snRNA   mouse             113    2025-04-23
#> 8                      protein_coding   mouse             113    2025-04-23
#> 9                              lncRNA   mouse             113    2025-04-23
#> 10                             lncRNA   mouse             113    2025-04-23
```
