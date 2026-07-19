# Read REGENIE results

Read REGENIE results

## Usage

``` r
read_regenie(file, ...)
```

## Arguments

- file:

  Path to a .regenie results file.

- ...:

  Additional arguments passed to
  [`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html).

## Value

A `gwas_data` object.

## Examples

``` r
f <- system.file("extdata", "example_regenie.regenie", package = "ggwas")
gwas <- read_regenie(f)
#> Read 4 variants from example_regenie.regenie
gwas
#> A gwas_data object: 4 variants across 3 chromosomes
#>   Min p-value: 5.20e-08
#>   Lambda GC:   1.438
#>   Columns:     CHR, BP, SNP, BETA, SE, A1, A2, AF, N, P, TEST, CHISQ, EXTRA
```
