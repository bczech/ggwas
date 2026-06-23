# GWAS Color Palettes

Pre-defined color palettes optimized for GWAS visualizations. All
palettes are colorblind-friendly by default.

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
gwas_palette("colorblind")
#> [1] "#0072B2" "#E69F00"
gwas_palette("nature", n = 5)
#> [1] "#E64B35" "#4DBBD5" "#00A087" "#3C5488" "#F39B7F"
manhattan_plot(example_gwas, colors = gwas_palette("vibrant"))
```
