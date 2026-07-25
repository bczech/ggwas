# Changelog

## ggwas 0.99.6

- [`manhattan_plot()`](https://bczech.github.io/ggwas/reference/manhattan_plot.md)
  with a single `y_truncate` value now keeps the peaks above the break
  and compresses them, instead of dropping everything up to the top
- The summary dashboard top-hits table shows the base-pair position
  again (it was printing `NULL`)

## ggwas 0.99.5

- [`trumpet_plot()`](https://bczech.github.io/ggwas/reference/trumpet_plot.md),
  [`forest_plot()`](https://bczech.github.io/ggwas/reference/forest_plot.md)
  and
  [`effect_compare_plot()`](https://bczech.github.io/ggwas/reference/effect_compare_plot.md)
  match column names case-insensitively, like
  [`as_gwas_data()`](https://bczech.github.io/ggwas/reference/as_gwas_data.md)

## ggwas 0.99.4

- Column auto-detection is now case-insensitive, so lowercase headers
  (`pos`, `#chrom`, `alt`, …) are recognized
- `-log10(p)` columns (`LOG10P`, `neg_log_pvalue`, …) are auto-detected
  and back-transformed
- Fixed a crash when more than one required column could not be
  detected; the error now lists the missing columns

## ggwas 0.99.3

- Added GRanges interoperability:
  [`as_granges()`](https://bczech.github.io/ggwas/reference/as_granges.md)
  exports results to a Bioconductor GRanges, and
  [`as_gwas_data()`](https://bczech.github.io/ggwas/reference/as_gwas_data.md)
  now accepts GRanges input
- Added
  [`trumpet_plot()`](https://bczech.github.io/ggwas/reference/trumpet_plot.md):
  effect size versus minor allele frequency with statistical-power
  contours showing which variants a study can detect
- Added
  [`forest_plot()`](https://bczech.github.io/ggwas/reference/forest_plot.md)
  for effect estimates with confidence intervals across cohorts or lead
  variants
- Added
  [`effect_compare_plot()`](https://bczech.github.io/ggwas/reference/effect_compare_plot.md)
  comparing variant effects between two studies on their shared variants
- Added
  [`gene_annotation()`](https://bczech.github.io/ggwas/reference/gene_annotation.md)
  with bundled protein-coding genes for GRCh37 and GRCh38, so regional
  and gene-labelled plots work without a GTF
- [`gene_track()`](https://bczech.github.io/ggwas/reference/gene_track.md)
  now renders full exon structure when given `exon_data`
- Sped up `smart_downsample()` with exponential-key weighted sampling

## ggwas 0.99.2

- Added `y_truncate` parameter for Manhattan plots with broken y-axis,
  showing extreme p-values in a compressed zone above the break
- Added
  [`snp_density()`](https://bczech.github.io/ggwas/reference/snp_density.md)
  with heatmap and points styles for SNP density karyograms with
  centromere markers
- Added
  [`density_signal_plot()`](https://bczech.github.io/ggwas/reference/density_signal_plot.md)
  dual-track comparison of genotyping density vs association signal
- Added
  [`chr_info_human()`](https://bczech.github.io/ggwas/reference/chr_info.md),
  [`chr_info_mouse()`](https://bczech.github.io/ggwas/reference/chr_info.md),
  [`chr_info_cattle()`](https://bczech.github.io/ggwas/reference/chr_info.md)
  for built-in chromosome data, and
  [`chr_info_ucsc()`](https://bczech.github.io/ggwas/reference/chr_info_ucsc.md)
  for any UCSC assembly
- Used Greek letter on axis labels in volcano and architecture plots
- Reversed color scale in heatmaps (dark = high values)
- Filled empty bins in
  [`pvalue_heatmap()`](https://bczech.github.io/ggwas/reference/pvalue_heatmap.md)
  to eliminate gaps
- Replaced scattermore with geom_point for correct circle shapes
- Showed legends by default in journal themes
- Reduced overlapping text in genetic correlation and PheWAS plots

## ggwas 0.99.1

- Added PheWAS, colocalization, fine-mapping, genetic correlation, and
  architecture plots
- Added data utilities:
  [`filter_region()`](https://bczech.github.io/ggwas/reference/filter_region.md),
  [`maf_filter()`](https://bczech.github.io/ggwas/reference/maf_filter.md),
  [`merge_gwas()`](https://bczech.github.io/ggwas/reference/merge_gwas.md),
  [`get_loci()`](https://bczech.github.io/ggwas/reference/get_loci.md)
- Added scattermore support for faster rendering of large datasets
- Expanded vignette with interpretation guides for all plot types
- Added Zenodo DOI
- Fixed integer overflow in cumulative BP calculation
- Fixed NA handling in
  [`highlight_regions()`](https://bczech.github.io/ggwas/reference/highlight_regions.md)

## ggwas 0.99.0

Initial Bioconductor pre-release.

### Plot types

- Manhattan plot with smart downsampling, highlighting, and labeling
- QQ plot with confidence bands, genomic inflation factor, and
  stratification
- Miami plot for two-study comparison
- Locus zoom plot with LD coloring and gene track support
- Genome-wide p-value heatmap (novel)
- Effect-size volcano plot (novel)
- Circular Manhattan with multi-ring support (novel)
- Enrichment Manhattan with functional annotation overlays (novel)
- Multi-trait Manhattan with pleiotropy detection (novel)
- Summary dashboard with automatic panel tags (novel)

### Gene annotation

- [`manhattan_genes()`](https://bczech.github.io/ggwas/reference/manhattan_genes.md)
  for labeling peaks with gene names
- [`annotate_genes()`](https://bczech.github.io/ggwas/reference/annotate_genes.md)
  for nearest-gene mapping
- [`top_hits()`](https://bczech.github.io/ggwas/reference/top_hits.md)
  with clumping and cytoband estimation
- [`highlight_regions()`](https://bczech.github.io/ggwas/reference/highlight_regions.md)
  for marking genomic regions
- Arrow-style annotations

### Themes and palettes

- Journal themes: Nature, Science, Cell, PLOS, presentation, poster
- 14 colorblind-safe palettes
- Publication presets via
  [`gwas_preset()`](https://bczech.github.io/ggwas/reference/gwas_preset.md)

### Data I/O

- Readers for PLINK, REGENIE, GCTA, GEMMA, and generic formats
- Automatic column name detection
- [`as_gwas_data()`](https://bczech.github.io/ggwas/reference/as_gwas_data.md)
  constructor with validation
