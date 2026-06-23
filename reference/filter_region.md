# Filter variants by genomic region

Subset a GWAS dataset to variants within a specified genomic region.

## Usage

``` r
filter_region(data, chr, start, end)
```

## Arguments

- data:

  A `gwas_data` object or data.frame with CHR and BP columns.

- chr:

  Chromosome (integer or string like "chr6").

- start:

  Start position (bp).

- end:

  End position (bp).

## Value

A filtered `gwas_data` object.

## Examples

``` r
data(example_gwas)
mhc <- filter_region(example_gwas, chr = 6, start = 25e6, end = 34e6)
```
