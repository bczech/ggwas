# GWAS plot presets

Apply a preset configuration to any gwasplot function. Presets combine a
theme, color palette, and sizing appropriate for the context.

## Usage

``` r
gwas_preset(preset = "publication")
```

## Arguments

- preset:

  One of: "publication", "presentation", "poster", "exploratory".

## Value

A list with components: `theme`, `colors`, `point_size`, `alpha`,
`label_size`.

## Examples

``` r
p <- gwas_preset("publication")
manhattan_plot(example_gwas, colors = p$colors, point_size = p$point_size) +
  p$theme
```
