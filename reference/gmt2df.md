# Convert a GMT file to a long-format data frame

Reads a `.gmt` gene set file and returns a long-format data frame with
one row per gene.

## Usage

``` r
gmt2df(file)
```

## Arguments

- file:

  Character. Path to a `.gmt` file.

## Value

A data.frame with columns: `term`, `description`, `gene`.

## Examples

``` r
tmp <- toy_gmt()
gmt2df(tmp)
#>                         term                     description   gene
#> 1       HALLMARK_P53_PATHWAY          Genes regulated by p53   TP53
#> 2       HALLMARK_P53_PATHWAY          Genes regulated by p53  BRCA1
#> 3       HALLMARK_P53_PATHWAY          Genes regulated by p53    MYC
#> 4       HALLMARK_P53_PATHWAY          Genes regulated by p53   EGFR
#> 5       HALLMARK_P53_PATHWAY          Genes regulated by p53   PTEN
#> 6       HALLMARK_P53_PATHWAY          Genes regulated by p53   CDK2
#> 7       HALLMARK_P53_PATHWAY          Genes regulated by p53   MDM2
#> 8       HALLMARK_P53_PATHWAY          Genes regulated by p53    RB1
#> 9       HALLMARK_P53_PATHWAY          Genes regulated by p53 CDKN2A
#> 10      HALLMARK_P53_PATHWAY          Genes regulated by p53   AKT1
#> 11 HALLMARK_MTORC1_SIGNALING     Genes upregulated by mTORC1   PTEN
#> 12 HALLMARK_MTORC1_SIGNALING     Genes upregulated by mTORC1   CDK2
#> 13 HALLMARK_MTORC1_SIGNALING     Genes upregulated by mTORC1   MDM2
#> 14 HALLMARK_MTORC1_SIGNALING     Genes upregulated by mTORC1    RB1
#> 15 HALLMARK_MTORC1_SIGNALING     Genes upregulated by mTORC1 CDKN2A
#> 16 HALLMARK_MTORC1_SIGNALING     Genes upregulated by mTORC1   AKT1
#> 17 HALLMARK_MTORC1_SIGNALING     Genes upregulated by mTORC1   MTOR
#> 18 HALLMARK_MTORC1_SIGNALING     Genes upregulated by mTORC1 PIK3CA
#> 19 HALLMARK_MTORC1_SIGNALING     Genes upregulated by mTORC1   KRAS
#> 20 HALLMARK_MTORC1_SIGNALING     Genes upregulated by mTORC1   BRAF
#> 21          HALLMARK_HYPOXIA Genes upregulated under hypoxia   MTOR
#> 22          HALLMARK_HYPOXIA Genes upregulated under hypoxia PIK3CA
#> 23          HALLMARK_HYPOXIA Genes upregulated under hypoxia   KRAS
#> 24          HALLMARK_HYPOXIA Genes upregulated under hypoxia   BRAF
#> 25          HALLMARK_HYPOXIA Genes upregulated under hypoxia   NRAS
#> 26          HALLMARK_HYPOXIA Genes upregulated under hypoxia  VEGFA
#> 27          HALLMARK_HYPOXIA Genes upregulated under hypoxia  HIF1A
#> 28          HALLMARK_HYPOXIA Genes upregulated under hypoxia  STAT3
#> 29          HALLMARK_HYPOXIA Genes upregulated under hypoxia   JAK2
#> 30          HALLMARK_HYPOXIA Genes upregulated under hypoxia   BCL2
#> 31        HALLMARK_APOPTOSIS     Genes involved in apoptosis   TP53
#> 32        HALLMARK_APOPTOSIS     Genes involved in apoptosis    MYC
#> 33        HALLMARK_APOPTOSIS     Genes involved in apoptosis   PTEN
#> 34        HALLMARK_APOPTOSIS     Genes involved in apoptosis   MDM2
#> 35        HALLMARK_APOPTOSIS     Genes involved in apoptosis CDKN2A
#> 36        HALLMARK_APOPTOSIS     Genes involved in apoptosis   MTOR
#> 37        HALLMARK_APOPTOSIS     Genes involved in apoptosis   KRAS
#> 38        HALLMARK_APOPTOSIS     Genes involved in apoptosis   NRAS
#> 39        HALLMARK_APOPTOSIS     Genes involved in apoptosis  HIF1A
#> 40        HALLMARK_APOPTOSIS     Genes involved in apoptosis   JAK2
#> 41    HALLMARK_PI3K_AKT_MTOR         PI3K/AKT/mTOR signaling   AKT1
#> 42    HALLMARK_PI3K_AKT_MTOR         PI3K/AKT/mTOR signaling   MTOR
#> 43    HALLMARK_PI3K_AKT_MTOR         PI3K/AKT/mTOR signaling PIK3CA
#> 44    HALLMARK_PI3K_AKT_MTOR         PI3K/AKT/mTOR signaling   KRAS
#> 45    HALLMARK_PI3K_AKT_MTOR         PI3K/AKT/mTOR signaling   BRAF
#> 46    HALLMARK_PI3K_AKT_MTOR         PI3K/AKT/mTOR signaling   NRAS
#> 47    HALLMARK_PI3K_AKT_MTOR         PI3K/AKT/mTOR signaling  VEGFA
```
