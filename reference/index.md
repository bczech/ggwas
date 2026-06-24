# Package index

## Core plots

Standard GWAS visualizations

- [`manhattan_plot()`](https://bczech.github.io/ggwas/reference/manhattan_plot.md)
  : Manhattan plot
- [`qq_plot()`](https://bczech.github.io/ggwas/reference/qq_plot.md) :
  QQ plot for GWAS p-values
- [`miami_plot()`](https://bczech.github.io/ggwas/reference/miami_plot.md)
  : Miami plot (mirrored Manhattan)
- [`locus_plot()`](https://bczech.github.io/ggwas/reference/locus_plot.md)
  : Locus zoom plot
- [`volcano_plot()`](https://bczech.github.io/ggwas/reference/volcano_plot.md)
  : GWAS effect-size volcano plot
- [`pvalue_heatmap()`](https://bczech.github.io/ggwas/reference/pvalue_heatmap.md)
  : Genome-wide p-value heatmap
- [`circular_manhattan()`](https://bczech.github.io/ggwas/reference/circular_manhattan.md)
  : Circular Manhattan plot
- [`gwas_summary()`](https://bczech.github.io/ggwas/reference/gwas_summary.md)
  : GWAS Summary Panel

## Advanced plots

Multi-trait, enrichment, and post-GWAS visualizations

- [`enrichment_manhattan()`](https://bczech.github.io/ggwas/reference/enrichment_manhattan.md)
  : Enrichment Manhattan plot
- [`multitrait_manhattan()`](https://bczech.github.io/ggwas/reference/multitrait_manhattan.md)
  : Multi-trait Manhattan plot
- [`phewas_plot()`](https://bczech.github.io/ggwas/reference/phewas_plot.md)
  : PheWAS plot
- [`coloc_plot()`](https://bczech.github.io/ggwas/reference/coloc_plot.md)
  : Colocalization locus plot
- [`finemapping_plot()`](https://bczech.github.io/ggwas/reference/finemapping_plot.md)
  : Fine-mapping credible set plot
- [`genetic_correlation()`](https://bczech.github.io/ggwas/reference/genetic_correlation.md)
  : Genetic correlation matrix
- [`architecture_plot()`](https://bczech.github.io/ggwas/reference/architecture_plot.md)
  : Genetic architecture plot
- [`snp_density()`](https://bczech.github.io/ggwas/reference/snp_density.md)
  : SNP density karyogram
- [`density_signal_plot()`](https://bczech.github.io/ggwas/reference/density_signal_plot.md)
  : Density–signal dual-track plot
- [`chr_info_human()`](https://bczech.github.io/ggwas/reference/chr_info_human.md)
  : Human chromosome information (hg38)

## Annotation and analysis

Gene annotation, region highlights, top hits

- [`manhattan_genes()`](https://bczech.github.io/ggwas/reference/manhattan_genes.md)
  : Add gene labels to a Manhattan plot
- [`annotate_genes()`](https://bczech.github.io/ggwas/reference/annotate_genes.md)
  : Annotate peaks with nearest gene names
- [`highlight_regions()`](https://bczech.github.io/ggwas/reference/highlight_regions.md)
  : Add highlighted regions to a Manhattan plot
- [`top_hits()`](https://bczech.github.io/ggwas/reference/top_hits.md) :
  Extract top hits from GWAS results

## Data I/O

Reading GWAS summary statistics

- [`read_gwas_table()`](https://bczech.github.io/ggwas/reference/read_gwas_table.md)
  : Read GWAS summary statistics from any tabular file
- [`read_plink_assoc()`](https://bczech.github.io/ggwas/reference/read_plink_assoc.md)
  : Read PLINK association results
- [`read_plink_linear()`](https://bczech.github.io/ggwas/reference/read_plink_linear.md)
  : Read PLINK linear regression results
- [`read_plink_logistic()`](https://bczech.github.io/ggwas/reference/read_plink_logistic.md)
  : Read PLINK logistic regression results
- [`read_regenie()`](https://bczech.github.io/ggwas/reference/read_regenie.md)
  : Read REGENIE results
- [`read_gcta_mlma()`](https://bczech.github.io/ggwas/reference/read_gcta_mlma.md)
  : Read GCTA MLMA results
- [`read_gemma()`](https://bczech.github.io/ggwas/reference/read_gemma.md)
  : Read GEMMA association results
- [`as_gwas_data()`](https://bczech.github.io/ggwas/reference/as_gwas_data.md)
  : Create a gwas_data object
- [`validate_gwas_data()`](https://bczech.github.io/ggwas/reference/validate_gwas_data.md)
  : Validate a gwas_data object

## Themes and palettes

Publication-ready styling

- [`theme_gwas()`](https://bczech.github.io/ggwas/reference/theme_gwas.md)
  : Minimal GWAS theme for ggplot2
- [`theme_nature()`](https://bczech.github.io/ggwas/reference/journal_themes.md)
  [`theme_science()`](https://bczech.github.io/ggwas/reference/journal_themes.md)
  [`theme_plos()`](https://bczech.github.io/ggwas/reference/journal_themes.md)
  [`theme_cell()`](https://bczech.github.io/ggwas/reference/journal_themes.md)
  [`theme_presentation()`](https://bczech.github.io/ggwas/reference/journal_themes.md)
  [`theme_poster()`](https://bczech.github.io/ggwas/reference/journal_themes.md)
  : Journal-specific themes for GWAS plots
- [`gwas_palette()`](https://bczech.github.io/ggwas/reference/gwas_palette.md)
  : GWAS Color Palettes
- [`gwas_palettes()`](https://bczech.github.io/ggwas/reference/gwas_palettes.md)
  : List available GWAS palettes
- [`gwas_preset()`](https://bczech.github.io/ggwas/reference/gwas_preset.md)
  : GWAS plot presets
- [`scale_color_chromosome()`](https://bczech.github.io/ggwas/reference/scale_color_chromosome.md)
  [`scale_fill_chromosome()`](https://bczech.github.io/ggwas/reference/scale_color_chromosome.md)
  : Chromosome color scale
- [`scale_color_gwas()`](https://bczech.github.io/ggwas/reference/scale_color_gwas.md)
  [`scale_fill_gwas()`](https://bczech.github.io/ggwas/reference/scale_color_gwas.md)
  : Colorblind-safe chromosome color scale

## Data utilities

Filtering, merging, and extracting GWAS data

- [`filter_region()`](https://bczech.github.io/ggwas/reference/filter_region.md)
  : Filter variants by genomic region
- [`maf_filter()`](https://bczech.github.io/ggwas/reference/maf_filter.md)
  : Filter variants by minor allele frequency
- [`merge_gwas()`](https://bczech.github.io/ggwas/reference/merge_gwas.md)
  : Merge multiple GWAS datasets
- [`get_loci()`](https://bczech.github.io/ggwas/reference/get_loci.md) :
  Get significant loci
- [`calc_lambda()`](https://bczech.github.io/ggwas/reference/calc_lambda.md)
  : Calculate genomic inflation factor (lambda GC)
- [`example_gwas`](https://bczech.github.io/ggwas/reference/example_gwas.md)
  : Example GWAS dataset
