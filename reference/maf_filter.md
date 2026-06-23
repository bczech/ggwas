# Filter variants by minor allele frequency

Keep only variants with allele frequency within a specified range.
Requires the AF column.

## Usage

``` r
maf_filter(data, min_maf = 0.01, max_maf = 0.5)
```

## Arguments

- data:

  A `gwas_data` object or data.frame with an AF column.

- min_maf:

  Minimum minor allele frequency (default 0.01).

- max_maf:

  Maximum minor allele frequency (default 0.5).

## Value

A filtered `gwas_data` object.

## Examples

``` r
data(example_gwas)
common <- maf_filter(example_gwas, min_maf = 0.05)
```
