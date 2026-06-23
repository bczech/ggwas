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
# \donttest{
gwas <- read_gcta_mlma("my_results.mlma")
#> Error in data.table::fread(file, header = TRUE, data.table = FALSE, ...): File 'my_results.mlma' does not exist or is non-readable. getwd()=='/home/runner/work/ggwas/ggwas/docs/reference'
# }
```
