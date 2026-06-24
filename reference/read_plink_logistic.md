# Read PLINK logistic regression results

Read PLINK logistic regression results

## Usage

``` r
read_plink_logistic(file, test = "ADD", ...)
```

## Arguments

- file:

  Path to a PLINK .assoc.logistic file.

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
gwas <- read_plink_logistic("my_results.assoc.logistic")
} # }
```
