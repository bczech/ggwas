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
if (FALSE) { # \dontrun{
gwas <- read_plink_linear("my_results.assoc.linear")
} # }
```
