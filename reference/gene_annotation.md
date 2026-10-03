# Built-in protein-coding gene annotations

Return a data.frame of protein-coding gene positions bundled with ggwas,
ready for
[`gene_track()`](https://bczech.github.io/ggwas/reference/gene_track.md),
[`locus_plot()`](https://bczech.github.io/ggwas/reference/locus_plot.md)
or
[`manhattan_genes()`](https://bczech.github.io/ggwas/reference/manhattan_genes.md),
so that regional and gene-labelled plots work without downloading a GTF.
Data are derived from Ensembl (GRCh38 release 103; GRCh37 release 75)
and restricted to protein-coding genes.

## Usage

``` r
gene_annotation(build = c("GRCh38", "GRCh37"))
```

## Arguments

- build:

  Genome build: `"GRCh38"` (default) or `"GRCh37"`.

## Value

A data.frame with columns `chr` (integer), `start`, `end`, `gene`
(symbol), `strand`, and `gene_id` (Ensembl gene ID).

## Examples

``` r
genes <- gene_annotation("GRCh38")
head(genes)
#>   chr  start    end   gene strand         gene_id
#> 1   1  65419  71585  OR4F5      + ENSG00000186092
#> 2   1 450740 451678 OR4F29      - ENSG00000284733
#> 3   1 685679 686673 OR4F16      - ENSG00000284662
#> 4   1 923923 944575 SAMD11      + ENSG00000187634
#> 5   1 944203 959309  NOC2L      - ENSG00000188976
#> 6   1 960584 965719 KLHL17      + ENSG00000187961

# Gene track for a region, no GTF needed
gene_track(genes, region_chr = 6, region_start = 25e6, region_end = 34e6)
```
