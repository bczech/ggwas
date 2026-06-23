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

  A data.frame, tibble, or data.table.

- chr, bp, snp, p, beta, se, a1, a2, af, n, info:

  Column names to use. If NULL, auto-detection is attempted.

- log_p:

  If TRUE, the p-value column contains -log10(p) values that will be
  back-transformed.

## Value

A tibble with class `gwas_data`.

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
