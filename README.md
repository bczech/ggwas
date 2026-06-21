# gwasplot <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/bczech/gwasplot/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bczech/gwasplot/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/gwasplot)](https://CRAN.R-project.org/package=gwasplot)
<!-- badges: end -->

Modern, fast, and customizable GWAS visualizations built on **ggplot2**.

## Why gwasplot?

| Feature | qqman | CMplot | **gwasplot** |
|---|---|---|---|
| ggplot2-native | No | No | **Yes** |
| Manhattan plot | Yes | Yes | **Yes** |
| QQ plot | Yes | Yes | **Yes + CI + lambda + stratified** |
| Miami plot | No | No | **Yes** |
| Locus Zoom | No | No | **Yes** |
| Circular Manhattan | No | Yes (base R) | **Yes (ggplot2, multi-ring)** |
| Enrichment Manhattan | No | No | **Yes (novel)** |
| Multi-trait Manhattan | No | No | **Yes (novel)** |
| Genome Heatmap | No | No | **Yes (novel)** |
| Effect Volcano | No | No | **Yes (novel)** |
| Summary Dashboard | No | No | **Yes (novel)** |
| Journal themes | No | No | **Nature/Science/Cell/PLOS** |
| Color palettes | Limited | Limited | **RColorBrewer + ggsci + 14 presets** |
| Publication presets | No | No | **Yes** |
| Auto-detect formats | No | No | **Yes** |
| Smart downsampling | No | No | **Yes** |

## Installation

```r
# Install from GitHub
# install.packages("pak")
pak::pak("bczech/gwasplot")
```

## Quick Start

```r
library(gwasplot)

# Read any GWAS format — columns are auto-detected
gwas <- read_gwas_table("my_results.txt")

# Manhattan plot in one line
manhattan_plot(gwas)

# QQ plot with confidence bands and lambda
qq_plot(gwas, show_lambda = TRUE)

# Label top hits
manhattan_plot(gwas, label_top_n = 5)

# Miami plot — compare two studies
miami_plot(
  top = read_regenie("study1.regenie"),
  bottom = read_regenie("study2.regenie"),
  top_title = "Discovery",
  bottom_title = "Replication"
)

# Novel: genome-wide p-value heatmap
pvalue_heatmap(gwas, bin_size = 500000, palette = "magma")

# Novel: effect-size volcano
volcano_plot(gwas, label_top_n = 10)
```

## Supported Input Formats

| Format | Reader | Tool |
|---|---|---|
| Generic (auto-detect) | `read_gwas_table()` | Any |
| PLINK `.assoc` | `read_plink_assoc()` | PLINK |
| PLINK `.assoc.linear` | `read_plink_linear()` | PLINK |
| PLINK `.assoc.logistic` | `read_plink_logistic()` | PLINK |
| REGENIE `.regenie` | `read_regenie()` | REGENIE |
| GCTA `.mlma` | `read_gcta_mlma()` | GCTA |
| GEMMA `.assoc.txt` | `read_gemma()` | GEMMA |

Or pass any `data.frame` directly — column names are auto-matched:

```r
manhattan_plot(my_df, chr = "chrom", bp = "position", p = "pval")
```

## Plot Gallery

### Manhattan Plot

```r
data(example_gwas)
manhattan_plot(example_gwas, label_top_n = 3)
```

### QQ Plot with Confidence Bands

```r
qq_plot(example_gwas, ci = 0.95, show_lambda = TRUE)
```

### Miami Plot

```r
miami_plot(example_gwas, example_gwas,
           top_title = "Trait 1", bottom_title = "Trait 2")
```

### Genome-Wide Heatmap (Novel)

```r
pvalue_heatmap(example_gwas, bin_size = 5e6, palette = "magma")
```

### Effect-Size Volcano (Novel)

```r
volcano_plot(example_gwas, label_top_n = 5, color_by = "chromosome")
```

### Circular Manhattan

```r
circular_manhattan(example_gwas, colors = gwas_palette("vibrant"))

# Multi-ring: compare traits
circular_manhattan(list(BMI = gwas1, Height = gwas2, WHR = gwas3))
```

### Enrichment Manhattan (Novel)

```r
# Overlay functional annotations
annotations <- data.frame(
  chr = c(1, 6, 17), start = c(1e6, 25e6, 40e6),
  end = c(5e6, 35e6, 45e6), category = c("Enhancer", "MHC", "Gene")
)
enrichment_manhattan(gwas, annotations = annotations, palette = "nature")
```

### Multi-trait Manhattan (Novel)

```r
# Compare multiple GWAS on one plot
multitrait_manhattan(BMI = gwas_bmi, Height = gwas_height, WHR = gwas_whr,
                     colors = "nature", highlight_shared = TRUE)
```

### Summary Dashboard (Novel)

```r
# Publication-ready multi-panel figure with automatic panel labels (A, B, C, D)
gwas_summary(gwas, panels = c("manhattan", "qq", "top_hits", "density"))
```

## Themes and Palettes

```r
# Journal-specific themes
manhattan_plot(gwas) + theme_nature()
manhattan_plot(gwas) + theme_science()
manhattan_plot(gwas) + theme_cell()
manhattan_plot(gwas) + theme_plos()
manhattan_plot(gwas) + theme_presentation()  # talks
manhattan_plot(gwas) + theme_poster()        # posters

# 14 built-in palettes (colorblind-safe, journal-inspired)
gwas_palettes()  # list all
manhattan_plot(gwas, colors = gwas_palette("nature"))
manhattan_plot(gwas, colors = gwas_palette("brewer_set1"))

# Publication presets (theme + colors + sizes in one call)
p <- gwas_preset("publication")
manhattan_plot(gwas, colors = p$colors, point_size = p$point_size) + p$theme
```

## Performance

Smart downsampling preserves all significant and near-significant variants
while reducing non-significant variants through spatial binning:

```r
# 10M+ SNPs — downsampled to ~200k points automatically
manhattan_plot(large_gwas)  # fast rendering, visually identical
```

## Customization

Every function returns a `ggplot` object — add layers, themes, and scales:

```r
manhattan_plot(gwas) +
  ggplot2::theme_minimal() +
  ggplot2::labs(title = "My GWAS Results")
```

## Citation

If you use gwasplot in your research, please cite:

```
Czech B (2026). gwasplot: Modern ggplot2 Visualizations for Genome-Wide
Association Studies. R package version 0.1.0.
https://github.com/bczech/gwasplot
```

## License

MIT
