# GWAS Color Palettes

Pre-defined color palettes for GWAS visualizations. The two-color
palettes used by default for chromosomes stay distinguishable under the
common forms of color blindness: "default" (dark blue and light teal,
used by
[`manhattan_plot()`](https://bczech.github.io/ggwas/reference/manhattan_plot.md),
[`miami_plot()`](https://bczech.github.io/ggwas/reference/miami_plot.md),
and
[`circular_manhattan()`](https://bczech.github.io/ggwas/reference/circular_manhattan.md))
and "colorblind" (Okabe-Ito blue and orange, used by
[`scale_color_gwas()`](https://bczech.github.io/ggwas/reference/scale_color_gwas.md)
and
[`gwas_summary()`](https://bczech.github.io/ggwas/reference/gwas_summary.md)).
The journal palettes ("nature", "science", "lancet", "nejm", "aaas") and
"brewer_set1" and "brewer_paired" match common figure styles, but they
contain both red and green and are not colorblind-safe.

## Usage

``` r
gwas_palette(name = "default", n = NULL, type = "alternating")
```

## Arguments

- name:

  Palette name. One of: "default", "colorblind", "vibrant", "pastel",
  "dark", "nature", "science", "lancet", "nejm", "aaas", "brewer_set1",
  "brewer_set2", "brewer_paired", "brewer_dark2".

- n:

  Number of colors to return. If NULL, returns the full palette.

- type:

  For chromosome palettes: "alternating" (2 colors) or "distinct" (one
  per chromosome).

## Value

A character vector of hex colors.

## Examples

``` r
data(example_gwas)
gwas_palette("colorblind")
#> [1] "#0072B2" "#E69F00"
gwas_palette("nature", n = 5)
#> [1] "#E64B35" "#4DBBD5" "#00A087" "#3C5488" "#F39B7F"
manhattan_plot(example_gwas, colors = gwas_palette("vibrant"))
```
