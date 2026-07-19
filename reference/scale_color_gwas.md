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
  [`gwas_palette()`](https://bczech.github.io/ggwas/reference/gwas_palette.md).

- ...:

  Additional arguments passed to
  [`ggplot2::scale_color_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Value

A ggplot2 color scale.

## Examples

``` r
scale_color_gwas("nature")
#> <ggproto object: Class ScaleDiscrete, Scale, gg>
#>     aesthetics: colour
#>     axis_order: function
#>     break_info: function
#>     break_positions: function
#>     breaks: waiver
#>     call: call
#>     clone: function
#>     dimension: function
#>     drop: TRUE
#>     expand: waiver
#>     fallback_palette: function
#>     get_breaks: function
#>     get_breaks_minor: function
#>     get_labels: function
#>     get_limits: function
#>     get_transformation: function
#>     guide: legend
#>     is_discrete: function
#>     is_empty: function
#>     labels: waiver
#>     limits: function
#>     make_sec_title: function
#>     make_title: function
#>     map: function
#>     map_df: function
#>     minor_breaks: waiver
#>     n.breaks.cache: NULL
#>     na.translate: TRUE
#>     na.value: grey50
#>     name: waiver
#>     palette: function
#>     palette.cache: NULL
#>     position: left
#>     range: environment
#>     rescale: function
#>     reset: function
#>     train: function
#>     train_df: function
#>     transform: function
#>     transform_df: function
#>     super:  <ggproto object: Class ScaleDiscrete, Scale, gg>
scale_fill_gwas("colorblind")
#> <ggproto object: Class ScaleDiscrete, Scale, gg>
#>     aesthetics: fill
#>     axis_order: function
#>     break_info: function
#>     break_positions: function
#>     breaks: waiver
#>     call: call
#>     clone: function
#>     dimension: function
#>     drop: TRUE
#>     expand: waiver
#>     fallback_palette: function
#>     get_breaks: function
#>     get_breaks_minor: function
#>     get_labels: function
#>     get_limits: function
#>     get_transformation: function
#>     guide: legend
#>     is_discrete: function
#>     is_empty: function
#>     labels: waiver
#>     limits: function
#>     make_sec_title: function
#>     make_title: function
#>     map: function
#>     map_df: function
#>     minor_breaks: waiver
#>     n.breaks.cache: NULL
#>     na.translate: TRUE
#>     na.value: grey50
#>     name: waiver
#>     palette: function
#>     palette.cache: NULL
#>     position: left
#>     range: environment
#>     rescale: function
#>     reset: function
#>     train: function
#>     train_df: function
#>     transform: function
#>     transform_df: function
#>     super:  <ggproto object: Class ScaleDiscrete, Scale, gg>
```
