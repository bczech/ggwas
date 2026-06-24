# Fetch chromosome information from UCSC

Downloads chromosome lengths and centromere positions from the UCSC
Genome Browser for any supported genome assembly. Requires internet
access.

## Usage

``` r
chr_info_ucsc(genome, autosomes_only = TRUE)
```

## Arguments

- genome:

  UCSC genome identifier, e.g. `"hg38"`, `"mm39"`, `"bosTau9"`,
  `"canFam6"`, `"susScr11"`, `"galGal6"`.

- autosomes_only:

  If TRUE (default), return only autosomal chromosomes (exclude X, Y, M,
  and unplaced scaffolds).

## Value

A data.frame with columns: `chr` (integer), `length`,
`centromere_start`, `centromere_end`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Dog genome
dog <- chr_info_ucsc("canFam6")
snp_density(gwas, chr_info = dog)

# Pig genome
pig <- chr_info_ucsc("susScr11")
} # }
```
