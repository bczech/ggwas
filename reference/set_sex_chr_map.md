# Configure sex chromosome mapping

By default, ggwas uses human chromosome conventions where chromosome 23
is labeled "X", 24 is "Y", etc. For non-human organisms or when
chromosomes should be displayed as plain numbers, this mapping can be
customized or disabled.

## Usage

``` r
set_sex_chr_map(map = .default_sex_chr_map)
```

## Arguments

- map:

  A named integer vector mapping labels to integers, e.g.
  `c(X = 23L, Y = 24L)`. Pass `NULL` to disable all sex chromosome
  mapping (chromosomes displayed as plain numbers).

## Value

The previous mapping (invisibly).

## Examples

``` r
# Default: human (23 -> X, 24 -> Y, 25 -> XY, 26 -> MT)
set_sex_chr_map()

# Disable: all chromosomes shown as numbers
set_sex_chr_map(NULL)

# Mouse: 20 -> X, 21 -> Y
set_sex_chr_map(c(X = 20L, Y = 21L))

# Restore default
set_sex_chr_map()
```
