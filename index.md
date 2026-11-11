# ggwas

Fast, customizable GWAS visualizations built on **ggplot2**, with
sensible defaults and journal-specific themes for publication-ready
figures.

## Key features

- **21 plot types**: from classic Manhattan and QQ to post-GWAS
  visualizations (PheWAS, colocalization, fine-mapping, genetic
  correlations, SNP density, forest, effect comparison, and a
  power-contour trumpet plot)
- **Bioconductor inputs**: variants, gene models and annotation regions
  as `GRanges`, gene models from `TxDb`/`EnsDb`, chromosome lengths from
  `Seqinfo`
- **Genomic tracks**: composable gene annotation panels with exon
  structure, strand arrows and highlighting
- **Broken y-axis** for Manhattan plots with extreme p-values
  (`y_truncate`)
- **Effect-size confidence** mode showing \|beta\| - 2\*SE instead of
  p-values (`y_metric = "beta_min"`)
- **Smart downsampling** for 10M+ variant datasets
- **Journal themes** (Nature, Science, Cell, PLOS) and 14 color palettes
- **Gene annotation** with automatic nearest-gene mapping
- **Auto-detects** column names from PLINK, REGENIE, GCTA, GEMMA, and
  generic files
- **Fully composable**: every function returns a ggplot object

## Gallery

|  |  |
|:--:|:--:|
| **Manhattan plot** | **Broken y-axis** |
| ![](reference/figures/example_manhattan.png) | ![](reference/figures/example_truncate.png) |
| **QQ plot** | **Circular Manhattan** |
| ![](reference/figures/example_qq.png) | ![](reference/figures/example_circular.png) |
| **Miami plot** | **Multi-trait Manhattan** |
| ![](reference/figures/example_miami.png) | ![](reference/figures/example_multitrait.png) |
| **Enrichment Manhattan** | **PheWAS plot** |
| ![](reference/figures/example_enrichment.png) | ![](reference/figures/example_phewas.png) |
| **Genetic correlation** | **Effect-size volcano** |
| ![](reference/figures/example_rg.png) | ![](reference/figures/example_volcano.png) |
| **SNP density karyogram** | **SNP density (points)** |
| ![](reference/figures/example_density.png) | ![](reference/figures/example_density_points.png) |
| **Density vs signal** | **P-value heatmap** |
| ![](reference/figures/example_density_signal.png) | ![](reference/figures/example_heatmap.png) |
| **Locus zoom** | **Effect-size confidence** |
| ![](reference/figures/example_locus.png) | ![](reference/figures/example_beta_min.png) |
| **Genetic architecture** | **Journal themes** |
| ![](reference/figures/example_architecture.png) | ![](reference/figures/example_themes.png) |
| **Trumpet plot (power contours)** | **Forest plot** |
| ![](reference/figures/example_trumpet.png) | ![](reference/figures/example_forest.png) |
| **Effect comparison** | **Gene track with exons** |
| ![](reference/figures/example_effect_compare.png) | ![](reference/figures/example_gene_exons.png) |

Full documentation with worked examples:
**<https://bczech.github.io/ggwas/>**

## Comparison

The closest ggplot2-native package is
[topr](https://github.com/totajuliusd/topr); ggwas matches its
regional/gene depth and adds the genome-wide and post-GWAS breadth
below.

| Feature | qqman | CMplot | topr | **ggwas** |
|----|----|----|----|----|
| ggplot2-native | No | No | Yes | **Yes** |
| Manhattan + QQ | Yes | Yes | Yes | **Yes + CI + λ + MAF-stratified** |
| Miami plot | No | No | No | **Yes** |
| Locus zoom | No | No | Yes | **Yes (LD + gene track)** |
| Circular Manhattan | No | Yes | No | **Yes (multi-ring)** |
| Enrichment Manhattan | No | No | No | **Yes** |
| Multi-trait overlay | No | No | Yes | **Yes (pleiotropy)** |
| Genome-wide heatmap | No | No | No | **Yes** |
| Effect-size volcano | No | No | No | **Yes** |
| Summary dashboard | No | No | No | **Yes** |
| PheWAS plot | No | No | No | **Yes** |
| Colocalization | No | No | No | **Yes** |
| Fine-mapping (PIP) | No | No | No | **Yes** |
| Genetic correlation | No | No | No | **Yes** |
| Architecture plot | No | No | No | **Yes** |
| Trumpet (power) plot | No | No | No | **Yes** |
| Forest plot | No | No | Yes | **Yes** |
| Effect comparison | No | No | Yes | **Yes** |
| SNP density karyogram | No | Yes | No | **Yes** |
| Density vs signal | No | No | No | **Yes** |
| Gene track (with exons) | No | No | Yes | **Yes** |
| Gene models from TxDb/EnsDb | No | No | No | **Yes** |
| GRanges/Seqinfo inputs | No | No | No | **Yes** |
| Region highlights | No | No | No | **Yes** |
| Top hits (clumping) | No | No | No | **Yes** |
| Journal themes | No | No | No | **6 themes + 4 presets** |
| Color palettes | Limited | Limited | Limited | **14 (colorblind-safe default)** |
| Auto-detect formats | No | No | No | **Yes** |
| Downsampling | No | No | Yes | **Yes** |

## Installation

``` r

# From Bioconductor (once accepted)
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("ggwas")

# Development version from GitHub
pak::pak("bczech/ggwas")
```

## Quick start

``` r

library(ggwas)

# Try it on the bundled example dataset
data(example_gwas)          # a data.frame of GWAS results (CHR, BP, SNP, P, ...)
manhattan_plot(example_gwas)

# Read any GWAS results file (columns auto-detected)
gwas <- read_gwas_table("my_results.txt")

# Manhattan plot
manhattan_plot(gwas)

# Label top hits with gene names (gene models as GRanges, TxDb or EnsDb)
library(EnsDb.Hsapiens.v86)
manhattan_genes(gwas, genes = EnsDb.Hsapiens.v86, gene_top_n = 10)

# QQ plot with confidence band and lambda
qq_plot(gwas, show_lambda = TRUE)

# Miami plot: discovery vs replication
miami_plot(discovery, replication,
           top_title = "Discovery", bottom_title = "Replication")

# Publication preset
p <- gwas_preset("publication")
manhattan_plot(gwas, colors = p$colors, point_size = p$point_size) + p$theme
```

## Supported input formats

GWAS summary statistics. Bioconductor has no readers for these
tool-specific text formats, so ggwas provides them:

| Format | Function |
|----|----|
| Generic (auto-detect) | [`read_gwas_table()`](https://bczech.github.io/ggwas/reference/read_gwas_table.md) |
| PLINK .assoc/.linear/.logistic | [`read_plink_assoc()`](https://bczech.github.io/ggwas/reference/read_plink_assoc.md) / `_linear()` / `_logistic()` |
| REGENIE | [`read_regenie()`](https://bczech.github.io/ggwas/reference/read_regenie.md) |
| GCTA MLMA | [`read_gcta_mlma()`](https://bczech.github.io/ggwas/reference/read_gcta_mlma.md) |
| GEMMA | [`read_gemma()`](https://bczech.github.io/ggwas/reference/read_gemma.md) |
| Any data.frame | Pass directly with column mapping |
| `GRanges` (e.g. `rowRanges()` of a VCF read with `VariantAnnotation::readVcf()`) | Pass directly, or [`as_gwas_data()`](https://bczech.github.io/ggwas/reference/as_gwas_data.md) |

Genomic annotation comes from Bioconductor objects and readers:

| Input | Bioconductor source | Used by |
|----|----|----|
| Gene models | `TxDb` (`GenomicFeatures`), `EnsDb` (`ensembldb`), or `GRanges` from `rtracklayer::import()` of a GTF/GFF3 | [`gene_track()`](https://bczech.github.io/ggwas/reference/gene_track.md), [`locus_plot()`](https://bczech.github.io/ggwas/reference/locus_plot.md), [`annotate_genes()`](https://bczech.github.io/ggwas/reference/annotate_genes.md), [`manhattan_genes()`](https://bczech.github.io/ggwas/reference/manhattan_genes.md), [`top_hits()`](https://bczech.github.io/ggwas/reference/top_hits.md), [`annotate_positions()`](https://bczech.github.io/ggwas/reference/annotate_positions.md) |
| Annotation regions (BED, bigBed, …) | `GRanges`/`GRangesList` from `rtracklayer::import()` | [`enrichment_manhattan()`](https://bczech.github.io/ggwas/reference/enrichment_manhattan.md), [`highlight_regions()`](https://bczech.github.io/ggwas/reference/highlight_regions.md) |
| Chromosome lengths and names | `Seqinfo` (`GenomeInfoDb`), or the [`seqinfo()`](https://rdrr.io/pkg/Seqinfo/man/seqinfo.html) of a `TxDb`, `EnsDb` or `BSgenome` | [`snp_density()`](https://bczech.github.io/ggwas/reference/snp_density.md), [`density_signal_plot()`](https://bczech.github.io/ggwas/reference/density_signal_plot.md), [`set_sex_chr_map()`](https://bczech.github.io/ggwas/reference/set_sex_chr_map.md) |

## Plot gallery

### Core plots

``` r

manhattan_plot(gwas, label_top_n = 5)
manhattan_plot(gwas, y_truncate = 15)  # broken y-axis for extreme p-values
manhattan_plot(gwas, y_metric = "beta_min")  # effect-size confidence bound
qq_plot(gwas, show_lambda = TRUE, ci = 0.95)
miami_plot(gwas1, gwas2, top_title = "Study 1", bottom_title = "Study 2")
locus_plot(gwas, lead_snp = "rs12345", flank = 500000)
```

### Novel visualizations

``` r

pvalue_heatmap(gwas, bin_size = 1e6, palette = "magma")
volcano_plot(gwas, label_top_n = 10, color_by = "chromosome")
circular_manhattan(gwas, colors = gwas_palette("nature"))
circular_manhattan(list(BMI = gwas1, Height = gwas2))  # multi-ring
enrichment_manhattan(gwas, annotations = functional_regions)
multitrait_manhattan(BMI = gwas1, Height = gwas2, highlight_shared = TRUE)
trumpet_plot(gwas, n = 500000)  # effect vs MAF with statistical-power contours
gwas_summary(gwas)  # multi-panel dashboard
```

### Post-GWAS

``` r

phewas_plot(phewas_results)
coloc_plot(gwas, eqtl, region = "chr1:1000000-2000000")
finemapping_plot(susie_results, region = "chr1:1000000-2000000")
genetic_correlation(ldsc_matrix, cluster = TRUE)
architecture_plot(gwas)
snp_density(gwas, seqinfo = seqinfo(txdb))
density_signal_plot(gwas)
forest_plot(lead_variants)                       # effect estimates + CI
effect_compare_plot(discovery, replication)      # beta-vs-beta concordance
```

### Gene annotation and genomic tracks

``` r

library(GenomicRanges)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(org.Hs.eg.db)
txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene

# Gene models with symbols
genes <- genes(txdb)
genes$gene_name <- mapIds(org.Hs.eg.db, genes$gene_id, "SYMBOL", "ENTREZID")
# ...or from a GTF: gtf <- rtracklayer::import("Homo_sapiens.GRCh38.113.gtf.gz")

# Locus plot with a gene track and exon structure
region <- GRanges("chr6:25000000-35000000")
p <- locus_plot(gwas, region = region)
gt <- gene_track(genes, region, exons = exonsBy(txdb, by = "gene"),
                 highlight_genes = c("HLA-A", "HLA-B"))
patchwork::wrap_plots(p, gt, ncol = 1, heights = c(0.8, 0.2))

# Label peaks with nearest gene names (instead of rs IDs)
manhattan_genes(gwas, genes = genes, arrow = TRUE)

# Extract independent top hits with gene mapping
top_hits(gwas, genes = genes, p_threshold = 5e-8)

# Highlight genomic regions
plt <- manhattan_plot(gwas)
highlight_regions(plt, GRanges("chr6:25000000-34000000", label = "MHC"))
```

### Themes and palettes

``` r

# Journal themes
manhattan_plot(gwas) + theme_nature()
manhattan_plot(gwas) + theme_science()
manhattan_plot(gwas) + theme_cell()
manhattan_plot(gwas) + theme_plos()

# Presentation / poster
manhattan_plot(gwas) + theme_presentation()
manhattan_plot(gwas) + theme_poster()

# 14 color palettes
gwas_palettes()
manhattan_plot(gwas, colors = gwas_palette("nature"))
```

## Performance

Smart downsampling keeps every significant variant and spatially bins
the denser background, capping the number of plotted points. Render time
therefore stays roughly flat as datasets grow.

``` r

manhattan_plot(large_gwas)  # 10M SNPs, auto-downsampled to ~200k points
```

## Documentation

Full documentation with worked examples:
**<https://bczech.github.io/ggwas/>**

Or from R:

``` r

vignette("ggwas")
```

## Citation

``` r

citation("ggwas")
```

## License

MIT
