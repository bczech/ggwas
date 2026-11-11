# Enrichment Manhattan plot

A Manhattan plot with colored overlays for functional genomic
annotations. SNPs falling within annotated regions (genes, enhancers,
eQTLs, custom categories) are highlighted with distinct colors,
connecting GWAS results with functional genomics.

## Usage

``` r
enrichment_manhattan(
  data,
  annotations,
  chr = NULL,
  bp = NULL,
  p = NULL,
  snp = NULL,
  background_color = "grey75",
  background_alpha = 0.4,
  annotation_colors = NULL,
  annotation_size = 1.5,
  annotation_alpha = 0.9,
  annotation_shape = 16,
  show_legend = TRUE,
  legend_position = "right",
  genome_wide = 5e-08,
  suggestive = 1e-05,
  label_top_n = NULL,
  label_column = "SNP",
  downsample = TRUE,
  downsample_n = 2e+05,
  title = NULL,
  palette = "nature"
)
```

## Arguments

- data:

  A `gwas_data` object, data.frame or `GRanges` of variants.

- annotations:

  Annotation regions as a
  [GenomicRanges::GRanges](https://rdrr.io/pkg/GenomicRanges/man/GRanges-class.html)
  with an optional `category` metadata column (annotation type), or a
  named `GRangesList` (or named list of `GRanges`) whose names are used
  as categories. BED, GFF or bigBed files can be read with
  `rtracklayer::import()`. A variant falling in several regions takes
  the category of the first one.

- chr, bp, p, snp:

  Column name overrides.

- background_color:

  Color for non-annotated SNPs.

- background_alpha:

  Transparency of background points.

- annotation_colors:

  Named vector of colors for each annotation category. If NULL, colors
  are taken from `palette`.

- annotation_size:

  Point size for annotated SNPs.

- annotation_alpha:

  Transparency of annotated SNPs.

- annotation_shape:

  Point shape for annotated SNPs (default 16, circle).

- show_legend:

  Show legend for annotation categories.

- legend_position:

  Legend position.

- genome_wide:

  Genome-wide significance threshold.

- suggestive:

  Suggestive significance threshold.

- label_top_n:

  Label top N annotated significant SNPs.

- label_column:

  Column to use for labels.

- downsample:

  Enable smart downsampling.

- downsample_n:

  Target number of background points.

- title:

  Plot title.

- palette:

  Color palette for annotations (from
  [`gwas_palette()`](https://bczech.github.io/ggwas/reference/gwas_palette.md)).

## Value

A ggplot object.

## Examples

``` r
data(example_gwas)
# Annotation regions with a category column
annot <- GenomicRanges::GRanges(
  c("chr1:1000000-5000000", "chr2:50000000-55000000",
    "chr5:100000000-110000000"),
  category = c("Enhancer", "Gene", "eQTL")
)
enrichment_manhattan(example_gwas, annotations = annot)


# The same as a GRangesList, one element per category
annot_list <- GenomicRanges::GRangesList(
  Enhancer = annot[1], Gene = annot[2], eQTL = annot[3]
)
enrichment_manhattan(example_gwas, annotations = annot_list)
```
