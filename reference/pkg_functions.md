# List Package Functions

List exported symbols from a package's NAMESPACE. Optionally filter by a
case-insensitive keyword. Results are sorted alphabetically.

## Usage

``` r
pkg_functions(pkg, key = NULL)
```

## Arguments

- pkg:

  Character. Package name.

- key:

  Character. Optional keyword to filter function names
  (case-insensitive).

## Value

Character vector of exported names (invisibly).

## Examples

``` r
# List all functions in evanverse:
pkg_functions("evanverse")
#> 
#> ── Package: evanverse ──
#> 
#> ℹ Matched exported names: 63
#> %is%
#> %map%
#> %match%
#> %nin%
#> %p%
#> any_void
#> bio_palette_gallery
#> check_pkg
#> clear_palette_cache
#> cols_with_void
#> comb
#> combine_logic
#> compile_palettes
#> convert_gene_id
#> create_palette
#> df2list
#> download_batch
#> download_gene_ref
#> download_geo_data
#> download_url
#> drop_void
#> file_info
#> file_tree
#> get_ext
#> get_palette
#> gmt2df
#> gmt2list
#> hex2rgb
#> inst_pkg
#> is_void
#> list_palettes
#> map_column
#> palette_cache_info
#> perm
#> pkg_functions
#> pkg_version
#> plot_bar
#> plot_density
#> plot_forest
#> plot_pie
#> plot_venn
#> preview_palette
#> quick_anova
#> quick_chisq
#> quick_cor
#> quick_ttest
#> read_excel_flex
#> read_table_flex
#> reload_palette_cache
#> remind
#> remove_palette
#> replace_void
#> rgb2hex
#> rows_with_void
#> safe_execute
#> scale_color_evanverse
#> scale_colour_evanverse
#> scale_fill_evanverse
#> set_mirror
#> update_pkg
#> view
#> with_timer
#> write_xlsx_flex

# Filter by keyword:
pkg_functions("evanverse", key = "plot")
#> 
#> ── Package: evanverse ──
#> 
#> ℹ Matched exported names: 5
#> plot_bar
#> plot_density
#> plot_forest
#> plot_pie
#> plot_venn
```
