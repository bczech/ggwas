# Minimal GWAS theme for ggplot2

A clean, publication-ready theme optimized for GWAS plots.

## Usage

``` r
theme_gwas(base_size = 11, base_family = "")
```

## Arguments

- base_size:

  Base font size (default 11).

- base_family:

  Base font family.

## Value

A ggplot2 theme object.

## Examples

``` r
data(example_gwas)
manhattan_plot(example_gwas) + theme_gwas()
```
