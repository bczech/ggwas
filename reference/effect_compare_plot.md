# Compare variant effects between two GWAS

Scatter the per-variant effect sizes of two studies against each other
for the variants they share, to assess replication and effect
concordance (for example discovery versus replication, or two
ancestries). A `y = x` reference line is drawn; points are colored by
whether the two effects agree in sign among variants significant in
either study.

## Usage

``` r
effect_compare_plot(
  gwas1,
  gwas2,
  snp = NULL,
  beta = NULL,
  se = NULL,
  p = NULL,
  labels = c("Study 1", "Study 2"),
  p_threshold = 5e-08,
  show_ci = TRUE,
  ci = 0.95,
  label_top_n = 10,
  colors = c(concordant = "#2C7FB8", discordant = "#D7301F", ns = "#BDC3C7"),
  point_size = 1.8,
  title = NULL
)
```

## Arguments

- gwas1, gwas2:

  `gwas_data` objects or data.frames. Variants are matched on the SNP
  column.

- snp, beta, se, p:

  Column name overrides applied to both inputs when they are plain
  data.frames.

- labels:

  Length-2 character vector of axis labels.

- p_threshold:

  Significance threshold used to classify variants.

- show_ci:

  If TRUE, draw confidence-interval crosses for the significant variants
  (requires SE columns).

- ci:

  Confidence level for the crosses.

- label_top_n:

  Label the N most significant shared variants.

- colors:

  Named colors for "concordant", "discordant" and "ns".

- point_size:

  Point size.

- title:

  Plot title.

## Value

A ggplot object.

## Examples

``` r
data(example_gwas)
g2 <- example_gwas
g2$BETA <- g2$BETA + stats::rnorm(nrow(g2), 0, 0.02)
effect_compare_plot(example_gwas, g2,
                    labels = c("Discovery", "Replication"),
                    p_threshold = 1e-3)
```
