# Add highlighted regions to a Manhattan plot

Draws colored rectangular bands behind specified genomic regions. Useful
for marking known GWAS loci, MHC region, or custom regions of interest.

## Usage

``` r
highlight_regions(
  plt,
  regions,
  color = "#FFD700",
  alpha = 0.15,
  label_size = 2.5,
  label_y = "top",
  border = FALSE,
  border_color = "grey40"
)
```

## Arguments

- plt:

  A ggplot object from
  [`manhattan_plot()`](https://bczech.github.io/ggwas/reference/manhattan_plot.md)
  or similar.

- regions:

  Regions as a
  [GenomicRanges::GRanges](https://rdrr.io/pkg/GenomicRanges/man/GRanges-class.html)
  object. Optional metadata columns: `label`, `color`, `alpha`.

- color:

  Default fill color for regions (if not specified per region).

- alpha:

  Default transparency.

- label_size:

  Font size for region labels.

- label_y:

  Y-axis position for labels ("top" or numeric value).

- border:

  If TRUE, draw a border around regions.

- border_color:

  Border color.

## Value

The ggplot object with region highlights added.

## Examples

``` r
data(example_gwas)
plt <- manhattan_plot(example_gwas)
regions <- GenomicRanges::GRanges(
  c("chr6:25000000-35000000", "chr1:5000000-20000000"),
  label = c("MHC", "1p36")
)
highlight_regions(plt, regions)
```
