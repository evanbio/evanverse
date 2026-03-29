# Convert gene symbols to Entrez IDs

Convert gene symbols to Entrez IDs

## Usage

``` r
gene2entrez(x, ref = NULL, species = c("human", "mouse"))
```

## Arguments

- x:

  Character vector of gene symbols.

- ref:

  Data frame with columns `symbol` and `entrez_id`. If `NULL` (default),
  a full reference is downloaded via
  [`download_gene_ref`](https://evanbio.github.io/evanverse/reference/download_gene_ref.md)
  — this may trigger a network request. For examples and tests, pass
  [`toy_gene_ref()`](https://evanbio.github.io/evanverse/reference/toy_gene_ref.md)
  instead.

- species:

  One of `"human"` or `"mouse"`. Controls symbol case normalization
  before matching. Default: `"human"`.

## Value

A data.frame with columns `symbol` (original input), `symbol_std`
(case-normalized), and `entrez_id`. Unmatched entries have `NA` in
`entrez_id`.

## Examples

``` r
ref <- toy_gene_ref(species = "human")
gene2entrez(c("tp53", "brca1", "MYC"), ref = ref, species = "human")
#>   symbol symbol_std entrez_id
#> 1   tp53       TP53        NA
#> 2  brca1      BRCA1        NA
#> 3    MYC        MYC        NA

ref <- toy_gene_ref(species = "mouse")
gene2entrez(c("Trp53", "Zbp1"), ref = ref, species = "mouse")
#>   symbol symbol_std entrez_id
#> 1  Trp53      trp53        NA
#> 2   Zbp1       zbp1     58203
```
