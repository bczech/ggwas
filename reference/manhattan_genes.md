# Add gene labels to a Manhattan plot

A convenience wrapper that annotates a dataset and then creates a
Manhattan plot with gene names as labels instead of SNP IDs.

## Usage

``` r
manhattan_genes(
  data,
  genes,
  gene_p_threshold = 1e-05,
  gene_top_n = 10,
  gene_max_distance = 5e+05,
  arrow = FALSE,
  arrow_color = "grey30",
  label_size = 3,
  label_face = "italic",
  ...
)
```

## Arguments

- data:

  A `gwas_data` object or data.frame with GWAS results.

- genes:

  Gene models as a `GRanges`, `TxDb` or `EnsDb` object (see
  [`annotate_genes()`](https://bczech.github.io/ggwas/reference/annotate_genes.md)).

- gene_p_threshold:

  P-value threshold for gene annotation.

- gene_top_n:

  Number of top genes to label.

- gene_max_distance:

  Maximum distance to nearest gene.

- arrow:

  If TRUE, use annotation arrows instead of text labels.

- arrow_color:

  Color of annotation arrows.

- label_size:

  Font size for gene labels.

- label_face:

  Font face for gene labels ("italic", "bold", "bold.italic").

- ...:

  Additional arguments passed to
  [`manhattan_plot()`](https://bczech.github.io/ggwas/reference/manhattan_plot.md).

## Value

A ggplot object.

## Examples

``` r
data(example_gwas)
genes <- GenomicRanges::GRanges(
  c("chr1:1000000-2000000", "chr2:50000000-52000000",
    "chr5:80000000-85000000", "chr7:30000000-35000000",
    "chr11:60000000-65000000"),
  gene_name = c("GENE_A", "GENE_B", "GENE_C", "GENE_D", "GENE_E")
)
manhattan_genes(example_gwas, genes = genes, gene_top_n = 5)
```
