# Calculate genomic inflation factor (lambda GC)

Calculate genomic inflation factor (lambda GC)

## Usage

``` r
calc_lambda(p)
```

## Arguments

- p:

  Numeric vector of p-values.

## Value

Genomic inflation factor (lambda).

## Examples

``` r
data(example_gwas)
calc_lambda(example_gwas$P)
#> [1] 3.996032
```
