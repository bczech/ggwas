# Changelog

## ggwas 0.99.2

- Added
  [`snp_density()`](https://bczech.github.io/ggwas/reference/snp_density.md)
  karyogram-style SNP density visualization with optional centromere
  markers
- Added
  [`density_signal_plot()`](https://bczech.github.io/ggwas/reference/density_signal_plot.md)
  dual-track comparison of genotyping density vs association signal to
  distinguish real hits from artifacts
- Added
  [`chr_info_human()`](https://bczech.github.io/ggwas/reference/chr_info.md)
  helper for hg38 chromosome lengths and centromere positions
- Filled empty bins in
  [`pvalue_heatmap()`](https://bczech.github.io/ggwas/reference/pvalue_heatmap.md)
  to eliminate gaps
- Replaced scattermore with geom_point for correct circle shapes
- Showed legends by default in journal themes
- Reduced overlapping text in genetic correlation and PheWAS plots
- Fixed reader examples using non-existent files

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
