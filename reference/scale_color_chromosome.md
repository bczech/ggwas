# Chromosome color scale

Alternating color scale for chromosomes in Manhattan plots.

## Usage

``` r
scale_color_chromosome(
  colors = c("#1A5276", "#76D7C4"),
  chromosomes = NULL,
  ...
)

scale_fill_chromosome(
  colors = c("#1A5276", "#76D7C4"),
  chromosomes = NULL,
  ...
)
```

## Arguments

- colors:

  Two-element character vector of alternating colors.

- chromosomes:

  Chromosome codes present in the data, in the order they appear along
  the genome. Colors alternate across this set, so any organism is
  handled (e.g. cattle with 29 autosomes plus X coded as 30). When
  `NULL`, defaults to the human coding (autosomes 1-22 plus X/Y/XY/MT as
  23-26).

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
