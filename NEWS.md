# ggwas 0.99.2

* Added `y_truncate` parameter for Manhattan plots with broken y-axis,
  showing extreme p-values in a compressed zone above the break
* Added `snp_density()` with heatmap and points styles for SNP density
  karyograms with centromere markers
* Added `density_signal_plot()` dual-track comparison of genotyping
  density vs association signal
* Added `chr_info_human()`, `chr_info_mouse()`, `chr_info_cattle()` for
  built-in chromosome data, and `chr_info_ucsc()` for any UCSC assembly
* Used Greek letter on axis labels in volcano and architecture plots
* Reversed color scale in heatmaps (dark = high values)
* Filled empty bins in `pvalue_heatmap()` to eliminate gaps
* Replaced scattermore with geom_point for correct circle shapes
* Showed legends by default in journal themes
* Reduced overlapping text in genetic correlation and PheWAS plots

# ggwas 0.99.1

* Added PheWAS, colocalization, fine-mapping, genetic correlation, and
  architecture plots
* Added data utilities: `filter_region()`, `maf_filter()`, `merge_gwas()`,
  `get_loci()`
* Added scattermore support for faster rendering of large datasets
* Expanded vignette with interpretation guides for all plot types
* Added Zenodo DOI
* Fixed integer overflow in cumulative BP calculation
* Fixed NA handling in `highlight_regions()`

# ggwas 0.99.0

Initial Bioconductor pre-release.

## Plot types
* Manhattan plot with smart downsampling, highlighting, and labeling
* QQ plot with confidence bands, genomic inflation factor, and stratification
* Miami plot for two-study comparison
* Locus zoom plot with LD coloring and gene track support
* Genome-wide p-value heatmap (novel)
* Effect-size volcano plot (novel)
* Circular Manhattan with multi-ring support (novel)
* Enrichment Manhattan with functional annotation overlays (novel)
* Multi-trait Manhattan with pleiotropy detection (novel)
* Summary dashboard with automatic panel tags (novel)

## Gene annotation
* `manhattan_genes()` for labeling peaks with gene names
* `annotate_genes()` for nearest-gene mapping
* `top_hits()` with clumping and cytoband estimation
* `highlight_regions()` for marking genomic regions
* Arrow-style annotations

## Themes and palettes
* Journal themes: Nature, Science, Cell, PLOS, presentation, poster
* 14 colorblind-safe palettes
* Publication presets via `gwas_preset()`

## Data I/O
* Readers for PLINK, REGENIE, GCTA, GEMMA, and generic formats
* Automatic column name detection
* `as_gwas_data()` constructor with validation
