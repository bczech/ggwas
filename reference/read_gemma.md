# Read GEMMA association results

Read GEMMA association results

## Usage

``` r
read_gemma(file, p_column = "p_wald", ...)
```

## Arguments

- file:

  Path to a GEMMA .assoc.txt file.

- p_column:

  Which p-value column to use: "p_wald", "p_lrt", or "p_score".

- ...:

  Additional arguments passed to
  [`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html).

## Value

A `gwas_data` object.

## Examples

``` r
# \donttest{
gwas <- read_gemma("my_results.assoc.txt")
#> Error in data.table::fread(file, header = TRUE, data.table = FALSE, ...): File 'my_results.assoc.txt' does not exist or is non-readable. getwd()=='/home/runner/work/ggwas/ggwas/docs/reference'
# }
```
