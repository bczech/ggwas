# Create a gwas_data object

Convert a data.frame to the standardized gwas_data format used by all
ggwas plotting functions.

## Usage

``` r
as_gwas_data(
  x,
  chr = NULL,
  bp = NULL,
  snp = NULL,
  p = NULL,
  beta = NULL,
  se = NULL,
  a1 = NULL,
  a2 = NULL,
  af = NULL,
  n = NULL,
  info = NULL,
  log_p = FALSE
)
```

## Arguments

- x:

  A data.frame, tibble, data.table, or a Bioconductor `GRanges` object
  (variant positions are taken from the ranges and association
  statistics from the metadata columns).

- chr, bp, snp, p, beta, se, a1, a2, af, n, info:

  Column names to use. If NULL, auto-detection is attempted.

- log_p:

  If TRUE, the p-value column contains -log10(p) values. Use this for
  p-values smaller than R can store (about 1e-323).

## Value

A data.frame with class `gwas_data`. P-values below the double range are
stored as `P = 0`; their exact -log10(p) is then kept in a `LOG10P`
column, which all plots use. It comes from a -log10(p) column
(`log_p = TRUE`), from p-values read as text (e.g. `"1e-400"`, as
[`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html)
returns them), or from a `LOG10P` column next to the p-values.

## Examples

``` r
df <- data.frame(CHR = c(1, 1, 2), BP = c(1e6, 2e6, 5e6),
                 P = c(1e-8, 0.5, 0.01), SNP = c("rs1", "rs2", "rs3"))
gd <- as_gwas_data(df)
gd
#> A gwas_data object: 3 variants across 2 chromosomes
#>   Min p-value: 1.00e-08
#>   Lambda GC:   14.584
#>   Columns:     CHR, BP, SNP, P
```
