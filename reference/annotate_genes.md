# Annotate peaks with nearest gene names

Maps significant SNPs to their nearest gene using a provided gene
annotation table. Returns the data with a `gene` column, or adds gene
labels directly to a Manhattan plot.

## Usage

``` r
annotate_genes(
  data,
  genes,
  p_threshold = 5e-08,
  max_distance = 5e+05,
  top_n = NULL,
  clump_window = 1e+06
)
```

## Arguments

- data:

  A `gwas_data` object or data.frame.

- genes:

  A data.frame with gene positions. Required columns: `chr` (integer or
  "chr1" format), `start`, `end`, `gene` (gene symbol). Optional:
  `strand`.

- p_threshold:

  Only annotate SNPs with p \< this value.

- max_distance:

  Maximum distance (bp) from SNP to gene midpoint to assign annotation.
  Default 500kb.

- top_n:

  Annotate only the top N most significant SNPs.

- clump_window:

  Clumping window in bp. Within each window, only the most significant
  SNP is annotated. Default 1Mb.

## Value

A data.frame with added `nearest_gene` and `gene_distance` columns.

## Examples

``` r
data(example_gwas)
genes <- data.frame(
  chr = c(1, 2, 5), start = c(1e6, 50e6, 80e6),
  end = c(1.5e6, 51e6, 82e6), gene = c("GENE_A", "GENE_B", "GENE_C")
)
annotated <- annotate_genes(example_gwas, genes, top_n = 10)
head(annotated[!is.na(annotated$nearest_gene), ])
#> Warning: no non-missing arguments to min; returning Inf
#> A gwas_data object: 0 variants across 0 chromosome
#>   Min p-value: Inf
#>   Lambda GC:   NA
#>   Columns:     CHR, BP, SNP, P, BETA, SE, A1, A2, AF, nearest_gene, gene_distance
```
