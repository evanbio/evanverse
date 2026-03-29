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
#>  [4] "%nin%"             "%p%"               "check_pkg"        
#>  [7] "comb"              "compile_palettes"  "create_palette"   
#> [10] "df2list"           "df2vect"           "download_batch"   
#> [13] "download_gene_ref" "download_geo"      "download_url"     
#> [16] "file_info"         "file_ls"           "file_tree"        
#> [19] "gene2ensembl"      "gene2entrez"       "get_palette"      
#> [22] "gmt2df"            "gmt2list"          "hex2rgb"          
#> [25] "inst_pkg"          "list_palettes"     "palette_gallery"  
#> [28] "perm"              "pkg_functions"     "pkg_version"      
#> [31] "plot_bar"          "plot_density"      "plot_forest"      
#> [34] "plot_pie"          "plot_venn"         "preview_palette"  
#> [37] "quick_anova"       "quick_chisq"       "quick_cor"        
#> [40] "quick_ttest"       "recode_column"     "remove_palette"   
#> [43] "rgb2hex"           "set_mirror"        "stat_n"           
#> [46] "stat_power"        "toy_gene_ref"      "toy_gmt"          
#> [49] "update_pkg"        "view"             
pkg_functions("evanverse", key = "plot")
#> [1] "plot_bar"     "plot_density" "plot_forest"  "plot_pie"     "plot_venn"   
```
