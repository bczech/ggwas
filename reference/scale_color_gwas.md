# Colorblind-safe chromosome color scale

Scale using colorblind-friendly alternating colors for chromosomes.

## Usage

``` r
scale_color_gwas(palette = "colorblind", ...)

scale_fill_gwas(palette = "colorblind", ...)
```

## Arguments

- palette:

  Palette name from
  [`gwas_palette()`](https://bczech.github.io/gwasplot/reference/gwas_palette.md).

- ...:

  Additional arguments passed to
  [`ggplot2::scale_color_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Value

A ggplot2 color scale.
