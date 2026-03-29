# Toy Data Utilities

## Overview

The toy module provides two helper functions for examples, demos, and
tests:

| Task                    | Functions                                                                         |
|-------------------------|-----------------------------------------------------------------------------------|
| Toy gene reference data | [`toy_gene_ref()`](https://evanbio.github.io/evanverse/reference/toy_gene_ref.md) |
| Toy GMT file generation | [`toy_gmt()`](https://evanbio.github.io/evanverse/reference/toy_gmt.md)           |

``` r
library(evanverse)
```

> **Note:** All code examples in this vignette are static
> (`eval = FALSE`). Output is hand-written to reflect the current
> implementation.

------------------------------------------------------------------------

## 1 Toy Gene Reference Data

### `toy_gene_ref()` - Generate a compact gene reference table

[`toy_gene_ref()`](https://evanbio.github.io/evanverse/reference/toy_gene_ref.md)
returns a small reference table compatible with
[`gene2entrez()`](https://evanbio.github.io/evanverse/reference/gene2entrez.md)
/
[`gene2ensembl()`](https://evanbio.github.io/evanverse/reference/gene2ensembl.md)
workflows.

``` r
ref_human <- toy_gene_ref()
head(ref_human, 3)
#>          symbol       ensembl_id entrez_id      gene_type species ensembl_version download_date
#> 1        RNA5S5 ENSG00000199396 124905431           rRNA   human             113    2025-04-24
#> 2          <NA> ENSG00000295528        NA         lncRNA   human             113    2025-04-24
#> 3          <NA> ENSG00000301748        NA         lncRNA   human             113    2025-04-24
```

Key behavior:

- `species` supports only `"human"` and `"mouse"`.
- `n` controls returned rows and is capped at 100 available rows.
- Missing symbols are returned as `NA` (never empty strings).

Mouse example:

``` r
ref_mouse <- toy_gene_ref(species = "mouse", n = 10)
ref_mouse[, c("symbol", "ensembl_id", "species")]
#>          symbol          ensembl_id species
#> 1          <NA> ENSMUSG00000123309   mouse
#> 2       Gm45096 ENSMUSG00000108739   mouse
#> ...
```

`n` larger than 100 is silently capped:

``` r
nrow(toy_gene_ref(n = 999))
#> [1] 100
```

Invalid `n` (0, negative, non-integer) raises an error.

------------------------------------------------------------------------

## 2 Toy GMT File Generation

### `toy_gmt()` - Write a temporary GMT file

[`toy_gmt()`](https://evanbio.github.io/evanverse/reference/toy_gmt.md)
writes a GMT file to a temporary path and returns that file path. It is
designed to feed directly into
[`gmt2df()`](https://evanbio.github.io/evanverse/reference/gmt2df.md)
and
[`gmt2list()`](https://evanbio.github.io/evanverse/reference/gmt2list.md).

``` r
path <- toy_gmt()
path
#> [1] "C:/Users/.../Rtmp.../file....gmt"

readLines(path)[1]
#> [1] "HALLMARK_P53_PATHWAY\tGenes regulated by p53\tTP53\tBRCA1\tMYC\tEGFR\t..."
```

Key behavior:

- Default `n = 5` writes 5 gene sets.
- `n` is capped at 5 available built-in sets.
- Every line is GMT-formatted: `term`, `description`, then genes.

``` r
length(readLines(toy_gmt(n = 1)))
#> [1] 1

length(readLines(toy_gmt(n = 3)))
#> [1] 3

length(readLines(toy_gmt(n = 99)))
#> [1] 5
```

Invalid `n` (0, negative, non-integer) raises an error.

------------------------------------------------------------------------

## 3 Compatibility With Base Utilities

The outputs are intentionally aligned with existing base functions.

### `toy_gene_ref()` with gene ID conversion

``` r
ref <- toy_gene_ref(species = "human", n = 50)
gene2entrez(c("TP53", "BRCA1", "GHOST"), ref = ref, species = "human")
#>   symbol symbol_std entrez_id
#> 1   TP53       TP53      7157
#> 2  BRCA1      BRCA1       672
#> 3  GHOST      GHOST      <NA>
```

### `toy_gmt()` with GMT parsers

``` r
tmp <- toy_gmt(n = 3)

df <- gmt2df(tmp)
head(df, 4)
#>                    term               description  gene
#> 1 HALLMARK_P53_PATHWAY   Genes regulated by p53  TP53
#> 2 HALLMARK_P53_PATHWAY   Genes regulated by p53 BRCA1
#> 3 HALLMARK_P53_PATHWAY   Genes regulated by p53   MYC
#> 4 HALLMARK_P53_PATHWAY   Genes regulated by p53  EGFR

lst <- gmt2list(tmp)
names(lst)
#> [1] "HALLMARK_P53_PATHWAY" "HALLMARK_MTORC1_SIGNALING" "HALLMARK_HYPOXIA"
```

------------------------------------------------------------------------

## 4 A Combined Workflow

A common offline testing flow is:

1.  Build a small reference with
    [`toy_gene_ref()`](https://evanbio.github.io/evanverse/reference/toy_gene_ref.md).
2.  Build a small gene-set file with
    [`toy_gmt()`](https://evanbio.github.io/evanverse/reference/toy_gmt.md).
3.  Parse GMT and convert symbols to IDs using base converters.

``` r
library(evanverse)

# 1. Toy reference
ref <- toy_gene_ref(species = "human", n = 100)

# 2. Toy gene sets
path <- toy_gmt(n = 3)
long <- gmt2df(path)

# 3. Convert symbols to Entrez IDs
id_map <- gene2entrez(long$gene, ref = ref, species = "human")
long$entrez_id <- id_map$entrez_id

# 4. Rebuild list of Entrez IDs per term
long2 <- long[!is.na(long$entrez_id), ]
sets_entrez <- df2list(long2, group_col = "term", value_col = "entrez_id")

names(sets_entrez)
#> [1] "HALLMARK_P53_PATHWAY" "HALLMARK_MTORC1_SIGNALING" "HALLMARK_HYPOXIA"
```

------------------------------------------------------------------------

## Getting Help

- [`?toy_gene_ref`](https://evanbio.github.io/evanverse/reference/toy_gene_ref.md),
  [`?toy_gmt`](https://evanbio.github.io/evanverse/reference/toy_gmt.md)
- [`?gene2entrez`](https://evanbio.github.io/evanverse/reference/gene2entrez.md),
  [`?gene2ensembl`](https://evanbio.github.io/evanverse/reference/gene2ensembl.md)
- [`?gmt2df`](https://evanbio.github.io/evanverse/reference/gmt2df.md),
  [`?gmt2list`](https://evanbio.github.io/evanverse/reference/gmt2list.md),
  [`?df2list`](https://evanbio.github.io/evanverse/reference/df2list.md)
- [GitHub Issues](https://github.com/evanbio/evanverse/issues)
