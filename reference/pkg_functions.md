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
#>  [7] "compile_palettes"  "create_palette"    "df2list"          
#> [10] "df2vect"           "download_batch"    "download_gene_ref"
#> [13] "download_geo"      "download_url"      "file_info"        
#> [16] "file_ls"           "file_tree"         "gene2ensembl"     
#> [19] "gene2entrez"       "get_palette"       "gmt2df"           
#> [22] "gmt2list"          "hex2rgb"           "list_palettes"    
#> [25] "palette_gallery"   "perm"              "pkg_functions"    
#> [28] "plot_bar"          "plot_density"      "plot_forest"      
#> [31] "plot_pie"          "plot_venn"         "preview_palette"  
#> [34] "quick_anova"       "quick_chisq"       "quick_cor"        
#> [37] "quick_ttest"       "recode_column"     "remove_palette"   
#> [40] "rgb2hex"           "set_mirror"        "stat_n"           
#> [43] "stat_power"        "toy_gene_ref"      "toy_gmt"          
#> [46] "view"             
pkg_functions("evanverse", key = "plot")
#> [1] "plot_bar"     "plot_density" "plot_forest"  "plot_pie"     "plot_venn"   
```
