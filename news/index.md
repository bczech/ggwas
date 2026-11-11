# Changelog

## ggwas 0.99.11

Changes from the Bioconductor review. They break the API of the
functions listed below.

- Gene models are now `GRanges`, `TxDb` or `EnsDb` objects in
  [`gene_track()`](https://bczech.github.io/ggwas/reference/gene_track.md),
  [`locus_plot()`](https://bczech.github.io/ggwas/reference/locus_plot.md),
  [`annotate_genes()`](https://bczech.github.io/ggwas/reference/annotate_genes.md),
  [`manhattan_genes()`](https://bczech.github.io/ggwas/reference/manhattan_genes.md),
  [`top_hits()`](https://bczech.github.io/ggwas/reference/top_hits.md)
  and
  [`annotate_positions()`](https://bczech.github.io/ggwas/reference/annotate_positions.md).
  A data.frame is no longer accepted.
- Annotation regions in
  [`enrichment_manhattan()`](https://bczech.github.io/ggwas/reference/enrichment_manhattan.md)
  and
  [`highlight_regions()`](https://bczech.github.io/ggwas/reference/highlight_regions.md)
  are now `GRanges` (or a named `GRangesList`), and overlaps use
  [`GenomicRanges::findOverlaps()`](https://rdrr.io/pkg/IRanges/man/findOverlaps-methods.html).
- [`gene_track()`](https://bczech.github.io/ggwas/reference/gene_track.md),
  [`locus_plot()`](https://bczech.github.io/ggwas/reference/locus_plot.md),
  [`coloc_plot()`](https://bczech.github.io/ggwas/reference/coloc_plot.md)
  and
  [`finemapping_plot()`](https://bczech.github.io/ggwas/reference/finemapping_plot.md)
  take one `region` (a `GRanges` or a `"chr:start-end"` string) instead
  of `region_chr`, `region_start` and `region_end`.
  [`gene_track()`](https://bczech.github.io/ggwas/reference/gene_track.md)
  takes exons as a `GRangesList` from
  [`exonsBy()`](https://rdrr.io/pkg/GenomicFeatures/man/transcriptsBy.html),
  or `exons = TRUE` with a `TxDb`/`EnsDb`.
- The nearest gene is found with
  [`GenomicRanges::distanceToNearest()`](https://rdrr.io/pkg/IRanges/man/nearest-methods.html),
  so the distance is now measured to the gene body (0 inside a gene),
  not to its midpoint.
- [`snp_density()`](https://bczech.github.io/ggwas/reference/snp_density.md)
  and
  [`density_signal_plot()`](https://bczech.github.io/ggwas/reference/density_signal_plot.md)
  take chromosome lengths from a `Seqinfo` (`seqinfo =`) and
  [`snp_density()`](https://bczech.github.io/ggwas/reference/snp_density.md)
  takes centromeres as `GRanges` (`centromeres =`).
- [`set_sex_chr_map()`](https://bczech.github.io/ggwas/reference/set_sex_chr_map.md)
  accepts a `Seqinfo` and numbers X, Y, Z, W and MT from it.
  `set_sex_chr_map(NULL)` now really turns the mapping off.
- [`annotate_positions()`](https://bczech.github.io/ggwas/reference/annotate_positions.md)
  takes an `annotation` object and returns a `GRanges`;
  [`value_manhattan()`](https://bczech.github.io/ggwas/reference/value_manhattan.md)
  takes `annotation =` and also accepts a `GRanges`.
- Remove `read_gtf()` (use `rtracklayer::import()`), `gene_annotation()`
  and the bundled gene tables (use `TxDb`/`EnsDb` packages), and
  `chr_info_human()`, `chr_info_mouse()`, `chr_info_cattle()` and
  `chr_info_ucsc()` (use `Seqinfo`).
- Fix
  [`manhattan_genes()`](https://bczech.github.io/ggwas/reference/manhattan_genes.md)
  placing gene labels over the wrong chromosomes when only some
  chromosomes have labelled peaks.
- [`summary()`](https://rdrr.io/r/base/summary.html) of a `gwas_data`
  object now returns a summary object with its own print method.
- Set `LazyData: false`, depend on R \>= 4.6.0, add
  `BiocType: Software`, and drop `inst/CITATION` (Bioconductor generates
  the citation).

## ggwas 0.99.10

- Add
  [`value_manhattan()`](https://bczech.github.io/ggwas/reference/value_manhattan.md)
  to plot any per-feature value (rankings, effect sizes, scores) along
  the genome in Manhattan style.
- Add
  [`annotate_positions()`](https://bczech.github.io/ggwas/reference/annotate_positions.md)
  to map Ensembl gene IDs or symbols to genome coordinates from a GTF,
  bundled data, biomaRt, or an EnsDb.
- [`value_manhattan()`](https://bczech.github.io/ggwas/reference/value_manhattan.md)
  can look up coordinates from a gene-ID column directly via `annotate`
  and `id`.
- Bundled gene annotations now include an Ensembl `gene_id` column.

## ggwas 0.99.9

- Chromosome colours now follow the chromosomes present in the data
  instead of assuming the human set of 26. Manhattan, Miami and volcano
  plots of non-human genomes (for example cattle, with 29 autosomes
  plus X) no longer leave the extra chromosomes uncoloured.
  [`scale_color_chromosome()`](https://bczech.github.io/ggwas/reference/scale_color_chromosome.md),
  [`scale_fill_chromosome()`](https://bczech.github.io/ggwas/reference/scale_color_chromosome.md),
  [`scale_color_gwas()`](https://bczech.github.io/ggwas/reference/scale_color_gwas.md)
  and
  [`scale_fill_gwas()`](https://bczech.github.io/ggwas/reference/scale_color_gwas.md)
  gain a `chromosomes` argument for the same reason.

## ggwas 0.99.8

- Point labels now sit in the empty part of the plot with a connector
  line down to the variant, instead of landing on the points. Manhattan
  labels go into the headroom above the peaks; trumpet and volcano
  labels move off the dense band

## ggwas 0.99.7

- SNP and gene labels across all plots now share one repel style, so
  they spread out, always keep a connector line, and stay off the points
- Manhattan plots leave headroom at the top, giving top-hit labels room
  to sit
- The summary dashboard top-hits table no longer clips its bottom rows

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
- Added `gene_annotation()` with bundled protein-coding genes for GRCh37
  and GRCh38, so regional and gene-labelled plots work without a GTF
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
- Added `chr_info_human()`, `chr_info_mouse()`, `chr_info_cattle()` for
  built-in chromosome data, and `chr_info_ucsc()` for any UCSC assembly
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
- 14 color palettes, with a colorblind-safe default for chromosome
  colors
- Publication presets via
  [`gwas_preset()`](https://bczech.github.io/ggwas/reference/gwas_preset.md)

### Data I/O

- Readers for PLINK, REGENIE, GCTA, GEMMA, and generic formats
- Automatic column name detection
- [`as_gwas_data()`](https://bczech.github.io/ggwas/reference/as_gwas_data.md)
  constructor with validation
