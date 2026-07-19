# Read PLINK linear regression results

Read PLINK linear regression results

## Usage

``` r
read_plink_linear(file, test = "ADD", ...)
```

## Arguments

- file:

  Path to a PLINK .assoc.linear file.

- test:

  Which test to keep (default "ADD" for additive model).

- ...:

  Additional arguments passed to
  [`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html).

## Value

A `gwas_data` object.

## Examples

``` r
f <- system.file("extdata", "example_plink.assoc.linear", package = "ggwas")
gwas <- read_plink_linear(f)
#> Read 4 variants from example_plink.assoc.linear
gwas
#> A gwas_data object: 4 variants across 3 chromosomes
#>   Min p-value: 5.20e-08
#>   Lambda GC:   3.171
#>   Columns:     CHR, BP, SNP, P, BETA, A1, N, TEST, STAT
```
