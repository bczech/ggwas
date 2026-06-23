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
# \donttest{
gwas <- read_plink_linear("my_results.assoc.linear")
#> Error in data.table::fread(file, header = TRUE, data.table = FALSE, ...): File 'my_results.assoc.linear' does not exist or is non-readable. getwd()=='/home/runner/work/ggwas/ggwas/docs/reference'
# }
```
