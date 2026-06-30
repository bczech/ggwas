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
if (FALSE) { # \dontrun{
# Ensembl GTF
genes <- read_gtf("Homo_sapiens.GRCh38.110.gtf.gz")

# Use with gene_track
gene_track(genes, region_chr = 6, region_start = 25e6, region_end = 35e6)

# GFF3 format
genes <- read_gtf("gencode.v44.annotation.gff3.gz")
} # }
```
