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
if (FALSE) { # \dontrun{
gwas <- read_regenie("my_results.regenie")
} # }
```
