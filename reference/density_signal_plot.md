# Density–signal dual-track plot

Compare SNP genotyping density against association signal strength
across the genome. Each chromosome has two rows: the top track shows the
number of variants per bin (density), and the bottom track shows the
minimum p-value per bin (signal). This helps distinguish genuine
association signals from artifacts driven by uneven genotyping or
imputation coverage.

## Usage

``` r
density_signal_plot(
  data,
  chr = NULL,
  bp = NULL,
  p = NULL,
  bin_size = 1e+06,
  seqinfo = NULL,
  density_palette = "viridis",
  signal_palette = "magma",
  chromosomes = NULL,
  title = NULL
)
```

## Arguments

- data:

  A `gwas_data` object or data.frame with GWAS results.

- chr, bp, p:

  Column name overrides.

- bin_size:

  Bin size in base pairs (default 1 Mb).

- seqinfo:

  Optional chromosome lengths as a `Seqinfo` object (GenomeInfoDb) or
  any object that has one, such as a `TxDb`, `EnsDb` or `BSgenome`. If
  NULL, chromosome lengths are inferred from the data.

- density_palette:

  Color palette for the density track.

- signal_palette:

  Color palette for the signal track.

- chromosomes:

  Optional integer vector of chromosomes to display.

- title:

  Plot title.

## Value

A ggplot object.

## Examples

``` r
data(example_gwas, package = "ggwas")
density_signal_plot(example_gwas, bin_size = 5e6)


# Full chromosome lengths from a Seqinfo. With internet access,
# GenomeInfoDb::Seqinfo(genome = "hg38")[paste0("chr", 1:3)] gives the
# same object; here it is taken offline from a TxDb package.
if (requireNamespace("TxDb.Hsapiens.UCSC.hg38.knownGene", quietly = TRUE)) {
  library(GenomeInfoDb)
  txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene::TxDb.Hsapiens.UCSC.hg38.knownGene
  si <- seqinfo(txdb)[paste0("chr", 1:3)]
  density_signal_plot(example_gwas, bin_size = 5e6, seqinfo = si,
    chromosomes = 1:3)
}
#> Loading required package: BiocGenerics
#> Loading required package: generics
#> 
#> Attaching package: 'generics'
#> The following objects are masked from 'package:base':
#> 
#>     as.difftime, as.factor, as.ordered, intersect, is.element, setdiff,
#>     setequal, union
#> 
#> Attaching package: 'BiocGenerics'
#> The following objects are masked from 'package:stats':
#> 
#>     IQR, mad, sd, var, xtabs
#> The following objects are masked from 'package:base':
#> 
#>     Filter, Find, Map, Position, Reduce, anyDuplicated, aperm, append,
#>     as.data.frame, basename, cbind, colnames, dirname, do.call,
#>     duplicated, eval, evalq, get, grep, grepl, is.unsorted, lapply,
#>     mapply, match, mget, order, paste, pmax, pmax.int, pmin, pmin.int,
#>     rank, rbind, rownames, sapply, saveRDS, table, tapply, unique,
#>     unsplit, which.max, which.min
#> Loading required package: S4Vectors
#> Loading required package: stats4
#> 
#> Attaching package: 'S4Vectors'
#> The following object is masked from 'package:utils':
#> 
#>     findMatches
#> The following objects are masked from 'package:base':
#> 
#>     I, expand.grid, unname
#> Loading required package: IRanges
#> Loading required package: Seqinfo


# Subset to specific chromosomes
density_signal_plot(example_gwas, bin_size = 5e6, chromosomes = seq_len(5))


# Different palettes
density_signal_plot(example_gwas, bin_size = 5e6,
  density_palette = "plasma", signal_palette = "inferno")
```
