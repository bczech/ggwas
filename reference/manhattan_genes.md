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

  Gene annotation data.frame (see
  [`annotate_genes()`](https://bczech.github.io/gwasplot/reference/annotate_genes.md)).

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
  [`manhattan_plot()`](https://bczech.github.io/gwasplot/reference/manhattan_plot.md).

## Value

A ggplot object.

## Examples

``` r
data(example_gwas)
genes <- data.frame(
  chr = c(1, 2, 5, 7, 11), start = c(1e6, 50e6, 80e6, 30e6, 60e6),
  end = c(2e6, 52e6, 85e6, 35e6, 65e6),
  gene = c("BRCA1", "FTO", "TCF7L2", "CDKAL1", "KCNQ1")
)
manhattan_genes(example_gwas, genes = genes, gene_top_n = 5)
```
