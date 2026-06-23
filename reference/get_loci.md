# Get significant loci

Extract variants below a p-value threshold, with optional clumping to
return only independent lead SNPs.

## Usage

``` r
get_loci(data, p_threshold = 5e-08, clump = TRUE, clump_window = 1e+06)
```

## Arguments

- data:

  A `gwas_data` object or data.frame.

- p_threshold:

  P-value threshold (default 5e-8).

- clump:

  If TRUE, apply window-based clumping.

- clump_window:

  Clumping window in bp (default 1 Mb).

## Value

A data.frame of significant variants.

## Examples

``` r
data(example_gwas)
get_loci(example_gwas, p_threshold = 0.001)
#> A gwas_data object: 448 variants across 22 chromosomes
#>   Min p-value: 1.19e-14
#>   Lambda GC:   31.988
#>   Columns:     CHR, BP, SNP, P, BETA, SE, A1, A2, AF
```
