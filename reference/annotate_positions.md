# Map gene IDs or symbols to genome coordinates

Look up genomic positions for a set of gene identifiers in a gene
annotation. This is the inverse of
[`annotate_genes()`](https://bczech.github.io/ggwas/reference/annotate_genes.md),
which maps variant positions to the nearest gene; here you start from
gene identifiers and get their coordinates, for example to feed into
[`value_manhattan()`](https://bczech.github.io/ggwas/reference/value_manhattan.md).

## Usage

``` r
annotate_positions(ids, annotation, id_type = c("gene_id", "symbol"))
```

## Arguments

- ids:

  Character vector of gene identifiers (Ensembl gene IDs such as
  `"ENSG00000141510"`, Entrez IDs, or gene symbols such as `"TP53"`).

- annotation:

  Gene models as a
  [GenomicRanges::GRanges](https://rdrr.io/pkg/GenomicRanges/man/GRanges-class.html)
  object, or a `TxDb` (GenomicFeatures) or `EnsDb` (ensembldb) object.
  Gene IDs are read from the `gene_id` metadata column (or
  [`names()`](https://rdrr.io/r/base/names.html)), symbols from
  `gene_name`, `symbol` or `gene`. GTF and GFF3 files can be read with
  `rtracklayer::import()`; keep the `type == "gene"` rows.

- id_type:

  Whether `ids` are gene IDs (`"gene_id"`, default) or gene symbols
  (`"symbol"`).

## Value

A
[GenomicRanges::GRanges](https://rdrr.io/pkg/GenomicRanges/man/GRanges-class.html)
with one range per matched identifier and metadata columns `id` (the
input identifier), `gene` (symbol) and `gene_id`. Identifiers that
cannot be mapped are dropped.

## See also

[`value_manhattan()`](https://bczech.github.io/ggwas/reference/value_manhattan.md),
[`annotate_genes()`](https://bczech.github.io/ggwas/reference/annotate_genes.md)

## Examples

``` r
genes <- GenomicRanges::GRanges(
  c("chr17:7661779-7687538:-", "chr17:43044295-43170245:-"),
  gene_id = c("ENSG00000141510", "ENSG00000012048"),
  gene_name = c("TP53", "BRCA1")
)
annotate_positions(c("ENSG00000141510", "ENSG00000012048"), genes)
#> Mapped 2/2 identifiers to coordinates.
#> GRanges object with 2 ranges and 3 metadata columns:
#>       seqnames            ranges strand |              id        gene
#>          <Rle>         <IRanges>  <Rle> |     <character> <character>
#>   [1]    chr17   7661779-7687538      - | ENSG00000141510        TP53
#>   [2]    chr17 43044295-43170245      - | ENSG00000012048       BRCA1
#>               gene_id
#>           <character>
#>   [1] ENSG00000141510
#>   [2] ENSG00000012048
#>   -------
#>   seqinfo: 1 sequence from an unspecified genome; no seqlengths
annotate_positions(c("TP53", "NOT_A_GENE"), genes, id_type = "symbol")
#> Mapped 1/2 identifiers to coordinates.
#> GRanges object with 1 range and 3 metadata columns:
#>       seqnames          ranges strand |          id        gene         gene_id
#>          <Rle>       <IRanges>  <Rle> | <character> <character>     <character>
#>   [1]    chr17 7661779-7687538      - |        TP53        TP53 ENSG00000141510
#>   -------
#>   seqinfo: 1 sequence from an unspecified genome; no seqlengths
```
