# Example GWAS dataset

A simulated GWAS dataset with 8000 variants across 22 autosomal
chromosomes, sized proportionally to real human chromosome lengths.
Contains 20 genome-wide significant variants for demonstration.

## Usage

``` r
example_gwas
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

## Examples

``` r
data(example_gwas)
manhattan_plot(example_gwas)
```
