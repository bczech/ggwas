# Chromosome color scale

Alternating color scale for chromosomes in Manhattan plots.

## Usage

``` r
scale_color_chromosome(colors = c("#1A5276", "#76D7C4"), ...)

scale_fill_chromosome(colors = c("#1A5276", "#76D7C4"), ...)
```

## Arguments

- colors:

  Two-element character vector of alternating colors.

- ...:

  Additional arguments passed to
  [`ggplot2::scale_color_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Value

A ggplot2 color scale.

## Examples

``` r
data(example_gwas)
manhattan_plot(example_gwas, colors = c("#E64B35", "#4DBBD5"))
```
