# Circular Manhattan plot

A circos-style Manhattan plot where chromosomes are arranged in a
circle. Built entirely with ggplot2, unlike CMplot's base R
implementation. Supports multiple rings for multi-trait comparison.

## Usage

``` r
circular_manhattan(
  data,
  chr = NULL,
  bp = NULL,
  p = NULL,
  snp = NULL,
  colors = c("#1A5276", "#76D7C4"),
  point_size = 1.2,
  alpha = 0.85,
  genome_wide = 5e-08,
  threshold_color = "#E74C3C",
  highlight_snps = NULL,
  highlight_color = "#E74C3C",
  highlight_size = 2,
  label_snps = NULL,
  label_top_n = NULL,
  show_chr_labels = TRUE,
  inner_radius = 0.35,
  chr_gap_fraction = 0.012,
  ring_labels = NULL,
  downsample = TRUE,
  downsample_n = 1e+05,
  title = NULL
)
```

## Arguments

- data:

  A `gwas_data` object, data.frame, or named list of gwas_data objects
  for multi-ring display.

- chr, bp, p, snp:

  Column name overrides.

- colors:

  Two-color vector for alternating chromosomes, or a palette name from
  [`gwas_palette()`](https://bczech.github.io/ggwas/reference/gwas_palette.md).

- point_size:

  Point size.

- alpha:

  Point transparency.

- genome_wide:

  Genome-wide significance threshold.

- threshold_color:

  Color for threshold ring.

- highlight_snps:

  SNP IDs to highlight.

- highlight_color:

  Color for highlighted SNPs.

- highlight_size:

  Size for highlighted points.

- label_snps:

  SNP IDs to label.

- label_top_n:

  Label top N SNPs.

- show_chr_labels:

  Show chromosome labels.

- inner_radius:

  Inner radius of the circle (proportion, 0-1).

- chr_gap_fraction:

  Gap between chromosomes as fraction of total.

- ring_labels:

  For multi-ring: labels for each ring.

- downsample:

  Enable smart downsampling.

- downsample_n:

  Target points after downsampling.

- title:

  Plot title.

## Value

A ggplot object.

## Examples

``` r
data(example_gwas)
circular_manhattan(example_gwas)
```
