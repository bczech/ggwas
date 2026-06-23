# Merge multiple GWAS datasets

Combine results from multiple GWAS into a single data.frame with a
`study` column identifying the source. Useful for multi-trait
comparisons and meta-analysis visualization.

## Usage

``` r
merge_gwas(..., by = NULL)
```

## Arguments

- ...:

  Named `gwas_data` objects or data.frames. Names become the `study`
  column values.

- by:

  Columns to match variants across studies. Default uses SNP if
  available, otherwise CHR + BP.

## Value

A data.frame with an added `study` column.

## Examples

``` r
data(example_gwas)
trait1 <- example_gwas
trait2 <- example_gwas
trait2$P <- runif(nrow(trait2))
merged <- merge_gwas(BMI = trait1, Height = trait2)
head(merged)
#> A gwas_data object: 6 variants across 4 chromosomes
#>   Min p-value: 6.81e-03
#>   Lambda GC:   7.391
#>   Columns:     CHR, BP, SNP, P, BETA, SE, A1, A2, AF, study
```
