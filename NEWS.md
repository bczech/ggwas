# gwasplot 0.99.0

Bioconductor pre-release.

## New plot types
* Circular Manhattan plot with multi-ring support for trait comparison
* Enrichment Manhattan with functional annotation overlays
* Multi-trait Manhattan with automatic pleiotropy detection
* PheWAS plot for phenome-wide association results
* Colocalization locus plot (dual-trait shared coordinate axis)
* Fine-mapping credible set display (PIP sizing, credible set coloring)
* Genetic correlation matrix (clustered heatmap with significance markers)
* Genetic architecture plot (MAF vs effect size)
* Summary dashboard (multi-panel composite with automatic tags)

## Gene annotation and analysis
* `manhattan_genes()` for labeling peaks with nearest gene names
* `annotate_genes()` for mapping SNPs to genes
* `top_hits()` for extracting independent loci with clumping and cytoband
* `highlight_regions()` for marking genomic regions on Manhattan plots
* Arrow-style annotations as alternative to text labels

## Themes and palettes
* Journal themes: `theme_nature()`, `theme_science()`, `theme_cell()`,
  `theme_plos()`, `theme_presentation()`, `theme_poster()`
* 14 colorblind-safe palettes including journal-inspired schemes
* Publication presets via `gwas_preset()`

## Data utilities
* `filter_region()`, `maf_filter()`, `merge_gwas()`, `get_loci()`

## Performance
* Smart downsampling for 10M+ variant datasets
* Optional scattermore integration for accelerated rendering
* Optimized cumulative position calculation

## Core features
* Manhattan plot with smart downsampling, highlighting, and labeling
* QQ plot with confidence bands, genomic inflation factor, and stratification
* Miami plot for two-study comparison
* Locus zoom plot with LD coloring and gene track support
* Genome-wide p-value heatmap
* Effect-size volcano plot
* Readers for PLINK, REGENIE, GCTA, GEMMA, and generic formats
* Automatic column name detection
