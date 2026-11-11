# SNP density karyogram

Visualize the distribution of genotyped or imputed variants across
chromosomes. Two rendering styles are available: `"heatmap"` (default)
bins variants and colors tiles by count, while `"points"` draws
individual variant positions on chromosome outlines, where density is
visible through natural clustering. Optionally marks centromere
positions when `centromeres` are provided.

## Usage

``` r
snp_density(
  data,
  chr = NULL,
  bp = NULL,
  p = NULL,
  style = c("heatmap", "points"),
  bin_size = 1e+06,
  color_by = c("density", "significance", "uniform"),
  seqinfo = NULL,
  centromeres = NULL,
  palette = "viridis",
  point_size = 0.3,
  point_alpha = 0.5,
  show_centromeres = TRUE,
  downsample_n = 2e+05,
  title = NULL
)
```

## Arguments

- data:

  A `gwas_data` object or data.frame with GWAS results.

- chr, bp, p:

  Column name overrides.

- style:

  Rendering style: `"heatmap"` for binned density tiles, or `"points"`
  for individual variant positions on chromosome outlines.

- bin_size:

  Bin size in base pairs (default 1 Mb). Only used when
  `style = "heatmap"`.

- color_by:

  For `style = "points"`: how to color dots. `"density"` (default)
  colors by local density, `"significance"` colors by -log10(p), or
  `"uniform"` for a single color.

- seqinfo:

  Optional chromosome lengths as a `Seqinfo` object (GenomeInfoDb) or
  any object that has one, such as a `TxDb`, `EnsDb` or `BSgenome`. If
  NULL, chromosome lengths are inferred from the data.

- centromeres:

  Optional centromere positions as a
  [GenomicRanges::GRanges](https://rdrr.io/pkg/GenomicRanges/man/GRanges-class.html),
  one or more ranges per chromosome (for example the UCSC "Centromeres"
  track imported with rtracklayer).

- palette:

  Color palette: "viridis", "magma", "inferno", or "plasma".

- point_size:

  Point size for `style = "points"`.

- point_alpha:

  Point transparency for `style = "points"`.

- show_centromeres:

  If TRUE and `centromeres` are given, draw centromere markers.

- downsample_n:

  Maximum number of points to plot in `"points"` style. Set to NULL to
  plot all variants (can be slow for \>500k).

- title:

  Plot title.

## Value

A ggplot object.

## Examples

``` r
data(example_gwas, package = "ggwas")

# Heatmap style (default); chromosome lengths taken from the data
snp_density(example_gwas, bin_size = 5e6)


# Different palette
snp_density(example_gwas, bin_size = 5e6, palette = "magma")


# Points style with centromere markers (hg38 positions for chr1 and chr2)
cen <- GenomicRanges::GRanges(
  c("chr1:122026460-124932724", "chr2:92188146-94090557")
)
snp_density(example_gwas, style = "points", centromeres = cen)


# Points colored by significance
snp_density(example_gwas, style = "points", color_by = "significance")


# Full chromosome lengths from a Seqinfo, here taken from a TxDb
if (requireNamespace("TxDb.Hsapiens.UCSC.hg38.knownGene", quietly = TRUE)) {
  txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene::TxDb.Hsapiens.UCSC.hg38.knownGene
  snp_density(example_gwas, bin_size = 5e6,
    seqinfo = GenomeInfoDb::seqinfo(txdb))
}
```
