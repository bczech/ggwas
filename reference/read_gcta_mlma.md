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
if (FALSE) { # \dontrun{
gwas <- read_gcta_mlma("my_results.mlma")
} # }
```
