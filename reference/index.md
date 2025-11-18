# Package index

## Package Management

Functions for installing, checking, and managing R packages from
multiple sources (CRAN, GitHub, Bioconductor). Essential tools for
reproducible analysis environments.

- [`pkg_management`](https://evanbio.github.io/evanverse/reference/pkg_management.md)
  : Package Management
- [`check_pkg()`](https://evanbio.github.io/evanverse/reference/check_pkg.md)
  : Check Package Installation Status
- [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md)
  : Install R Packages from Multiple Sources
- [`update_pkg()`](https://evanbio.github.io/evanverse/reference/update_pkg.md)
  : Update R Packages
- [`pkg_version()`](https://evanbio.github.io/evanverse/reference/pkg_version.md)
  : Check Package Versions
- [`pkg_functions()`](https://evanbio.github.io/evanverse/reference/pkg_functions.md)
  : List Package Functions
- [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md)
  : Set CRAN/Bioconductor Mirrors

## Visualization & Plotting

High-level plotting functions with sensible defaults for common chart
types and publication-ready visualizations. Create professional plots
with minimal code.

- [`plot_venn()`](https://evanbio.github.io/evanverse/reference/plot_venn.md)
  : Draw Venn Diagrams (2-4 sets, classic or gradient style)
- [`plot_forest()`](https://evanbio.github.io/evanverse/reference/plot_forest.md)
  : Draw a forest plot using forestploter with publication-quality
  styling
- [`plot_bar()`](https://evanbio.github.io/evanverse/reference/plot_bar.md)
  : Bar plot with optional fill grouping, sorting, and directional
  layout
- [`plot_pie()`](https://evanbio.github.io/evanverse/reference/plot_pie.md)
  : Plot a Clean Pie Chart with Optional Inner Labels
- [`plot_density()`](https://evanbio.github.io/evanverse/reference/plot_density.md)
  : plot_density: Univariate Density Plot (Fill Group, Black Outline)

## Statistical Analysis

Intelligent statistical testing functions with automatic method
selection, assumption checking, and publication-ready visualizations.
Streamline your statistical workflows with smart defaults.

- [`quick_ttest()`](https://evanbio.github.io/evanverse/reference/quick_ttest.md)
  : Quick t-test with Automatic Visualization
- [`print(`*`<quick_ttest_result>`*`)`](https://evanbio.github.io/evanverse/reference/print.quick_ttest_result.md)
  : Print method for quick_ttest_result
- [`summary(`*`<quick_ttest_result>`*`)`](https://evanbio.github.io/evanverse/reference/summary.quick_ttest_result.md)
  : Summary method for quick_ttest_result
- [`quick_anova()`](https://evanbio.github.io/evanverse/reference/quick_anova.md)
  : Quick ANOVA with Automatic Method Selection
- [`quick_chisq()`](https://evanbio.github.io/evanverse/reference/quick_chisq.md)
  : Quick Chi-Square Test with Automatic Visualization
- [`print(`*`<quick_chisq_result>`*`)`](https://evanbio.github.io/evanverse/reference/print.quick_chisq_result.md)
  : Print Method for quick_chisq_result
- [`summary(`*`<quick_chisq_result>`*`)`](https://evanbio.github.io/evanverse/reference/summary.quick_chisq_result.md)
  : Summary Method for quick_chisq_result
- [`quick_cor()`](https://evanbio.github.io/evanverse/reference/quick_cor.md)
  : Quick Correlation Analysis with Heatmap Visualization
- [`print(`*`<quick_cor_result>`*`)`](https://evanbio.github.io/evanverse/reference/print.quick_cor_result.md)
  : Print method for quick_cor_result
- [`summary(`*`<quick_cor_result>`*`)`](https://evanbio.github.io/evanverse/reference/summary.quick_cor_result.md)
  : Summary method for quick_cor_result
- [`stat_power()`](https://evanbio.github.io/evanverse/reference/stat_power.md)
  : Calculate Statistical Power
- [`stat_samplesize()`](https://evanbio.github.io/evanverse/reference/stat_samplesize.md)
  : Calculate Required Sample Size

## Color Palettes & Management

Bioinformatics-focused color palette system with creation, management,
and visualization tools. Build consistent, accessible color schemes for
your projects.

- [`get_palette()`](https://evanbio.github.io/evanverse/reference/get_palette.md)
  : Get Palette: Load Color Palette from RDS
- [`list_palettes()`](https://evanbio.github.io/evanverse/reference/list_palettes.md)
  : list_palettes(): List All Color Palettes from RDS
- [`create_palette()`](https://evanbio.github.io/evanverse/reference/create_palette.md)
  : create_palette(): Save Custom Color Palettes as JSON
- [`preview_palette()`](https://evanbio.github.io/evanverse/reference/preview_palette.md)
  : Preview Palette: Visualize a Palette from RDS
- [`bio_palette_gallery()`](https://evanbio.github.io/evanverse/reference/bio_palette_gallery.md)
  : bio_palette_gallery(): Visualize All Palettes in a Gallery View
- [`compile_palettes()`](https://evanbio.github.io/evanverse/reference/compile_palettes.md)
  : compile_palettes(): Compile JSON palettes into RDS
- [`remove_palette()`](https://evanbio.github.io/evanverse/reference/remove_palette.md)
  : Remove a Saved Palette JSON
- [`clear_palette_cache()`](https://evanbio.github.io/evanverse/reference/clear_palette_cache.md)
  : Clear Palette Cache
- [`palette_cache_info()`](https://evanbio.github.io/evanverse/reference/palette_cache_info.md)
  : Get Palette Cache Information
- [`reload_palette_cache()`](https://evanbio.github.io/evanverse/reference/reload_palette_cache.md)
  : Reload Palette Cache
- [`hex2rgb()`](https://evanbio.github.io/evanverse/reference/hex2rgb.md)
  : Convert HEX color(s) to RGB numeric components
- [`rgb2hex()`](https://evanbio.github.io/evanverse/reference/rgb2hex.md)
  : Convert RGB values to HEX color codes

## ggplot2 Integration

Seamless ggplot2 integration for evanverse color palettes. Apply
palettes directly to ggplot2 color and fill scales.

- [`scale_color_evanverse()`](https://evanbio.github.io/evanverse/reference/scale_evanverse.md)
  [`scale_fill_evanverse()`](https://evanbio.github.io/evanverse/reference/scale_evanverse.md)
  [`scale_colour_evanverse()`](https://evanbio.github.io/evanverse/reference/scale_evanverse.md)
  : Discrete Color and Fill Scales for evanverse Palettes

## File & Data I/O

Flexible file reading/writing functions with enhanced error handling,
progress reporting, and format detection. Handle various data formats
with robust error recovery.

- [`read_table_flex()`](https://evanbio.github.io/evanverse/reference/read_table_flex.md)
  : Flexible and fast table reader using data.table::fread
- [`read_excel_flex()`](https://evanbio.github.io/evanverse/reference/read_excel_flex.md)
  : Flexible Excel reader
- [`write_xlsx_flex()`](https://evanbio.github.io/evanverse/reference/write_xlsx_flex.md)
  : Flexible Excel writer
- [`download_url()`](https://evanbio.github.io/evanverse/reference/download_url.md)
  : download_url(): Download File from URL
- [`download_batch()`](https://evanbio.github.io/evanverse/reference/download_batch.md)
  : download_batch(): Batch download files using multi_download
  (parallel with curl)
- [`download_geo_data()`](https://evanbio.github.io/evanverse/reference/download_geo_data.md)
  : Download GEO Data Resources
- [`file_info()`](https://evanbio.github.io/evanverse/reference/file_info.md)
  : file_info: Summarise file information
- [`file_tree()`](https://evanbio.github.io/evanverse/reference/file_tree.md)
  : file_tree: Print and Log Directory Tree Structure
- [`get_ext()`](https://evanbio.github.io/evanverse/reference/get_ext.md)
  : get_ext: Extract File Extension(s)
- [`view()`](https://evanbio.github.io/evanverse/reference/view.md) :
  Quick interactive table viewer (reactable)

## Bioinformatics Utilities

Specialized functions for bioinformatics workflows including gene ID
conversion and gene set analysis. Essential tools for genomic data
processing and analysis.

- [`convert_gene_id()`](https://evanbio.github.io/evanverse/reference/convert_gene_id.md)
  : convert_gene_id(): Convert gene identifiers using a reference table
- [`download_gene_ref()`](https://evanbio.github.io/evanverse/reference/download_gene_ref.md)
  : Download gene annotation reference table from Ensembl
- [`gmt2df()`](https://evanbio.github.io/evanverse/reference/gmt2df.md)
  : gmt2df: Convert GMT File to Long-format Data Frame
- [`gmt2list()`](https://evanbio.github.io/evanverse/reference/gmt2list.md)
  : gmt2list: Convert GMT File to Named List

## Data Processing & Transformation

Functions for data manipulation, column mapping, and handling missing or
void values. Clean and transform data with comprehensive void value
handling.

- [`df2list()`](https://evanbio.github.io/evanverse/reference/df2list.md)
  : Convert Data Frame to Named List by Grouping
- [`map_column()`](https://evanbio.github.io/evanverse/reference/map_column.md)
  : map_column(): Map values in a column using named vector or list
- [`is_void()`](https://evanbio.github.io/evanverse/reference/void.md)
  [`any_void()`](https://evanbio.github.io/evanverse/reference/void.md)
  [`drop_void()`](https://evanbio.github.io/evanverse/reference/void.md)
  [`replace_void()`](https://evanbio.github.io/evanverse/reference/void.md)
  [`cols_with_void()`](https://evanbio.github.io/evanverse/reference/void.md)
  [`rows_with_void()`](https://evanbio.github.io/evanverse/reference/void.md)
  : Void Value Utilities

## Operators & Logic

Custom infix operators and logical utility functions for expressive and
readable code. Enhance R syntax with powerful shortcuts and
combinatorial tools.

- [`` `%p%` ``](https://evanbio.github.io/evanverse/reference/grapes-p-grapes.md)
  :

  `%p%`: paste two strings with a single space

- [`` `%is%` ``](https://evanbio.github.io/evanverse/reference/grapes-is-grapes.md)
  : Strict identity comparison with diagnostics

- [`` `%nin%` ``](https://evanbio.github.io/evanverse/reference/grapes-nin-grapes.md)
  :

  `%nin%`: Not-in operator (negation of `%in%`)

- [`` `%map%` ``](https://evanbio.github.io/evanverse/reference/grapes-map-grapes.md)
  : %map%: Case-insensitive mapping returning named vector

- [`` `%match%` ``](https://evanbio.github.io/evanverse/reference/grapes-match-grapes.md)
  : %match%: Case-insensitive match returning indices

- [`combine_logic()`](https://evanbio.github.io/evanverse/reference/combine_logic.md)
  : combine_logic: Combine multiple logical vectors with a logical
  operator

- [`comb()`](https://evanbio.github.io/evanverse/reference/comb.md) :
  comb: Calculate Number of Combinations C(n, k)

- [`perm()`](https://evanbio.github.io/evanverse/reference/perm.md) :
  Calculate Number of Permutations A(n, k)

## Workflow & Development Tools

Helper functions for development workflow, timing, and safe code
execution. Streamline your development process with
productivity-enhancing utilities.

- [`with_timer()`](https://evanbio.github.io/evanverse/reference/with_timer.md)
  : Wrap a function to measure and display execution time
- [`remind()`](https://evanbio.github.io/evanverse/reference/remind.md)
  : Show usage tips for common R commands
- [`safe_execute()`](https://evanbio.github.io/evanverse/reference/safe_execute.md)
  : Safely Execute an Expression

## Example Datasets

Sample datasets included with evanverse for testing and demonstration
purposes. Useful for learning functions and exploring package
capabilities.

- [`df_forest_test`](https://evanbio.github.io/evanverse/reference/df_forest_test.md)
  : Test Dataset for Forest Plots
- [`trial`](https://evanbio.github.io/evanverse/reference/trial.md) :
  Clinical Trial Dataset
