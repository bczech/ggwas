# Map gene IDs or symbols to genome coordinates

Look up genomic positions (chromosome, start, end, strand) for a set of
Ensembl gene IDs or gene symbols. This is the inverse of
[`annotate_genes()`](https://bczech.github.io/ggwas/reference/annotate_genes.md),
which maps variant positions to the nearest gene; here you start from
gene identifiers and get their coordinates, ready to feed into
[`value_manhattan()`](https://bczech.github.io/ggwas/reference/value_manhattan.md)
or any plot that needs `chr`/`bp`. Several annotation sources are
supported, trading offline convenience against coverage and the ability
to pick an arbitrary Ensembl release.

## Usage

``` r
annotate_positions(
  ids,
  source = c("gtf", "biomart", "ensdb", "builtin"),
  build = c("GRCh38", "GRCh37"),
  release = NULL,
  gtf = NULL,
  ensdb = NULL,
  id_type = c("ensembl_gene_id", "symbol")
)
```

## Arguments

- ids:

  Character vector of gene identifiers (Ensembl gene IDs such as
  `"ENSG00000141510"`, or gene symbols such as `"TP53"`).

- source:

  Annotation backend:

  - `"gtf"` (default) reads a local GTF/GFF3 file via
    [`read_gtf()`](https://bczech.github.io/ggwas/reference/read_gtf.md).
    Full coverage, offline, works for any build you have a file for;
    requires `gtf`.

  - `"builtin"` uses the protein-coding genes bundled with ggwas
    ([`gene_annotation()`](https://bczech.github.io/ggwas/reference/gene_annotation.md)).
    Offline and dependency-free, but limited to protein-coding genes for
    GRCh38 (release 103) and GRCh37 (release 75).

  - `"biomart"` queries Ensembl online (any release/build). Needs the
    biomaRt package and network access.

  - `"ensdb"` reads an `EnsDb` object you pass via `ensdb`. Needs the
    ensembldb package and an installed `EnsDb.Hsapiens.*` data package.

- build:

  Genome build for the `"builtin"` and `"biomart"` sources: `"GRCh38"`
  (default) or `"GRCh37"`.

- release:

  Ensembl release for `source = "biomart"`. `NULL` (default) uses the
  current release.

- gtf:

  Path to a GTF/GFF3 file (required when `source = "gtf"`).

- ensdb:

  An `EnsDb` object (required when `source = "ensdb"`).

- id_type:

  Whether `ids` are Ensembl gene IDs (`"ensembl_gene_id"`, default) or
  gene symbols (`"symbol"`).

## Value

A data.frame with one row per matched identifier and columns `id` (the
input identifier), `chr` (integer), `start`, `end`, `strand`, `gene`
(symbol) and `gene_id` (Ensembl gene ID). Identifiers that cannot be
mapped are dropped.

## See also

[`value_manhattan()`](https://bczech.github.io/ggwas/reference/value_manhattan.md),
[`read_gtf()`](https://bczech.github.io/ggwas/reference/read_gtf.md),
[`gene_annotation()`](https://bczech.github.io/ggwas/reference/gene_annotation.md)

## Examples

``` r
# Offline, from a GTF file (uses the tiny example shipped with ggwas)
f <- system.file("extdata", "example.gtf", package = "ggwas")
ids <- read_gtf(f)$gene_id
#> Read 4 gene features from example.gtf.
annotate_positions(ids, source = "gtf", gtf = f)
#> Read 4 gene features from example.gtf.
#> Mapped 4/4 identifiers to coordinates ("gtf").
#>             id chr   start     end strand  gene      gene_id
#> 1 ENSG00000001   1 1000000 2000000      + GeneA ENSG00000001
#> 2 ENSG00000002   1 5000000 6500000      - GeneB ENSG00000002
#> 3 ENSG00000003   1 8000000 9000000      + GeneC ENSG00000003
#> 4 ENSG00000004   2 3000000 4000000      + GeneD ENSG00000004

# From the bundled protein-coding annotation, by symbol
annotate_positions(c("TP53", "BRCA1"), source = "builtin", id_type = "symbol")
#> Using built-in protein-coding genes for "GRCh38".
#> Mapped 2/2 identifiers to coordinates ("builtin").
#>      id chr    start      end strand  gene         gene_id
#> 1  TP53  17  7661779  7687538      -  TP53 ENSG00000141510
#> 2 BRCA1  17 43044295 43170245      - BRCA1 ENSG00000012048
```
