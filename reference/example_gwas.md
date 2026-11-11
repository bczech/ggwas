# Example GWAS dataset

A simulated GWAS dataset with 8000 variants across 22 autosomal
chromosomes, sized proportionally to real human chromosome lengths.
Contains 20 genome-wide significant variants for demonstration.

## Usage

``` r
data(example_gwas)
```

## Format

A `gwas_data` data.frame with 8000 rows and 9 columns:

- CHR:

  Chromosome (integer, 1-22)

- BP:

  Base pair position

- SNP:

  Variant identifier (rs ID)

- P:

  P-value

- BETA:

  Effect size

- SE:

  Standard error

- A1:

  Effect allele

- A2:

  Other allele

- AF:

  Allele frequency

## Source

Simulated with `data-raw/example_gwas.R` in the package source.
Positions are drawn within GRCh38 (hg38) chromosome lengths.

## Value

A `gwas_data` data.frame, loaded into the workspace by
`data(example_gwas)`.

## Examples

``` r
data(example_gwas)
manhattan_plot(example_gwas)
```
