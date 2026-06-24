# SNP density karyogram

Visualize the distribution of genotyped or imputed variants across
chromosomes. Each chromosome is drawn proportionally to its length and
colored by SNP density per genomic bin. Optionally marks centromere
positions when `chr_info` is provided.

## Usage

``` r
snp_density(
  data,
  chr = NULL,
  bp = NULL,
  bin_size = 1e+06,
  chr_info = NULL,
  palette = "viridis",
  show_centromeres = TRUE,
  title = NULL
)
```

## Arguments

- data:

  A `gwas_data` object or data.frame with GWAS results.

- chr, bp:

  Column name overrides.

- bin_size:

  Bin size in base pairs (default 1 Mb).

- chr_info:

  Optional data.frame with columns `chr`, `length`, and optionally
  `centromere_start`, `centromere_end`. Use
  [`chr_info_human()`](https://bczech.github.io/ggwas/reference/chr_info_human.md)
  for hg38. If NULL, chromosome lengths are inferred from the data.

- palette:

  Color palette for density: "viridis", "magma", "inferno", or "plasma".

- show_centromeres:

  If TRUE and centromere positions are available in `chr_info`, draw
  centromere markers.

- title:

  Plot title.

## Value

A ggplot object.

## Examples

``` r
data(example_gwas, package = "ggwas")
snp_density(example_gwas, bin_size = 5e6)


# With human centromere markers
snp_density(example_gwas, bin_size = 5e6, chr_info = chr_info_human())
```
