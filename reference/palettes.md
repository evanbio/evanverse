# Built-in color palettes

A compiled list of all built-in color palettes, organized by type.
Generated from JSON source files in `inst/extdata/palettes/` via
`data-raw/palettes.R`.

## Usage

``` r
palettes
```

## Format

A named list with three elements:

- sequential:

  Named list of sequential palettes; each element is a character vector
  of HEX color codes.

- diverging:

  Named list of diverging palettes; each element is a character vector
  of HEX color codes.

- qualitative:

  Named list of qualitative palettes; each element is a character vector
  of HEX color codes.

## Source

`data-raw/palettes.R`

## Examples

``` r
names(palettes)
#> [1] "sequential"  "diverging"   "qualitative"
names(palettes$qualitative)
#>  [1] "qual_archambault_met" "qual_austria_met"     "qual_balanced"       
#>  [4] "qual_cassatt1_met"    "qual_cassatt2_met"    "qual_cosmic_g"       
#>  [7] "qual_cross_met"       "qual_degas_met"       "qual_demuth_met"     
#> [10] "qual_derain_met"      "qual_earthy"          "qual_egypt_met"      
#> [13] "qual_flatui_g"        "qual_futurama_g"      "qual_gauguin_met"    
#> [16] "qual_greek_met"       "qual_harmony"         "qual_hokusai1_met"   
#> [19] "qual_homer1_met"      "qual_homer2_met"      "qual_ingres_met"     
#> [22] "qual_isfahan2_met"    "qual_jama_g"          "qual_java_met"       
#> [25] "qual_jco_g"           "qual_johnson_met"     "qual_juarez_met"     
#> [28] "qual_kandinsky_met"   "qual_klimt_met"       "qual_lakota_met"     
#> [31] "qual_lancet_g"        "qual_manet_met"       "qual_mobility"       
#> [34] "qual_monet_met"       "qual_moreau_met"      "qual_morgenstern_met"
#> [37] "qual_nattier_met"     "qual_navajo_met"      "qual_nejm_g"         
#> [40] "qual_newkingdom_met"  "qual_nizami_met"      "qual_npg_g"          
#> [43] "qual_okeeffe1_met"    "qual_okeeffe2_met"    "qual_paquin_met"     
#> [46] "qual_pastel"          "qual_pbmc_sc"         "qual_peru1_met"      
#> [49] "qual_peru2_met"       "qual_pillement_met"   "qual_pissaro_met"    
#> [52] "qual_primary"         "qual_redon_met"       "qual_renoir_met"     
#> [55] "qual_set1_rb"         "qual_set2_rb"         "qual_set3_rb"        
#> [58] "qual_signac_met"      "qual_softtrio"        "qual_tam_met"        
#> [61] "qual_tara_met"        "qual_thomas_met"      "qual_tiepolo_met"    
#> [64] "qual_tron_g"          "qual_troy_met"        "qual_tsimshian_met"  
#> [67] "qual_vangogh1_met"    "qual_vangogh2_met"    "qual_vangogh3_met"   
#> [70] "qual_veronese_met"    "qual_vibrant"         "qual_vintage"        
#> [73] "qual_violin"          "qual_vivid"           "qual_wissing_met"    
palettes$qualitative$qual_vivid
#> [1] "#E64B35" "#4DBBD5" "#00A087" "#3C5488" "#F39B7F" "#8491B4" "#91D1C2"
#> [8] "#DC0000" "#7E6148"
```
