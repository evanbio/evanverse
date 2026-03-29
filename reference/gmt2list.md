# Convert a GMT file to a named list

Reads a `.gmt` gene set file and returns a named list where each element
is a character vector of gene symbols.

## Usage

``` r
gmt2list(file)
```

## Arguments

- file:

  Character. Path to a `.gmt` file.

## Value

A named list where each element is a character vector of gene symbols.

## Examples

``` r
tmp <- toy_gmt()
gmt2list(tmp)
#> $HALLMARK_P53_PATHWAY
#>  [1] "TP53"   "BRCA1"  "MYC"    "EGFR"   "PTEN"   "CDK2"   "MDM2"   "RB1"   
#>  [9] "CDKN2A" "AKT1"  
#> 
#> $HALLMARK_MTORC1_SIGNALING
#>  [1] "PTEN"   "CDK2"   "MDM2"   "RB1"    "CDKN2A" "AKT1"   "MTOR"   "PIK3CA"
#>  [9] "KRAS"   "BRAF"  
#> 
#> $HALLMARK_HYPOXIA
#>  [1] "MTOR"   "PIK3CA" "KRAS"   "BRAF"   "NRAS"   "VEGFA"  "HIF1A"  "STAT3" 
#>  [9] "JAK2"   "BCL2"  
#> 
#> $HALLMARK_APOPTOSIS
#>  [1] "TP53"   "MYC"    "PTEN"   "MDM2"   "CDKN2A" "MTOR"   "KRAS"   "NRAS"  
#>  [9] "HIF1A"  "JAK2"  
#> 
#> $HALLMARK_PI3K_AKT_MTOR
#> [1] "AKT1"   "MTOR"   "PIK3CA" "KRAS"   "BRAF"   "NRAS"   "VEGFA" 
#> 
```
