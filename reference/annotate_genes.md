# Annotate peaks with nearest gene names

Maps significant SNPs to their nearest gene with
[`GenomicRanges::distanceToNearest()`](https://rdrr.io/pkg/IRanges/man/nearest-methods.html).

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

  A `gwas_data` object, data.frame or `GRanges` of variants.

- genes:

  Gene models as a
  [GenomicRanges::GRanges](https://rdrr.io/pkg/GenomicRanges/man/GRanges-class.html),
  `TxDb` or `EnsDb` object. Gene names are taken as described in
  [`gene_track()`](https://bczech.github.io/ggwas/reference/gene_track.md).

- p_threshold:

  Only annotate SNPs with p \< this value.

- max_distance:

  Maximum distance (bp) between a SNP and the nearest gene. The distance
  is 0 for a SNP inside a gene and otherwise the gap to the closest gene
  end. Default 500kb.

- top_n:

  Annotate only the top N most significant SNPs.

- clump_window:

  Clumping window in bp. Within each window, only the most significant
  SNP is annotated. Default 1Mb.

## Value

The input as a `gwas_data` object with added `nearest_gene` and
`gene_distance` columns.

## Examples

``` r
data(example_gwas)
genes <- GenomicRanges::GRanges(
  c("chr1:1000000-1500000", "chr2:50000000-51000000",
    "chr5:80000000-82000000"),
  gene_name = c("GENE_A", "GENE_B", "GENE_C")
)
annotated <- annotate_genes(example_gwas, genes, top_n = 10)
head(annotated[!is.na(annotated$nearest_gene), ])
#> Warning: no non-missing arguments to min; returning Inf
#> A gwas_data object: 0 variants across 0 chromosome
#>   Min p-value: Inf
#>   Lambda GC:   NA
#>   Columns:     CHR, BP, SNP, P, BETA, SE, A1, A2, AF, nearest_gene, gene_distance
```
