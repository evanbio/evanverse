# List Package Functions

List exported symbols from a package's NAMESPACE, optionally filtered by
a case-insensitive keyword. Results are sorted alphabetically.

## Usage

``` r
pkg_functions(pkg, key = NULL)
```

## Arguments

- pkg:

  Character. Package name.

- key:

  Character. Keyword to filter function names (case-insensitive).
  Default: NULL.

## Value

Character vector of exported names.

## Examples

``` r
pkg_functions("evanverse")
#>  [1] "%is%"              "%map%"             "%match%"          
#>  [4] "%nin%"             "%p%"               "comb"             
#>  [7] "df2list"           "df2vect"           "download_batch"   
#> [10] "download_gene_ref" "download_geo"      "download_url"     
#> [13] "file_info"         "file_ls"           "file_tree"        
#> [16] "gene2ensembl"      "gene2entrez"       "gmt2df"           
#> [19] "gmt2list"          "perm"              "pkg_functions"    
#> [22] "plot_bar"          "plot_density"      "plot_forest"      
#> [25] "plot_pie"          "plot_venn"         "quick_anova"      
#> [28] "quick_chisq"       "quick_cor"         "quick_ttest"      
#> [31] "recode_column"     "set_mirror"        "stat_n"           
#> [34] "stat_power"        "toy_gene_ref"      "toy_gmt"          
#> [37] "view"             
pkg_functions("evanverse", key = "plot")
#> [1] "plot_bar"     "plot_density" "plot_forest"  "plot_pie"     "plot_venn"   
```
