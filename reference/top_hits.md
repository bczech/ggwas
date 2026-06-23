# Extract top hits from GWAS results

Identifies independent significant loci using window-based clumping,
optionally annotates with nearest gene, and returns a publication-ready
table.

## Usage

``` r
top_hits(
  data,
  p_threshold = 5e-08,
  clump_window = 1e+06,
  genes = NULL,
  max_gene_distance = 5e+05,
  n = 20
)
```

## Arguments

- data:

  A `gwas_data` object or data.frame.

- p_threshold:

  Significance threshold for lead SNPs.

- clump_window:

  Window size in bp for clumping. Only the most significant SNP within
  each window is retained.

- genes:

  Optional gene annotation data.frame (chr, start, end, gene). If
  provided, nearest gene is added.

- max_gene_distance:

  Maximum distance to assign a gene.

- n:

  Maximum number of hits to return.

## Value

A data.frame with columns: SNP, CHR, BP, P, BETA, SE, nearest_gene (if
genes provided), gene_distance, cytoband.

## Examples

``` r
data(example_gwas)
top_hits(example_gwas, p_threshold = 0.001, n = 10)
#> === Top 10 GWAS Hits ===
#> 
#>  SNP       CHR BP        P        BETA     cytoband
#>  rs4551863 10   12347484 1.19e-14 -0.65050 10p2    
#>  rs6815318 5     8647048 1.67e-14  0.22025 5p1     
#>  rs7084233 9    67050634 2.21e-14  0.09187 9q7     
#>  rs3834775 11   55974589 3.20e-14 -0.44376 11q6    
#>  rs7664467 1   243745976 1.13e-13  0.27479 1q25    
#>  rs5643433 12   25442148 1.27e-13  0.37069 12p3    
#>  rs8682426 8    82835070 6.14e-12  0.31901 8q9     
#>  rs5807931 1    32792647 2.75e-11  0.14800 1p4     
#>  rs4355535 14   80736074 7.20e-11 -0.02754 14q9    
#>  rs8870315 2   123129235 7.36e-11  0.09318 2q13    
```
