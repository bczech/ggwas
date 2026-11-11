# Configure sex chromosome mapping

ggwas stores chromosomes as integer codes. By default it uses human
conventions, where chromosome 23 is labeled "X", 24 is "Y", 25 is "XY"
and 26 is "MT". For other organisms, pass the genome's `Seqinfo` object
(GenomeInfoDb) and the codes are taken from its sequence names: numbered
chromosomes keep their number, and named ones (X, Y, Z, W, MT, ...) are
numbered after the last autosome, in `Seqinfo` order. Unplaced scaffolds
are ignored.

## Usage

``` r
set_sex_chr_map(map = .default_sex_chr_map)
```

## Arguments

- map:

  A `Seqinfo` object, or any object that has one (`TxDb`, `EnsDb`,
  `BSgenome`); or a named integer vector mapping labels to integers,
  e.g. `c(X = 20L, Y = 21L)`. Pass `NULL` to disable the mapping
  (chromosomes displayed as plain numbers).

## Value

The previous mapping (invisibly).

## Examples

``` r
# Mouse (GRCm39): 19 autosomes, then X, Y and MT
mouse <- GenomeInfoDb::Seqinfo(c(1:19, "X", "Y", "MT"), genome = "GRCm39")
old <- set_sex_chr_map(mouse)
getOption("ggwas.sex_chr_map")
#>  X  Y MT 
#> 20 21 22 

# Chicken: Z and W follow the last numbered chromosome
chicken <- GenomeInfoDb::Seqinfo(c(1:39, "Z", "W", "MT"))
set_sex_chr_map(chicken)

# Disable: all chromosomes shown as numbers
set_sex_chr_map(NULL)

# Restore the previous (here the human default) mapping
set_sex_chr_map(old)
```
