# compile_palettes(): Compile JSON palettes into RDS

Read JSON files under `palettes_dir/`, validate content, and compile
into a structured RDS file.

## Usage

``` r
compile_palettes(palettes_dir, output_rds, log = TRUE)
```

## Arguments

- palettes_dir:

  Character. Folder containing subdirs: sequential/, diverging/,
  qualitative/ (required)

- output_rds:

  Character. Path to save compiled RDS file (required). Use tempdir()
  for examples/tests.

- log:

  Logical. Whether to log compilation events. Default: TRUE

## Value

Invisibly returns RDS file path (character)

## Examples

``` r
# \donttest{
# Compile palettes using temporary directory:
compile_palettes(
  palettes_dir = system.file("extdata", "palettes", package = "evanverse"),
  output_rds = file.path(tempdir(), "palettes.rds")
)
#> 
#> ── Compiling Color Palettes (JSON -> RDS) ──────────────────────────────────────
#> ✔ Added 'seq_benedictus' (Type: sequential, 13 colors)
#> ✔ Added 'seq_blues' (Type: sequential, 3 colors)
#> ✔ Added 'seq_blush' (Type: sequential, 4 colors)
#> ✔ Added 'seq_forest' (Type: sequential, 4 colors)
#> ✔ Added 'seq_hiroshige' (Type: sequential, 10 colors)
#> ✔ Added 'seq_hokusai2' (Type: sequential, 6 colors)
#> ✔ Added 'seq_hokusai3' (Type: sequential, 6 colors)
#> ✔ Added 'seq_isfahan' (Type: sequential, 8 colors)
#> ✔ Added 'seq_locuszoom' (Type: sequential, 7 colors)
#> ✔ Added 'seq_mobility' (Type: sequential, 9 colors)
#> ✔ Added 'seq_muted' (Type: sequential, 4 colors)
#> ✔ Added 'div_contrast' (Type: diverging, 2 colors)
#> ✔ Added 'div_earthy' (Type: diverging, 5 colors)
#> ✔ Added 'div_fireice' (Type: diverging, 2 colors)
#> ✔ Added 'div_pinkgreen_rb' (Type: diverging, 3 colors)
#> ✔ Added 'div_polar' (Type: diverging, 2 colors)
#> ✔ Added 'div_sage' (Type: diverging, 7 colors)
#> ✔ Added 'div_sunset' (Type: diverging, 2 colors)
#> ✔ Added 'qual_archambault_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_austria_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_balanced' (Type: qualitative, 4 colors)
#> ✔ Added 'qual_cassatt1_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_cassatt2_met' (Type: qualitative, 10 colors)
#> ✔ Added 'qual_cosmic_g' (Type: qualitative, 10 colors)
#> ✔ Added 'qual_cross_met' (Type: qualitative, 9 colors)
#> ✔ Added 'qual_degas_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_demuth_met' (Type: qualitative, 10 colors)
#> ✔ Added 'qual_derain_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_earthy' (Type: qualitative, 3 colors)
#> ✔ Added 'qual_egypt_met' (Type: qualitative, 4 colors)
#> ✔ Added 'qual_flatui_g' (Type: qualitative, 10 colors)
#> ✔ Added 'qual_futurama_g' (Type: qualitative, 12 colors)
#> ✔ Added 'qual_gauguin_met' (Type: qualitative, 6 colors)
#> ✔ Added 'qual_greek_met' (Type: qualitative, 5 colors)
#> ✔ Added 'qual_harmony' (Type: qualitative, 6 colors)
#> ✔ Added 'qual_hokusai1_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_homer1_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_homer2_met' (Type: qualitative, 6 colors)
#> ✔ Added 'qual_ingres_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_isfahan2_met' (Type: qualitative, 5 colors)
#> ✔ Added 'qual_jama_g' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_java_met' (Type: qualitative, 5 colors)
#> ✔ Added 'qual_jco_g' (Type: qualitative, 10 colors)
#> ✔ Added 'qual_johnson_met' (Type: qualitative, 5 colors)
#> ✔ Added 'qual_juarez_met' (Type: qualitative, 6 colors)
#> ✔ Added 'qual_kandinsky_met' (Type: qualitative, 4 colors)
#> ✔ Added 'qual_klimt_met' (Type: qualitative, 6 colors)
#> ✔ Added 'qual_lakota_met' (Type: qualitative, 6 colors)
#> ✔ Added 'qual_lancet_g' (Type: qualitative, 9 colors)
#> ✔ Added 'qual_manet_met' (Type: qualitative, 11 colors)
#> ✔ Added 'qual_mobility' (Type: qualitative, 10 colors)
#> ✔ Added 'qual_monet_met' (Type: qualitative, 9 colors)
#> ✔ Added 'qual_moreau_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_morgenstern_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_nattier_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_navajo_met' (Type: qualitative, 5 colors)
#> ✔ Added 'qual_nejm_g' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_newkingdom_met' (Type: qualitative, 5 colors)
#> ✔ Added 'qual_nizami_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_npg_g' (Type: qualitative, 10 colors)
#> ✔ Added 'qual_okeeffe1_met' (Type: qualitative, 11 colors)
#> ✔ Added 'qual_okeeffe2_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_paquin_met' (Type: qualitative, 11 colors)
#> ✔ Added 'qual_pastel' (Type: qualitative, 6 colors)
#> ✔ Added 'qual_pbmc_sc' (Type: qualitative, 17 colors)
#> ✔ Added 'qual_peru1_met' (Type: qualitative, 6 colors)
#> ✔ Added 'qual_peru2_met' (Type: qualitative, 6 colors)
#> ✔ Added 'qual_pillement_met' (Type: qualitative, 6 colors)
#> ✔ Added 'qual_pissaro_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_primary' (Type: qualitative, 3 colors)
#> ✔ Added 'qual_redon_met' (Type: qualitative, 12 colors)
#> ✔ Added 'qual_renoir_met' (Type: qualitative, 12 colors)
#> ✔ Added 'qual_set1_rb' (Type: qualitative, 9 colors)
#> ✔ Added 'qual_set2_rb' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_set3_rb' (Type: qualitative, 12 colors)
#> ✔ Added 'qual_signac_met' (Type: qualitative, 14 colors)
#> ✔ Added 'qual_softtrio' (Type: qualitative, 3 colors)
#> ✔ Added 'qual_tam_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_tara_met' (Type: qualitative, 5 colors)
#> ✔ Added 'qual_thomas_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_tiepolo_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_tron_g' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_troy_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_tsimshian_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_vangogh1_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_vangogh2_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_vangogh3_met' (Type: qualitative, 8 colors)
#> ✔ Added 'qual_veronese_met' (Type: qualitative, 7 colors)
#> ✔ Added 'qual_vibrant' (Type: qualitative, 5 colors)
#> ✔ Added 'qual_vintage' (Type: qualitative, 3 colors)
#> ✔ Added 'qual_violin' (Type: qualitative, 5 colors)
#> ✔ Added 'qual_vivid' (Type: qualitative, 9 colors)
#> ✔ Added 'qual_wissing_met' (Type: qualitative, 5 colors)
#> ✔ Saved RDS: /tmp/RtmpjLapgI/palettes.rds
#> 
#> ── Compilation Summary ──
#> 
#> ℹ Sequential:   11
#> ℹ Diverging:    7
#> ℹ Qualitative:  75
#> ℹ Log written to: /tmp/RtmpjLapgI/logs/palettes/compile_palettes.log
#> ✔ All palettes compiled successfully!
# }
```
