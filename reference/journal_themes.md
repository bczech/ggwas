# Journal-specific themes for GWAS plots

Publication-ready themes matching the style guides of major journals.
Includes appropriate fonts, sizes, and spacing.

## Usage

``` r
theme_nature(base_size = 7, base_family = "")

theme_science(base_size = 8, base_family = "")

theme_plos(base_size = 10, base_family = "")

theme_cell(base_size = 7, base_family = "")

theme_presentation(base_size = 16, base_family = "")

theme_poster(base_size = 20, base_family = "")
```

## Arguments

- base_size:

  Base font size.

- base_family:

  Base font family. Defaults vary by journal.

## Value

A ggplot2 theme object.

## Examples

``` r
data(example_gwas)
manhattan_plot(example_gwas) + theme_nature()
```
