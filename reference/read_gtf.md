# Read gene annotations from GTF/GFF3 file

Parse a GTF or GFF3 annotation file and return a data.frame of gene
positions ready for use with
[`gene_track()`](https://bczech.github.io/ggwas/reference/gene_track.md)
or
[`locus_plot()`](https://bczech.github.io/ggwas/reference/locus_plot.md).
Supports `.gz` compressed files.

## Usage

``` r
read_gtf(
  path,
  feature_type = "gene",
  gene_name_attr = c("gene_name", "Name", "gene"),
  gene_id_attr = "gene_id",
  biotype = NULL
)
```

## Arguments

- path:

  Path to GTF or GFF3 file (plain text or gzipped).

- feature_type:

  Feature type to extract (column 3 of GTF). Default `"gene"`.

- gene_name_attr:

  Attribute key(s) to use as gene name, tried in order. For GTF:
  `"gene_name"`, for GFF3: `"Name"`.

- gene_id_attr:

  Attribute key for gene ID (e.g. ENSG...).

- biotype:

  Character vector of gene biotypes to keep, e.g. `"protein_coding"`. If
  NULL (default), all biotypes are returned.

## Value

A data.frame with columns: chr (integer), start, end, gene, strand,
gene_id. Ready for
[`gene_track()`](https://bczech.github.io/ggwas/reference/gene_track.md)
or `locus_plot(gene_data = ...)`.

## Examples

``` r
f <- system.file("extdata", "example.gtf", package = "ggwas")
genes <- read_gtf(f)
#> Read 4 gene features from example.gtf.
head(genes)
#>   chr   start     end strand  gene      gene_id
#> 1   1 1000000 2000000      + GeneA ENSG00000001
#> 2   1 5000000 6500000      - GeneB ENSG00000002
#> 3   1 8000000 9000000      + GeneC ENSG00000003
#> 4   2 3000000 4000000      + GeneD ENSG00000004
```
