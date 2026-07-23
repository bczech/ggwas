# Read GCTA MLMA results

Read GCTA MLMA results

## Usage

``` r
read_gcta_mlma(file, ...)
```

## Arguments

- file:

  Path to a GCTA .mlma file.

- ...:

  Additional arguments passed to
  [`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html).

## Value

A `gwas_data` object.

## Examples

``` r
f <- system.file("extdata", "example_gcta.mlma", package = "ggwas")
gwas <- read_gcta_mlma(f)
#> Read 4 variants from example_gcta.mlma
gwas
#> A gwas_data object: 4 variants across 3 chromosomes
#>   Min p-value: 5.20e-08
#>   Lambda GC:   3.171
#>   Columns:     CHR, BP, SNP, P, BETA, SE, A1, A2, AF
```
