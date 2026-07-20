# Convert GWAS results to a GRanges object

Turn a `gwas_data` object or data.frame into a Bioconductor
[GRanges](https://rdrr.io/pkg/GenomicRanges/man/GRanges-class.html)
object, with association statistics stored as metadata columns, for
interoperability with the Bioconductor ecosystem (e.g.
VariantAnnotation, SummarizedExperiment, coloc).

## Usage

``` r
as_granges(x, ...)
```

## Arguments

- x:

  A `gwas_data` object or a data.frame accepted by
  [`as_gwas_data()`](https://bczech.github.io/ggwas/reference/as_gwas_data.md).

- ...:

  Column overrides passed to
  [`as_gwas_data()`](https://bczech.github.io/ggwas/reference/as_gwas_data.md)
  when `x` is a plain data.frame.

## Value

A [GRanges](https://rdrr.io/pkg/GenomicRanges/man/GRanges-class.html)
object, one width-1 range per variant, named by SNP when available.

## Examples

``` r
data(example_gwas)
gr <- as_granges(example_gwas)
gr
#> GRanges object with 8000 ranges and 7 metadata columns:
#>             seqnames    ranges strand |         SNP          P      BETA
#>                <Rle> <IRanges>  <Rle> | <character>  <numeric> <numeric>
#>   rs2678525       16  80841579      * |   rs2678525 0.18988331  -0.01723
#>   rs8451246        5  80011524      * |   rs8451246 0.05264044  -0.02073
#>   rs7069507       12  34577737      * |   rs7069507 0.04506835   0.01575
#>   rs4824759       12  16869788      * |   rs4824759 0.00680649  -0.10267
#>   rs7209949        7  38647669      * |   rs7209949 0.56527788  -0.00012
#>         ...      ...       ...    ... .         ...        ...       ...
#>   rs7761398       11  23750379      * |   rs7761398   0.115608   0.05872
#>   rs7135121        3  69639436      * |   rs7135121   0.929757   0.04248
#>   rs6635611       18  40340076      * |   rs6635611   0.788155   0.06943
#>   rs6641483       13  74927676      * |   rs6641483   0.174590   0.00629
#>   rs5502842       20  14803036      * |   rs5502842   0.291328   0.06330
#>                    SE          A1          A2        AF
#>             <numeric> <character> <character> <numeric>
#>   rs2678525   0.01314           G           T    0.2522
#>   rs8451246   0.01070           G           T    0.3089
#>   rs7069507   0.00786           T           A    0.3404
#>   rs4824759   0.03794           C           A    0.1418
#>   rs7209949   0.00021           T           C    0.3506
#>         ...       ...         ...         ...       ...
#>   rs7761398   0.03732           C           G    0.1445
#>   rs7135121   0.48192           T           C    0.3549
#>   rs6635611   0.25838           G           A    0.3425
#>   rs6641483   0.00463           T           A    0.2657
#>   rs5502842   0.05999           C           T    0.1301
#>   -------
#>   seqinfo: 22 sequences from an unspecified genome; no seqlengths

# Round-trip back to gwas_data
as_gwas_data(gr)
#> A gwas_data object: 8,000 variants across 22 chromosomes
#>   Min p-value: 1.19e-14
#>   Lambda GC:   3.996
#>   Columns:     CHR, BP, SNP, P, BETA, SE, A1, A2, AF
```
