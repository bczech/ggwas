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
f <- system.file("extdata", "example_gemma.assoc.txt", package = "ggwas")
gwas <- read_gemma(f)
#> Read 4 variants from example_gemma.assoc.txt
gwas
#> A gwas_data object: 4 variants across 3 chromosomes
#>   Min p-value: 5.20e-08
#>   Lambda GC:   3.171
#>   Columns:     CHR, BP, SNP, P, BETA, SE, A1, A2, AF, n_miss, logl_H1, l_remle
```
