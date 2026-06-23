# Read GWAS summary statistics from any tabular file

Reads a GWAS results file with automatic column detection. Supports any
delimited text file. Column names are matched against common GWAS naming
conventions.

## Usage

``` r
read_gwas_table(
  file,
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
  sep = "auto",
  log_p = FALSE,
  ...
)
```

## Arguments

- file:

  Path to the input file.

- chr, bp, snp, p, beta, se, a1, a2, af, n, info:

  Optional column name overrides.

- sep:

  Column separator. "auto" uses
  [`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html)
  auto-detection.

- log_p:

  If TRUE, the p-value column contains -log10(p) values.

- ...:

  Additional arguments passed to
  [`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html).

## Value

A `gwas_data` object.

## Examples

``` r
f <- system.file("extdata", "example_plink.assoc", package = "gwasplot")
gwas <- read_gwas_table(f)
#> Read 10 variants from example_plink.assoc
gwas
#> A gwas_data object: 10 variants across 6 chromosomes
#>   Min p-value: 6.80e-11
#>   Lambda GC:   0.692
#>   Columns:     CHR, BP, SNP, P, A1, A2, F_A, F_U, CHISQ, OR
```
