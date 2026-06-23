# Read PLINK association results

Read PLINK association results

## Usage

``` r
read_plink_assoc(file, ...)
```

## Arguments

- file:

  Path to a PLINK .assoc file.

- ...:

  Additional arguments passed to
  [`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html).

## Value

A `gwas_data` object.

## Examples

``` r
f <- system.file("extdata", "example_plink.assoc", package = "gwasplot")
gwas <- read_plink_assoc(f)
#> Read 10 variants from example_plink.assoc
gwas
#> A gwas_data object: 10 variants across 6 chromosomes
#>   Min p-value: 6.80e-11
#>   Lambda GC:   0.692
#>   Columns:     CHR, BP, SNP, P, A1, A2, F_A, F_U, CHISQ, OR
```
